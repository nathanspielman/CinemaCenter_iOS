//
//  NDSScheduleFilmCell.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/3/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NDSScheduleFilmCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *scheduleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UITextView *showtimesTextView;

- (void)centerText;

@end
