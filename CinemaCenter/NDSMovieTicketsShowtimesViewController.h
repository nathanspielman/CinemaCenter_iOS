//
//  NDSMovieTicketsShowtimesViewController.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/29/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NDSMovieTicketsShowtimesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (copy, nonatomic) NSString *dateText;
@property (nonatomic, copy) NSString *showtimesText;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
