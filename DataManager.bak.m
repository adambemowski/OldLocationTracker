//
//  DataManager.m
//  LocationTracker
//
//  Created by Eric Mai on 9/17/10.
//  Copyright 2010 UC Berkeley. All rights reserved.
//

#import "DataManager.h"
#import "LocationTrackerAppDelegate.h"


id _sharedDataManager;


@implementation DataManager

@synthesize fetchedResultsController, managedObjectContext;
@synthesize pendingRequests;
@synthesize currentMode;
@synthesize responseLoader;
@synthesize reachabilityStatus;


+(DataManager *)sharedDataManager {
	if(!_sharedDataManager) {
		_sharedDataManager = [[DataManager alloc]init];
		
	}
	return _sharedDataManager;
}

-(void)setTheDelegate:(id<DataManagerDelegate>)delegate{
	_delegate = delegate;
}

-(id)init {
	if(self == [super init]) {
		NSError *error;
		if (![[self fetchedResultsController] performFetch:&error]) {
			// Update to handle the error appropriately.
			MCLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
	}
    responseLoader = [[LocationTrackingResponseLoader alloc] init];
	return self;
}


-(void)initiateLocationTransmissionAtFrequency:(int)frequency{
	MCLog(@"going to start transmitting every %i seconds",frequency);
	
	pendingRequests = [[NSMutableDictionary alloc]  init];
	NSTimer *transmissionTimer;
	transmissionTimer = [NSTimer scheduledTimerWithTimeInterval:frequency target:self selector:@selector(transmitData:) userInfo:nil repeats:YES];
	
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	
    //Change the host name here to change the server your monitoring
	hostReach = [[Reachability reachabilityWithHostName: @"www.google.com"] retain];
	[hostReach startNotifier];
	
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifier];
	
    wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
	[wifiReach startNotifier];
	
	reachabilityStatus = @"";
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocationReading" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSError *error;
	NSArray *locationReadings = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if ([_delegate respondsToSelector:@selector(setLabelToString:)]) {
		[_delegate setLabelToString:[NSString stringWithFormat:@"%i points saved",[locationReadings count]]];
	}
	[fetchRequest release];
}

