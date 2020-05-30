@interface CKDNDList: NSObject
+(id)sharedList;
-(NSDate *)unmuteDateForIdentifier:(id)arg1;
@end

@interface IMServiceImpl: NSObject
+(id)serviceWithName:(id)arg1 ;
-(NSArray *)imABPeopleWithScreenName:(id)arg1;
-(id)infoForAllScreenNames;
@end

@interface IMHandle: NSObject
+(NSArray *)imHandlesForIMPerson:(id)arg1 ;
@property (nonatomic,retain,readonly) NSString * _displayNameWithAbbreviation; 
@end

@interface IMPerson: NSObject
@property (nonatomic,readonly) int _recordID;
@property (nonatomic,readonly) BOOL _registered;
@property (nonatomic,readonly) void* _recordRef; 
@property (nonatomic,readonly) NSString * uniqueID; 
@property (nonatomic,readonly) int recordID; 
@property (nonatomic,copy,readonly) NSString * cnContactID; 
@property (nonatomic,readonly) BOOL isInAddressBook; 
@property (nonatomic,readonly) NSArray * groups; 
@property (nonatomic,readonly) NSString * name; 
@property (nonatomic,readonly) NSString * fullName; 
@property (nonatomic,readonly) NSString * displayName; 
@property (nonatomic,readonly) NSString * abbreviatedName; 
@property (nonatomic,copy) NSString * nickname; 
@property (nonatomic,copy) NSString * firstName; 
@property (nonatomic,copy) NSString * lastName; 
@property (nonatomic,readonly) BOOL isCompany; 
@property (nonatomic,readonly) NSString * companyName; 
@property (nonatomic,copy) NSArray * emails; 
@property (nonatomic,readonly) NSArray * allEmails; 
@property (nonatomic,retain) NSArray * phoneNumbers; 
@property (nonatomic,readonly) NSArray * mobileNumbers; 
@property (nonatomic,retain) NSData * imageData; 
@property (nonatomic,readonly) NSData * imageDataWithoutLoading; 
@property (nonatomic,readonly) unsigned long long status; 
@end