//
//  LocationTrackerAppDelegate.h
//  LocationTracker
//
//  Created by Adam Bemowski on 9/17/10.
//  Copyright UC Berkeley 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "LTLocationManager.h"
#import "DataManager.h"
#import "Constants.h"


@class MainViewController;
@class FlipsideViewController;

@interface LocationTrackerAppDelegate : NSObject <UIApplicationDelegate>{
	
	NSString* token;
	UIWindow *window;
    MainViewController *mainViewController;
	FlipsideViewController *flipsideViewController;
	LTLocationManager *locationManager;
    CLLocationManager *CLLManager;
    int improveAccuracyCounter;
	
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
}

@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;
@property (nonatomic, retain) IBOutlet FlipsideViewController *flipsideViewController;
@property (nonatomic, retain) LTLocationManager *locationManager;
@property (nonatomic, retain) CLLocationManager *CLLManager;
@property (assign) int improveAccuracyCounter;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;

-(void)improveAccuracy;
-(void)endImprovedAccuracy;

@end

