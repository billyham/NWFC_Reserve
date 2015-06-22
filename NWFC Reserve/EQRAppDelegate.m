//
//  EQRAppDelegate.m
//  NWFC Reserve
//
//  Created by Japhy Ryder on 11/6/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import "EQRAppDelegate.h"
#import "EQRColors.h"
#import "EQRGlobals.h"
#import "EQRStaffUserManager.h"
#import "EQRWebData.h"
#import "EQRContactNameItem.h"
#import "EQRInboxLeftTableVC.h"
#import "EQRModeManager.h"

@interface EQRAppDelegate ()

@property (strong, nonatomic) UITabBarController* myTabBarController;

@end

@implementation EQRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //set system user defaults
//    NSDictionary* EQRWebDataUrl = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   @"http://dhanagan02262.local/nwfc/", @"url",
//                                   nil];
    
//    NSDictionary* EQRWebDataUrl = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   @"http://EducationAssistant-5.local/nwfc/", @"url",
//                                   nil];
    
    NSDictionary* EQRWebDataUrl = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"http://www.kitschplayer.com/nwfc/", @"url",
                                   nil];
    
    NSDictionary* EQRCurrentTermCode = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"F13", @"term",
                                        nil];
    
    NSDictionary* EQRCurrentCampTermCode = [NSDictionary dictionaryWithObjectsAndKeys:
                                            @"SC14", @"campTerm",
                                            nil];
    
    NSDictionary* EQRDefaultStaffUserKeyID = [NSDictionary dictionaryWithObjectsAndKeys:
                                              @"", @"staffUserKey"
                                              , nil];
    
    NSDictionary* EQRKioskModeIsOn = @{@"kioskModeIsOn":@"no"};
    
    NSDictionary *EQRDemoModeIsOn = @{@"demoModeIsOn":@"no"};
    
    
    NSDictionary* appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 EQRWebDataUrl, @"url",
                                 EQRCurrentTermCode, @"term",
                                 EQRCurrentCampTermCode, @"campTerm",
                                 EQRDefaultStaffUserKeyID, @"staffUserKey",
                                 EQRKioskModeIsOn, @"kioskModeIsOn",
                                 EQRDemoModeIsOn, @"demoModeIsOn",
                                 nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    
    //instantiate system colors
    EQRColors* myColors = [EQRColors sharedInstance];
    [myColors loadColors];
    
    //instantiate staffUserManager and assign as delegate for root view tabBarController
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    UITabBarController* thisTabVC = (UITabBarController*)self.window.rootViewController;
    thisTabVC.delegate = staffUserManager;
    
    //set staffUser to last user
    NSString* keyID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"staffUserKey"] objectForKey:@"staffUserKey"];
    
    if (![keyID isEqualToString:@""]){
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        
        NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", keyID, nil];
        NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
        __block EQRContactNameItem* contactObject;
        [webData queryWithLink:@"EQGetContactNameWithKey.php" parameters:topArray class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
            
            if ([muteArray count] > 0){
                
                contactObject = (EQRContactNameItem*)[muteArray objectAtIndex:0];
            }
        }];
        
        //__________ERROR HANDLING WHEN NO CURRENTSTAFFUSER EXISTS______________
        //This isn't doing it...
//        if (contactObject == nil){
//            
//            contactObject = [[EQRContactNameItem alloc] init];
//            contactObject.key_id = EQRErrorCode88888888;
//        }
        
        //set the current staffUser as the last previous user
        staffUserManager.currentStaffUser = contactObject;
    }
    
    //set to demo mode if it was last in demo mode
    EQRModeManager* modeManager = [EQRModeManager sharedInstance];
    NSString *currentDemoMode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"demoModeIsOn"] objectForKey:@"demoModeIsOn"];
    if ([currentDemoMode isEqualToString:@"yes"]){
        modeManager.isInDemoMode = YES;
    }
    
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
    
    //set to kiosk mode if it was last in kiosk mode
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    NSString* currentKioskMode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"kioskModeIsOn"] objectForKey:@"kioskModeIsOn"];
    if ([currentKioskMode isEqualToString:@"yes"]){
        [staffUserManager goToKioskMode:YES];
    }
    
    
    //set preferred display modes on splitviews
    UIApplication* thisApp = [UIApplication sharedApplication];
    NSArray* originalArray = [(UITabBarController*)thisApp.keyWindow.rootViewController viewControllers];
    for (UIViewController* VC in originalArray){
        if ([VC class] == [UISplitViewController class]){   //must be a split view
            
            //need to discern inbox from settings
            if ([VC.title isEqualToString:@"Inbox"]){   //must be inbox
                [(UISplitViewController *)VC setPreferredDisplayMode:UISplitViewControllerDisplayModeAutomatic];
                NSLog(@"Identifed as Inbox");
            } else if ([VC.title isEqualToString:@"Settings"]){  //must be settings
                NSLog(@"identified as Settings, this is the title: %@", VC.title);
                [(UISplitViewController *)VC setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];
            }
        }
    }

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "David-Vincent-Hanagan.Core_Data_Sample" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Gear" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Gear.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}












@end
