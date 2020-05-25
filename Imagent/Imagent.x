#import <HBLog.h>
#import "../TypingNotifications.h"
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "Headers.h"

#define IMMessageItemFlagsTypingBegan 0
#define IMMessageItemFlagsTypingEnded 9
#define IMMessageItemFlagsRecordingBegan 2097160
#define IMMessageItemFlagsRecordingEnded 18874369

void IBTIPostMessage(IBTIMessageType type, NSString *handle, BOOL isTyping) {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSDictionary *userInfo = @{
        	@"type": @(type),
			@"handle": handle,
			@"isTyping": @(isTyping)
    	};

    	HBLogDebug(@"TypingIndicator: sending %@", userInfo);
		CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.itaysoft.typingindicator.springboard"];
    	rocketbootstrap_distributedmessagingcenter_apply(center);
    	[center sendMessageName:@"change" userInfo:userInfo];
	});
}

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
			IBTIPostMessage(IBTIMessageTypeTypingBegan,message.sender,YES);
		} else if(message.flags == IMMessageItemFlagsRecordingBegan) {
			IBTIPostMessage(IBTIMessageTypeRecordingBegan,message.sender,YES);
		}
	} else {
		IBTIPostMessage(IBTIMessageTypeTypingEnded,message.sender,NO);
	}
    return %orig;
}

%end

%hook IMDFileTransferCenter

- (void)_addActiveTransfer:(NSString *)transferGUID {
	HBLogDebug(@"TypingIndicator: _addActiveTransfer");
	%orig;

	IMFileTransfer *transfer = [self transferForGUID:transferGUID];
	IBTIPostMessage(IBTIMessageTypeSendingFile,transfer.otherPerson,YES);
}

- (void)updateTransfer:(NSString *)transferGUID currentBytes:(size_t)currentBytes totalBytes:(size_t)totalBytes {
    HBLogDebug(@"TypingIndicator: updateTransfer");

	%orig;

	if (currentBytes >= totalBytes) {
		IMFileTransfer *transfer = [self transferForGUID:transferGUID];
		IBTIPostMessage(IBTIMessageTypeTypingEnded,transfer.otherPerson,NO);
	}
}

%end

%hook IMDServiceSession

- (void)didReceiveMessageReadReceiptForMessageID:(NSString *)messageID date:(NSDate *)date completionBlock:(id)completion {
	HBLogDebug(@"TypingIndicator: didReceiveMessageReadReceiptForMessageID");
	
	%orig;

	FZMessage *message = [[%c(IMDMessageStore) sharedInstance] messageWithGUID:messageID];
	IBTIPostMessage(IBTIMessageTypeReadReceipt, message.handle, NO);
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
}