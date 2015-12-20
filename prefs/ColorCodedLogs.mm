#import <Preferences/Preferences.h>

#define exampleTweakPreferencePath @"/User/Library/Preferences/org.thebigboss.elite.plist"

@interface ColorCodedLogsListController: PSListController {
}
@end

@implementation ColorCodedLogsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"ColorCodedLogs" target:self] retain];
	}
	return _specifiers;
}

-(id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *exampleTweakSettings = [NSDictionary dictionaryWithContentsOfFile:exampleTweakPreferencePath];
    if (!exampleTweakSettings[specifier.properties[@"key"]]) {
        return specifier.properties[@"default"];
    }
    return exampleTweakSettings[specifier.properties[@"key"]];
}
 
-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:exampleTweakPreferencePath]];
    [defaults setObject:value forKey:specifier.properties[@"key"]];
    [defaults writeToFile:exampleTweakPreferencePath atomically:YES];
    //NSDictionary *exampleTweakSettings = [NSDictionary dictionaryWithContentsOfFile:exampleTweakPreferencePath];
    CFStringRef toPost = (CFStringRef)specifier.properties[@"PostNotification"];
    if(toPost) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
}

@end

// vim:ft=objc
