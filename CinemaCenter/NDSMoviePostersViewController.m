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
#import "NDSCinemaCenterMovie.h"
#import "NDSCinemaCenterApiKeys.h"

@interface NDSMoviePostersViewController ()

@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL loadingError;
@property (strong, nonatomic) NSArray *arrayOfMovies;
@property (nonatomic, copy) NSString *path;

@end

@implementation NDSMoviePostersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshView)];
    
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    if([self.tabBarItem.title isEqualToString:@"Now Showing"]){
        self.path = kNowShowing;
    }
    else if([self.tabBarItem.title isEqualToString:@"Coming Soon"]){
        self.path = kComingSoon;
    }
    
    self.loading = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    
    if (self.loadingError || self.loading) {
                
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [NDSCinemaCenterMovie getAllOnSuccess:^(NSArray *movies) {
                
                self.arrayOfMovies = movies;
                
                self.loadingError = NO;
                
                self.loading = NO;
                
                [self.tableView reloadData];
                
            } failure:^(NSError *error) {
                self.loadingError = YES;
                
                self.loading = NO;
                
                [self.tableView reloadData];
            } path:self.path];
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
    
    return [self.arrayOfMovies count];
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
        
        NSString *errorMessage = @"The application could not connect to Cinema Center's website for film data, please check network connection and restart the application";
        
        textView.text = errorMessage;
        
        return cell;

    }
    
    NSString *CellIdentifier = @"MoviePosterCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView *moviePoster = (UIImageView *)[cell viewWithTag:5];
    
    moviePoster.image = [[self.arrayOfMovies objectAtIndex:indexPath.row] valueForKey:@"poster"];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NDSMovieDescriptionViewController *destination = segue.destinationViewController;
    
    int row = [[self.tableView indexPathForSelectedRow]row];
    
    NSString *movieTitle = [[self.arrayOfMovies objectAtIndex:row] valueForKey:@"title"];
        
    NSString *movieDescription = [[self.arrayOfMovies objectAtIndex:row] valueForKey:@"description"];
        
    destination.movieDescription = [[movieTitle stringByAppendingString:@"\n\n"] stringByAppendingString:movieDescription];
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
