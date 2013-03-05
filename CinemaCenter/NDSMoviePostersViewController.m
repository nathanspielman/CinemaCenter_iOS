//
//  NDSMoviePostersViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/9/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSMoviePostersViewController.h"
#import "NDSMovieDescriptionViewController.h"
#import "NDSAppDelegate.h"

@interface NDSMoviePostersViewController ()

@property (strong,nonatomic) NSMutableDictionary *moviePosterImages;
@property (strong,nonatomic) NSMutableDictionary *movieDescriptions;
@property (strong,nonatomic) NSArray *htmlOriginalSymbolArray;
@property (strong,nonatomic) NSArray *htmlReplacedSymbolArray;
@property (assign, nonatomic) NSInteger pageLoadError;
@property (nonatomic) BOOL loading;

@end

@implementation NDSMoviePostersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    
    self.moviePosterImages = [[NSMutableDictionary alloc]init];
    self.movieDescriptions = [[NSMutableDictionary alloc]init];
    
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
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    
    if (self.pageLoadError || self.loading) {
        
        self.loading = YES;
        
        [self.tableView reloadData];
    }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.loading || self.pageLoadError){
        return 1;
    }
    
    return [self.moviePosterImages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    
    NSString *CellIdentifier = @"MoviePosterCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSString *movieKey = [[NSString alloc]initWithFormat:@"movie%d", indexPath.row];
    
    UIImageView *moviePoster = (UIImageView *)[cell viewWithTag:5];
    
    moviePoster.image = [self.moviePosterImages objectForKey:movieKey];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NDSMovieDescriptionViewController *destination = segue.destinationViewController;
    
    int row = [[self.tableView indexPathForSelectedRow]row];
    
    NSString *movieKey = [[NSString alloc]initWithFormat:@"movie%d", row];
    
    NSString *movieText = [self.movieDescriptions objectForKey:movieKey];
    
    NSRange range;
    
    for (int i = 0; i < 2; i++) {
        
        range = [movieText rangeOfString:@"\n"];
        
        movieText = [movieText substringFromIndex:range.location+1];
    }
    
    range = [movieText rangeOfString:@"\n"];
        
    NSString *movieTitle = [movieText substringToIndex:range.location-1];
        
    destination.movieTitle = movieTitle;
        
    destination.movieDescription = movieText;
}

