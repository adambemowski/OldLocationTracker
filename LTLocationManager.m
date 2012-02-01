//
//  LTLocationManager.m
//  LocationTracker
//
//  Created by Adam Bemowski on 9/17/10.
//  Copyright 2010 UC Berkeley. All rights reserved.
//

#import "LTLocationManager.h"

id _sharedLTLocationManager;

@implementation LTLocationManager

@synthesize locationManager;
@synthesize currentLocation;
@synthesize previousLocation;
@synthesize previousAccuracy;
@synthesize steadyPositionLat;
@synthesize steadyPositionLon;
//@synthesize ZeroVelocityLocation;
@synthesize ZeroVelocityTime;
@synthesize NavigationLocationTime;
@synthesize atBestNavCounter;
@synthesize atKilometerCounter;
@synthesize timeLastVelocityZero;
@synthesize timeInNavigation;
@synthesize firstTimeInKilometerAccuracy;
@synthesize firstTimeInHundredMeterAccuracy;
@synthesize firstTimeInNavigationAccuracy;
@synthesize needToSleep;
@synthesize currentVelocity;
@synthesize headingCounter;
@synthesize headingTimeArray;

+(LTLocationManager *)sharedLTLocationManager {
	if(!_sharedLTLocationManager) {
		_sharedLTLocationManager = [[LTLocationManager alloc] init];
	}
	return _sharedLTLocationManager;
}

-(id)init {
	if((self = [super init])) {
		currentLocation = [[CLLocation alloc] init];
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
//        locationManager.desiredAccuracy =kCLLocationAccuracyKilometer;
        
        headingTimeArray = [[NSMutableArray alloc] init];

		/*
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         NSString *desiredAccuracy = [[NSString alloc] initWithFormat:@"%@", [defaults objectForKey:@"accuracy"]];
         NSLog(@"AccuracyString:%@",desiredAccuracy);
         if ([desiredAccuracy isEqualToString:@"0"]) {
         locationManager.desiredAccuracy = bestAccuracy;
         NSLog(@"Accuracy:BestForNav");
         }
         if ([desiredAccuracy isEqualToString:@"1"]) {
         locationManager.desiredAccuracy = bestAccuracy;
         NSLog(@"Accuracy:Best");
         }
         if ([desiredAccuracy isEqualToString:@"2"]) {
         locationManager.desiredAccuracy = baseAccuracy;
         NSLog(@"Accuracy:Ten");
         }
         if ([desiredAccuracy isEqualToString:@"3"]) {
         locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
         NSLog(@"Accuracy:Hundred");
         }
         if ([desiredAccuracy isEqualToString:@"4"]) {
         locationManager.desiredAccuracy = sleepAccuracy;
         NSLog(@"Accuracy:Kilometer");
         }*/
		
//        //for region test
//        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(37.749892,-116.718192);     
//        CLRegion *grRegion = [[CLRegion alloc] initCircularRegionWithCenter:coordinates radius:50 identifier:[NSString stringWithFormat:@"grRegion1"]];
//        
//        [locationManager startMonitoringForRegion:grRegion desiredAccuracy:kCLLocationAccuracyKilometer];
        
//        //for header test
//        [locationManager startUpdatingHeading];
//        locationManager.headingFilter = 1;
        
        firstTimeInKilometerAccuracy = true;
        firstTimeInHundredMeterAccuracy = true;
        firstTimeInNavigationAccuracy = true;
		[locationManager startUpdatingLocation]; 
        [locationManager startUpdatingHeading];
        locationManager.headingFilter = 15;
	}
	return self;
}

-(void)setTheDelegate:(id<LTLocationManagerDelegate>)delegate{
	_delegate = delegate;
}

-(void)initiateLocationRecordingAtFrequency:(int)frequency{
	MCLog(@"going to start recording every %i seconds",frequency);
	NSTimer *recordingTimer;
	recordingTimer = [NSTimer scheduledTimerWithTimeInterval:frequency target:self selector:@selector(saveData:) userInfo:nil repeats:YES];
}

-(void)saveData:(NSTimer *)theTimer{
	[[DataManager sharedDataManager] saveNewLocation:self.currentLocation];
}
-(void)minusHeading {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    headingCounter = headingCounter - 1;
    [defaults setObject:[NSString stringWithFormat:@"%i", headingCounter] forKey:@"headingCount"];
    if (currentLocation) {
        [_delegate updateToLocation:currentLocation];
    }

}

