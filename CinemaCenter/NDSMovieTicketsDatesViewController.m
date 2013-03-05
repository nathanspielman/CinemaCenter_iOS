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

@interface NDSMovieTicketsDatesViewController ()

@property (strong, nonatomic) NSMutableDictionary *dictionaryOfDaysText;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) NSInteger pageLoadError;
@property (nonatomic) BOOL loading;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfDatesText;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfShowtimesText;
@property (nonatomic, assign) int daysRemoved;
@property (strong,nonatomic) NSArray *htmlOriginalSymbolArray;
@property (strong,nonatomic) NSArray *htmlReplacedSymbolArray;

@end

@implementation NDSMovieTicketsDatesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
            
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    self.htmlOriginalSymbolArray = ((NDSAppDelegate *)[[UIApplication sharedApplication]delegate]).htmlOriginalSymbolArray;
    self.htmlReplacedSymbolArray = ((NDSAppDelegate *)[[UIApplication sharedApplication]delegate]).htmlReplacedSymbolArray;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshView)];
    
    self.navigationItem.rightBarButtonItem = refreshButton;
            
    self.loading = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    
    if (self.pageLoadError || self.loading) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            self.pageLoadError = [self parseWebsiteText];
            
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
    
    if (self.pageLoadError || self.loading) {
        
        self.loading = YES;
                
        [self.tableView reloadData];
    }    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    self.pageLoadError = [self parseWebsiteText];
    
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
    
    NSString *dayKey = [[NSString alloc]initWithFormat:@"day%d", row+1+self.daysRemoved];
    
    NSString *dateText = [self.dictionaryOfDatesText objectForKey:dayKey];
    
    NSString *showtimesText = [self.dictionaryOfShowtimesText objectForKey:dayKey];
    
    destination.dateText = dateText;
    
    destination.showtimesText = showtimesText;
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.loading || self.pageLoadError){
        return 1;
    }
    
    return [self.dictionaryOfDaysText count];    
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
    
    if (self.pageLoadError && indexPath.row == 0) {
        
        NSString *CellIdentifier = @"MoviePosterErrorCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UITextView *textView = (UITextView *)[cell viewWithTag:5];
        
        NSString *errorMessage = nil;
        
        if(self.pageLoadError == -1){
            
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
    
    NSString *dayKey = [[NSString alloc]initWithFormat:@"day%d", indexPath.row+1+self.daysRemoved];
    
    NSString *dayText = [self.dictionaryOfDaysText objectForKey:dayKey];
    
    NSRange range = [dayText rangeOfString:@"\n"];
    
    NSString *dateText = [dayText substringToIndex:range.location+1];
    
    NSString *showtimesText = [dayText substringFromIndex:range.location+1];
    
    [self.dictionaryOfDatesText setObject:dateText forKey:dayKey];
    
    [self.dictionaryOfShowtimesText setObject:showtimesText forKey:dayKey];
    
    cell.textLabel.opaque = NO;
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.text = dateText;
    
    return cell;
}

-(int)parseWebsiteText
{
    self.pageLoadError = NO;
    
    self.dictionaryOfDaysText = [[NSMutableDictionary alloc]init];
    
    self.dictionaryOfDatesText = [[NSMutableDictionary alloc]init];
    
    self.dictionaryOfShowtimesText = [[NSMutableDictionary alloc]init];
    
    NSString *ccMovieSchedule = @"http://cinemacenter.org/movies/index.php";
    
    NSURL *ccURL = [NSURL URLWithString:ccMovieSchedule];
    
    NSError *error;
    
    NSString *ccPageContent = [NSString stringWithContentsOfURL:ccURL encoding:NSASCIIStringEncoding error:&error];
    
    if(ccPageContent == nil){
        self.pageLoadError = YES;
        return -1;
    }
    
    NSMutableArray *dayRangeLocations = [[NSMutableArray alloc]init];
    
    NSRange searchRange, foundRange;
    
    
    //Get rid of all the stuff before "Movie Schedule"
    
    foundRange = [ccPageContent rangeOfString:@"Movie Schedule"];
    
    if(foundRange.location == NSNotFound){
        
        self.pageLoadError = YES;
        return -2;
    }
    
    NSRange movieScheduleRange = NSMakeRange(foundRange.location, ([ccPageContent length] - foundRange.location));
    
    ccPageContent = [ccPageContent substringWithRange:movieScheduleRange];
    
    
    //Get rid of all the stuff after "<!-- End of PageLime Text Stack -->"
    
    foundRange = [ccPageContent rangeOfString:@"<!-- End of PageLime Text Stack -->"];
    
    if(foundRange.location == NSNotFound){
        
        self.pageLoadError = YES;
        return -3;
    }
    
    movieScheduleRange = NSMakeRange(0, foundRange.location);
    
    ccPageContent = [ccPageContent substringWithRange:movieScheduleRange];
    
    
    NSRange firstRange = [ccPageContent rangeOfString:@"<"];
    
    while (firstRange.location != NSNotFound) {
        
        NSRange secondRange = [ccPageContent rangeOfString:@">"];
        
        if(secondRange.location == NSNotFound){
            break;
        }
        
        int length = secondRange.location - firstRange.location;
        
        NSRange replaceRange = NSMakeRange(firstRange.location, length+1);
        
        ccPageContent = [ccPageContent stringByReplacingCharactersInRange:replaceRange withString:@" "];
        
        firstRange = [ccPageContent rangeOfString:@"<"];
    }
    
    for (int i = 0; i < [self.htmlOriginalSymbolArray count]; i++) {
        
        NSString *originalSymbol = [self.htmlOriginalSymbolArray objectAtIndex:i];
        
        NSString *replacedSymbol = [self.htmlReplacedSymbolArray objectAtIndex:i];
        
        ccPageContent = [ccPageContent stringByReplacingOccurrencesOfString:originalSymbol withString:replacedSymbol];
    }
    
    NSArray *daysOfWeek = [NSArray arrayWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
    
    for (NSString *day in daysOfWeek) {
        
        searchRange = NSMakeRange(0,[ccPageContent length]);
        
        while (searchRange.location < [ccPageContent length]) {
            
            searchRange.length = [ccPageContent length] - searchRange.location;
            
            foundRange = [ccPageContent rangeOfString:day options:NSCaseInsensitiveSearch range:searchRange];
            
            if (foundRange.location != NSNotFound) {
                // found an occurrence of the substring! do stuff here
                
                [dayRangeLocations addObject:[NSNumber numberWithInt:foundRange.location]];
                
                searchRange.location = foundRange.location+foundRange.length;
            }
            else {
                // no more substring to find
                break;
            }
        }
    }
    
    NSArray *dayRangeLocationsSorted = [dayRangeLocations sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                                        {
                                            int int1 = [obj1 integerValue];
                                            int int2 = [obj2 integerValue];
                                            
                                            if( int1 > int2 )
                                            {
                                                return NSOrderedDescending;
                                            }
                                            else if ( int1 < int2 )
                                            {
                                                return NSOrderedAscending;
                                            }
                                            return NSOrderedSame;
                                        }];
    
    for(int i = 0; i < [dayRangeLocationsSorted count]; i++){
        
        NSString *day = nil;
        
        NSInteger endingIndex;
        
        NSInteger startingIndex = [[dayRangeLocationsSorted objectAtIndex:i]integerValue];
        
        if(i+1 != [dayRangeLocationsSorted count]){
            
            endingIndex = [[dayRangeLocationsSorted objectAtIndex:i+1]integerValue]-1;
        }
        else{
            
            endingIndex = [ccPageContent length];
        }
        
        NSInteger length = endingIndex - startingIndex;
        
        NSRange dayRange = NSMakeRange(startingIndex, length);
        
        day = [ccPageContent substringWithRange:dayRange];
        
        NSString *dayKey = [[NSString alloc]initWithFormat:@"day%d",i+1];
        
        [self.dictionaryOfDaysText setObject:day forKey:dayKey];
    }
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMMM d"];
    NSDate *now = [[NSDate alloc] init];
    NSString *today = [format stringFromDate:now];
    
    NSString *dayKey = nil;
    
    for (int i = 0; i < [self.dictionaryOfDaysText count]; i++) {
        
        dayKey = [[NSString alloc]initWithFormat:@"day%d",i+1];
        
        NSString *dayText = [self.dictionaryOfDaysText objectForKey:dayKey];
        
        NSRange foundRange = [dayText rangeOfString:today];
        
        if (foundRange.location != NSNotFound) {
            break;
        }
        
        dayKey = nil;
    }
    
    self.daysRemoved = 0;
        
    if (dayKey != nil) {
        
        for (int i = 0; i < [self.dictionaryOfDaysText count]; i++) {
            
            NSString *key = [[NSString alloc]initWithFormat:@"day%d",i+1];
            
            if([key isEqualToString:dayKey]){
                break;
            }
            
            [self.dictionaryOfDaysText removeObjectForKey:key];
            
            self.daysRemoved++;
        }        
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    
    if (self.loading) {
        return 398.0;
    }
    
    if (self.pageLoadError && row == 0) {
        return 131.0;
    }
    
    return 44.0;
}

@end
