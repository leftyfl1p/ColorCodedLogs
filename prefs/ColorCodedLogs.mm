#import <Preferences/Preferences.h>

#define prefPath @"/User/Library/Preferences/org.thebigboss.elite.plist"

@interface PFSimpleLiteColorCell : NSObject
- (void)updateCellDisplay;
@end

@interface ColorCodedLogsListController: PSListController
@end

@implementation ColorCodedLogsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"ColorCodedLogs" target:self] retain];
	}
	return _specifiers;
}

-(id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *exampleTweakSettings = [NSDictionary dictionaryWithContentsOfFile:prefPath];
    if (!exampleTweakSettings[specifier.properties[@"key"]]) {
        return specifier.properties[@"default"];
    }
    return exampleTweakSettings[specifier.properties[@"key"]];
}
 
-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:prefPath]];
    [defaults setObject:value forKey:specifier.properties[@"key"]];
    [defaults writeToFile:prefPath atomically:YES];
    CFStringRef toPost = (CFStringRef)specifier.properties[@"PostNotification"];
    if(toPost) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
}

- (void)loadView {
    [super loadView];
    //[UISwitch appearanceWhenContainedInInstancesOfClasses:self.class].onTintColor = [UIColor colorWithRed:0 green:0.478 blue:1 alpha:1]; /*#007aff*/ //broken ios 10

    // [UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = [UIColor colorWithRed:0 green:0.478 blue:1 alpha:1]; /*#007aff*/ //older
}

//reset libcolorpicker values to defaults and update their cells
- (void)resetColors {
    //delete pref file.
    [[NSFileManager defaultManager] removeItemAtPath:prefPath error:nil];
    //because touching a PSButtonCell isn't considered changing anything so it won't fire in prefs normally.
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("org.thebigboss.elite/settingsChanged"), NULL, NULL, YES);
    //update cell info
    for (PSSpecifier *specifier in [self specifiers]) {
        if ([specifier.target isKindOfClass:[PFSimpleLiteColorCell class]]) {
            [(PFSimpleLiteColorCell *)specifier.target updateCellDisplay];
        }
    }
}
@end

// vim:ft=objc
