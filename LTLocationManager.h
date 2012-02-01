//
//  LTLocationManager.h
//  LocationTracker
//
//  Created by Adam Bemowski on 9/17/10.
//  Copyright 2010 UC Berkeley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationReading.h"
#import "DataManager.h"


@protocol LTLocationManagerDelegate
- (void)updateToLocation:(CLLocation *)newLocation;
@end


@interface LTLocationManager : NSObject <CLLocationManagerDelegate> {
	id _delegate;
	CLLocationManager *locationManager;
	CLLocation *currentLocation;
    CLLocation *previousLocation;
    double previousAccuracy;
    double steadyPositionLat;
    double steadyPositionLon;
    time_t ZeroVelocityTime;
    time_t NavigationLocationTime;
    double timeLastVelocityZero;
    double timeInNavigation;
    bool firstTimeInKilometerAccuracy;
    bool firstTimeInHundredMeterAccuracy;
    bool firstTimeInNavigationAccuracy;
    bool needToSleep;
    float currentVelocity;
    int headingCounter;
    NSMutableArray *headingTimeArray;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLLocation *previousLocation;
@property double previousAccuracy;
@property double steadyPositionLat;
@property double steadyPositionLon;
@property time_t ZeroVelocityTime;
@property time_t NavigationLocationTime;
@property int atBestNavCounter;
@property int atKilometerCounter;
@property double timeLastVelocityZero;
@property double timeInNavigation;
@property bool firstTimeInKilometerAccuracy;
@property bool firstTimeInHundredMeterAccuracy;
@property bool firstTimeInNavigationAccuracy;
@property bool needToSleep;
@property float currentVelocity;
@property int headingCounter;
@property (nonatomic, retain) NSMutableArray *headingTimeArray;

+(LTLocationManager *)sharedLTLocationManager; // Singleton accessor method
-(void)initiateLocationRecordingAtFrequency:(int)frequency;
-(void)setTheDelegate:(id<LTLocationManagerDelegate>)delegate;
-(void)saveData:(NSTimer *)theTimer;
-(void)minusHeading;

@end