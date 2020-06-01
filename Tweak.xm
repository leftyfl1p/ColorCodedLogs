#import <UIKit/UIKit.h>
#import <libcolorpicker.h>
#import <version.h>

#define isiOS7 (kCFCoreFoundationVersionNumber > 793.00 && kCFCoreFoundationVersionNumber < 1129.15)
#define isiOS89 (kCFCoreFoundationVersionNumber >= 1129.15 && kCFCoreFoundationVersionNumber < 1333.2)

#ifndef kCFCoreFoundationVersionNumber_iOS_10_3_3
#define kCFCoreFoundationVersionNumber_iOS_10_3_3 1349.7
#endif

#define IS_IOS_10 IS_IOS_BETWEEN(iOS_10_0, iOS_10_3_3)

#ifndef kCFCoreFoundationVersionNumber_iOS_12_4
#define kCFCoreFoundationVersionNumber_iOS_12_4 1575.17
#endif

#define IS_IOS_11_OR_12 IS_IOS_BETWEEN(iOS_11_0, iOS_12_4)

#ifndef kCFCoreFoundationVersionNumber_iOS_13_0
#define kCFCoreFoundationVersionNumber_iOS_13_0 1665.15
#endif

#define prefPath @"/User/Library/Preferences/org.thebigboss.elite.plist"

#define defaultIncomingColor @"#24579c"
#define defaultOutgoingColor @"#007D00"
#define defaultMissedColor @"#DA0000"

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

// iOS 10
@interface MPRecentsTableViewCell : UITableViewCell
-(UILabel *)callerNameLabel;
-(UILabel *)callerCountLabel;
-(CHRecentCall *)call;
@end
// end iOS 10

// iOS 11
@interface MPRecentsTableViewController
-(CHRecentCall *)recentCallAtTableViewIndex:(NSInteger)index;
@end
// end iOS 11

// iOS 13
@interface NUIContainerStackView
-(NSArray<UILabel *> *)arrangedSubviews;
@end

@interface MPRecentsTableViewCell (iOS13)
@property (nonatomic,retain) NUIContainerStackView * titleStackView; 
@end

// end iOS 13

static NSMutableDictionary *prefs   = nil;
static BOOL kEnabled = YES;
static NSString *kIncomingCallColor = nil; // [UIColor colorWithRed:36.0/255.0 green:87.0/255.0 blue:156.0/255.0 alpha:1];
static NSString *kOutgoingCallColor = nil; // [UIColor colorWithRed:0.0/255.0 green:125.0/255.0 blue:0.0/255.0 alpha:1];
static NSString *kMissedCallColor   = nil; // [UIColor colorWithRed:218.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1];

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
			[nameLabel setTextColor:LCPParseColorString(kIncomingCallColor, defaultIncomingColor)];
		} else 

		if (callInfo.type == 2 || callInfo.type == 16) {
			[nameLabel setTextColor:LCPParseColorString(kOutgoingCallColor, defaultOutgoingColor)];
		} else {
			[nameLabel setTextColor:LCPParseColorString(kMissedCallColor, @"#DA0000")];
		}
	}	
}


%end

%end


%group iOS89

%hook PHRecentsViewController
-(void)tableView:(UITableView*)arg1 willDisplayCell:(PHRecentsCell*)arg2 forRowAtIndexPath:(NSIndexPath*)arg3 {
	%orig;
	
	if(kEnabled) {

		UILabel *nameLabel = MSHookIvar<UILabel *>(arg2, "_callerNameLabel");
		CHRecentCall *callInfo = MSHookIvar<CHRecentCall *>(arg2, "_call");

		//incoming call : 1
		//answered elsewhere (another device) : 4
		if (callInfo.callStatus == 1 || callInfo.callStatus == 4) {
			[nameLabel setTextColor:LCPParseColorString(kIncomingCallColor, defaultIncomingColor)];
		} else

		//outgoing call : 2
		//outgoing but cancelled : 16
		if (callInfo.callStatus == 2 || callInfo.callStatus == 16) {
			[nameLabel setTextColor:LCPParseColorString(kOutgoingCallColor, defaultOutgoingColor)];
		} else {
			[nameLabel setTextColor:LCPParseColorString(kMissedCallColor, defaultMissedColor)];
		}
	}
}

