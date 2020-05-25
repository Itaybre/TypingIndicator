#define IBMessageTypingStarted CFSTR("com.itaysoft.typingindicator.started")
#define IBMessageTypingEnded CFSTR("com.itaysoft.typingindicator.ended")

typedef NS_ENUM(NSUInteger, IBMessageType) {
    IBMessageTypeTypingBegan = 0,
    IBMessageTypeTypingEnded = 1,
    IBMessageTypeRecordingBegan = 2
};