//
//  NDSMovieTicketsCheckoutViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/29/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSMovieTicketsCheckoutViewController.h"
#import "NDSShowtimeInfoCell.h"
#import "NDSTicketTypeCell.h"
#import "NDSSubtotalCell.h"
#import "NDSReceipt.h"
#import "NDSAppDelegate.h"

#define paykeys_filename @"paykeys.plist"
#define receipts_archive @"receipts_archive"

@interface NDSMovieTicketsCheckoutViewController ()

@property (nonatomic, assign) double subtotal;
@property (strong, nonatomic) NSMutableArray *arrayOfTicketTypes;
@property (strong, nonatomic) NSMutableArray *arrayOfTicketPrices;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfTicketTypes;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfTicketPrices;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfTicketTypeQuantities;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfTicketTypeTotals;
@property (nonatomic, assign) BOOL paymentSuccess;
@property (nonatomic, strong) PayPalPayment *currentPayment;
@property (strong, nonatomic) NSMutableDictionary *payKeysDictionary;
@property (strong, nonatomic) NSMutableArray *receiptsArray;

@end

@implementation NDSMovieTicketsCheckoutViewController

- (void)viewDidLoad
{    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    
    self.arrayOfTicketTypes = ((NDSAppDelegate *)[[UIApplication sharedApplication]delegate]).arrayOfTicketTypes;
    
    self.arrayOfTicketPrices = ((NDSAppDelegate *)[[UIApplication sharedApplication]delegate]).arrayOfTicketPrices;
    
    self.dictionaryOfTicketTypes = [[NSMutableDictionary alloc]init];
    self.dictionaryOfTicketPrices = [[NSMutableDictionary alloc]init];
    self.dictionaryOfTicketTypeQuantities = [[NSMutableDictionary alloc]init];
    self.dictionaryOfTicketTypeTotals = [[NSMutableDictionary alloc]init];
    
    NSNumber *initialQuantity = [NSNumber numberWithInt:0];
    
    for (int i = 0; i < [self.arrayOfTicketTypes count]; i++) {
        
        NSString *ticketType = [self.arrayOfTicketTypes objectAtIndex:i];
        NSNumber *ticketPrice = [self.arrayOfTicketPrices objectAtIndex:i];
        NSString *UITicketTypeKey = [[NSString alloc]initWithFormat:@"TicketType%d-%d", 1, i];
        
        [self.dictionaryOfTicketTypes setObject:ticketType forKey:UITicketTypeKey];
        [self.dictionaryOfTicketPrices setObject:ticketPrice forKey:UITicketTypeKey];
        [self.dictionaryOfTicketTypeQuantities setObject:initialQuantity forKey:ticketType];
        [self.dictionaryOfTicketTypeTotals setObject:initialQuantity forKey:ticketType];
    }
    
    self.subtotal = 0.0;
    self.subtotalTextField.text = @"$0.00";
}

- (void)viewWillAppear:(BOOL)animated
{    
    self.tableView.showsHorizontalScrollIndicator = NO;
}

- (void)storeReceiptInCoreData:(NDSReceipt*)receipt withPayKey:(NSString*)payKey
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
                
        [theReceipt setValue:[NSNumber numberWithBool:receipt.isMembershipReceipt] forKey:@"isMembershipReceipt"];
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

