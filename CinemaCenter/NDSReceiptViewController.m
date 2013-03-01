//
//  NDSReceiptViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 2/11/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSReceiptViewController.h"
#import "NDSShowtimeInfoCell.h"
#import "NDSProofOfPurchaseCell.h"
#import "NDSSubtotalCell.h"
#import "NDSTicketTypeCell.h"
#import "NDSAppDelegate.h"

@interface NDSReceiptViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSMutableArray *arrayOfTicketTypes;
@property (strong, nonatomic) NSMutableArray *arrayOfTicketPrices;
@property (strong, nonatomic) NSMutableArray *arrayOfPurchasedTicketIndices;

@property (strong, nonatomic) NSMutableDictionary *dictionaryOfTicketPrices;

@end

@implementation NDSReceiptViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];

    [self.dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock:) userInfo:nil repeats:YES];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    if (self.receipt.isMembershipReceipt) {
        self.arrayOfTicketTypes = ((NDSAppDelegate *)[[UIApplication sharedApplication]delegate]).arrayOfMembershipTypes;
        self.arrayOfTicketPrices = ((NDSAppDelegate *)[[UIApplication sharedApplication]delegate]).arrayOfMembershipPrices;
    }
    else{
        self.arrayOfTicketTypes = ((NDSAppDelegate *)[[UIApplication sharedApplication]delegate]).arrayOfTicketTypes;
        self.arrayOfTicketPrices = ((NDSAppDelegate *)[[UIApplication sharedApplication]delegate]).arrayOfTicketPrices;
    }
    
    self.dictionaryOfTicketPrices = [[NSMutableDictionary alloc]init];
    
    for (int i = 0; i < [self.arrayOfTicketTypes count]; i++) {
        
        NSString *ticketType = [self.arrayOfTicketTypes objectAtIndex:i];
        
        NSNumber *ticketPrice = [self.arrayOfTicketPrices objectAtIndex:i];
        
        [self.dictionaryOfTicketPrices setObject:ticketPrice forKey:ticketType];
    }
    
    self.arrayOfPurchasedTicketIndices = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [self.receipt.dictionaryOfPurchaseTypeQuantities count]; i++) {
        
        NSString *ticketType = [self.arrayOfTicketTypes objectAtIndex:i];
        
        int ticketQuantity = [[self.receipt.dictionaryOfPurchaseTypeQuantities objectForKey:ticketType]intValue];
        
        if (ticketQuantity > 0) {
            
            [self.arrayOfPurchasedTicketIndices addObject:[NSNumber numberWithInt:i]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateClock:(id)sender
{
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.receipt.isMembershipReceipt){
        return 3 + [self.arrayOfPurchasedTicketIndices count];
    }
    
    return 2 + [self.arrayOfPurchasedTicketIndices count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellTableIdentifier = nil;
    
    int row = [indexPath row];
    
    if (row == 0) {
        
        CellTableIdentifier = @"ShowtimeInfoCell";
        
        NDSShowtimeInfoCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        
        cell.showtimeLabel.text = self.receipt.event;
        
        cell.dateLabel.text = self.receipt.eventDate;
        
        return cell;
    }
    
    if (row == [self.arrayOfPurchasedTicketIndices count]+1) {
        
        CellTableIdentifier = @"SubtotalCell";
        
        NDSSubtotalCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        
        cell.subtotalTextField.text = [[NSString alloc]initWithFormat:@"$%.02f",[self.receipt.subTotal doubleValue]];
        
        return cell;
    }
    
    if (row == [self.arrayOfPurchasedTicketIndices count]+3) {
        
        CellTableIdentifier = @"ProofOfPurchaseCell";
        
        NDSProofOfPurchaseCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        
        cell.purchaseDateTextField.text = self.receipt.purchaseDate;
        
        NSString *currentTime = [self.dateFormatter stringFromDate: [NSDate date]];
        
        cell.currentTimeTextField.text = currentTime;
        
        return cell;
    }
    
    if (row == [self.arrayOfPurchasedTicketIndices count]+2) {
        
        CellTableIdentifier = @"PayKeyCell";
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        
        cell.textLabel.text = self.receipt.payKey;
        
        return cell;
    }
    
    /*CellTableIdentifier = @"TicketTypeOriginalCell";
    
    NDSTicketTypeCellController *cell = [self.tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    
    int purchasedTicketIndex = [[self.arrayOfPurchasedTicketIndices objectAtIndex:row-1]intValue];
    
    NSString *ticketType = [self.arrayOfTicketTypes objectAtIndex:purchasedTicketIndex];
    
    cell.ticketTypeLabel.text = ticketType;
    
    cell.ticketQuantityTextField.text = [[self.receipt.dictionaryOfPurchaseTypeQuantities objectForKey:ticketType]stringValue];
    
    cell.ticketTotalTextField.text = [[NSString alloc]initWithFormat:@"$%.02f",[[self.receipt.dictionaryOfPurchaseTypeTotals objectForKey:ticketType]doubleValue]];
    
    return cell;*/
    
    CellTableIdentifier = @"TicketTypeCell";
    
    NDSTicketTypeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    
    int purchasedTicketIndex = [[self.arrayOfPurchasedTicketIndices objectAtIndex:row-1]intValue];
    
    NSString *ticketType = [self.arrayOfTicketTypes objectAtIndex:purchasedTicketIndex];
    
    cell.ticketTypeLabel.text = ticketType;
    
    cell.ticketQuantityTextField.text = [[self.receipt.dictionaryOfPurchaseTypeQuantities objectForKey:ticketType]stringValue];
    
    NSNumber *ticketTypePrice = [self.dictionaryOfTicketPrices objectForKey:ticketType];
    
    cell.ticketPriceLabel.text = [[NSString alloc]initWithFormat:@"x $%.02f =", [ticketTypePrice doubleValue]];
    
    cell.ticketTotalTextField.text = [[NSString alloc]initWithFormat:@"$%.02f",[[self.receipt.dictionaryOfPurchaseTypeTotals objectForKey:ticketType]doubleValue]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    int row = [indexPath row];
    
    if(row == 0){
        
        return 50.0;
    }
    
    if (row == [self.arrayOfPurchasedTicketIndices count]+1) {
        
        return 32.0;
    }
    
    if (row == [self.arrayOfPurchasedTicketIndices count]+2) {
        
        return 67.0;
    }
    
    return 58.0;
    
}

@end
