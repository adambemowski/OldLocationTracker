/*
 *  Constants.h
 *  LocationTracker
 *
 *  Created by Adam Bemowski on 11/16/10.
 *  Copyright 2010 UC Berkeley. All rights reserved.
 *
 */

// NOTE: Remember to comment out the #define DEBUG_MODE line in LocationTracker_Prefix.pch to silence logging on release builds (for performance)

#define kLocationTransmissionOnOff 0 // 0 for off, anything else for on
#define kMeasurementIntervalSeconds 1
#define kTransmissionIntervalSeconds 1800 // 30 Min = 1800
#define kImproveAccuracySeconds 43200 // 12 hours = 43200, 6 minutes = 360
#define kMaxDataPointsPerTransmission 5000
#define baseAccuracy kCLLocationAccuracyHundredMeters
#define sleepAccuracy kCLLocationAccuracyKilometer
#define bestAccuracy kCLLocationAccuracyBest
#define kMinIntervalBetweenPoints 5 // Minimum seconds between data points
#define kInfoButtonIsActive 1 // 1 for active, 0 for deactivated
#define kVersion 1.006

// String constants put together according to http://stackoverflow.com/questions/538996/constants-in-objective-c
extern NSString * const kKey;
extern NSString * const kUsername;
extern NSString * const kServerAddress;
extern NSString * const kServerAuthAddress;