-(BOOL)saveNewLocation:(CLLocation *)location{


	MCLog(@"[DM] saveNewLocation");
	BOOL success = NO;
	
	// Save to CoreData
	// Step 1: Create Object
    LocationReading * newLocationReading = (LocationReading *)[NSEntityDescription
															   insertNewObjectForEntityForName:@"LocationReading"
															   inManagedObjectContext:managedObjectContext];
	
    // Step 2: Set Properties
	newLocationReading.altitude = [NSNumber numberWithFloat:location.altitude];
	newLocationReading.course = [NSNumber numberWithFloat:location.course];
	newLocationReading.horizontalAccuracy = [NSNumber numberWithFloat:location.horizontalAccuracy];
	newLocationReading.latitude = [NSNumber numberWithFloat:location.coordinate.latitude];
	newLocationReading.longitude = [NSNumber numberWithFloat:location.coordinate.longitude];
	newLocationReading.mode = self.currentMode;
	newLocationReading.speed = [NSNumber numberWithFloat:location.speed];
	newLocationReading.timestampGPS = location.timestamp;
	newLocationReading.timestampSample = [NSDate dateWithTimeIntervalSinceNow:0];
    newLocationReading.verticalAccuracy = [NSNumber numberWithFloat:location.verticalAccuracy];
    
    if([LTLocationManager sharedLTLocationManager].locationManager.desiredAccuracy==baseAccuracy){
        newLocationReading.course=[NSNumber numberWithInt:100];
    }    
    else if([LTLocationManager sharedLTLocationManager].locationManager.desiredAccuracy==sleepAccuracy){
        newLocationReading.course=[NSNumber numberWithInt:1000];
    }    
    else if([LTLocationManager sharedLTLocationManager].locationManager.desiredAccuracy==bestAccuracy){
        newLocationReading.course=[NSNumber numberWithInt:1];
    }else{
        newLocationReading.course=[NSNumber numberWithInt:-1];
    }
        
	
    // Step 3: Save Object
    [self saveData]; 
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocationReading" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSError *error;
	NSArray *locationReadings = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if ([_delegate respondsToSelector:@selector(setLabelToString:)]) {
		[_delegate setLabelToString:[NSString stringWithFormat:@"%i points saved",[locationReadings count]]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        int currentDataPoints= [[defaults objectForKey:@"currentDataPoints"] intValue] + 1;
        [defaults setObject:[NSString stringWithFormat:@"%i", currentDataPoints] forKey:@"currentDataPoints"];
        int totalDataPoints= [[defaults objectForKey:@"totalDataPoints"] intValue] + 1;
        [defaults setObject:[NSString stringWithFormat:@"%i", totalDataPoints] forKey:@"totalDataPoints"];
    }
	[fetchRequest release];	
	return success;
}

-(void)saveData{
	NSError *error;
	if (![self.managedObjectContext save:&error]) {
		MCLog(@"Unresolved Core Data Save error %@, %@", error, [error userInfo]);
		exit(-1);
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocationReading" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSError *theError;
	NSArray *locationReadings = [self.managedObjectContext executeFetchRequest:fetchRequest error:&theError];
	if ([_delegate respondsToSelector:@selector(setLabelToString:)]) {
		[_delegate setLabelToString:[NSString stringWithFormat:@"%i points saved",[locationReadings count]]];
	}
    [fetchRequest release];
}

-(void)transmitData:(NSTimer *)theTimer{
    NSLog(@"transmitting Data...");
	// Get data from storage
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocationReading" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSError *error;
	NSArray *locationReadings = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	MCLog(@"there are %i items saved",[locationReadings count]);	
	[fetchRequest release];
	int count = 0; // To limit the total number of data points transmitted
	
//	//test the strength of signal by changing timeout interval and send if desireable
//	NSString *urlString = [NSString stringWithFormat:@"www.google.com"];
//	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]			  
//                                              cachePolicy:NSURLRequestUseProtocolCachePolicy							  
//										  timeoutInterval:60];
//	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
//	BOOL goodConnect;
//	if (theConnection) {
//        NSLog(@"goodconnection");
//		goodConnect = YES;		
//	} 
//	else {
//		goodConnect = NO;
//        NSLog(@"badconnection");
//	}
//	[theConnection release];
//	
//	if (goodConnect) {
        if([locationReadings count] > 0){
            if(count < kMaxDataPointsPerTransmission){
                MCLog(@"we've got some location readings. Let's build transmissionString");
                // Build the transmission string
                NSString *UDID = [[UIDevice currentDevice] uniqueIdentifier];
                NSString *platform = @"1"; // for iPhone
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                //NSLog(@"userid:%@ username:%@ kKey:%@ kUsername:%@",[defaults objectForKey:@"userid"],[defaults objectForKey:@"username"], kKey, kUsername);			
                NSString *MD5Key = [self md5:[NSString stringWithFormat:@"%@%@",kKey,[defaults objectForKey:@"username"]]];
                //NSString *MD5Key = [self md5:[NSString stringWithFormat:@"%@%@",kKey,kUsername]];
                NSMutableString *transmissionString = [NSMutableString stringWithCapacity:(50+(400*[locationReadings count]))];
                [transmissionString setString:@""];
                [transmissionString appendFormat:@"1,%@\n",[defaults objectForKey:@"username"]];
                
                //[transmissionString appendFormat:@"1,%@\n",kUsername];
                for(LocationReading *locationReading in locationReadings){
                    NSString *timestampGPS = [NSString stringWithFormat:@"%0.0f",[locationReading.timestampGPS timeIntervalSince1970]];
                    //			NSString *timestampSample = [NSString stringWithFormat:@"%0.0f",[locationReading.timestampSample timeIntervalSince1970]];
                    NSString *hasSpeed = ([locationReading.speed floatValue] >= 0) ? @"1" : @"0";
                    NSString *hasCourse = ([locationReading.course floatValue] >= 0) ? @"1" : @"0";
                    
                    [transmissionString appendString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%f,,,%@,%@,1,%@,1,%@,,%@,%@\n",
                                                      UDID,platform,locationReading.latitude,locationReading.longitude,@"0",timestampGPS,
                                                      locationReading.speed,locationReading.horizontalAccuracy,locationReading.verticalAccuracy,
                                                      locationReading.altitude,[locationReading.course floatValue],self.reachabilityStatus,hasSpeed,hasSpeed,hasCourse,hasCourse,locationReading.mode]]; 
                }
                
                
                // Using LocationTrackingResponseLoader like the BayTripper XML loaders
                [transmissionString setString:[transmissionString substringToIndex:([transmissionString length] - 1)]]; // Trim last \n from the string
                transmissionString = (NSMutableString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)transmissionString, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8);
                [transmissionString setString:[[NSMutableString stringWithFormat:@"key=%@&trace_data=",MD5Key] stringByAppendingString:transmissionString]];
                MCLog(@"transmissionString is %@",transmissionString);
                NSData *postData = [transmissionString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];  
                NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
                
                NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
                [request setURL:[NSURL URLWithString:kServerAddress]];  
                [request setHTTPMethod:@"POST"];  
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
                [request setHTTPBody:postData]; 
                
                NSString *connectionKey = [NSString stringWithFormat:@"%i",request.hash];
                [pendingRequests setObject:locationReadings forKey:connectionKey];
                
                [responseLoader setTheDelegate:self];
                [responseLoader setTheDelegate:((LocationTrackerAppDelegate *)[UIApplication sharedApplication].delegate).mainViewController];
                [responseLoader getLocationTransmissionResponse:request];		
                
                count++;
				[transmissionString release];
            }
        }
//	}	
}

