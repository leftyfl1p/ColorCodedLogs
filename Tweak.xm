#import <UIKit/UIKit.h>

@interface CHRecentCall : NSObject
@property unsigned int callStatus;
@end

@interface PHRecentsCell : UITableViewCell {
	UILabel* _callerNameLabel;
	CHRecentCall* _call;
}
-(void)setEditing:(BOOL)arg1 animated:(BOOL)arg2;
@end

%hook PHRecentsCell

//yea probably not the best place to do this
-(void)setEditing:(BOOL)arg1 animated:(BOOL)arg2 {

	UILabel *nameLabel = MSHookIvar<UILabel *>(self, "_callerNameLabel");
	CHRecentCall *callInfo = MSHookIvar<CHRecentCall *>(self, "_call");

	//incoming call : 1
	//answered elsewhere (another device) : 4
	if (callInfo.callStatus == 1 || callInfo.callStatus == 4) {
		nameLabel.textColor = [UIColor colorWithRed:36.0/255.0 green:87.0/255.0 blue:156.0/255.0 alpha:1];
	} else

	//outgoing call : 2
	//cancelled (??) : 16
	if (callInfo.callStatus == 2 || callInfo.callStatus == 16) {
		nameLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:125.0/255.0 blue:0.0/255.0 alpha:1];
	} else {
		nameLabel.textColor = [UIColor colorWithRed:218.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1];
	}

	%orig;
}
%end