#pragma mark CLLocationManager Delegate Method

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    NSLog(@"IN DIDUPDATEHEADING!! ________________________");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    headingCounter++;    
    [defaults setObject:[NSString stringWithFormat:@"%i", headingCounter] forKey:@"headingCount"];
    [self performSelector:@selector(minusHeading) withObject:nil afterDelay:180];    
    if (currentLocation) {
        [_delegate updateToLocation:currentLocation];
    }
    
    
    int currentDataPoints= [[defaults objectForKey:@"headingDataPoints"] intValue] + 1;
    [defaults setObject:[NSString stringWithFormat:@"%i", currentDataPoints] forKey:@"headingDataPoints"];
//    if (locationManager.headingFilter == 15) {
//        if (firstTimeInKilometerAccuracy) {
//            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
//            firstTimeInKilometerAccuracy = false;
//        }
//        long time = [[NSDate date] timeIntervalSince1970];
//        [headingTimeArray addObject:[NSNumber numberWithLong:time]];
//        if ( [headingTimeArray count] >= 72) {
//            long time1 = [[headingTimeArray objectAtIndex:0] longValue];
//            long time2 = [[headingTimeArray objectAtIndex:23] longValue];
//            double difference = time1 - time2;
//            NSLog(@"%f", difference);
//            if (difference > -180) {
//                locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//                firstTimeInNavigationAccuracy = true;
//                [headingTimeArray removeAllObjects];
//            }
//            else {
//                [headingTimeArray removeObjectAtIndex:0];
//            }
//        }
//    }
}

- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region     {
    NSLog(@"Exited Region");
    UIAlertView *regionAlert = [[UIAlertView alloc] initWithTitle:@"Exited Region" message:@"Note where you are idiot" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
	[regionAlert show];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
	NSLog(@"Got a new location: (%f, %f) with speed: %f",newLocation.coordinate.latitude,newLocation.coordinate.longitude,newLocation.speed);
        
    if (locationManager.desiredAccuracy == kCLLocationAccuracyKilometer) {
        NSLog(@"in kilometer accuracy");
    }
    else if (locationManager.desiredAccuracy == kCLLocationAccuracyHundredMeters) {
        NSLog(@"in hundred acc");
    }
    
    [_delegate updateToLocation:newLocation];

// testing for bahlahalha!
    // another change
    
//    //~~~~~~~~~~~~~~~~~~ STATE 1 ~~~~~~~~~~~~~~~~~~~~~~~~~~~
//    //	NSLog(@"++ Previous timestamp: %f",[self.currentLocation.timestamp timeIntervalSince1970]);
//    //	NSLog(@"++ New timestamp:      %f",[newLocation.timestamp timeIntervalSince1970]);
//    //	NSLog(@"++ Difference:         %f",difference);
//    
//    if(locationManager.desiredAccuracy==sleepAccuracy){
//        NSLog(@"currently in sleep accuracy");
//        if(firstTimeInKilometerAccuracy){
//            NSLog(@"First Time in Kilometer");
//            steadyPositionLat = newLocation.coordinate.latitude;
//            steadyPositionLon = newLocation.coordinate.longitude;
//            firstTimeInKilometerAccuracy = false;
//            atKilometerCounter = 0;
//        }
//        else{
//            CLLocation *steadyPosition = [[CLLocation alloc] initWithLatitude:steadyPositionLat longitude:steadyPositionLon];
//            double distance = [newLocation distanceFromLocation:steadyPosition];
//            [steadyPosition release];
//            if(distance>70) {//70 meters
//                NSLog(@"In Kilometer, distance greater than 70 changed");
//                locationManager.desiredAccuracy = bestAccuracy;
//                firstTimeInNavigationAccuracy = true;
//                [_delegate updateToLocation:newLocation];
//            }
//            else if (newLocation.speed>0){
//                NSLog(@"In Kilometer, speed greater than 0 changed");
//                locationManager.desiredAccuracy = bestAccuracy;
//                firstTimeInNavigationAccuracy = true;
//                [_delegate updateToLocation:newLocation];
//            }
//                        
//        }
//    }
//	else if(locationManager.desiredAccuracy==baseAccuracy){
//        NSLog(@"currently in base accuracy");
//        
//        if (firstTimeInHundredMeterAccuracy) {
//            NSLog(@"First Time in Hundred");
//            ZeroVelocityTime = (time_t) [[NSDate date] timeIntervalSince1970];
//            firstTimeInHundredMeterAccuracy = false;
//            
//            steadyPositionLat = newLocation.coordinate.latitude;
//            steadyPositionLon = newLocation.coordinate.longitude;
//        }
//        else {
//            if(newLocation.speed <= 0) {
//                time_t currentTime = (time_t) [[NSDate date] timeIntervalSince1970];
//                double difference =ZeroVelocityTime - currentTime;
//                timeLastVelocityZero = difference;
//            }
//            else{
//                NSLog(@"In TenAccuracy, speed greater than 0 = %f, reset counter",newLocation.speed);                
//                timeLastVelocityZero = 0;
//                ZeroVelocityTime = (time_t) [[NSDate date] timeIntervalSince1970];                
//                steadyPositionLat = newLocation.coordinate.latitude;
//                steadyPositionLon = newLocation.coordinate.longitude;
//            }
//            
//            NSLog(@"Time spent at velocity 0:%f",timeLastVelocityZero);
//            
//            CLLocation *steadyPosition = [[CLLocation alloc] initWithLatitude:steadyPositionLat longitude:steadyPositionLon];
//            double distance = [newLocation distanceFromLocation:steadyPosition];
//            [steadyPosition release];
//
//            if((timeLastVelocityZero < -180) && (distance < 50)) {// 3 minutes
//                NSLog(@"In HundredAccuracy, 2 minutes passed, swap to Kilometer, distance:%f", distance);
//                [_delegate updateToLocation:newLocation];
//            }
//            else if((timeLastVelocityZero < -180) && (distance > 50)) {// 5 minutes
//                locationManager.desiredAccuracy = bestAccuracy;
//                firstTimeInNavigationAccuracy = true;
//                [_delegate updateToLocation:newLocation];
//            }
//        }
//        
//    }
//
//	else if(locationManager.desiredAccuracy==bestAccuracy){
//        NSLog(@"currently in bestforNav accuracy");
//        if (firstTimeInNavigationAccuracy) {
//            NSLog(@"FirstTime in Navigation");
//            NavigationLocationTime = (time_t) [[NSDate date] timeIntervalSince1970];                
//            atBestNavCounter = 0;
//            steadyPositionLat = newLocation.coordinate.latitude;
//            steadyPositionLon = newLocation.coordinate.longitude;
//
//            firstTimeInNavigationAccuracy = false;
//            [_delegate updateToLocation:newLocation];
//        }
//        else {
//            time_t currentTime = (time_t) [[NSDate date] timeIntervalSince1970];
//            double difference =NavigationLocationTime - currentTime;
//            timeInNavigation = difference;
//            CLLocation *steadyPosition = [[CLLocation alloc] initWithLatitude:steadyPositionLat longitude:steadyPositionLon];
//            double distance = [newLocation distanceFromLocation:steadyPosition];
//            [steadyPosition release];
//            NSLog(@"Time in Navigation 0:%f",timeInNavigation);
//
//            if (timeInNavigation < -30){
//                if (distance > 50) {
//                    NSLog(@"In Navigation, speed less than 0 detected but distance moved > 50, swap to hundred meter accuracy");
//                    locationManager.desiredAccuracy = bestAccuracy;
//                    firstTimeInNavigationAccuracy = true;
//                }
//                else {
//                    NSLog(@"In Navigation, speed less than 0 detected for 30 seconds, swap to Kilometer");
//                    locationManager.desiredAccuracy = baseAccuracy;
//                    firstTimeInKilometerAccuracy = true;
//                    firstTimeInNavigationAccuracy = true;
//                }
//            }
//                //atBestNavCounter = 0;
//               
//            else{
//                if(newLocation.speed > 0){
//                    locationManager.desiredAccuracy = baseAccuracy; 
//                    firstTimeInHundredMeterAccuracy = true;
//                    firstTimeInNavigationAccuracy = true;
//                }
//            }
//            [_delegate updateToLocation:newLocation];
//            
//        }
//	}
//    else if(locationManager.desiredAccuracy==kCLLocationAccuracyThreeKilometers) {
//        NSLog(@"in 3 kilometeraccuracy");
//        [_delegate updateToLocation:newLocation];
//    }
//    //~~~~~~~~~~~~~ END STATE 1 ~~~~~~~~~~~~~~~~~~
    
    // POWER SAVER STATE TEST 1
    
    if (locationManager.desiredAccuracy == kCLLocationAccuracyHundredMeters) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        if ([[defaults objectForKey:@"state"] isEqualToString:@"stationary"]) {
//            NSLog(@"Location manager active in stationary state");
//            if (previousLocation != nil) {
//                double distance = [newLocation getDistanceFrom:previousLocation];
//                double accuracy = newLocation.horizontalAccuracy;
//                if (distance > (accuracy + previousAccuracy)) {
//                    firstTimeInHundredMeterAccuracy = true;
//                    [defaults setObject:@"traveling" forKey:@"state"];
//                }
//            }
//            previousLocation = nil;
//            [previousLocation release];
//            previousAccuracy = 0;
//            previousLocation = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
//            previousAccuracy = newLocation.horizontalAccuracy;
//            
//
//        }
        
//        if ([[defaults objectForKey:@"state"] isEqualToString:@"traveling"]) {
            NSLog(@"Location manager active in traveling state");
            if (firstTimeInNavigationAccuracy) {
                locationManager.headingFilter = 359;  // for heading test
                timeLastVelocityZero = 0;
                ZeroVelocityTime = (time_t) [[NSDate date] timeIntervalSince1970]; 
                previousLocation = nil;
                [previousLocation release];
                previousLocation = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
                firstTimeInNavigationAccuracy = false;
            }
            
            if(newLocation.speed <= 4) {
                time_t currentTime = (time_t) [[NSDate date] timeIntervalSince1970];
                double difference =ZeroVelocityTime - currentTime;
                timeLastVelocityZero = difference;
            }
            else{
                timeLastVelocityZero = 0;
                ZeroVelocityTime = (time_t) [[NSDate date] timeIntervalSince1970];
                previousLocation = nil;
                [previousLocation release];
                previousLocation = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
            }
            
            double distance = [newLocation getDistanceFrom:previousLocation];
            if (timeLastVelocityZero < -120  && distance < 50) {
                firstTimeInKilometerAccuracy = true;
                self.locationManager.headingFilter = 15; //for heading
            }
            
            // Only care if there is a change in lat, long, or velocity
            if((self.currentLocation.coordinate.latitude - newLocation.coordinate.latitude != 0) || (self.currentLocation.coordinate.longitude - newLocation.coordinate.longitude != 0) || (self.currentLocation.speed - newLocation.speed != 0)){
                MCLog(@"it's a new point");
                // It's been at least 5 minutes
                if(fabs([newLocation.timestamp timeIntervalSinceDate:self.currentLocation.timestamp]) >= kMinIntervalBetweenPoints){ 
                    MCLog(@"it's an interesting point");
                    self.currentLocation = newLocation;
                    [_delegate updateToLocation:newLocation];
                    
                    // Don't record at a set frequency - just do it whenever a new point comes in
                    NSTimer *recordingTimer;
                    [self saveData:recordingTimer];
                }
            }
            
    //}
    }
    else if(locationManager.desiredAccuracy==kCLLocationAccuracyThreeKilometers){
        NSLog(@"currently in 3k accuracy");
    }
    else if (locationManager.desiredAccuracy == kCLLocationAccuracyBest) {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        NSLog(@"currently in best accuracy");
    }
    
//	// Only care if there is a change in lat, long, or velocity
//	if((self.currentLocation.coordinate.latitude - newLocation.coordinate.latitude != 0) || (self.currentLocation.coordinate.longitude - newLocation.coordinate.longitude != 0) || (self.currentLocation.speed - newLocation.speed != 0)){
//		NSLog(@"it's a new point");
//		// It's been at least 5 minutes
//		if(fabs([newLocation.timestamp timeIntervalSinceDate:self.currentLocation.timestamp]) >= kMinIntervalBetweenPoints){ 
//			NSLog(@"it's an interesting point");
//			self.currentLocation = newLocation;
//			[_delegate updateToLocation:newLocation];
//			
//			// Don't record at a set frequency - just do it whenever a new point comes in
//			NSTimer *recordingTimer;
//			[self saveData:recordingTimer];
//		}
//	}
}


#pragma mark CoreData


-(void)dealloc{
//    [NavigationLocation release];
	[locationManager release];
	[currentLocation release];
	[super dealloc];
}

@end
