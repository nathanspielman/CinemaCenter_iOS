//
//  NDSTicketTypeCell.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/30/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NDSTicketTypeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *ticketTypeLabel;
@property (weak, nonatomic) IBOutlet UITextField *ticketQuantityTextField;
@property (weak, nonatomic) IBOutlet UITextField *ticketTotalTextField;
@property (weak, nonatomic) IBOutlet UILabel *ticketPriceLabel;

@end
