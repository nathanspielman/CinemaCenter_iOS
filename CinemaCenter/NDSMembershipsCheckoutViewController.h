//
//  NDSMembershipsCheckoutViewController.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 2/4/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPal.h"
#import "PayPalPayment.h"

@interface NDSMembershipsCheckoutViewController : UIViewController <PayPalPaymentDelegate, UITableViewDataSource, UITableViewDelegate>

@property (copy, nonatomic) NSString *dateText;
@property (nonatomic, copy) NSString *showtimeText;

@end