-(int)parseWebsiteText
{
    self.pageLoadError = NO;
    
    //self.moviePosterImages = [[NSMutableDictionary alloc]init];
    //self.movieDescriptions = [[NSMutableDictionary alloc]init];
    
    NSString *ccWebLink = nil;
    NSString *pageHeading = nil;
    
    if([self.tabBarItem.title isEqualToString:@"Now Showing"]){
        ccWebLink = @"http://cinemacenter.org/movies/movies/now-showing.php";
        pageHeading = @"Now Showing";
    }
    else if([self.tabBarItem.title isEqualToString:@"Coming Soon"]){
        ccWebLink = @"http://cinemacenter.org/movies/movies/coming-attractions.php";
        pageHeading = @"Coming Attractions";
    }
    
    NSURL *ccURL = [NSURL URLWithString:ccWebLink];
    
    NSError *error;
        
    NSString *ccPageContent = [NSString stringWithContentsOfURL:ccURL encoding:NSASCIIStringEncoding error:&error];
    
    if(ccPageContent == nil){
        self.pageLoadError = YES;
        return -1;
    }
    
    NSRange searchRange, foundRange, trimRange;
    
    
    //Get rid of all the stuff before searchString variable
    
    foundRange = [ccPageContent rangeOfString:pageHeading];
    
    if(foundRange.location == NSNotFound){
        self.pageLoadError = YES;
        return -2;
    }
    
    NSRange pageHeadingRange = NSMakeRange(foundRange.location, ([ccPageContent length] - foundRange.location));
    
    ccPageContent = [ccPageContent substringWithRange:pageHeadingRange];
    
    
    
    //Get rid of all the stuff after "<!-- End of PageLime Text Stack -->"
    
    foundRange = [ccPageContent rangeOfString:@"<!-- End of PageLime Text Stack -->"];
    
    if(foundRange.location == NSNotFound){
        self.pageLoadError = YES;
        return -3;
    }
    
    pageHeadingRange = NSMakeRange(0, foundRange.location);
    
    ccPageContent = [ccPageContent substringWithRange:pageHeadingRange];
    
    for (int i = 0; i < [self.htmlOriginalSymbolArray count]; i++) {
        
        NSString *originalSymbol = [self.htmlOriginalSymbolArray objectAtIndex:i];
        
        NSString *replacedSymbol = [self.htmlReplacedSymbolArray objectAtIndex:i];
        
        ccPageContent = [ccPageContent stringByReplacingOccurrencesOfString:originalSymbol withString:replacedSymbol];
    }
    
    int movieCount = 0;
    
    BOOL finished = NO;
    
    while (true) {
        
        if(finished){
            break;
        }
        
        NSString *movieKey = [[NSString alloc]initWithFormat:@"movie%d", movieCount];
        
        searchRange = NSMakeRange(0, [ccPageContent length]);
        
        foundRange = [ccPageContent rangeOfString:@"<img" options:NSCaseInsensitiveSearch range:searchRange];
        
        if(foundRange.location == NSNotFound){
            self.pageLoadError = YES;
            return -4;
        }
        
        NSUInteger imgLocation = foundRange.location;
        
        foundRange = [ccPageContent rangeOfString:@"src" options:NSCaseInsensitiveSearch range:searchRange];
        
        if(foundRange.location == NSNotFound){
            self.pageLoadError = YES;
            return -5;
        }
        
        NSUInteger srcLocation = foundRange.location;
        
        searchRange = NSMakeRange(imgLocation, srcLocation-imgLocation);
        
        foundRange = [ccPageContent rangeOfString:@"Poster" options:NSCaseInsensitiveSearch range:searchRange];
        
        if (foundRange.location == NSNotFound) {
                        
            ccPageContent = [ccPageContent substringFromIndex:srcLocation+3];
            continue;
        }
        
        searchRange = NSMakeRange(0, [ccPageContent length]);
        
        foundRange = [ccPageContent rangeOfString:@"src" options:NSCaseInsensitiveSearch range:searchRange];
        
        if(foundRange.location == NSNotFound){
            self.pageLoadError = YES;
            return -6;
        }
        
        trimRange = NSMakeRange(foundRange.location, [ccPageContent length]-foundRange.location);
        
        ccPageContent = [ccPageContent substringWithRange:trimRange];
        
        searchRange = NSMakeRange(0, [ccPageContent length]);
        
        //First quotation mark surrounding image web link
        foundRange = [ccPageContent rangeOfString:@"\"" options:NSCaseInsensitiveSearch range:searchRange];
        
        if(foundRange.location == NSNotFound){
            self.pageLoadError = YES;
            return -7;
        }
        
        NSUInteger trimLocation = foundRange.location + 1;
        
        NSUInteger trimLength = [ccPageContent length] - trimLocation;
        
        trimRange = NSMakeRange(trimLocation, trimLength);
        
        ccPageContent = [ccPageContent substringWithRange:trimRange];
        
        //Second quotation mark surrounding image web link
        searchRange = NSMakeRange(0, [ccPageContent length]);
        
        foundRange = [ccPageContent rangeOfString:@"\"" options:NSCaseInsensitiveSearch range:searchRange];
        
        if(foundRange.location == NSNotFound){
            self.pageLoadError = YES;
            return -8;
        }
        
        trimLocation = 0;
        
        trimLength = foundRange.location;
        
        trimRange = NSMakeRange(trimLocation, trimLength);
        
        NSString *posterURL = [ccPageContent substringWithRange:trimRange];
        
        trimLocation = foundRange.location;
        
        trimLength = [ccPageContent length] - trimLocation;
        
        trimRange = NSMakeRange(trimLocation, trimLength);
        
        ccPageContent = [ccPageContent substringWithRange:trimRange];
        
        foundRange = [ccPageContent rangeOfString:@">"];
        
        if(foundRange.location == NSNotFound){
            self.pageLoadError = YES;
            return -9;
        }
        
        trimRange = NSMakeRange(foundRange.location+1, [ccPageContent length]-foundRange.location-1);
        
        ccPageContent = [ccPageContent substringWithRange:trimRange];
        
        //Add the movie poster image to the array
        
        NSURL *URL = [NSURL URLWithString:posterURL];
        
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:URL]];
        
        [self.moviePosterImages setObject:image forKey:movieKey];
        
        //Find the next movie poster image web link location
        
        searchRange = NSMakeRange(0, [ccPageContent length]);
        
        foundRange = [ccPageContent rangeOfString:@"src" options:NSCaseInsensitiveSearch range:searchRange];
        
        if (foundRange.location == NSNotFound) {
            
            foundRange.location = [ccPageContent length];
            
            finished = YES;
        }
        
        trimRange = NSMakeRange(0, foundRange.location);
        
        NSString *movieDescription = [ccPageContent substringWithRange:trimRange];
        
        NSRange firstRange = [movieDescription rangeOfString:@"<"];
        
        while (firstRange.location != NSNotFound) {
            
            NSRange secondRange = [movieDescription rangeOfString:@">"];
            
            if(secondRange.location == NSNotFound){
                
                trimRange = NSMakeRange(0, firstRange.location-1);
                
                movieDescription = [movieDescription substringWithRange:trimRange];
                
                break;
            }
            
            int length = secondRange.location - firstRange.location;
            
            NSRange replaceRange = NSMakeRange(firstRange.location, length+1);
            
            movieDescription = [movieDescription stringByReplacingCharactersInRange:replaceRange withString:@" "];
            
            firstRange = [movieDescription rangeOfString:@"<"];
        }
        
        [self.movieDescriptions setObject:movieDescription forKey:movieKey];
        
        movieCount++;
        
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
    
    return 398.0;
}

@end
