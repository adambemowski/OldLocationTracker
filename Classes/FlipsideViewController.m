//
//  FlipsideViewController.m
//  LocationTracker
//
//  Created by Adam Bemowski on 9/17/10.
//  Copyright UC Berkeley 2010. All rights reserved.
//

#import "FlipsideViewController.h"
#import "LocationTrackerAppDelegate.h"


@implementation FlipsideViewController

@synthesize delegate;
@synthesize UsernameField;
@synthesize PasswordField;
@synthesize LoginButton;
@synthesize ConfirmPassField;
@synthesize CreateAccountButton;
@synthesize topLael;
@synthesize ConfirmPassLael;
@synthesize createConfirmLabel;




- (void)viewDidLoad {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	UsernameField.text = [defaults objectForKey:@"username"];
    PasswordField.text = [defaults objectForKey:@"password"];
	topLael.hidden = YES;
	ConfirmPassField.hidden = YES;
	ConfirmPassLael.hidden = YES;
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];      
}


- (IBAction)done:(id)sender {
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:@"main" forKey:@"view"];
	
	NSString *responseString = [[NSString alloc] init];
    NSString *UDID = [[UIDevice currentDevice] uniqueIdentifier];
    NSString *MD5Key = [self md5:[NSString stringWithFormat:@"%@%@",kKey,UsernameField.text]];
	NSMutableString *transmissionString = [NSMutableString stringWithFormat:@"username=%@&password=%@&identifier=%@&platform=1&key=%@", UsernameField.text, PasswordField.text,UDID,MD5Key];
    //    NSLog(@"%@",transmissionString);
	//[transmissionString appendFormat:];
	NSData *postData = [transmissionString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];  
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
    [request setURL:[NSURL URLWithString:@"http://data.modechoice.org/api/auth/?format=xml"]];  
	//[request setURL:[NSURL URLWithString:@"http://berkeleytelematics.com/api/auth/?format=xml"]];  
	[request setHTTPMethod:@"POST"];  
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
	[request setHTTPBody:postData]; 
	NSLog(@"%@",transmissionString);
	responseLoader = [[LocationTrackingResponseLoader alloc] init];
	[responseLoader setTheDelegate:self];
	[responseLoader setTheDelegate:((LocationTrackerAppDelegate *)[UIApplication sharedApplication].delegate).flipsideViewController];
	responseString = [responseLoader getLocationTransmissionResponse:request];
	NSLog(@"%@",responseString);
	if ([[defaults objectForKey:@"code"] isEqualToString:@"1"]) {
        
        [self SendLifeCycle];
        
		[defaults setObject:UsernameField.text forKey:@"username"];
        [defaults setObject:PasswordField.text forKey:@"password"];
		[self.delegate flipsideViewControllerDidFinish:self];
	}
    else if ([[defaults objectForKey:@"code"] isEqualToString:@"2"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Unsuccessful" message:[defaults objectForKey:@"message"] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles: @"No", nil];
		[alert show];
		[alert release];
        
    }
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Unsuccessful" message:[defaults objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
}


- (void)SendLifeCycle{
    time_t unixTime = [[NSUserDefaults standardUserDefaults] floatForKey:@"lastAlive"];
    time_t currentTime = (time_t) [[NSDate date] timeIntervalSince1970];
    NSLog(@"Last Alive = %ld", unixTime);
    
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:@"main" forKey:@"view"];
	
	NSString *responseString = [[NSString alloc] init];
    NSString *UDID = [[UIDevice currentDevice] uniqueIdentifier];
    NSString *MD5Key = [self md5:[NSString stringWithFormat:@"%@%@",kKey,UsernameField.text]];
    NSMutableString *transmissionString;
    if(unixTime==0){
        transmissionString = [NSMutableString stringWithFormat:@"username=%@&identifier=%@&platform=1&key=%@&event_data=1,%ld", UsernameField.text,UDID,MD5Key,currentTime];
    }
    else{
        transmissionString = [NSMutableString stringWithFormat:@"username=%@&identifier=%@&platform=1&key=%@&event_data=0,%ld\n1,%ld", UsernameField.text,UDID,MD5Key,unixTime,currentTime];        
    }
	NSData *postData = [transmissionString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];  
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
    [request setURL:[NSURL URLWithString:@"http://data.modechoice.org/api/auth/?format=xml"]];  
	//[request setURL:[NSURL URLWithString:@"http://berkeleytelematics.com/api/lifecycle/?format=xml"]];  
	[request setHTTPMethod:@"POST"];  
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
	[request setHTTPBody:postData]; 
	NSLog(@"%@",transmissionString);
	responseLoader = [[LocationTrackingResponseLoader alloc] init];
	[responseLoader setTheDelegate:self];
	[responseLoader setTheDelegate:((LocationTrackerAppDelegate *)[UIApplication sharedApplication].delegate).flipsideViewController];
	responseString = [responseLoader getLocationTransmissionResponse:request];
	NSLog(@"%@",responseString);
    
    
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 0)
    {
        NSLog(@"ok");
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"main" forKey:@"view"];
        
        NSString *responseString = [[NSString alloc] init];
        
        NSString *UDID = [[UIDevice currentDevice] uniqueIdentifier];
        NSString *MD5Key = [self md5:[NSString stringWithFormat:@"%@%@",kKey,UsernameField.text]];
        NSMutableString *transmissionString = [NSMutableString stringWithFormat:@"username=%@&password=%@&identifier=%@&platform=1&key=%@&change_phone=1", UsernameField.text, PasswordField.text,UDID,MD5Key];
        //    NSLog(@"%@",transmissionString);
        //[transmissionString appendFormat:];
        NSData *postData = [transmissionString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];  
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
        
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
        [request setURL:[NSURL URLWithString:@"http://data.modechoice.org/api/auth/?format=xml"]];  
        //[request setURL:[NSURL URLWithString:@"http://berkeleytelematics.com/api/auth/?format=xml"]];  
        [request setHTTPMethod:@"POST"];  
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
        [request setHTTPBody:postData]; 
        responseLoader = [[LocationTrackingResponseLoader alloc] init];
        [responseLoader setTheDelegate:self];
        [responseLoader setTheDelegate:((LocationTrackerAppDelegate *)[UIApplication sharedApplication].delegate).flipsideViewController];
        responseString = [responseLoader getLocationTransmissionResponse:request];
        
        if ([[defaults objectForKey:@"code"] isEqualToString:@"1"]) {
            [defaults setObject:UsernameField.text forKey:@"username"];
            [defaults setObject:PasswordField.text forKey:@"password"];
            [self.delegate flipsideViewControllerDidFinish:self];
        }
        else if ([[defaults objectForKey:@"code"] isEqualToString:@"2"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Unsuccessful" message:[defaults objectForKey:@"message"] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles: @"No", nil];
            [alert show];
            [alert release];
            
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Unsuccessful" message:[defaults objectForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        
        
    }
}

- (NSString *)md5:(NSString *)str{
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [[NSString stringWithFormat:
			 @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			 result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			 result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			 ] lowercaseString];
}

- (IBAction)createAccount:(id)sender{
	LoginButton.hidden = YES;
	topLael.hidden = NO;
	ConfirmPassField.hidden = NO;
	ConfirmPassLael.hidden = NO;
	createConfirmLabel.text = @"Create your account!";
	[CreateAccountButton setTitle:@"Confirm and Log in" forState:UIControlStateNormal];
	
}

- (IBAction)textFieldDoneEditing:(id)sender {
	[sender resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


- (void)dealloc {
	[UsernameField release];
	[PasswordField release];
	[LoginButton release];
    [super dealloc];
}


@end
