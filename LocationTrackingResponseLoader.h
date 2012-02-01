//
//  LocationTrackingResponseLoader.h
//  LocationTracker
//
//  Created by Adam Bemowski on 10/20/10.
//  Copyright 2010 UC Berkeley. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol LocationTrackingResponseLoaderDelegate
- (void)gotAResponse:(NSString *)response fromRequest:(NSMutableURLRequest *) request;
@end

@interface LocationTrackingResponseLoader : NSObject <NSXMLParserDelegate> {
	id _delegate;
	NSData *responseData;
	NSMutableString *contentOfCurrentTag;
	NSString *responseString;
	NSMutableURLRequest *theRequest;
}

@property (nonatomic, retain) NSData *responseData;
@property (nonatomic, retain) NSMutableString *contentOfCurrentTag;
@property (nonatomic, retain) NSString *responseString;
@property (nonatomic, retain) NSMutableURLRequest *theRequest;

-(void)setTheDelegate:(id<LocationTrackingResponseLoaderDelegate>)delegate;
- (NSString *) getLocationTransmissionResponse:(NSMutableURLRequest *) request;

@end
