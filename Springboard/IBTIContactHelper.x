#import "IBTIContactHelper.h"
#import "Headers.h"
#import <HBLog.h>

@implementation IBTIContactHelper

+ (NSString *)nameForHandle:(NSString *)handle useShortName:(BOOL)shortName {
	static IMServiceImpl *service;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		service = [%c(IMServiceImpl) serviceWithName:@"iMessage"];
	});

	IMPerson *person = [service imABPeopleWithScreenName:handle].firstObject;

	if (shortName) {
		IMHandle *imHandle = [%c(IMHandle) imHandlesForIMPerson:person].firstObject;
		NSString *result = imHandle._displayNameWithAbbreviation;

		if (result) {
			return result;
		}
	}

	return person.name ?: handle;
}

@end