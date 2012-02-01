//
//  LocationTrackerAppDelegate.m
//  LocationTracker
//
//  Created by Adam Bemowski on 9/17/10.
//  Copyright UC Berkeley 2010. All rights reserved.
//

#import "LocationTrackerAppDelegate.h"
#import "MainViewController.h"

@implementation LocationTrackerAppDelegate

@synthesize token;
@synthesize window;
@synthesize mainViewController;
@synthesize flipsideViewController;
@synthesize locationManager;
@synthesize CLLManager;
@synthesize improveAccuracyCounter;
@synthesize managedObjectContext, managedObjectModel, persistentStoreCoordinator;

#pragma mark -
#pragma mark Application lifecycle

- (void)awakeFromNib {    
	
	
}

- (void)improveAccuracy{
    
//    self.locationManager.firstTimeInKilometerAccuracy = true;
//    self.locationManager.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    if ([[defaults objectForKey:@"state"] isEqualToString:@"stationary"]) {
//        NSLog(@"improvingAccuracy in stationary");
//        if (improveAccuracyCounter >= 4) {
//            self.locationManager.firstTimeInKilometerAccuracy = true;
//            self.locationManager.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
//            [self performSelector:@selector(endImprovedAccuracy) withObject:nil afterDelay:1];
//            improveAccuracyCounter = 0;
//        }
//        else {
//            improveAccuracyCounter++;
//        }
//    }
//    if ([[defaults objectForKey:@"state"] isEqualToString:@"traveling"]) {
//        NSLog(@"improvingAccuracy in traveling");
//        improveAccuracyCounter = 0;
//        self.locationManager.firstTimeInKilometerAccuracy = true;
//        if (self.locationManager.firstTimeInHundredMeterAccuracy) {
//            self.locationManager.firstTimeInHundredMeterAccuracy = false;
//            self.locationManager.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//        }
//        else {
//            self.locationManager.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
//        }
//        [self performSelector:@selector(endImprovedAccuracy) withObject:nil afterDelay:10];
//    }
//    
//    
    
}

- (void)endImprovedAccuracy{
//    NSLog(@"ending improved accuracy");

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions { 
	
	application.idleTimerDisabled = YES;
	// Turn on GPS
	self.locationManager = [LTLocationManager sharedLTLocationManager];
	[DataManager sharedDataManager].managedObjectContext = self.managedObjectContext;
	[DataManager sharedDataManager].currentMode = @"3"; // This is what the spinner starts on
    self.locationManager.firstTimeInNavigationAccuracy = true;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:@"login" forKey:@"view"];
    [defaults setObject:@"traveling" forKey:@"state"]; // initial state is not moving
	
	// Configure and show the window
	[window addSubview:mainViewController.view];
	[window makeKeyAndVisible];
	
	//transmissionTimer = [NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(improveAccuracy:) userInfo:nil repeats:YES];
	
	// Start saving location points every kMeasurementIntervalSeconds
	//	[self.locationManager initiateLocationRecordingAtFrequency:kMeasurementIntervalSeconds];
	
	// Start transmitting updates every kTransmissionIntervalSeconds
	if(kLocationTransmissionOnOff != 0){
		[[DataManager sharedDataManager] initiateLocationTransmissionAtFrequency:kTransmissionIntervalSeconds];
		//[[LTLocationManager sharedLTLocationManager] toggleAccuracy:10];
		NSTimer *transmissionTimer;	
		transmissionTimer = [NSTimer scheduledTimerWithTimeInterval:kImproveAccuracySeconds target:self selector:@selector(improveAccuracy) userInfo:nil repeats:YES];
		
	}
	//NSLog(@"MyTokenFirst");	
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
	//NSLog(@"MyTokenSecibd");	
    	
    improveAccuracyCounter = 0;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
	[defaults setObject:date forKey:@"birthDate"];
    [defaults setObject:@"0" forKey:@"currentDataPoints"];
    [date release];
    [dateFormatter release];
    
    UIAlertView *wifiAlert = [[UIAlertView alloc] initWithTitle:@"For Better Battery Life" message:@"Please have wifi turned ON when using this app" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
	[wifiAlert show];
    
    return YES;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	
	NSLog(@"Running Did Register");	
	//	NSLog(@"%@", devToken); 
	NSString *deviceToken = [NSString stringWithFormat:@"%@",devToken];
	/*clean token up*/
	deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
	deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
	deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSLog(@"%@", deviceToken); 
	self.token = [NSString stringWithFormat:@"%@",deviceToken];
	[self  performSelectorInBackground:@selector(registerOnServer) withObject:nil];
}

-(void)registerOnServer{
	/*
	 NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://ibreathea.blinktag.com/regToken.php?token=%@",self.token];
	 //wirte settings specific to user
	 NSURL *url = [[NSURL alloc] initWithString:urlString];
	 NSMutableString *checkString = [[NSString alloc] initWithContentsOfURL:url];
	 [checkString release];
	 //now download the notifications
	 [self downloadNotifications:token];//specific to your app
	 */
}



- (void)applicationWillResignActive:(UIApplication *)application {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:@"login" forKey:@"view"];
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	MCLog(@"Did enter background");
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	MCLog(@"Will enter foreground");
	[mainViewController showInfo];
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	[mainViewController showInfo];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSString *terminateDate = [dateFormatter stringFromDate:date];
    time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:terminateDate forKey:@"terminateDate"];
    [defaults setFloat:unixTime forKey:@"lastAlive"];
    
    [dateFormatter release];
    [date release];
	
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Update to handle the error appropriately.
			MCLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();  // Fail
        } 
    }
}


#pragma mark -
#pragma mark Core Data stack

//- (IBAction)saveAction:(id)sender {
//	
//    NSError *error;
//    if (![[self managedObjectContext] save:&error]) {
//		// Update to handle the error appropriately.
//		MCLog(@"Unresolved error %@, %@", error, [error userInfo]);
//		exit(-1);  // Fail
//    }
//}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"LocationTracker.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];    
    [mainViewController release];
    [window release];
	[locationManager release];
    [super dealloc];
}

@end
