#import <HBLog.h>
#import "../TypingNotifications.h"
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

@interface IMItem : NSObject
@property (nonatomic,retain) NSString * handle;
@property (nonatomic,readonly) BOOL isFromMe; 
@property (nonatomic, retain) NSDictionary *senderInfo;
@property (nonatomic, retain) NSString *sender;
@end

@interface IMMessageItem : IMItem
@property (nonatomic,retain) NSString * subject;
@property (nonatomic,retain) NSAttributedString * body;
@property (assign,nonatomic) unsigned long long flags;
@property (nonatomic,readonly) BOOL isTypingMessage; 
@property (nonatomic,retain) NSData * typingIndicatorIcon;
@end

@interface FZMessage : IMMessageItem
@end

@interface MessageServiceSession: NSObject 
-(BOOL)didReceiveMessages:(NSArray <FZMessage *> *)messages forChat:(NSString *)arg2 style:(unsigned char)arg3 account:(id)arg4;
-(void) _typingIndicator_postMessage:(IBMessageType) type handle:(NSString *)handle isTyping:(BOOL) typing;
@end

#define IMMessageItemFlagsTypingBegan 0
#define IMMessageItemFlagsTypingEnded 9
#define IMMessageItemFlagsRecordingBegan 2097160
#define IMMessageItemFlagsRecordingEnded 18874369

CPDistributedMessagingCenter *center;

%group iMessage

%hook MessageServiceSession

-(BOOL)didReceiveMessages:(NSArray <FZMessage *> *)messages forChat:(NSString *)arg2 style:(unsigned char)arg3 account:(id)arg4 {
	HBLogDebug(@"TypingIndicator: %@", messages.firstObject);
	HBLogDebug(@"TypingIndicator: isTyping %i", messages.firstObject.isTypingMessage);
	HBLogDebug(@"TypingIndicator: flags %llu", messages.firstObject.flags);
	HBLogDebug(@"TypingIndicator: sender %@", messages.firstObject.sender);
	FZMessage *message = messages.firstObject;
	if(message.isTypingMessage) {
		if(message.flags == IMMessageItemFlagsTypingBegan) {
			[self _typingIndicator_postMessage:IBMessageTypeTypingBegan handle:message.sender isTyping:YES];
		} else if(message.flags == IMMessageItemFlagsRecordingBegan) {
			[self _typingIndicator_postMessage:IBMessageTypeRecordingBegan handle:message.sender isTyping:YES];
		}
	} else {
		[self _typingIndicator_postMessage:IBMessageTypeTypingBegan handle:message.sender isTyping:NO];
	}
    return %orig;
}

%new
- (void) _typingIndicator_postMessage:(IBMessageType) type handle:(NSString *)handle isTyping:(BOOL) typing {
	NSDictionary *userInfo = @{
        @"type": @(type),
		@"handle": handle,
		@"isTyping": @(typing)
    };

    HBLogDebug(@"TypingIndicator: sending %@", userInfo);
    [center sendMessageName:@"change" userInfo:userInfo];
}

%end

%end

static void bundleLoaded(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSBundle* bundle = (__bridge NSBundle*)(object);
	HBLogDebug(@"iCU - Bundle Loaded: %@", bundle.bundleIdentifier);
    if ([bundle.bundleIdentifier isEqualToString:@"com.apple.imservice.imessage"]) {
		%init(iMessage);
	}
}

#pragma mark - Constructor

%ctor {
	%init;
	HBLogDebug(@"TypingIndicator: Imagent Injected");
	CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), 
                                    NULL,
		                            bundleLoaded,
		                            (CFStringRef)NSBundleDidLoadNotification,
		                            NULL, 
                                    CFNotificationSuspensionBehaviorCoalesce);
	center = [CPDistributedMessagingCenter centerNamed:@"com.itaysoft.typingindicator.springboard"];
    rocketbootstrap_distributedmessagingcenter_apply(center);
}