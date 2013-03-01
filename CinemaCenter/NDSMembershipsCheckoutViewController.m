//
//  NDSMembershipsCheckoutViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 2/4/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSMembershipsCheckoutViewController.h"
#import "NDSShowtimeInfoCell.h"
#import "NDSTicketTypeCell.h"
#import "NDSSubtotalCell.h"
#import "NDSReceipt.h"
#import "NDSAppDelegate.h"

#define paykeys_filename @"paykeys.plist"
#define receipts_archive @"receipts_archive"

@interface NDSMembershipsCheckoutViewController ()

@property (nonatomic, assign) double subtotal;
@property (strong, nonatomic) NSMutableArray *arrayOfMembershipTypes;
@property (strong, nonatomic) NSMutableArray *arrayOfMembershipPrices;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfMembershipTypes;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfMembershipPrices;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfMembershipTypeQuantities;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfMembershipTypeTotals;
@property (nonatomic, assign) BOOL paymentSuccess;
@property (nonatomic, strong) PayPalPayment *currentPayment;
@property (strong, nonatomic) NSMutableDictionary *payKeysDictionary;
@property (strong, nonatomic) NSMutableArray *receiptsArray;

@property (nonatomic, assign) BOOL mailingMembership;

@end

@implementation NDSMembershipsCheckoutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    
    self.arrayOfMembershipTypes = ((NDSAppDelegate *)[[UIApplication sharedApplication]delegate]).arrayOfMembershipTypes;

    self.arrayOfMembershipPrices = ((NDSAppDelegate *)[[UIApplication sharedApplication]delegate]).arrayOfMembershipPrices;
    
    self.dictionaryOfMembershipTypes = [[NSMutableDictionary alloc]init];
    self.dictionaryOfMembershipPrices = [[NSMutableDictionary alloc]init];
    self.dictionaryOfMembershipTypeQuantities = [[NSMutableDictionary alloc]init];
    self.dictionaryOfMembershipTypeTotals = [[NSMutableDictionary alloc]init];
    
    NSNumber *initialQuantity = [NSNumber numberWithInt:0];
    
    int k = 0, j = 0;
        
    for (int i = 0; i < [self.arrayOfMembershipTypes count]; i++) {
        
        NSString *membershipType = [self.arrayOfMembershipTypes objectAtIndex:i];
        NSNumber *membershipPrice = [self.arrayOfMembershipPrices objectAtIndex:i];
        NSString *UIMembershipTypeKey = [[NSString alloc]initWithFormat:@"MembershipType%d-%d", k, j];
        
        [self.dictionaryOfMembershipTypes setObject:membershipType forKey:UIMembershipTypeKey];
        [self.dictionaryOfMembershipPrices setObject:membershipPrice forKey:UIMembershipTypeKey];
        [self.dictionaryOfMembershipTypeQuantities setObject:initialQuantity forKey:membershipType];
        [self.dictionaryOfMembershipTypeTotals setObject:initialQuantity forKey:membershipType];
        
        if ( (k == 0 && j == 3) || (k == 1 && j == 0) ) {
            k++;
            j = -1;
        }
        
        j++;
    }
    
    self.subtotal = 0.0;
    self.subtotalTextField.text = @"$0.00";
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tableView.showsHorizontalScrollIndicator = NO;
}

