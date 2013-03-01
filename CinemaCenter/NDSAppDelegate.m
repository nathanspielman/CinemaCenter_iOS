//
//  NDSAppDelegate.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/7/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSAppDelegate.h"
#import "PayPal.h"

#import "PayPalPayment.h"
#import "PayPalAdvancedPayment.h"
#import "PayPalAmounts.h"
#import "PayPalReceiverAmounts.h"
#import "PayPalAddress.h"
#import "PayPalInvoiceItem.h"

@implementation NDSAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_NONE];
        
    self.htmlOriginalSymbolArray = [[NSArray alloc]initWithObjects:@"&nbsp;", @"&amp;", @"&ldquo;", @"&rdquo;", @"&ndash;", @"&rsquo;", @"&uuml;", @"&ouml;", @"&mdash;", nil];
    
    self.htmlReplacedSymbolArray = [[NSArray alloc]initWithObjects:@" ", @"&", @"\"", @"\"", @"—", @"\'", @"ü", @"ö", @"—", nil];
    
    self.arrayOfTicketTypes = [[NSMutableArray alloc]initWithObjects:@"General: $8.00", @"Student/Senior: $6.50", @"Regular Member: $5.00", @"Student/Senior Member: $4.00", @"IPFW/St. Francis Student w/ID: $3.00", nil];
    
    self.arrayOfTicketPrices = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithDouble:8.00], [NSNumber numberWithDouble:6.50], [NSNumber numberWithDouble:5.00], [NSNumber numberWithDouble:4.00], [NSNumber numberWithDouble:3.00], nil];
    
    self.arrayOfMembershipTypes = [[NSMutableArray alloc]initWithObjects:@"Student: $20.00", @"Individual: $40.00", @"Dual: $75.00", @"Family: $100.00", @"Film Buff: $150.00", @"Producer (Individual Patron): $250.00", @"Director (Dual Patron): $500.00", @"Mogul (Mega Patron): $1000.00", nil];
    
    self.arrayOfMembershipPrices = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithDouble:20.00], [NSNumber numberWithDouble:40.00], [NSNumber numberWithDouble:75.00], [NSNumber numberWithDouble:100.00], [NSNumber numberWithDouble:150.00], [NSNumber numberWithDouble:250.00], [NSNumber numberWithDouble:500.00], [NSNumber numberWithDouble:1000.00], nil];
    
    self.arrayOfMembershipDetails = [[NSMutableArray alloc]initWithObjects:@"1/2 off regular admission price for 1 person, free popcorn.", @"$3 off regular admission price for 1 person, free popcorn.", @"$3 off regular admission price for 2 adults, free popcorn.", @"$3 off regular admission price for 2 adults and children within a household (or grandchildren), free popcorn.", @"10 movie passes, $3 off regular admission price for 2 adults, free popcorn.", @"Free movies for 1 adult for a year, free popcorn.", @"Free movies for 2 adults for a year, free popcorn.", @"Free movies for 2 adults and children within a household (or grandchildren) for a year, free popcorn and free admission to all Cinema Center events (Artament, Oscar Party and other fundraisers). No kids? Bring up to a party of four to all movies and Cinema Center events for a year.", nil];
        
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //NSDate *timePassed = [NSDate dateWithTimeInterval:60 sinceDate:self.backgroundDate];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Core_Data" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Core_Data.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
