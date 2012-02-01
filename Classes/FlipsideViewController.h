//
//  FlipsideViewController.h
//  LocationTracker
//
//  Created by Adam Bemowski on 9/17/10.
//  Copyright UC Berkeley 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationTrackingResponseLoader.h"


@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController <LocationTrackingResponseLoaderDelegate>{
	id <FlipsideViewControllerDelegate> delegate;
	UITextField *UsernameField;
	UITextField *PasswordField;
	UITextField *ConfirmPassField;
	UIButton *LoginButton;
	UIButton *CreateAccountButton;
	UILabel *topLael;
	UILabel *ConfirmPassLael;
	UILabel *createConfirmLabel;
    UILabel *versionNumber;
	LocationTrackingResponseLoader *responseLoader;
	
}


@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
- (IBAction)done:(id)sender;
- (IBAction)createAccount:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)SendLifeCycle;
- (void)gotAResponse:(NSString *)response fromRequest:(NSMutableURLRequest *) request;

@property (nonatomic, retain) IBOutlet UITextField *UsernameField;
@property (nonatomic, retain) IBOutlet UITextField *PasswordField;
@property (nonatomic, retain) IBOutlet UITextField *ConfirmPassField;
@property (nonatomic, retain) IBOutlet UIButton *LoginButton;
@property (nonatomic, retain) IBOutlet UIButton *CreateAccountButton;
@property (nonatomic, retain) IBOutlet UILabel *topLael;
@property (nonatomic, retain) IBOutlet UILabel *ConfirmPassLael;
@property (nonatomic, retain) IBOutlet UILabel *createConfirmLabel;
@property (nonatomic, retain) IBOutlet UILabel *versionNumber;
@property (nonatomic, retain) LocationTrackingResponseLoader *responseLoader;
-(NSString *)md5:(NSString *)str;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;

@end

