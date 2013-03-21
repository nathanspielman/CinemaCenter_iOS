//
//  NDSScheduleViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/7/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSScheduleViewController.h"
#import "TFHpple.h"

@interface NDSScheduleViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL loading;
@property (assign, nonatomic) __block NSInteger loadingError;
@property (strong, nonatomic) NSArray *scheduleDayKeysArray;
@property (strong, nonatomic) NSDictionary *scheduleShowtimesDictionary;

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
            
            self.loadingError = [self parseWebsiteHTML];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.loading = NO;
                
                [self.tableView reloadData];
            });
        });
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

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(self.loadingError){
        return 3;
    }
    
    int numOfTableRows = [self.scheduleDayKeysArray count]+1;
    
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
    
    NSString *dayKey = [self.scheduleDayKeysArray objectAtIndex:indexPath.row-1];
    
    NSArray *showtimesArray = [self.scheduleShowtimesDictionary objectForKey:dayKey];
    
    NSString *showtimesText = @"";
    
    for (NSString *showtime in showtimesArray) {
        
        showtimesText = [[showtimesText stringByAppendingString:showtime] stringByAppendingString:@"\n"];
    }
    
    if (self.loadingError) {
        
        dateLabel.text = @"Something went wrong...";
        
        NSString *errorMessage;
        
        if(self.loadingError == -1){
            
            errorMessage = @"The application could not connect to Cinema Center's website for schedule data, please check network connection and restart the application";
        }
        else{
            
            errorMessage = @"The application had trouble retrieving schedule data from Cinema Center's website, this is error is our fault. Please check back soon after we solve the problem";
        }
                        
        showtimesTextView.text = errorMessage;
        
        return cell;
    }
    
    dateLabel.text = dayKey;
    
    showtimesTextView.text = showtimesText;
        
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 175.0;
}

- (int)parseWebsiteHTML
{
    self.loadingError = NO;
    
    NSMutableArray *scheduleDayKeysArray = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *scheduleShowtimesDictionary = [[NSMutableDictionary alloc] init];
    
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
            
            [scheduleDayKeysArray addObject:dayKey];
            
            [scheduleShowtimesDictionary setValue:[[NSMutableArray alloc] init] forKey:dayKey];
            
            newDay = NO;
            
            continue;
        }
        else{
                        
            [[scheduleShowtimesDictionary objectForKey:dayKey] addObject:elementText];
        }
    }
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMMM d"];
    NSDate *now = [[NSDate alloc] init];
    NSString *today = [format stringFromDate:now];
    
    dayKey = nil;
    
    int j = 0;
    
    for (int i = 0; i < [scheduleDayKeysArray count]; i++) {
        
        dayKey = [scheduleDayKeysArray objectAtIndex:i];
        
        NSRange foundRange = [dayKey rangeOfString:today];
        
        if (foundRange.location != NSNotFound) {
            break;
        }
        
        j++;
    }
    
    for (int i = 0; i < j; i++) {
        
        dayKey = [scheduleDayKeysArray objectAtIndex:i];
        
        [scheduleShowtimesDictionary removeObjectForKey:dayKey];        
    }
    
    NSMutableArray *dayKeysSaved = [[NSMutableArray alloc] init];
    
    for (int i = j; i < [scheduleDayKeysArray count]; i++) {
        
        [dayKeysSaved addObject:[scheduleDayKeysArray objectAtIndex:i]];
    }
    
    self.scheduleDayKeysArray = [dayKeysSaved copy];
    
    self.scheduleShowtimesDictionary = [scheduleShowtimesDictionary copy];
    
    return 0;
}

@end
