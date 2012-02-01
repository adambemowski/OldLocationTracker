//
//  MainViewController.h
//  LocationTracker
//
//  Created by Adam Bemowski on 9/17/10.
//  Copyright UC Berkeley 2010. All rights reserved.
//


#import "FlipsideViewController.h"
#import "InfoPage.h"
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "LTLocationManager.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, InfoPageDelegate, MKMapViewDelegate, LTLocationManagerDelegate, LocationTrackingResponseLoaderDelegate, DataManagerDelegate> {
	
    NSManagedObjectContext *managedObjectContext;	
	IBOutlet MKMapView *mapView;
	IBOutlet UILabel *modeLabel;
	IBOutlet UILabel *timeLabel;
	IBOutlet UILabel *accuracyLabel;
   	IBOutlet UILabel *accuracySettingLabel;
	IBOutlet UILabel *speedLabel;
	IBOutlet UILabel *networkLabel;
	IBOutlet UIActivityIndicatorView *networkIndicatorView;
	IBOutlet UILabel *serverResponse;
    IBOutlet UIButton *transmitDataButton;
    IBOutlet UIButton *infoButton;
    IBOutlet UILabel *headingLabel;
	int loggedin;
}


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UILabel *modeLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *accuracyLabel;
@property (nonatomic, retain) IBOutlet UILabel *accuracySettingLabel;
@property (nonatomic, retain) IBOutlet UILabel *speedLabel;
@property (nonatomic, retain) IBOutlet UILabel *networkLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *networkIndicatorView;
@property (nonatomic, retain) IBOutlet UILabel *serverResponse;
@property (nonatomic, retain) IBOutlet UIButton *transmitDataButton;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) IBOutlet UILabel *headingLabel;
@property int loggedin;

- (IBAction)showInfo ;
- (IBAction)goToInfoPage:(id)sender;
- (IBAction)transmitDataButtonPressed ;
- (IBAction)resetHeadingPoints;


@end
