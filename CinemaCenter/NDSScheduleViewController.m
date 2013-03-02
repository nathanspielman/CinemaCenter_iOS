//
//  NDSScheduleViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/7/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSScheduleViewController.h"
#import "NDSScheduleFilmCell.h"
#import "NDSAppDelegate.h"

@interface NDSScheduleViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) __block NSInteger pageLoadError;
@property (nonatomic) BOOL loading;
@property (nonatomic, assign) int daysRemoved;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfDaysText;
@property (strong,nonatomic) NSArray *htmlOriginalSymbolArray;
@property (strong,nonatomic) NSArray *htmlReplacedSymbolArray;

@property (nonatomic, assign) int degrees;
@property (nonatomic) BOOL continueSpinning;


@end

@implementation NDSScheduleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
            
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    self.htmlOriginalSymbolArray = ((NDSAppDelegate *)[[UIApplication sharedApplication]delegate]).htmlOriginalSymbolArray;
    self.htmlReplacedSymbolArray = ((NDSAppDelegate *)[[UIApplication sharedApplication]delegate]).htmlReplacedSymbolArray;
    
    self.loading = YES;
    
    /*[NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self.tableView
                                   selector:@selector(reloadData)
                                   userInfo:nil
                                    repeats:YES];*/
    
}

- (void)viewWillAppear:(BOOL)animated
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

/*-(void)startSpinningImageView:(UIImageView *)imageView
{
    self.degrees = 0;
    self.continueSpinning = true;
    [self continueSpinningImageView:imageView];
}

-(void)continueSpinningImageView:(UIImageView *)imageView
{
    self.degrees = (self.degrees + 1) % 360;
    
    CGAffineTransform rotate = CGAffineTransformMakeRotation( self.degrees / 180.0 * 3.14 );
    [imageView setTransform:rotate];
    
    [self.tableView reloadData];
    
    if(!self.continueSpinning)
        return;
    else
        [self performSelector:@selector(continueSpinning) withObject:nil afterDelay:0.1f];
}

-(void)stopSpinningImageView:(UIImageView *)imageView
{
    self.continueSpinning = false;
}*/

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(self.pageLoadError){
        return 3;
    }
    
    int numOfTableRows = [self.dictionaryOfDaysText count]+1;
    
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
        
    int row = [indexPath row];
    
    if (row == 0) {
        
        CellTableIdentifier = @"CinemaCenterFilmCell";
        
        NDSScheduleFilmCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        
        if (self.loading) {
            cell.scheduleLabel.text = @"";
        }
        else{
            cell.scheduleLabel.text = @"Movie Schedule";
        }
        
        /*self.degrees = (self.degrees + 1) % 360;
        
        CGAffineTransform rotate = CGAffineTransformMakeRotation( self.degrees / 180.0 * 3.14 );
        [cell.iconImageView setTransform:rotate];*/
                
        return cell;
    }
    
    if (self.pageLoadError && row == 2){
        
        CellTableIdentifier = @"CutFilmCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        
        return cell;
    }
    
    CellTableIdentifier = @"ScheduleFilmCell";
    
    NDSScheduleFilmCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    
    NSString *dayKey = [[NSString alloc]initWithFormat:@"day%d", row+self.daysRemoved];
    
    NSString *dayText = [self.dictionaryOfDaysText objectForKey:dayKey];
    
    if (self.pageLoadError) {
        
        cell.dateLabel.text = @"Something went wrong...";
        
        NSString *errorMessage;
        
        if(self.pageLoadError == -1){
            
            errorMessage = @"The application could not connect to Cinema Center's website for schedule data, please check network connection and restart the application";
        }
        else{
            
            errorMessage = @"The application had trouble retrieving schedule data from Cinema Center's website, this is error is our fault. Please check back soon after we solve the problem";
        }
                        
        cell.showtimesTextView.text = errorMessage;
        
        return cell;
    }
    
    NSRange range = [dayText rangeOfString:@"\n"];
    
    NSString *dateText = [dayText substringToIndex:range.location-1];
        
    NSString *showtimesText = [dayText substringFromIndex:range.location+1];
    
    cell.dateLabel.text = dateText;
    
    cell.showtimesTextView.text = showtimesText;
        
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 175.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(int)parseWebsiteText
{
    self.pageLoadError = NO;
    
    self.dictionaryOfDaysText = [[NSMutableDictionary alloc]init];
    
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
    
    for (int i = 0; i < [self.htmlOriginalSymbolArray count]; i++) {
        
        NSString *originalSymbol = [self.htmlOriginalSymbolArray objectAtIndex:i];
        
        NSString *replacedSymbol = [self.htmlReplacedSymbolArray objectAtIndex:i];
        
        ccPageContent = [ccPageContent stringByReplacingOccurrencesOfString:originalSymbol withString:replacedSymbol];
    }
    
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
    [format setDateFormat:@"MMMM dd"];
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

@end