- (void)storeReceipt:(NDSReceipt*)receipt withPayKey:(NSString*)payKey
{
    NDSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSError *error;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"NDSReceipt" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(payKey = %@)", payKey];
    
    [request setPredicate:pred];
    
    NSManagedObject *theReceipt = nil;
    
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if (objects != nil) {
        
        if ([objects count] > 0){
            theReceipt = [objects objectAtIndex:0];
        }
        else{
            theReceipt = [NSEntityDescription insertNewObjectForEntityForName:@"NDSReceipt" inManagedObjectContext:context];
        }
        
        NSNumber *num = [NSNumber numberWithBool:receipt.isMembershipReceipt];
        
        [theReceipt setValue:num forKey:@"isMembershipReceipt"];
        [theReceipt setValue:receipt.event forKey:@"event"];
        [theReceipt setValue:receipt.eventDate forKey:@"eventDate"];
        [theReceipt setValue:receipt.purchaseDate forKey:@"purchaseDate"];
        [theReceipt setValue:receipt.payKey forKey:@"payKey"];
        [theReceipt setValue:receipt.paymentCurrency forKey:@"paymentCurrency"];
        [theReceipt setValue:receipt.subTotal forKey:@"subtotal"];
        [theReceipt setValue:receipt.recipient forKey:@"recipient"];
        [theReceipt setValue:receipt.description forKey:@"paymentDescription"];
        [theReceipt setValue:receipt.customId forKey:@"customId"];
        [theReceipt setValue:receipt.merchantName forKey:@"merchantName"];
        [theReceipt setValue:receipt.ipnUrl forKey:@"ipnUrl"];
        [theReceipt setValue:receipt.memo forKey:@"memo"];
        [theReceipt setValue:receipt.dictionaryOfPurchaseTypeQuantities forKey:@"dictionaryOfPurchaseTypeQuantities"];
        [theReceipt setValue:receipt.dictionaryOfPurchaseTypeTotals forKey:@"dictionaryOfPurchaseTypeTotals"];
    }
    
    [context save:&error];
}

- (void)loadReceipts
{
    //Get the paykeys array
    NSString *filePath = [self dataFilePathForFile: paykeys_filename];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        
        self.payKeysDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    }
    else{
        
        self.payKeysDictionary = [[NSMutableDictionary alloc]init];
    }
    
    //Get the receipts archive
    self.receiptsArray = [[NSMutableArray alloc]initWithCapacity:[self.payKeysDictionary count]];
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self dataFilePathForFile:receipts_archive]];
    
    if (data == NULL) {
        return;
    }
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    
    for (id payKey in self.payKeysDictionary) {
        
        [self.receiptsArray addObject: [unarchiver decodeObjectForKey:[self.payKeysDictionary objectForKey:payKey]]];
    }
    
    [unarchiver finishDecoding];
}

- (void)saveReceiptsForNewReceipt:(NDSReceipt*)receipt withPayKey:(NSString*)payKey
{
    [self loadReceipts];
    
    //Save the receipt
    NSMutableData *data = [[NSMutableData alloc] init];
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    
    int i = 0;
    for (id payKey in self.payKeysDictionary) {
        
        NDSReceipt *receipt = [self.receiptsArray objectAtIndex:i];
        
        [archiver encodeObject:receipt forKey:payKey];
        
        i++;
    }
    
    [archiver encodeObject:receipt forKey:payKey];
    
    [archiver finishEncoding];
    
    [data writeToFile:[self dataFilePathForFile:receipts_archive] atomically:YES];
    
    //Save paykeys array
    [self.payKeysDictionary setObject:payKey forKey:payKey];
    
    [self.payKeysDictionary writeToFile:[self dataFilePathForFile:paykeys_filename] atomically:YES];
}

- (NSString *)dataFilePathForFile:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)valueChangedForUIStepper:(UIStepper *)sender
{
    int value = (int)[sender value];
    
    NSString *membershipType = [(UITextField *)[[sender superview]viewWithTag:3]text];
    
    NSNumber *quantity = [NSNumber numberWithInt:value];
    
    [self.dictionaryOfMembershipTypeQuantities setObject:quantity forKey:membershipType];
    
    [self calculateSubtotal];
}

- (IBAction)valueChangedForUISegmentedControl:(UISegmentedControl *)sender
{
    self.mailingMembership = (int)[sender selectedSegmentIndex];
}

