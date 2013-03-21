//
//  NDSMovieTicketsDatesViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/28/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSMovieTicketsDatesViewController.h"
#import "NDSMovieTicketsShowtimesViewController.h"
#import "TFHpple.h"

@interface NDSMovieTicketsDatesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL loading;
@property (assign, nonatomic) NSInteger loadingError;
@property (strong, nonatomic) NSArray *scheduleDayKeysArray;
@property (strong, nonatomic) NSDictionary *scheduleShowtimesDictionary;

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
            
            self.loadingError = [self parseWebsiteHTML];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.loading = NO;
                                
                [self.tableView reloadData];
            });
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
    self.loadingError = [self parseWebsiteHTML];
    
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
    
    NSString *dayKey = [self.scheduleDayKeysArray objectAtIndex:row];
    
    NSArray *showtimesArray = [self.scheduleShowtimesDictionary objectForKey:dayKey];
    
    destination.dateText = dayKey;
    
    destination.showtimesArray = showtimesArray;
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.loading || self.loadingError){
        return 1;
    }
    
    return [self.scheduleDayKeysArray count];
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
        
        NSString *errorMessage = nil;
        
        if(self.loadingError == -1){
            
            errorMessage = @"The application could not connect to Cinema Center's website for film data, please check network connection and restart the application";
        }
        else{
            
            errorMessage = @"The application had trouble retrieving film data from Cinema Center's website, this is error is our fault. Please check back soon after we solve the problem";
        }
        
        textView.text = errorMessage;
        
        return cell;
        
    }
    NSString *CellTableIdentifier = @"DateCell";
        
    cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    
    NSString *dayKey = [self.scheduleDayKeysArray objectAtIndex:indexPath.row];
    
    cell.textLabel.opaque = NO;
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.text = dayKey;
    
    return cell;
}

- (int)parseWebsiteHTML
{
    self.loadingError = NO;
    
    NSMutableArray *scheduleKeysArray = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *scheduleDictionary = [[NSMutableDictionary alloc] init];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://cinemacenter.org/movies/index.php"]];
    
    if (data == nil) {
        self.loadingError = YES;
        return -1;
    }
    
    TFHpple *document = [[TFHpple alloc] initWithHTMLData:data];
    
    if (document == nil) {
        self.loadingError = YES;
        return -2;
    }
    
    NSArray *elements = [document searchWithXPathQuery:@"//p"];
    
    if (elements == nil) {
        self.loadingError = YES;
        return -3;
    }
    
    NSString *dayKey = nil;
    
    BOOL newDay = true;
    
    for(TFHppleElement *element in elements){
        
        NSString *elementText = [element text];
        
        if([elementText length] == 1){
            newDay = YES;
            continue;
        }
        else if (newDay){
            
            dayKey = elementText;
            
            [scheduleKeysArray addObject:dayKey];
            
            [scheduleDictionary setValue:[[NSMutableArray alloc] init] forKey:dayKey];
            
            newDay = NO;
            
            continue;
        }
        else{
            
            [[scheduleDictionary objectForKey:dayKey] addObject:elementText];
        }
    }
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMMM d"];
    NSDate *now = [[NSDate alloc] init];
    NSString *today = [format stringFromDate:now];
    
    dayKey = nil;
    
    int j = 0;
    
    for (int i = 0; i < [scheduleKeysArray count]; i++) {
        
        dayKey = [scheduleKeysArray objectAtIndex:i];
        
        NSRange foundRange = [dayKey rangeOfString:today];
        
        if (foundRange.location != NSNotFound) {
            break;
        }
        
        j++;
    }
    
    for (int i = 0; i < j; i++) {
        
        dayKey = [scheduleKeysArray objectAtIndex:i];
        
        [scheduleDictionary removeObjectForKey:dayKey];
    }
    
    NSMutableArray *dayKeysSaved = [[NSMutableArray alloc] init];
    
    for (int i = j; i < [scheduleKeysArray count]; i++) {
        
        [dayKeysSaved addObject:[scheduleKeysArray objectAtIndex:i]];
    }
    
    self.scheduleDayKeysArray = [dayKeysSaved copy];
    
    self.scheduleShowtimesDictionary = [scheduleDictionary copy];
    
    return 0;
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
