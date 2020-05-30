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
        	@"Type": @(type),
			@"Name": handle,
			@"IsTyping": @(isTyping)
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
	
	FZMessage *message = messages.firstObject;
	if(message.isTypingMessage) {
		// THe message is typing status update

		if(message.flags == IMMessageItemFlagsTypingBegan) {
			// Someone started typing

			IBTIPostMessage(IBTIMessageTypeTypingBegan,message.sender,YES);
		} else if(message.flags == IMMessageItemFlagsRecordingBegan) {
			// Someone is recording a message

			IBTIPostMessage(IBTIMessageTypeRecordingBegan,message.sender,YES);
		} else {
			// Clear status

			IBTIPostMessage(IBTIMessageTypeTypingEnded,message.sender,NO);	
		}
	} else {
		// Regular message

		IBTIPostMessage(IBTIMessageTypeTypingEnded,message.sender,NO);
	}
    return %orig;
}

%end

%hook IMDFileTransferCenter

- (void)_addActiveTransfer:(NSString *)transferGUID {
	HBLogDebug(@"TypingIndicator: New file transfer");
	%orig;

	IMFileTransfer *transfer = [self transferForGUID:transferGUID];
	if(transfer.otherPerson) {
		IBTIPostMessage(IBTIMessageTypeSendingFile,transfer.otherPerson,YES);
	}
}

- (void)updateTransfer:(NSString *)transferGUID currentBytes:(size_t)currentBytes totalBytes:(size_t)totalBytes {
    HBLogDebug(@"TypingIndicator: Transfer updated");

	%orig;

	if (currentBytes >= totalBytes) {
		IMFileTransfer *transfer = [self transferForGUID:transferGUID];

		if(transfer.otherPerson) {
			IBTIPostMessage(IBTIMessageTypeTypingEnded,transfer.otherPerson,NO);
		}
	}
}

%end

%hook IMDServiceSession

- (void)didReceiveMessageReadReceiptForMessageID:(NSString *)messageID date:(NSDate *)date completionBlock:(id)completion {
	HBLogDebug(@"TypingIndicator: Read Receipt Received");
	
	%orig;

	FZMessage *message = [[%c(IMDMessageStore) sharedInstance] messageWithGUID:messageID];
	IBTIPostMessage(IBTIMessageTypeReadReceipt, message.handle, NO);
}

%end

%end

static void bundleLoaded(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSBundle* bundle = (__bridge NSBundle*)(object);
	HBLogDebug(@"TypingIndicator: Bundle Loaded: %@", bundle.bundleIdentifier);
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