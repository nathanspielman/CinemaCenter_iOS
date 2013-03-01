//
//  NDSReceipt.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 2/11/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayPalPayment.h"

@interface NDSReceipt : PayPalPayment <NSCoding, NSCopying>

@property (nonatomic, assign) BOOL isMembershipReceipt;

@property (nonatomic, strong) NSString *event;
@property (nonatomic, strong) NSString *eventDate;
@property (nonatomic, strong) NSString *purchaseDate;
@property (nonatomic, strong) NSString *payKey;

@property (nonatomic, strong) NSMutableDictionary *dictionaryOfPurchaseTypeQuantities;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfPurchaseTypeTotals;

- (id)initWithPayPalPayment:(PayPalPayment *)payPalPayment;

@end