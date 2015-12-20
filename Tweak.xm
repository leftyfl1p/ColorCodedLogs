#import <UIKit/UIKit.h>
#import <libcolorpicker.h>

#define isiOS8Up (kCFCoreFoundationVersionNumber >= 1129.15)
#define prefPath @"/User/Library/Preferences/org.thebigboss.elite.plist"

@interface CHRecentCall : NSObject
@property unsigned int callStatus;
@end

@interface PHRecentCall : NSObject
-(int)type;
@end

@interface PHRecentsCell : UITableViewCell {
	UILabel* _callerNameLabel;
	CHRecentCall* _call;
}
@end

@interface PHRecentsViewController : UIViewController
-(void)tableView:(UITableView*)arg1 willDisplayCell:(PHRecentsCell*)arg2 forRowAtIndexPath:(NSIndexPath*)arg3;
@end

static NSMutableDictionary *prefs  = nil;
static BOOL kEnabled = YES;
static NSString *kIncomingCallColor = nil;//[UIColor colorWithRed:36.0/255.0 green:87.0/255.0 blue:156.0/255.0 alpha:1];
static NSString *kOutgoingCallColor = nil;//[UIColor colorWithRed:0.0/255.0 green:125.0/255.0 blue:0.0/255.0 alpha:1];
static NSString *kMissedCallColor   = nil;//[UIColor colorWithRed:218.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1];

static void loadPrefs()
{
    prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    kEnabled = prefs[@"enabled"] ? [prefs[@"enabled"] boolValue] : 1;
	kIncomingCallColor = [prefs objectForKey:@"incomingCall"];
	kOutgoingCallColor = [prefs objectForKey:@"outgoingCall"];
	kMissedCallColor   = [prefs objectForKey:@"missedCall"];
}

static void receivedNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	loadPrefs();
}

%group iOS7

%hook PHRecentsViewController
-(void)tableView:(UITableView*)arg1 willDisplayCell:(PHRecentsCell*)arg2 forRowAtIndexPath:(NSIndexPath*)arg3 {
	%orig;

	if(kEnabled) {

		UILabel *nameLabel = MSHookIvar<UILabel *>(arg2, "_callerNameLabel");
		PHRecentCall *callInfo = MSHookIvar<PHRecentCall *>(arg2, "_call");

		if (callInfo.type == 1 || callInfo.type == 4) {
			[nameLabel setTextColor:LCPParseColorString(kIncomingCallColor, @"#24579c")];
		} else 

		if (callInfo.type == 2 || callInfo.type == 16) {
			[nameLabel setTextColor:LCPParseColorString(kOutgoingCallColor, @"#007D00")];
		} else {
			[nameLabel setTextColor:LCPParseColorString(kMissedCallColor, @"#DA0000")];
		}
	}	
}


%end

%end


%group iOS8

%hook PHRecentsViewController
-(void)tableView:(UITableView*)arg1 willDisplayCell:(PHRecentsCell*)arg2 forRowAtIndexPath:(NSIndexPath*)arg3 {
	%orig;
	
	if(kEnabled) {

		UILabel *nameLabel = MSHookIvar<UILabel *>(arg2, "_callerNameLabel");
		CHRecentCall *callInfo = MSHookIvar<CHRecentCall *>(arg2, "_call");
		
		//incoming call : 1
		//answered elsewhere (another device) : 4
		if (callInfo.callStatus == 1 || callInfo.callStatus == 4) {
			[nameLabel setTextColor:LCPParseColorString(kIncomingCallColor, @"#24579c")];
		} else

		//outgoing call : 2
		//outgoing but cancelled : 16
		if (callInfo.callStatus == 2 || callInfo.callStatus == 16) {
			[nameLabel setTextColor:LCPParseColorString(kOutgoingCallColor, @"#007D00")];
		} else {
			[nameLabel setTextColor:LCPParseColorString(kMissedCallColor, @"#DA0000")];
		}
	}
}

%end

%end


%ctor {
	if (isiOS8Up) {
		%init(iOS8);
	} else {
		%init(iOS7);
	}

	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		receivedNotification,
		CFSTR("org.thebigboss.elite/settingsChanged"),
		NULL,
		CFNotificationSuspensionBehaviorCoalesce);

	loadPrefs();
}