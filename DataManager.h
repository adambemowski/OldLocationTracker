//
//  DataManager.h
//  LocationTracker
//
//  Created by Adam Bemowski on 9/17/10.
//  Copyright 2010 UC Berkeley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import <CommonCrypto/CommonDigest.h>
#import "LocationReading.h"
#import "UIDevice+machine.h"
#import "LocationTrackingResponseLoader.h"
#import "ASIFormDataRequest.h"
#import "Reachability.h"
#import "Constants.h"


@protocol DataManagerDelegate
- (void)setLabelToString:(NSString *)string;
@end


@interface DataManager : NSObject <NSFetchedResultsControllerDelegate, LocationTrackingResponseLoaderDelegate> {
	id _delegate;
	NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;	    
	NSMutableDictionary *pendingRequests; // A dictionary to pair arrays of LocationReading objects with NSURLConnection objects that are pending a server response
	NSString *currentMode;
	LocationTrackingResponseLoader *responseLoader;
	
	Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
	NSString *reachabilityStatus;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSDictionary *pendingRequests;
@property (nonatomic, retain) NSString *currentMode;
@property (nonatomic, retain) LocationTrackingResponseLoader *responseLoader;
@property (nonatomic, retain) NSString *reachabilityStatus;

+(DataManager *)sharedDataManager; // Singleton accessor method
-(void)setTheDelegate:(id<DataManagerDelegate>)delegate;
-(void)initiateLocationTransmissionAtFrequency:(int)frequency;
-(BOOL)saveNewLocation:(CLLocation *)location;
-(void)saveData;
-(void)transmitData:(NSTimer *)theTimer;
-(NSString *)md5:(NSString *)str;
-(void)gotAResponse:(NSString *)response fromRequest:(NSMutableURLRequest *) request;


@end