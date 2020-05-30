#import <HBLog.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "IBTINotificationManager.h"

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)arg1  {
    %orig;

    HBLogDebug(@"TypingIndicator: SpringBoard Launched");
    CPDistributedMessagingCenter *center = [%c(CPDistributedMessagingCenter) centerNamed:@"com.itaysoft.typingindicator.springboard"];
    rocketbootstrap_distributedmessagingcenter_apply(center);
	[center runServerOnCurrentThread];
    [center registerForMessageName:@"change" target:self selector:@selector(_typingIndicator:userInfo:)];
}

%new
-(void) _typingIndicator:(NSString *)nameSent userInfo:(NSDictionary *)dictionary {
    HBLogDebug(@"TypingIndicator: message received: %@", dictionary);

    [[IBTINotificationManager sharedManager] processUserAction:dictionary];
}

%end

#pragma mark - Constructor

%ctor {
	%init;
	HBLogDebug(@"TypingIndicator: SpringBoard Injected");
}