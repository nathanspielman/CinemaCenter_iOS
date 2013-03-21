//
//  NDSInformationViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/28/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSInformationViewController.h"
#import "NDSAppDelegate.h"

@interface NDSInformationViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NDSInformationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellTableIdentifier = nil;
    
    UITableViewCell *cell = nil;
    
    if(indexPath.row == 0){
        
        CellTableIdentifier = @"MapCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        
        cell.textLabel.text = @"Map";
        
        cell.imageView.image = [UIImage imageNamed:@"mappin.png"];
        
    }
    
    if(indexPath.row == 1){
        
        CellTableIdentifier = @"MembershipsCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        
        cell.textLabel.text = @"Memberships";
        
        cell.imageView.image = [UIImage imageNamed:@"jacket.png"];
        
    }
    
    if(indexPath.row == 2){
        
        CellTableIdentifier = @"ReceiptsCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
        
        cell.textLabel.text = @"Receipts";
        
        cell.imageView.image = [UIImage imageNamed:@"receipt.png"];
        
    }
    
    return cell;
}

@end
