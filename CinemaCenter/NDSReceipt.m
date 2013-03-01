//
//  NDSReceipt.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 2/11/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSReceipt.h"

#define IsMembershipReceiptKey @"IsMembershipReceipt"

#define PaymentCurrencyKey @"PaymentCurrency"
#define SubTotalKey @"SubTotal"
#define RecipientKey @"Recipient"

#define PaymentTypeKey @"PaymentType"
#define PaymentSubTypeKey @"PaymentSubType"
#define InvoiceDataKey @"InvoiceData"
#define DescriptionKey @"Description"
#define CustomIDKey @"CustomID"
#define MerchantNameKey @"MerchantName"
#define IpnUrlKey @"IpnUrl"
#define MemoKey @"Memo"

#define EventKey @"Event"
#define EventDateKey @"EventDate"
#define PurchaseDateKey @"PurchaseDate"
#define PayKeyKey @"PayKey"

#define DictionaryOfPurchaseTypeQuantitiesKey @"DictionaryOfPurchaseTypeQuantities"
#define DictionaryOfPurchaseTypeTotalsKey @"DictionaryOfPurchaseTypeTotals"

@implementation NDSReceipt

- (id)initWithPayPalPayment:(PayPalPayment *)payPalPayment
{
    if (self = [super init]) {
        
        self.paymentCurrency = payPalPayment.paymentCurrency;
        self.subTotal = payPalPayment.subTotal;
        self.recipient = payPalPayment.recipient;
        
        self.paymentType = payPalPayment.paymentType;
        self.paymentSubType = payPalPayment.paymentSubType;
        self.invoiceData = payPalPayment.invoiceData;
        self.description = payPalPayment.description;
        self.customId = payPalPayment.customId;
        self.merchantName = payPalPayment.merchantName;
        self.ipnUrl = payPalPayment.ipnUrl;
        self.memo = payPalPayment.memo;
    }
    
    return self;
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeBool:self.isMembershipReceipt forKey:IsMembershipReceiptKey];
    
    [encoder encodeObject:self.paymentCurrency forKey:PaymentCurrencyKey];
    [encoder encodeObject:self.subTotal forKey:SubTotalKey];
    [encoder encodeObject:self.recipient forKey:RecipientKey];
    
    //[encoder encodeObject:self.paymentType forKey:PaymentTypeKey];
    //[encoder encodeObject:self.paymentSubType forKey:PaymentSubTypeKey];
    //[encoder encodeObject:self.invoiceData forKey:InvoiceDataKey];
    [encoder encodeObject:self.description forKey:DescriptionKey];
    [encoder encodeObject:self.customId forKey:CustomIDKey];
    [encoder encodeObject:self.merchantName forKey:MerchantNameKey];
    [encoder encodeObject:self.ipnUrl forKey:IpnUrlKey];
    [encoder encodeObject:self.memo forKey:MemoKey];
    
    [encoder encodeObject:self.event forKey:EventKey];
    [encoder encodeObject:self.eventDate forKey:EventDateKey];
    [encoder encodeObject:self.purchaseDate forKey:PurchaseDateKey];
    [encoder encodeObject:self.payKey forKey:PayKeyKey];
    
    [encoder encodeObject:self.dictionaryOfPurchaseTypeQuantities forKey:DictionaryOfPurchaseTypeQuantitiesKey];
    [encoder encodeObject:self.dictionaryOfPurchaseTypeTotals forKey:DictionaryOfPurchaseTypeTotalsKey];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        
        self.isMembershipReceipt = [decoder decodeBoolForKey:IsMembershipReceiptKey];
        
        self.paymentCurrency = [decoder decodeObjectForKey:PaymentCurrencyKey];
        self.subTotal = [decoder decodeObjectForKey:SubTotalKey];
        self.recipient = [decoder decodeObjectForKey:RecipientKey];
        
        //self.paymentType = [decoder decodeObjectForKey:PaymentTypeKey];
        //self.paymentSubType = [decoder decodeObjectForKey:PaymentSubTypeKey];
        //self.invoiceData = [decoder decodeObjectForKey:InvoiceDataKey];
        self.description = [decoder decodeObjectForKey:DescriptionKey];
        self.customId = [decoder decodeObjectForKey:CustomIDKey];
        self.merchantName = [decoder decodeObjectForKey:MerchantNameKey];
        self.ipnUrl = [decoder decodeObjectForKey:IpnUrlKey];
        self.memo = [decoder decodeObjectForKey:MemoKey];
        
        self.event = [decoder decodeObjectForKey:EventKey];
        self.eventDate = [decoder decodeObjectForKey:EventDateKey];
        self.purchaseDate = [decoder decodeObjectForKey:PurchaseDateKey];
        self.payKey = [decoder decodeObjectForKey:PayKeyKey];
        
        self.dictionaryOfPurchaseTypeQuantities = [decoder decodeObjectForKey:DictionaryOfPurchaseTypeQuantitiesKey];
        self.dictionaryOfPurchaseTypeTotals = [decoder decodeObjectForKey:DictionaryOfPurchaseTypeTotalsKey];
    }
    
    return self;
}

#pragma mark -
#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    NDSReceipt *copy = [[[self class] allocWithZone:zone] init];
    /*copy.isMembershipReceipt = self.isMembershipReceipt;
    copy.paymentCurrency = [self.paymentCurrency copyWithZone:zone];
    copy.subTotal = [self.subTotal copyWithZone:zone];
    copy.recipient = [self.recipient copyWithZone:zone];*/
    return copy;
}

@end
