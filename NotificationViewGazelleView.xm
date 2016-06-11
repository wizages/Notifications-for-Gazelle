//
//  NotificationViewGazelleView.m
//  NotificationView
//
//  Created by wizages on 04/15/2016.
//  Copyright (c) wizages. All rights reserved.
//

#import <Gazelle/Gazelle.h>
#import <BulletinBoard/BBServer.h>
#import "NotificationViewGazelleView.h"
#import <BulletinBoard/BBBulletin.h>

static NSDictionary *preferences;

@interface BBServer (privateNCV)
+(id) NCV_sharedInstance;
@end

@implementation NotificationViewGazelleView

- (UIColor *)presentationBackgroundColor {
	return [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.0];
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
	    
    }

    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	if(![[preferences objectForKey:@"darkView"] boolValue] || [preferences objectForKey:@"darkView"] == nil)
	{
	    _blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
	} else
	{
		_blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	}

	UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:_blurEffect];
	blurView.frame = self.frame;

	if (_notifications)
    {
    	if([_notifications count] == 0)
    	{
    		UIVibrancyEffect *vibrance = [UIVibrancyEffect effectForBlurEffect:_blurEffect];
	    	UIVisualEffectView *vibranceView = [[UIVisualEffectView alloc] initWithEffect:vibrance];
	    	vibranceView.frame = self.frame;
	    	UILabel *noLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,self.frame.size.height/2-30, self.frame.size.width, 60)];
	    	noLabel.text = @"No notifications";
	    	noLabel.font = [noLabel.font fontWithSize:30];
	    	noLabel.textAlignment = NSTextAlignmentCenter;
	    	[vibranceView.contentView addSubview:noLabel];
	    	[blurView.contentView addSubview:vibranceView];
	    	[self addSubview:blurView];
    	}
    	else
    	{
    		[self addSubview:blurView];
    		UITableView *notificationTableView = [[UITableView alloc] initWithFrame:self.frame];
    		notificationTableView.delegate = self;
    		notificationTableView.dataSource = self;
    		notificationTableView.backgroundColor = [UIColor clearColor];
    		[self addSubview:notificationTableView];
    	}
	}
	
}

- (void)handleActionForIconTap  {
	/**
	* Decide what happens when the user taps on the icon view
	* Perhaps remove the presented view?
	*/
	[Gazelle tearDownAnimated:YES];

	/**
	* Or perhaps open the application?
	*/
	[Gazelle openApplicationForBundleIdentifier:_bundleID];
}

- (void)setActivatedApplicationIdentifier:(NSString *)identifier {
	/*
	* This will be set during presentation, it will allow you to determine what app was swiped up on
	* incase user set your view for an app you didn't intend
	*/
	//_swipedIdentifier = identifier;
	_bundleID = identifier;
	HBLogDebug(@"	")
	_notifications = [[[[%c(BBServer) NCV_sharedInstance] _allBulletinsForSectionID:identifier] allObjects] copy];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_notifications count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotificationCell"];
	BBBulletin *test = _notifications[indexPath.row];
	tableCell.textLabel.text = test.message;
	tableCell.backgroundColor = [UIColor clearColor];
	return tableCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BBBulletin *test = _notifications[indexPath.row];
    BBAction *action = test.defaultAction;
    if(action == nil || !action)
        return;
    [Gazelle tearDownAnimated:YES];
    [test actionBlockForAction:action withOrigin:4 context:nil](nil);
}

@end

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[preferences release];
	CFStringRef appID = CFSTR("com.wizages.weather");
	CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!keyList) {
		HBLogDebug(@"There's been an error getting the key list!");
		return;
	}
	preferences = (NSDictionary *)CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!preferences) {
		HBLogDebug(@"There's been an error getting the preferences dictionary!");
	}
	CFRelease(keyList);
}

%ctor{
	PreferencesChangedCallback(NULL,NULL,NULL,NULL,NULL);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)PreferencesChangedCallback, CFSTR("com.wizages.weather.settings"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}