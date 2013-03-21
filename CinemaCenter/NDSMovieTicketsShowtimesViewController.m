//
//  NDSMovieTicketsShowtimesViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/29/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSMovieTicketsShowtimesViewController.h"
#import "NDSMovieTicketsCheckoutViewController.h"

@interface NDSMovieTicketsShowtimesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfShowtimes;

@end

@implementation NDSMovieTicketsShowtimesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    
    NSMutableArray *showtimesToKeep = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.showtimesArray count]; i++) {
        
        NSString *showtime = [self.showtimesArray objectAtIndex:i];
        
        NSRange foundRange = [showtime rangeOfString:@":"];
        
        if (foundRange.location != NSNotFound) {
            
            for(int j = 0; j < 10; j++){
                
                NSString *integer = [[NSString alloc] initWithFormat:@"%d", j];
                
                NSRange foundRange = [showtime rangeOfString:integer];
                
                if (foundRange.location != NSNotFound) {
                    
                    [showtimesToKeep addObject:showtime];
                    break;
                }
            }
        }
    }
    
    self.showtimesArray = [showtimesToKeep copy];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NDSMovieTicketsCheckoutViewController *destination = segue.destinationViewController;
    
    destination.dateText = self.dateText;
    
    int row = [[self.tableView indexPathForSelectedRow]row];
    
    NSString *showtimeKey = [self.showtimesArray objectAtIndex:row];
        
    destination.showtimeText = showtimeKey;
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.dateText;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    int count = [self.showtimesArray count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"ShowtimeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString *showtimeKey = [self.showtimesArray objectAtIndex:indexPath.row];
        
    cell.textLabel.opaque = NO;
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.text = showtimeKey;
    
    return cell;
}

@end
