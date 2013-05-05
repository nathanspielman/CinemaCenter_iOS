//
//  NDSMovieTicketsDatesViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/28/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSMovieTicketsDatesViewController.h"
#import "NDSMovieTicketsShowtimesViewController.h"
#import "NDSAppDelegate.h"
#import "NDSScheduleViewController.h"
#import "NDSCinemaCenterDay.h"

@interface NDSMovieTicketsDatesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL loadingError;
@property (strong, nonatomic) NSArray *arrayOfDays;

@end

@implementation NDSMovieTicketsDatesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
            
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
        
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshView)];
    
    self.navigationItem.rightBarButtonItem = refreshButton;
            
    self.loading = YES;
}

- (void)viewDidAppear:(BOOL)animated
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

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    if (self.loadingError || self.loading) {
        
        self.loading = YES;
                
        [self.tableView reloadData];
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

- (void)refreshView
{
    self.loading = YES;
        
    [self viewWillAppear:NO];
    
    [self viewDidAppear:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NDSMovieTicketsShowtimesViewController *destination = segue.destinationViewController;
    
    int row = [[self.tableView indexPathForSelectedRow]row];
        
    NSDate *date = [[self.arrayOfDays objectAtIndex:row] valueForKey:@"date"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEEE, MMMM d"];
    
    NSString *dateText = [df stringFromDate:date];
    
    NSString *showtimesText = [[self.arrayOfDays objectAtIndex:row] valueForKey:@"showtimes"];
    
    destination.dateText = dateText;
    
    destination.showtimesText = showtimesText;
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.loading || self.loadingError){
        return 1;
    }
    
    return [self.arrayOfDays count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = nil;
    
    if(self.loading && indexPath.row == 0){
        
        NSString *CellIdentifier = @"LoadCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell viewWithTag:6];
        
        [activityIndicator startAnimating];
        
        return cell;
    }
    
    if (self.loadingError && indexPath.row == 0) {
        
        NSString *CellIdentifier = @"MoviePosterErrorCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UITextView *textView = (UITextView *)[cell viewWithTag:5];
        
        NSString *errorMessage = @"The application could not connect to Cinema Center's website for film data, please check network connection and restart the application";
        
        textView.text = errorMessage;
        
        return cell;
        
    }
    NSString *CellTableIdentifier = @"DateCell";
        
    cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    
    NSDate *date = [[self.arrayOfDays objectAtIndex:indexPath.row] valueForKey:@"date"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEEE, MMMM d"];
    
    NSString *dateText = [df stringFromDate:date];
    
    cell.textLabel.opaque = NO;
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.text = dateText;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    
    if (self.loading) {
        return 398.0;
    }
    
    if (self.loadingError && row == 0) {
        return 131.0;
    }
    
    return 44.0;
}

@end
