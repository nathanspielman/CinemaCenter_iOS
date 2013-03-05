//
//  NDSMoviePostersViewController.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/9/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NDSMoviePostersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