- (void)calculateSubtotal
{
    double subtotal = 0.0;
    
    for (int i = 0; i < [self.arrayOfMembershipTypes count]; i++) {
        
        NSString *membershipType = [self.arrayOfMembershipTypes objectAtIndex:i];
        
        int membershipQuantity = [[self.dictionaryOfMembershipTypeQuantities objectForKey:membershipType]intValue];
        double membershipPrice = [[self.arrayOfMembershipPrices objectAtIndex:i]doubleValue];
        
        double membershipTotal = membershipQuantity * membershipPrice;
        
        [self.dictionaryOfMembershipTypeTotals setObject:[NSNumber numberWithDouble:membershipTotal] forKey:membershipType];
        
        subtotal += membershipTotal;
    }
    
    self.subtotal = subtotal;
    
    NDSSubtotalCell *cell = (NDSSubtotalCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    
    cell.subtotalTextField.text = [[NSString alloc]initWithFormat:@"$%.02f", self.subtotal];
    
    [self.tableView reloadData];
}

- (NSString*)currentPaymentDescription
{
    NSMutableString *description = [[NSMutableString alloc]initWithString:@""];
        
    for (int i = 0; i < [self.dictionaryOfMembershipTypeQuantities count]; i++) {
        
        NSString *membershipType = [self.arrayOfMembershipTypes objectAtIndex:i];
        
        int membershipQuantity = [[self.dictionaryOfMembershipTypeQuantities objectForKey:membershipType]intValue];
        
        if (membershipQuantity > 0) {
            
            NSString *purchasedMembershipDescription = [[NSString alloc]initWithFormat:@"%@: %d\n", membershipType, membershipQuantity];
            
            [description appendString:purchasedMembershipDescription];
        }
    }
    
    return description;
}

- (void)payWithPayPal
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMMM dd, yyyy HH:mm"];
    
    NSDate *now = [[NSDate alloc] init];
    
    self.purchaseDate = [format stringFromDate:now];
    
    PayPal *ppMEP = [PayPal getPayPalInst];
    
    if (self.mailingMembership) {
        
        ppMEP.shippingEnabled = YES;
    }else{
        
        ppMEP.shippingEnabled = NO;
    }
    
    self.currentPayment = [[PayPalPayment alloc] init];
    
    self.currentPayment.paymentCurrency = @"USD";
    
    self.currentPayment.paymentType = TYPE_GOODS;
    
    self.currentPayment.subTotal = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:self.subtotal];
    
    self.currentPayment.recipient = @"fortwaynecinemacenter@paypal.com";
    
    self.currentPayment.merchantName = @"Fort Wayne Cinema Center";
    
    self.currentPayment.description = [self currentPaymentDescription];
    
    self.currentPayment.invoiceData = [[PayPalInvoiceData alloc] init];
        
    [ppMEP checkoutWithPayment:self.currentPayment];
}

- (void)paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)paymentStatus
{
    if(paymentStatus == STATUS_COMPLETED){
        
        /*USED FOR TESTING*/
        int payKeyCount = ((NDSAppDelegate *)[[UIApplication sharedApplication]delegate]).payKeyCount;
        payKey = [payKey stringByAppendingString:[NSString stringWithFormat:@"%d", payKeyCount]];
        payKeyCount++;
        ((NDSAppDelegate *)[[UIApplication sharedApplication]delegate]).payKeyCount = payKeyCount;
        
        self.paymentSuccess = YES;
        
        NDSReceipt *receipt = [[NDSReceipt alloc]initWithPayPalPayment:self.currentPayment];
        
        NSString *eventName = nil;
        
        if (self.mailingMembership) {
            eventName = @"Membership Purchase (Mail)";
        }
        else{
            eventName = @"Membership Purchase (Pick Up)";
        }
        
        receipt.event = eventName;
        receipt.eventDate = self.purchaseDate;
        receipt.purchaseDate = self.purchaseDate;
        receipt.payKey = payKey;
        receipt.dictionaryOfPurchaseTypeQuantities = self.dictionaryOfMembershipTypeQuantities;
        receipt.dictionaryOfPurchaseTypeTotals = self.dictionaryOfMembershipTypeTotals;
        
        receipt.isMembershipReceipt = YES;
        
        //[self saveReceiptsForNewReceipt:receipt withPayKey:payKey];
        
        [self storeReceipt:receipt withPayKey:payKey];
    }
}

- (void)paymentFailedWithCorrelationID:(NSString *)correlationID
{
    
}

- (void)paymentCanceled
{
    
}

