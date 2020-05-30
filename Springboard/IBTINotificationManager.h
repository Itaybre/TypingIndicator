#import <Foundation/Foundation.h>

@interface IBTINotificationManager: NSObject
+ (instancetype) sharedManager;
- (void) processUserAction:(NSDictionary *)dictionary;
@end