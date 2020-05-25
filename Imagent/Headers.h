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
@end

@interface IMFileTransfer: NSObject
@property(retain, nonatomic) NSString *otherPerson; 
@property (nonatomic, retain) NSString *messageGUID;
@end

@interface IMDFileTransferCenter : NSObject
- (IMFileTransfer *)transferForGUID:(NSString *)guid;
@end

@interface IMDMessageStore: NSObject
+(id)sharedInstance;
-(FZMessage *)messageWithGUID:(id)arg1;
@end