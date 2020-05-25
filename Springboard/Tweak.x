#import <HBLog.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)arg1  {
    HBLogDebug(@"TypingIndicator: SpringBoard Launched");
    CPDistributedMessagingCenter *center = [%c(CPDistributedMessagingCenter) centerNamed:@"com.itaysoft.typingindicator.springboard"];
    rocketbootstrap_distributedmessagingcenter_apply(center);
	[center runServerOnCurrentThread];
    [center registerForMessageName:@"change" target:self selector:@selector(_typingIndicator:userInfo:)];

    %orig;
}

%new
-(void) _typingIndicator:(NSString *)name userInfo:(NSDictionary *)dictionary {
    HBLogDebug(@"TypingIndicator: message received: %@", dictionary);
}

%end

%ctor {
    HBLogDebug(@"TypingIndicator: SpringBoard Injected");
}