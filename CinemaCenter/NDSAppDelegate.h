//
//  NDSAppDelegate.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/7/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NDSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong,nonatomic) NSArray *htmlOriginalSymbolArray;
@property (strong,nonatomic) NSArray *htmlReplacedSymbolArray;

@property (strong, nonatomic) NSMutableArray *arrayOfTicketTypes;
@property (strong, nonatomic) NSMutableArray *arrayOfTicketPrices;

@property (strong, nonatomic) NSMutableArray *arrayOfMembershipTypes;
@property (strong, nonatomic) NSMutableArray *arrayOfMembershipPrices;
@property (strong, nonatomic) NSMutableArray *arrayOfMembershipDetails;

@property (nonatomic, assign) int payKeyCount;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
