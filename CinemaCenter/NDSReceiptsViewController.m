//
//  NDSReceiptsViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 2/10/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSReceiptsViewController.h"
#import "NDSReceipt.h"
#import "NDSReceiptCell.h"
#import "NDSReceiptViewController.h"
#import "NDSAppDelegate.h"

#define paykeys_filename @"paykeys.plist"
#define receipts_archive @"receipts_archive"

@interface NDSReceiptsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *payKeysDictionary;
@property (strong, nonatomic) NSMutableArray *receiptsArray;
@property (strong, nonatomic) NSNumberFormatter *formatter;


@end

@implementation NDSReceiptsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.formatter = [[NSNumberFormatter alloc] init];

    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    
    //[self clearReceipts];
    
    //[self removeReceiptsFromCoreData];
            
    //[self loadReceipts];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    //[self loadReceipts];
    
    [self restoreReceiptsFromCoreData];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)restoreReceiptsFromCoreData
{
    NDSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"NDSReceipt" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if (objects == nil) {
        
        self.receiptsArray = [[NSMutableArray alloc]init];
        return;
    }
    
    self.receiptsArray = [[NSMutableArray alloc]initWithCapacity:[objects count]];
    
    for(NSManagedObject* receipt in objects){
        
        NDSReceipt *theReceipt = [[NDSReceipt alloc]init];
        
        theReceipt.isMembershipReceipt = [[receipt valueForKey:@"isMembershipReceipt"]boolValue];
        theReceipt.event = [receipt valueForKey:@"event"];
        theReceipt.eventDate = [receipt valueForKey:@"eventDate"];
        theReceipt.purchaseDate = [receipt valueForKey:@"purchaseDate"];
        theReceipt.payKey = [receipt valueForKey:@"payKey"];
        theReceipt.paymentCurrency = [receipt valueForKey:@"paymentCurrency"];
        theReceipt.subTotal = [receipt valueForKey:@"subtotal"];
        theReceipt.recipient = [receipt valueForKey:@"recipient"];
        theReceipt.description = [receipt valueForKey:@"description"];
        theReceipt.customId = [receipt valueForKey:@"customId"];
        theReceipt.merchantName = [receipt valueForKey:@"merchantName"];
        theReceipt.ipnUrl = [receipt valueForKey:@"ipnUrl"];
        theReceipt.memo = [receipt valueForKey:@"memo"];
        theReceipt.dictionaryOfPurchaseTypeQuantities = [receipt valueForKey:@"dictionaryOfPurchaseTypeQuantities"];
        theReceipt.dictionaryOfPurchaseTypeTotals = [receipt valueForKey:@"dictionaryOfPurchaseTypeTotals"];
        
        [self.receiptsArray addObject:theReceipt];
    }
}

- (void)removeReceiptsFromCoreData
{
    NDSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"NDSReceipt" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if (objects == nil) {        
        return;
    }
        
    for(NSManagedObject* receipt in objects){
        
        [context deleteObject:receipt];
    }
    
    [context save:&error];
    
    [self restoreReceiptsFromCoreData];
    
    [self.tableView reloadData];
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

- (void)clearReceipts
{
    NSError *error;
    
    [[NSFileManager defaultManager] removeItemAtPath:[self dataFilePathForFile:receipts_archive] error: &error];
    
    [[NSFileManager defaultManager] removeItemAtPath:[self dataFilePathForFile:paykeys_filename] error: &error];
    
    [self loadReceipts];
    
    [self.tableView reloadData];
    
    //self.tableView.editing = YES;
}

- (NSString *)dataFilePathForFile:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}*/

- (IBAction)clearPressed:(id)sender
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Warning!"
                                                      message:@"Clearing will erase all of your saved receipts. Do NOT clear if you still need a receipt for proof of purchase. Cinema Center cannot guarantee entry if you do not have proof of purchase."
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Clear", nil];
        
    [message show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        //[self clearReceipts];
        
        [self removeReceiptsFromCoreData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NDSReceiptViewController *destination = segue.destinationViewController;
    
    int row = [[self.tableView indexPathForSelectedRow]row];
    
    int index = [self.receiptsArray count]-1-row;
    
    NDSReceipt *receipt = [self.receiptsArray objectAtIndex:index];
    
    destination.receipt = receipt;
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return [self.payKeysDictionary count];
    return [self.receiptsArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellTableIdentifier = @"ReceiptCell";
    
    NDSReceiptCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    
    int row = [indexPath row];
    
    int index = [self.receiptsArray count]-1-row;
    
    NDSReceipt *receipt = [self.receiptsArray objectAtIndex:index];
        
    [self.formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    if (receipt.isMembershipReceipt) {
        
        cell.showtimeLabel.text = @"Membership Purchase";
        cell.dateLabel.text = receipt.purchaseDate;
    }
    else{
        
        cell.showtimeLabel.text = receipt.event;
        cell.dateLabel.text = receipt.eventDate;
    }
        
    cell.subtotalLabel.text = [[NSString alloc]initWithFormat:@"%@", [self.formatter stringFromNumber:receipt.subTotal]];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

@end
