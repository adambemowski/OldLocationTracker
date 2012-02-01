//
//  InfoPage.m
//  LocationTracker
//
//  Created by Adam Bemowski on 5/23/11.
//  Copyright 2011 UC Berkeley. All rights reserved.
//

#import "InfoPage.h"


@implementation InfoPage

@synthesize delegate=_delegate;
@synthesize tableView;

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];  
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Data Collection Information";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 6;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *returnString;
    NSString *detailedText;
    static NSString *CellIdentifier = @"Cell";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    switch (indexPath.row){
        case(0):
            returnString = @"Time of last launch";
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            detailedText = [dateFormatter stringFromDate:[defaults objectForKey:@"birthDate"]];
            break;
        case (1):
            returnString = @"Time of last exit";
            detailedText = [defaults objectForKey:@"terminateDate"];
            break;	
        case (2):
            returnString = @"Runtime";
            NSTimeInterval elapsedSeconds = [[NSDate date] timeIntervalSinceDate: [defaults objectForKey:@"birthDate"]];
            int hour = floor(elapsedSeconds/3600);
            int mins = floor(elapsedSeconds/60 - hour*60);
            detailedText = [NSString stringWithFormat:@"%i Hours, %i Mins", hour, mins];
            break;	
        case (3):
            returnString = @"Data points on current run";
            detailedText = [defaults objectForKey:@"currentDataPoints"];
            break;	
        case (4):
            returnString = @"Total Data points collected";
            detailedText = [defaults objectForKey:@"totalDataPoints"];
            break;
        case (5):
            returnString = @"Heading Data points collected";
            detailedText = [defaults objectForKey:@"headingDataPoints"];
            break;	
    }
    
    [dateFormatter release];
    [date release];
    
    cell.detailTextLabel.text = detailedText;
    cell.textLabel.text = returnString;
    return cell;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate InfoPageDidFinish:self];
}

@end
