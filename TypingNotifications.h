#define IBMessageTypingStarted CFSTR("com.itaysoft.typingindicator.started")
#define IBMessageTypingEnded CFSTR("com.itaysoft.typingindicator.ended")

typedef NS_ENUM(NSUInteger, IBTIMessageType) {
    IBTIMessageTypeTypingBegan = 0,
    IBTIMessageTypeTypingEnded = 1,
    IBTIMessageTypeRecordingBegan = 2,
    IBTIMessageTypeSendingFile = 3,
    IBTIMessageTypeReadReceipt = 4
};