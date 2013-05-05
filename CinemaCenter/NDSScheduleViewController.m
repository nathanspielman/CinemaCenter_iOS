//
//  NDSScheduleViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/7/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSScheduleViewController.h"
#import "NDSAppDelegate.h"
#import "NDSCinemaCenterDay.h"

@interface NDSScheduleViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL loading;
@property (nonatomic) __block BOOL loadingError;
@property (strong, nonatomic) NSArray *arrayOfDays;

@end

@implementation NDSScheduleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
            
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    self.loading = YES;    
}

- (void)viewWillAppear:(BOOL)animated
{    
    if (self.loadingError || self.loading) {
                
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [NDSCinemaCenterDay getAllOnSuccess:^(NSArray *days) {
                
                self.arrayOfDays = days;
                
                self.loadingError = NO;
                
                self.loading = NO;
                
                [self.tableView reloadData];
                
            } failure:^(NSError *error) {
                self.loadingError = YES;
                
                self.loading = NO;
                
                [self.tableView reloadData];
            }];
        });
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [NDSCinemaCenterDay getAllOnSuccess:^(NSArray *days) {
        
        self.arrayOfDays = days;
        
        self.loading = NO;
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        self.loadingError = YES;
        
        self.loading = NO;
        
        [self.tableView reloadData];
    }];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(self.loadingError){
        return 3;
    }
    
    int numOfTableRows = [self.arrayOfDays count]+1;
    
    if(numOfTableRows >= 4){
        return numOfTableRows;
    }
    else{
        return 4;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellTableIdentifier = nil;
        
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 0) {
        
        CellTableIdentifier = @"CinemaCenterFilmCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        
        UILabel *scheduleLabel = (UILabel *)[cell viewWithTag:6];
        
        if (self.loading) {
            scheduleLabel.text = @"";
        }
        else{
            scheduleLabel.text = @"Movie Schedule";
        }
                
        return cell;
    }
    
    if (self.loadingError && indexPath.row == 2){
        
        CellTableIdentifier = @"CutFilmCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        
        return cell;
    }
    
    CellTableIdentifier = @"ScheduleFilmCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:7];
    
    UITextView *showtimesTextView = (UITextView *)[cell viewWithTag:8];
            
    if (self.loadingError) {
        
        dateLabel.text = @"Something went wrong...";
        
        NSString *errorMessage = @"The application could not connect to Cinema Center's website for schedule data, please check network connection and restart the application";
                        
        showtimesTextView.text = errorMessage;
        
        return cell;
    }
        
    NSDate *date = [[self.arrayOfDays objectAtIndex:indexPath.row-1] valueForKey:@"date"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEEE, MMMM d"];
    
    NSString *dateText = [df stringFromDate:date];
        
    NSString *showtimesText = [[self.arrayOfDays objectAtIndex:indexPath.row-1] valueForKey:@"showtimes"];
    
    dateLabel.text = dateText;
    
    showtimesTextView.text = showtimesText;
        
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 175.0;
}

@end
