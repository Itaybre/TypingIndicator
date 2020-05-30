#import "IBTINotificationManager.h"
#import "IBTIContactHelper.h"
#import "../TypingNotifications.h"

@interface CPNotification : NSObject
+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message userInfo:(NSDictionary*)userInfo badgeCount:(int)badgeCount soundName:(NSString*)soundName delay:(double)delay repeats:(BOOL)repeats bundleId:(nonnull NSString*)bundleId;
+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message userInfo:(NSDictionary*)userInfo badgeCount:(int)badgeCount soundName:(NSString*)soundName delay:(double)delay repeats:(BOOL)repeats bundleId:(nonnull NSString*)bundleId uuid:(nonnull NSString*)uuid silent:(BOOL)silent;
+ (void)hideAlertWithBundleId:(NSString *)bundleId uuid:(NSString*)uuid;
@end

@interface IBTINotificationManager ()
@property (nonatomic, strong) NSMutableDictionary *userMessages;
- (void) timeoutTyping:(NSString *)handle;
- (NSString *) showNotification:(NSString *)message name:(NSString *)name;
- (void) clearPreviousTimeouts:(NSString *)handle;
@end

static NSString *mobileSMS = @"com.apple.MobileSMS";
static NSString *libNotificationsPath = @"/usr/lib/libnotifications.dylib";

@implementation IBTINotificationManager

+ (instancetype) sharedManager {
    static IBTINotificationManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype) init {
    if(self = [super init]) {
        self.userMessages = [NSMutableDictionary new];
    }
    return self;
}

- (void) processUserAction:(NSDictionary *)dictionary {
    BOOL isTyping = [dictionary[@"IsTyping"] boolValue];
    NSString *name = [IBTIContactHelper nameForHandle:dictionary[@"Name"] useShortName:YES];
                                       
    if(isTyping) {
        IBTIMessageType type = [dictionary[@"Type"] integerValue];

        NSString *message = nil;
        switch(type) {
            case IBTIMessageTypeTypingBegan:
                message = [NSString stringWithFormat:@"%@ is typing", name];
                break;
            case IBTIMessageTypeRecordingBegan: 
                message = [NSString stringWithFormat:@"Read by %@", name];
                break;
            case IBTIMessageTypeSendingFile:
                message = [NSString stringWithFormat:@"%@ is sending a file", name];
                break;
            default:
                break;
        }
        
        [self clearPreviousTimeouts:name];

        NSString *uuid = [self showNotification:message name:name];
        self.userMessages[name] = uuid;

        NSInteger delayTime = 10;
        CFPropertyListRef delay = CFPreferencesCopyValue(CFSTR("autoHide"), CFSTR("com.itaysoft.typingindicator"), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
        if(delay) {
            delayTime = [(__bridge NSNumber *)delay integerValue];
            CFRelease(delay);
        }

        [self performSelector:@selector(timeoutTyping:) withObject:name afterDelay:delayTime];
    
    } else {
        HBLogDebug(@"TypingIndicator: should hide");
        
        [self clearPreviousTimeouts:name];
        [self timeoutTyping:name];
    }
}

- (void) clearPreviousTimeouts:(NSString *)handle {
    NSString *uuid = self.userMessages[handle];

    if(uuid) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutTyping:) object:uuid];
    }
}

- (void) timeoutTyping:(NSString *)handle {
    NSString *uuid = self.userMessages[handle];

    if(uuid) {
        void *libNotifications = dlopen([libNotificationsPath UTF8String], RTLD_LAZY);
        if (libNotifications != NULL) {           
            [%c(CPNotification) hideAlertWithBundleId:mobileSMS uuid:uuid];
        }
        dlclose(libNotifications);
    }
    self.userMessages[handle] = nil;
}

- (NSString *) showNotification:(NSString *)message name:(NSString *)name {
    HBLogDebug(@"TypingIndicator: should show");
    NSString *uuid = [[NSUUID UUID] UUIDString];

    void *libNotifications = dlopen([libNotificationsPath UTF8String], RTLD_LAZY);
    if (libNotifications != NULL) {           
        [%c(CPNotification) showAlertWithTitle:name
                                       message:message 
                                      userInfo:@{}
                                    badgeCount:0
                                     soundName:nil
                                         delay:1.00
                                       repeats:NO
                                      bundleId:mobileSMS
                                          uuid:uuid
                                        silent:YES];  
    }
    dlclose(libNotifications);
    return uuid;
}

@end