%end

%end

%group iOS10

%hook MPRecentsTableViewController

-(id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
	MPRecentsTableViewCell *orig = %orig;
	
	if(kEnabled) {

		UILabel *nameLabel = [orig callerNameLabel];
		CHRecentCall *callInfo = [orig call];

		//incoming call : 1
		//answered elsewhere (another device) : 4
		if (callInfo.callStatus == 1 || callInfo.callStatus == 4) {
			[nameLabel setTextColor:LCPParseColorString(kIncomingCallColor, defaultIncomingColor)];
		} else

		//outgoing call : 2
		//outgoing but cancelled : 16
		if (callInfo.callStatus == 2 || callInfo.callStatus == 16) {
			[nameLabel setTextColor:LCPParseColorString(kOutgoingCallColor, defaultOutgoingColor)];
		} else {
			[nameLabel setTextColor:LCPParseColorString(kMissedCallColor, defaultMissedColor)];
		}
	}

	return orig;
}

%end

%end //iOS 10

%group iOS11OR12

%hook MPRecentsTableViewController

-(id)tableView:(id)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	MPRecentsTableViewCell *orig = %orig;

	if(kEnabled) {

		UILabel *nameLabel = [orig callerNameLabel];
		CHRecentCall *callInfo = [self recentCallAtTableViewIndex:arg2.row];

		//incoming call : 1
		//answered elsewhere (another device) : 4
		if (callInfo.callStatus == 1 || callInfo.callStatus == 4) {
			[nameLabel setTextColor:LCPParseColorString(kIncomingCallColor, defaultIncomingColor)];
		} else

		//outgoing call : 2
		//outgoing but cancelled : 16
		if (callInfo.callStatus == 2 || callInfo.callStatus == 16) {
			[nameLabel setTextColor:LCPParseColorString(kOutgoingCallColor, defaultOutgoingColor)];
		} else {
			[nameLabel setTextColor:LCPParseColorString(kMissedCallColor, defaultMissedColor)];
		}
	}

	return orig;
}

%end

%end //iOS 11

%group iOS13

%hook MPRecentsTableViewController

-(id)tableView:(id)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2 {
	MPRecentsTableViewCell *orig = %orig;

	if(kEnabled) {

		UILabel *nameLabel = orig.titleStackView.arrangedSubviews[0];
		CHRecentCall *callInfo = [self recentCallAtTableViewIndex:arg2.row];

		//incoming call : 1
		//answered elsewhere (another device) : 4
		if (callInfo.callStatus == 1 || callInfo.callStatus == 4) {
			[nameLabel setTextColor:LCPParseColorString(kIncomingCallColor, defaultIncomingColor)];
		} else

		//outgoing call : 2
		//outgoing but cancelled : 16
		if (callInfo.callStatus == 2 || callInfo.callStatus == 16) {
			[nameLabel setTextColor:LCPParseColorString(kOutgoingCallColor, defaultOutgoingColor)];
		} else {
			[nameLabel setTextColor:LCPParseColorString(kMissedCallColor, defaultMissedColor)];
		}
	}

	return orig;
}

%end

%end //iOS 13


%ctor {
	if(isiOS7) %init(iOS7);
	if(isiOS89) %init(iOS89);
	if(IS_IOS_10) %init(iOS10);
	if(IS_IOS_11_OR_12) %init(iOS11OR12);
	if(IS_IOS_OR_NEWER(iOS_13_0)) %init(iOS13);

	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		receivedNotification,
		CFSTR("org.thebigboss.elite/settingsChanged"),
		NULL,
		CFNotificationSuspensionBehaviorCoalesce);

	loadPrefs();
}