//
//  NDSReceiptCell.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 2/11/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NDSReceiptCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *showtimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtotalLabel;

@end
