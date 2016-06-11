//
//  NotificationViewGazelleView.h
//  NotificationView
//
//  Created by wizages on 04/15/2016.
//  Copyright (c) wizages. All rights reserved.
//

@interface NotificationViewGazelleView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSArray *notifications;

@property (nonatomic, retain) NSString *bundleID;

@property (nonatomic, retain) UIBlurEffect *blurEffect;
/**
* If you need to change the background color of the block view
* this is where you would change it
*/
- (UIColor *)presentationBackgroundColor;

/**
* This is called after a user taps on the presented views icon image
* You don't need to do anything except tell it what to do
*/
- (void)handleActionForIconTap;
@end
