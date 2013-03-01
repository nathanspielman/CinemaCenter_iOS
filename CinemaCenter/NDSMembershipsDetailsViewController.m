//
//  NDSMembershipsDetailsViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 2/18/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSMembershipsDetailsViewController.h"
#import "NDSMembershipDetailCell.h"
#import "NDSAppDelegate.h"

@interface NDSMembershipsDetailsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arrayOfMembershipTypes;
@property (strong, nonatomic) NSMutableArray *arrayOfMembershipDetails;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfMembershipTypes;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfMembershipDetails;

@end

@implementation NDSMembershipsDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.arrayOfMembershipTypes = ((NDSAppDelegate *)[[UIApplication sharedApplication]delegate]).arrayOfMembershipTypes;
    
    self.arrayOfMembershipDetails = ((NDSAppDelegate *)[[UIApplication sharedApplication]delegate]).arrayOfMembershipDetails;
    
    self.dictionaryOfMembershipTypes = [[NSMutableDictionary alloc]init];
    self.dictionaryOfMembershipDetails = [[NSMutableDictionary alloc]init];
    
    int k = 0, j = 0;
    
    for (int i = 0; i < [self.arrayOfMembershipTypes count]; i++) {
        
        NSString *membershipType = [self.arrayOfMembershipTypes objectAtIndex:i];
        NSString *membershipDetail = [self.arrayOfMembershipDetails objectAtIndex:i];
        NSString *UIMembershipTypeKey = [[NSString alloc]initWithFormat:@"MembershipType%d-%d", k, j];
        
        [self.dictionaryOfMembershipTypes setObject:membershipType forKey:UIMembershipTypeKey];
        [self.dictionaryOfMembershipDetails setObject:membershipDetail forKey:UIMembershipTypeKey];
        
        if ( (k == 0 && j == 3) || (k == 1 && j == 0) ) {
            k++;
            j = -1;
        }
        
        j++;
    }
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
    /*if (section == 0) {
     return 1;
     }*/
    if (section == 0) {
        return 4;
    }
    else if (section == 1){
        return 1;
    }
    else {
        return 3;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
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
    else {
        return @"";
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellTableIdentifier = nil;
    
    int section = [indexPath section];
    
    int row = [indexPath row];
    
    if (section == 0 && row == 3) {
        CellTableIdentifier = @"MembershipDetailCell3";
    }
    else if (section == 2 && (row == 0 || row == 1) ) {
        CellTableIdentifier = @"MembershipDetailCell1";
    }
    else if (section == 2 && row == 2) {
        CellTableIdentifier = @"MembershipDetailCell4";
    }
    else {
        CellTableIdentifier = @"MembershipDetailCell2";
    }
    
    NDSMembershipDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    
    NSString *membershipTypeKey = [[NSString alloc]initWithFormat:@"MembershipType%d-%d", section, row];
    
    NSString *membershipType = [self.dictionaryOfMembershipTypes objectForKey:membershipTypeKey];
        
    NSString *membershipDetail = [self.dictionaryOfMembershipDetails objectForKey:membershipTypeKey];
    
    cell.membershipTypeLabel.text = membershipType;
        
    cell.membershipDetailLabel.text = membershipDetail;
        
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    
    int row = [indexPath row];
    
    if(section == 0 && row == 3){
        
        return 95.0;
    }
    
    if (section == 2 && (row == 0 || row == 1) ) {
        
        return 66.0;
    }
    
    if (section == 2 && row == 2) {
        
        return 144.0;
    }
    
    return 81.0;
}

@end
