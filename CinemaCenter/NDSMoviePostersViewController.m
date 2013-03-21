//
//  NDSMoviePostersViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/9/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSMoviePostersViewController.h"
#import "NDSMovieDescriptionViewController.h"
#import "TFHpple.h"
#import "TFHppleElement.h"
#import "NDSAppDelegate.h"

@interface NDSMoviePostersViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL loading;
@property (assign, nonatomic) NSInteger loadingError;
@property (strong, nonatomic) NSArray *moviePostersArray;
@property (strong, nonatomic) NSArray *movieDescriptionsArray;

@end

@implementation NDSMoviePostersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
        
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
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    
    if (self.loadingError || self.loading) {
        
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
    if (self.loading || self.loadingError){
        return 1;
    }
    
    return [self.moviePostersArray count];
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
    
    NSString *CellIdentifier = @"MoviePosterCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView *moviePoster = (UIImageView *)[cell viewWithTag:5];
    
    moviePoster.image = [self.moviePostersArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NDSMovieDescriptionViewController *destination = segue.destinationViewController;
    
    int row = [[self.tableView indexPathForSelectedRow]row];
        
    NSString *movieText = [self.movieDescriptionsArray objectAtIndex:row];
    
    /*NSRange range;
    
    for (int i = 0; i < 2; i++) {
        
        range = [movieText rangeOfString:@"\n"];
        
        movieText = [movieText substringFromIndex:range.location+1];
    }
    
    range = [movieText rangeOfString:@"\n"];
        
    NSString *movieTitle = [movieText substringToIndex:range.location-1];
        
    destination.movieTitle = movieTitle;*/
        
    destination.movieDescription = movieText;
}

- (int)parseWebsiteHTML
{
    self.loadingError = NO;
    
    NSMutableArray *moviePostersArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *movieDescriptionsArray = [[NSMutableArray alloc] init];
    
    NSString *url = nil;
    NSString *navigationBarTitle = nil;
    NSString *searchXPath = nil;
    
    if([self.tabBarItem.title isEqualToString:@"Now Showing"]){
        url = @"http://cinemacenter.org/movies/movies/now-showing.php";
        navigationBarTitle = @"Now Showing";
        //searchXPath = @"//div[@class='cms-editable  pl_stacks_in_47_page29 ']";
        searchXPath = @"//div[@id='pl_stacks_in_47_page29']";
    }
    else if([self.tabBarItem.title isEqualToString:@"Coming Soon"]){
        url = @"http://cinemacenter.org/movies/movies/coming-attractions.php";
        navigationBarTitle = @"Coming Attractions";
        //searchXPath = @"//div[@class='cms-editable  pl_stacks_in_58_page14 ']";
        searchXPath = @"//div[@id='pl_stacks_in_58_page14']";
    }
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    
    if (data == nil) {
        self.loadingError = YES;
        return -1;
    }
    
    TFHpple *document = [[TFHpple alloc] initWithHTMLData:data];
    
    if (document == nil) {
        self.loadingError = YES;
        return -2;
    }
                
    NSArray *searchPathElements = [document searchWithXPathQuery:searchXPath];
    
    if (searchPathElements == nil || [searchPathElements count] == 0) {
        self.loadingError = YES;
        return -3;
    }
    
    NSArray *elements = [[searchPathElements objectAtIndex:0] children];
        
    if (elements == nil || [elements count] == 0) {
        self.loadingError = YES;
        return -4;
    }
    
    BOOL foundMovie = NO;
    
    NSString *movieDescription = @"";
    
    for (TFHppleElement *element in elements) {
        
        NSArray *imgChildren = [self imgChildrenFromElement:element];
        
        if ([imgChildren count] > 0) {
            
            if (foundMovie) {
                
                [movieDescriptionsArray addObject:movieDescription];
                
                movieDescription = @"";
            }
            
            for (TFHppleElement *imgChild in imgChildren) {
                
                NSDictionary *attributes = [imgChild attributes];
                
                NSString *title = [attributes valueForKey:@"title"];
                
                if (title != nil && [title rangeOfString:@"Poster"].location != NSNotFound) {
                    
                    NSURL *moviePosterURL = [NSURL URLWithString:[attributes valueForKey:@"src"]];
                    
                    UIImage *moviePoster = [UIImage imageWithData:[NSData dataWithContentsOfURL:moviePosterURL]];
                    
                    [moviePostersArray addObject:moviePoster];
                    
                    foundMovie = YES;
                }
                else{
                    
                    foundMovie = NO;
                }
            }
        }
        else if (foundMovie){
            
            movieDescription = [self createMovieDescription:movieDescription fromElement:element];
        }
    }
    
    if (foundMovie) {
        
        [movieDescriptionsArray addObject:movieDescription];
        
        movieDescription = @"";
    }
    
    self.moviePostersArray = [moviePostersArray copy];
    
    self.movieDescriptionsArray = [movieDescriptionsArray copy];
    
    return 0;
}

- (NSArray *)imgChildrenFromElement:(TFHppleElement *)element
{
    NSArray *imgChildren = [element childrenWithTagName:@"img"];
    
    if ([imgChildren count] > 0) {
        return imgChildren;
    }
    
    if ([imgChildren count] == 0 && [[element children] count] > 0) {
        
        NSArray *elementChildren = [element children];
        
        for (TFHppleElement *elementChild in elementChildren) {
            
            NSArray *imgElementChildren = [self imgChildrenFromElement:elementChild];
            
            if ([imgElementChildren count] > 0) {
                return imgElementChildren;
            }
        }
    }
    
    return imgChildren;
}

- (NSString *)createMovieDescription:(NSString *)movieDescription fromElement:(TFHppleElement *)element
{
    NSArray *children = [element children];
    
    for (TFHppleElement *child in children) {
        
        NSString *text = [child text];
        
        if (text != nil) {
            movieDescription = [[movieDescription stringByAppendingString:text] stringByAppendingString:@"\n"];
        }
        
        NSString *content = [child content];
        
        if (content != nil) {
            movieDescription = [[movieDescription stringByAppendingString:content] stringByAppendingString:@"\n"];
        }
        
        if ([[child children] count] > 0) {
            [self createMovieDescription:movieDescription fromElement:child];
        }
    }
    
    return movieDescription;
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
    
    return 398.0;
}

@end
