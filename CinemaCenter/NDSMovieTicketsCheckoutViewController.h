//
//  NDSMovieTicketsCheckoutViewController.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/29/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPal.h"
#import "PayPalPayment.h"

@interface NDSMovieTicketsCheckoutViewController : UIViewController <PayPalPaymentDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *dateText;
@property (nonatomic, copy) NSString *showtimeText;

@end
