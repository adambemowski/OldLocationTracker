//
//  LocationTrackingResponseLoader.m
//  LocationTracker
//
//  Created by Adam Bemowski on 10/20/10.
//  Copyright 2010 UC Berkeley. All rights reserved.
//

#import "LocationTrackingResponseLoader.h"


@implementation LocationTrackingResponseLoader

@synthesize responseData;
@synthesize contentOfCurrentTag;
@synthesize responseString;
@synthesize theRequest;


-(void)setTheDelegate:(id<LocationTrackingResponseLoaderDelegate>)delegate{
	_delegate = delegate;
}

- (NSString *) getLocationTransmissionResponse:(NSMutableURLRequest *) request{
	MCLog(@"[LTRL] getLocationTransmissionResponse");
	responseString = @"";
	theRequest = request;
	NSURLResponse *trackingResponseResponse;
	NSError *trackingResponseError;
	responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&trackingResponseResponse error:&trackingResponseError];
	
	if(!responseData){
		if ([_delegate respondsToSelector:@selector(gotAResponse: fromRequest:)]) {
			[_delegate gotAResponse:@"failure" fromRequest:theRequest];
		}
	}
	else{
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:responseData];
		// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
		[parser setDelegate:self];
		[parser setShouldProcessNamespaces:NO];
		[parser setShouldReportNamespacePrefixes:NO];
		[parser setShouldResolveExternalEntities:NO];
		[parser parse];
		
		[parser release];
	}
	return responseString;
}

// Called when an opening element tag is found
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict {
	
	self.contentOfCurrentTag = [[NSMutableString alloc] init];
	//	MCLog(@"opening element: %@",elementName);
	if (qName) {
		elementName = qName;
	}
}

// Called when a closing element tag is found
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {     
	if (qName) {
		elementName = qName;
	}
	//	MCLog(@"closing element: %@",elementName);	
	if ([elementName isEqualToString:@"code"]) { // origin or transfer
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:contentOfCurrentTag forKey:@"code"];
		
		NSLog(@"code is %@", contentOfCurrentTag);
		[self.contentOfCurrentTag release];
	}
	else if ([elementName isEqualToString:@"userid"]) { // origin or transfer
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:contentOfCurrentTag forKey:@"userid"];
		
		NSLog(@"userid is %@", contentOfCurrentTag);
		[self.contentOfCurrentTag release];
	}
	else if ([elementName isEqualToString:@"message"]) { // origin or transfer
		//		MCLog(@"message: %@",self.contentOfCurrentTag);
		if ([_delegate respondsToSelector:@selector(gotAResponse: fromRequest:)]) {
			[_delegate gotAResponse:self.contentOfCurrentTag fromRequest:theRequest];
		}
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:contentOfCurrentTag forKey:@"message"];
		NSLog(@"message is %@", contentOfCurrentTag);
		[self.contentOfCurrentTag release];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    [self.contentOfCurrentTag appendString:string];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	MCLog(@"connection didFinishLoading");
	//	NSString *connectionKey = [NSString stringWithFormat:@"%@",connection.hash];
	//	NSArray *finishedArray = [pendingRequests objectForKey:connectionKey];
	//	MCLog(@"the array of location readings that finished was %i items long",[finishedArray count]);
	//
	//	for(LocationReading *locationReading in finishedArray){
	//		[self.managedObjectContext deleteObject:locationReading];
	//	}
	//	[self saveData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	MCLog(@"connection didFailWithError %@",error);
	
	//	NSString *connectionKey = [NSString stringWithFormat:@"%@",connection.hash];
	//	NSArray *failedArray = [pendingRequests objectForKey:connectionKey];
	//	MCLog(@"the array of location readings that failed was %i items long",[failedArray count]);
}

-(void)dealloc{
	[responseData release];
	[contentOfCurrentTag release];
	[responseString release];
	[super dealloc];
}

@end
