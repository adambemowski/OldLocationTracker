//
//  InfoPage.h
//  LocationTracker
//
//  Created by Adam Bemowski on 5/23/11.
//  Copyright 2011 UC Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfoPageDelegate;

@interface InfoPage : UIViewController <UITableViewDataSource> {
    id <InfoPageDelegate> delegate;
    IBOutlet UITableView *tableView;
}

@property (nonatomic, assign) id <InfoPageDelegate> delegate;
@property (nonatomic, assign) IBOutlet UITableView *tableView;

- (IBAction)done:(id)sender;

@end


@protocol InfoPageDelegate
- (void)InfoPageDidFinish:(InfoPage *)controller;
@end