- (void)paymentLibraryExit
{
    NSString *msg = nil;
    
    if (self.mailingMembership) {
        msg = @"Thanks for becoming a Member of Cinema Center! Your Membership is being mailed to you.";
    }
    else{
        msg = @"Thanks for becoming a Member of Cinema Center! Your Membership is waiting at Cinema Center for you.";
    }
    
    if(self.paymentSuccess){
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"You're In!"
                                                          message:msg
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
    
    self.paymentSuccess = NO;
    
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*if (section == 0) {
        return 1;
    }*/
    if (section == 0) {
        return 4;
    }
    else if (section == 1){
        return 1;
    }
    else if (section == 2){
        return 3;
    }
    else {
        return 3;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Basic Memberships";
    }
    else if (section == 1) {
        return @"Upgrade Membership";
    }
    else if (section == 2) {
        return @"Patron Memberships";
    }
    else if (section == 3) {
        return @"Checkout";
    }
    else {
        return @"";
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellTableIdentifier = nil;
    
    int section = [indexPath section];
    
    int row = [indexPath row];
    
    /*if (section == 0 && row == 0) {
        
        CellTableIdentifier = @"ShowtimeInfoCell";
        
        NDSShowtimeInfoCellController *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        
        cell.dateLabel.text = self.dateText;
        
        cell.showtimeLabel.text = self.showtimeText;
                
        return cell;
    }*/
    
    if (section == 3 && row == 0) {
        
        CellTableIdentifier = @"SubtotalCell";
        
        NDSSubtotalCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        
        cell.subtotalTextField.text = [[NSString alloc]initWithFormat:@"$%.02f", self.subtotal];
        
        return cell;
    }
    
    if (section == 3 && row == 1) {
        
        CellTableIdentifier = @"DeliveryOptionCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
                
        return cell;
    }
    
    if (section == 3 && row == 2) {
        
        CellTableIdentifier = @"PayPalButtonCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        
        UIButton *payPalButton = [[PayPal getPayPalInst] getPayButtonWithTarget:self andAction:@selector(payWithPayPal) andButtonType:BUTTON_278x43 andButtonText:BUTTON_TEXT_PAY];
        
        payPalButton.tag = 5;
        
        [[cell viewWithTag:5] removeFromSuperview];
        
        CGFloat buttonWidth = [payPalButton bounds].size.width;
        CGFloat buttonHeight = [payPalButton bounds].size.height;
        
        CGFloat cellWidth = [cell bounds].size.width;
        CGFloat cellHeight = [cell bounds].size.height;
        
        int x = (cellWidth - buttonWidth)/2;
        int y = (cellHeight - buttonHeight)/2;
        
        payPalButton.frame = CGRectMake(x, y, 278, 43);
        
        [cell addSubview:payPalButton];
        
        return cell;
    }
    
    /*CellTableIdentifier = @"TicketTypeOriginalCell";
    
    NDSTicketTypeCellController *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    
    NSString *ticketTypeKey = [[NSString alloc]initWithFormat:@"MembershipType%d-%d", section, row];
    
    NSString *ticketTypeLabel = [self.dictionaryOfMembershipTypes objectForKey:ticketTypeKey];
    
    cell.ticketTypeLabel.text = ticketTypeLabel;
        
    NSString *quantityText = [[self.dictionaryOfMembershipTypeQuantities objectForKey:ticketTypeLabel]stringValue];
    
    cell.ticketQuantityTextField.text = quantityText;
    
    return cell;*/
    
    CellTableIdentifier = @"TicketTypeCell";
    
    NDSTicketTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    
    NSString *membershipTypeKey = [[NSString alloc]initWithFormat:@"MembershipType%d-%d", section, row];
    
    NSString *membershipType = [self.dictionaryOfMembershipTypes objectForKey:membershipTypeKey];
    
    cell.ticketTypeLabel.text = membershipType;
    
    NSString *membershipTypeQuantity = [[self.dictionaryOfMembershipTypeQuantities objectForKey:membershipType]stringValue];
    
    cell.ticketQuantityTextField.text = membershipTypeQuantity;
    
    NSNumber *membershipTypePrice = [self.dictionaryOfMembershipPrices objectForKey:membershipTypeKey];
    
    cell.ticketPriceLabel.text = [[NSString alloc]initWithFormat:@"x $%d =", [membershipTypePrice intValue]];
    
    NSNumber *membershipTypeTotal = [self.dictionaryOfMembershipTypeTotals objectForKey:membershipType];
    
    cell.ticketTotalTextField.text = [[NSString alloc]initWithFormat:@"$%d", [membershipTypeTotal intValue]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    
    int row = [indexPath row];
    
    /*if(section == 0 && row == 0){
        
        return 90.0;
    }*/
    
    if (section == 3 && row == 0) {
        
        return 45.0;
    }
    
    if (section == 3 && (row == 1 || row == 2)) {
        
        return 60.0;
    }
    
    return 80.0;//90.0;
    
}

@end
