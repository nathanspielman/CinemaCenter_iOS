//
//  NDSMovieTicketsShowtimesViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/29/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSMovieTicketsShowtimesViewController.h"
#import "NDSMovieTicketsCheckoutViewController.h"
#import "NDSAppDelegate.h"

@interface NDSMovieTicketsShowtimesViewController ()

@property (strong, nonatomic) NSMutableDictionary *dictionaryOfShowtimes;

@end

@implementation NDSMovieTicketsShowtimesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    
    self.dictionaryOfShowtimes = [[NSMutableDictionary alloc]init];
        
    int i = 1;
    
    BOOL end = NO;
    
    while (true) {
        
        NSRange range1, range2, trimRange, foundRange;
        
        NSString *showtime;
        
        range1 = [self.showtimesText rangeOfString:@"\n"];
        
        if(range1.location != NSNotFound){
            
            foundRange = NSMakeRange(0, range1.location+1);
            
            showtime = [self.showtimesText substringWithRange:foundRange];
            
            trimRange = NSMakeRange(range1.location+1, [self.showtimesText length] - range1.location-1);
            
            self.showtimesText = [self.showtimesText substringWithRange:trimRange];
            
            range2 = [self.showtimesText rangeOfString:@"\n"];
        }
        
        if(range1.location == NSNotFound || range2.location == NSNotFound){
            end = YES;
        }
        
        BOOL foundInteger = NO;
        
        for(int j = 0; j < 10; j++){
            
            NSString *integer = [[NSString alloc]initWithFormat:@"%d", j];
            
            foundRange = [showtime rangeOfString:integer];
            
            if (foundRange.location != NSNotFound) {
                foundInteger = YES;
                break;
            }
        }
        
        BOOL foundColon = NO;
        
        foundRange = [showtime rangeOfString:@":"];
        
        if (foundRange.location != NSNotFound) {
            foundColon = YES;
        }
        
        if (!foundInteger && !foundColon) {
            
            if (end) {
                break;
            }
            
            continue;
        }
        
        NSString *showtimeKey = [[NSString alloc]initWithFormat:@"showtime%d", i];
        
        showtime = [showtime substringFromIndex:0];
        
        [self.dictionaryOfShowtimes setObject:showtime forKey:showtimeKey];
        
        i++;
        
        if (end) {
            break;
        }
    }
    
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
    
    int row = [[self.tableView indexPathForSelectedRow]row]+1;
    
    NSString *showtimeKey = [[NSString alloc]initWithFormat:@"showtime%d", row];
    
    NSString *showtimeText = [self.dictionaryOfShowtimes objectForKey:showtimeKey];
    
    destination.showtimeText = showtimeText;
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
    int count = [self.dictionaryOfShowtimes count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"ShowtimeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString *showtimeKey = [[NSString alloc]initWithFormat:@"showtime%d", [indexPath row]+1];
    
    NSString *showtimeText = [self.dictionaryOfShowtimes objectForKey:showtimeKey];
    
    cell.textLabel.opaque = NO;
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.text = showtimeText;
    
    return cell;
}

@end