- (NSString *)md5:(NSString *)str{
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [[NSString stringWithFormat:
			 @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			 result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			 result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			 ] lowercaseString];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	MCLog(@"connection didFinishLoading");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	MCLog(@"connection didFailWithError %@",error);
}

#pragma mark -
#pragma mark Fetched results controller

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
	LocationTrackerAppDelegate *delegate = (LocationTrackerAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;
	
	// Create and configure a fetch request with the LocationReading entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocationReading" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *timestampDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestampGPS" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:timestampDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Create and initialize the fetch results controller.
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"timestampGPS" cacheName:@"Root"];
	self.fetchedResultsController = aFetchedResultsController;
	fetchedResultsController.delegate = self;
	
	// Memory management.
	[aFetchedResultsController release];
	[fetchRequest release];
	[timestampDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    


/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			
			break;
			
		case NSFetchedResultsChangeDelete:
			
			break;
			
		case NSFetchedResultsChangeUpdate:
			
			break;
			
		case NSFetchedResultsChangeMove:
			
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications
}

- (void)gotAResponse:(NSString *)response fromRequest:(NSMutableURLRequest *) request{
	
}

#pragma mark Reachability

// Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus){
        case NotReachable:
        {
			MCLog(@"-----NotReachable");
			self.reachabilityStatus = @"WiFi_NO";
            break;
        }
            
        case ReachableViaWWAN:
        {
			MCLog(@"-----ReachableWWAN");
			self.reachabilityStatus = @"WiFi_NO";
            break;
        }
        case ReachableViaWiFi:
        {
			MCLog(@"-----ReachableWiFi");
			self.reachabilityStatus = @"WiFi_YES";
            break;
		}
    }
}


#pragma mark Memory management

-(void)dealloc{
	self.fetchedResultsController = nil;
	[fetchedResultsController release];
	[managedObjectContext release];
	[pendingRequests release];
	[currentMode release];
	[responseLoader release];
	[reachabilityStatus release];
	[super dealloc];
}


@end

