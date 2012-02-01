//
//  LocationReading.h
//  LocationTracker
//
//  Created by Adam Bemowski on 9/29/10.
//  Copyright 2010 UC Berkeley. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface LocationReading :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * verticalAccuracy;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * mode;
@property (nonatomic, retain) NSNumber * horizontalAccuracy;
@property (nonatomic, retain) NSNumber * course;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSDate * timestampGPS;
@property (nonatomic, retain) NSDate * timestampSample;
@property (nonatomic, retain) NSDate * timestampEnd;
@property (nonatomic, retain) NSNumber * altitude;

@end