/*- (void)loadReceipts
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
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)valueChangedForUIStepper:(UIStepper *)sender
{
    int value = (int)[sender value];
    
    NSString *ticketType = [(UITextField *)[[sender superview]viewWithTag:3]text];
    
    NSNumber *quantity = [NSNumber numberWithInt:value];
    
    [self.dictionaryOfTicketTypeQuantities setObject:quantity forKey:ticketType];
    
    [self calculateSubtotal];
    
}

- (void)calculateSubtotal
{
    double subtotal = 0.0;
    
    for (int i = 0; i < [self.arrayOfTicketTypes count]; i++) {
        
        NSString *ticketType = [self.arrayOfTicketTypes objectAtIndex:i];
        
        int ticketQuantity = [[self.dictionaryOfTicketTypeQuantities objectForKey:ticketType]intValue];
        double ticketPrice = [[self.arrayOfTicketPrices objectAtIndex:i]doubleValue];
        
        double ticketTotal = ticketQuantity * ticketPrice;
        
        [self.dictionaryOfTicketTypeTotals setObject:[NSNumber numberWithDouble:ticketTotal] forKey:ticketType];
        
        subtotal += ticketTotal;
    }
    
    self.subtotal = subtotal;
        
    NDSSubtotalCell *cell = (NDSSubtotalCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
        
    cell.subtotalTextField.text = [[NSString alloc]initWithFormat:@"$%.02f", self.subtotal];
    
    [self.tableView reloadData];
}

- (NSString*)currentPaymentDescription
{    
    NSMutableString *description = [[NSMutableString alloc]initWithFormat:@"Showtime: %@Date: %@Purchase Date: %@\n", self.showtimeText, self.dateText, self.purchaseDate];
    
    for (int i = 0; i < [self.dictionaryOfTicketTypeQuantities count]; i++) {
        
        NSString *ticketType = [self.arrayOfTicketTypes objectAtIndex:i];
        
        int ticketQuantity = [[self.dictionaryOfTicketTypeQuantities objectForKey:ticketType]intValue];
        
        if (ticketQuantity > 0) {
            
            NSString *purchasedTicketDescription = [[NSString alloc]initWithFormat:@"%@: %d\n", ticketType, ticketQuantity];
            
            [description appendString:purchasedTicketDescription];
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
    
    ppMEP.shippingEnabled = NO;
    
    self.currentPayment = [[PayPalPayment alloc] init];
    
    self.currentPayment.paymentCurrency = @"USD";
    
    self.currentPayment.paymentType = TYPE_SERVICE;
    
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
        
        receipt.event = self.showtimeText;
        receipt.eventDate = self.dateText;
        receipt.purchaseDate = self.purchaseDate;
        receipt.payKey = payKey;
        receipt.dictionaryOfPurchaseTypeQuantities = self.dictionaryOfTicketTypeQuantities;
        receipt.dictionaryOfPurchaseTypeTotals = self.dictionaryOfTicketTypeTotals;
        
        receipt.isMembershipReceipt = NO;
 
        //[self saveReceiptsForNewReceipt:receipt withPayKey:payKey];
        [self storeReceiptInCoreData:receipt withPayKey:payKey];
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
    if(self.paymentSuccess){
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"See You at the Movies!"
                                                          message:@"When you arrive at the Cinema Center box office, please show us your ticket receipt. To pull up your receipt, click on the 'More' tab and navigate to 'Receipts'."
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
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 5;
    }
    else {
        return 2;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Showtime & Date";
    }
    else if (section == 1) {
        return @"Ticket Options";
    }
    else if (section == 2) {
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
    
    if (section == 0 && row == 0) {
        
        CellTableIdentifier = @"ShowtimeInfoCell";
        
        NDSShowtimeInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        
        cell.dateLabel.text = self.dateText;
        
        cell.showtimeLabel.text = self.showtimeText;
                
        return cell;
    }
    
    if (section == 2 && row == 0) {
        
        CellTableIdentifier = @"SubtotalCell";
        
        NDSSubtotalCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        
        cell.subtotalTextField.text = [[NSString alloc]initWithFormat:@"$%.02f", self.subtotal];
        
        return cell;
    }
    
    if (section == 2 && row == 1) {
        
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
    
    NSString *ticketTypeKey = [[NSString alloc]initWithFormat:@"TicketType%d-%d", section, row];
    
    NSString *ticketTypeLabel = [self.dictionaryOfTicketTypes objectForKey:ticketTypeKey];
    
    cell.ticketTypeLabel.text = ticketTypeLabel;
    
    NSString *quantityText = [[self.dictionaryOfTicketTypeQuantities objectForKey:ticketTypeLabel]stringValue];
    
    cell.ticketQuantityTextField.text = quantityText;
    
    return cell;*/
    
    CellTableIdentifier = @"TicketTypeCell";
    
    NDSTicketTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    
    NSString *ticketTypeKey = [[NSString alloc]initWithFormat:@"TicketType%d-%d", section, row];
    
    NSString *ticketType = [self.dictionaryOfTicketTypes objectForKey:ticketTypeKey];
        
    cell.ticketTypeLabel.text = ticketType;
    
    NSString *ticketTypeQuantity = [[self.dictionaryOfTicketTypeQuantities objectForKey:ticketType]stringValue];
    
    cell.ticketQuantityTextField.text = ticketTypeQuantity;
    
    NSNumber *ticketTypePrice = [self.dictionaryOfTicketPrices objectForKey:ticketTypeKey];
    
    cell.ticketPriceLabel.text = [[NSString alloc]initWithFormat:@"x $%.02f =", [ticketTypePrice doubleValue]];
    
    NSNumber *ticketTypeTotal = [self.dictionaryOfTicketTypeTotals objectForKey:ticketType];
    
    cell.ticketTotalTextField.text = [[NSString alloc]initWithFormat:@"$%.02f", [ticketTypeTotal doubleValue]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    
    int row = [indexPath row];
    
    if(section == 0 && row == 0){
        
        return 90.0;
    }
    
    if (section == 2 && row == 0) {
        
        return 45.0;
    }
    
    if (section == 2 && row == 1) {
        
        return 60.0;
    }
    
    return 80.0;//90.0;
}

@end
