//
//  MainViewController.m
//  LocationTracker
//
//  Created by Adam Bemowski on 9/17/10.
//  Copyright UC Berkeley 2010. All rights reserved.
//

#import "MainViewController.h"


@implementation MainViewController

@synthesize managedObjectContext;

@synthesize mapView;
@synthesize modeLabel;
@synthesize timeLabel;
@synthesize accuracyLabel;
@synthesize accuracySettingLabel;
@synthesize speedLabel;
@synthesize networkLabel;
@synthesize networkIndicatorView;
@synthesize serverResponse;
@synthesize transmitDataButton;
@synthesize loggedin;
@synthesize infoButton;
@synthesize headingLabel;

#pragma mark View Lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];

    
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
	NSString* dateString = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	[date release];//pl
	
	self.serverResponse.text = [NSString stringWithFormat:@"%@ - No server response yet.",dateString];
	
	[mapView setZoomEnabled:YES];
	[mapView setScrollEnabled:NO];
	MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
	
	if([LTLocationManager sharedLTLocationManager].currentLocation) {
		region.center.latitude = [LTLocationManager sharedLTLocationManager].currentLocation.coordinate.latitude;
		region.center.longitude = [LTLocationManager sharedLTLocationManager].currentLocation.coordinate.longitude;
	}
	
	region.span.longitudeDelta = 0.01;
	region.span.latitudeDelta = 0.1;
	[mapView setRegion:region animated:YES];
	[mapView setShowsUserLocation:YES];
	[mapView setDelegate:self];
    
    if (kInfoButtonIsActive == 0) {
        infoButton.enabled = NO;
        infoButton.hidden = YES;
    }
	
	[[LTLocationManager sharedLTLocationManager] setTheDelegate:self];
	[[DataManager sharedDataManager] setTheDelegate:self];
	
}


// Implement viewWillAppear: to do additional setup before the view is presented. You might, for example, fetch objects from the managed object context if necessary.
- (void)viewWillAppear:(BOOL)animated {
	
	
    [super viewWillAppear:animated];
	
}

- (IBAction)transmitDataButtonPressed {
    // Call the transmitData function again in case there is more data still stored to send
    NSTimer *theTimer;
    [[DataManager sharedDataManager] transmitData:theTimer];
}

#pragma mark Flipside view methods

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)InfoPageDidFinish:(InfoPage *)controller {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)goToInfoPage:(id)sender {    
    InfoPage *controller = [[InfoPage alloc] initWithNibName:@"InfoPage" bundle:nil];
    controller.delegate = self;
    [controller.tableView reloadData];
    
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
}

- (IBAction)showInfo {    
    if(loggedin!=1){
		FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
		controller.delegate = self;
		
		controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:controller animated:NO];
		
		[controller release];
	}
	loggedin=1;
}

- (IBAction)resetHeadingPoints{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%i", 0] forKey:@"headingDataPoints"];
}


#pragma mark LTLocationManagerDelegate methods

- (void)updateToLocation:(CLLocation *)newLocation{
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([[defaults objectForKey:@"view"] isEqualToString:@"login"]) {
		[self showInfo];
	}
	
	MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
	
	region.center.latitude = newLocation.coordinate.latitude;
	region.center.longitude = newLocation.coordinate.longitude;
	
	region.span.longitudeDelta = 0.001;
	region.span.latitudeDelta = 0.001;
	[mapView setRegion:region animated:YES];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];    
	self.timeLabel.text = [dateFormatter stringFromDate:newLocation.timestamp];

    [dateFormatter release];
	self.accuracyLabel.text = [NSString stringWithFormat:@"%f m",newLocation.horizontalAccuracy];
	self.speedLabel.text = [NSString stringWithFormat:@"%f mph",(newLocation.speed*2.237)];
    self.headingLabel.text = [defaults objectForKey:@"headingCount"];
    //self.accuracySettingLabel.text = [NSString stringWithFormat:@"%@", [LTLocationManager sharedLTLocationManager].locationManager.desiredAccuracy];
    if([LTLocationManager sharedLTLocationManager].locationManager.desiredAccuracy==baseAccuracy){
        self.accuracySettingLabel.text = [NSString stringWithFormat:@"Hundred"];
    }
    else if([LTLocationManager sharedLTLocationManager].locationManager.desiredAccuracy == sleepAccuracy){
        self.accuracySettingLabel.text = [NSString stringWithFormat:@"Kilometer"];
    }
    else if([LTLocationManager sharedLTLocationManager].locationManager.desiredAccuracy==bestAccuracy){
        self.accuracySettingLabel.text = [NSString stringWithFormat:@"Navigation"];
    }
    else if([LTLocationManager sharedLTLocationManager].locationManager.desiredAccuracy == kCLLocationAccuracyThreeKilometers){
        self.accuracySettingLabel.text = [NSString stringWithFormat:@"3 Kilometers"];
    }
    //self.accuracySettingLabel.text = [NSString stringWithFormat:@"blahblah"];

}

#pragma mark LocationTrackingResponseLoaderDelegate methods

- (void)gotAResponse:(NSString *)response fromRequest:(NSMutableURLRequest *) request{
	NSLog(@"got a response: %@",response);
	if(![response isEqualToString:@"Success"]){
		MCLog(@"transmission failed");
//		NSString *connectionKey = [NSString stringWithFormat:@"%i",request.hash];
//		NSArray *failedArray = [[DataManager sharedDataManager].pendingRequests objectForKey:connectionKey];
//		MCLog(@"the array of location readings that failed was %i items long",[failedArray count]);
	}
	else{
		MCLog(@"transmission succeeded");
		NSString *connectionKey = [NSString stringWithFormat:@"%i",request.hash];
		NSArray *finishedArray = [[DataManager sharedDataManager].pendingRequests objectForKey:connectionKey];
		MCLog(@"the array of location readings that finished was %i items long",[finishedArray count]);
		
		for(LocationReading *locationReading in finishedArray){
			[[DataManager sharedDataManager].managedObjectContext deleteObject:locationReading];
		}
		[[DataManager sharedDataManager] saveData];
		
		// Call the transmitData function again in case there is more data still stored to send
		NSTimer *theTimer;
		[[DataManager sharedDataManager] transmitData:theTimer];
	}
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
	NSString* dateString = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	[date release];//pl
	
	self.serverResponse.text = [NSString stringWithFormat:@"%@ - %@",dateString,response];
}

#pragma mark DataManager Delegate methods

- (void)setLabelToString:(NSString *)string{
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([[defaults objectForKey:@"view"] isEqualToString:@"login"]) {
		[self showInfo];
	}
	
	self.modeLabel.text = string;
}


#pragma mark Memory management methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


- (void)dealloc {
    [managedObjectContext release];
//	[modePickerView release];
	[mapView release];
	[modeLabel release];
	[timeLabel release];
	[accuracyLabel release];
    [accuracySettingLabel release];
	[speedLabel release];
	[networkLabel release];
	[networkIndicatorView release];
	[serverResponse release];
    [super dealloc];
}


@end

