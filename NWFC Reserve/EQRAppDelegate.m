//
//  EQRAppDelegate.m
//  NWFC Reserve
//
//  Created by Japhy Ryder on 11/6/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import <CloudKit/CloudKit.h>
#import "EQRAppDelegate.h"
#import "EQRColors.h"
#import "EQRGlobals.h"
#import "EQRStaffUserManager.h"
#import "EQRWebData.h"
#import "EQRContactNameItem.h"
#import "EQRInboxLeftTableVC.h"
#import "EQRModeManager.h"
#import "EQRTextElement.h"

@interface EQRAppDelegate () <EQRWebDataDelegate>

@property (strong, nonatomic) UITabBarController* myTabBarController;
@property BOOL isInitialLaunch;
@property BOOL anEmailSigExists;

@end

@implementation EQRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //set system user defaults
//    NSDictionary* EQRWebDataUrl = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   @"http://dhanagan02262.local/nwfc/", @"url",
//                                   nil];
    
    NSDictionary* EQRWebDataUrl = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"http://EducationAssistant-5.local/nwfc/", @"url",
                                   nil];
    
    NSDictionary* EQRWebDataUrlBackup = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"http://www.kitschplayer.com/nwfc/", @"backupUrl",
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
    
    NSDictionary *EQRUseBackup = @{@"useBackup":@"no"};
    
    NSDictionary *EQRUseCloudKit = @{@"useCloudKit":@"no"};
    
    
    NSDictionary* appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 EQRWebDataUrl, @"url",
                                 EQRWebDataUrlBackup, @"backupUrl",
                                 EQRCurrentTermCode, @"term",
                                 EQRCurrentCampTermCode, @"campTerm",
                                 EQRDefaultStaffUserKeyID, @"staffUserKey",
                                 EQRKioskModeIsOn, @"kioskModeIsOn",
                                 EQRDemoModeIsOn, @"demoModeIsOn",
                                 EQRUseBackup, @"useBackup",
                                 EQRUseCloudKit, @"useCloudKit",
                                 nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    // Register for Remote Notifications
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeNone categories:nil];
    [application registerUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications];
    
    // Test Remote Notification
    
    //____!!!!!!  This is a Query Based subscription   !!!!______
//    NSPredicate *predicate = nil;
//    predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
//    
//    CKSubscription *subscription = [[CKSubscription alloc]
//                                   initWithRecordType:@"Contact" predicate:predicate options:CKSubscriptionOptionsFiresOnRecordCreation];
    
    //____!!!!!!  This is a Zone Based subscription   !!!!______
    CKSubscription *subscription = [[CKSubscription alloc] initWithZoneID:[[CKRecordZoneID alloc] initWithZoneName:EQRRecordZoneStandard ownerName:CKOwnerDefaultName] options:0];
    
    CKNotificationInfo *notificationInfo = [CKNotificationInfo new];
//    notificationInfo.alertLocalizationKey = @"Change in standard zone";
//    notificationInfo.shouldBadge = YES;
    notificationInfo.shouldSendContentAvailable = YES;
    
    subscription.notificationInfo = notificationInfo;
    
    CKDatabase *privateDatabase = [[CKContainer containerWithIdentifier:EQRCloudKitContainer] privateCloudDatabase];
    [privateDatabase saveSubscription:subscription completionHandler:^(CKSubscription * _Nullable subscription, NSError * _Nullable error) {
        if (error){
            NSLog(@"AppDelegate > didFinishLaunching  failed to save CloudKit subscription");
        }
    }];
    
    
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
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            
            [webData queryForStringwithAsync:@"EQGetContactNameWithKey.php" parameters:topArray completion:^(id object) {
                
                //completion block may not ever run??
                
                //set the current staffUser as the last previous user
                if (object){
                    staffUserManager.currentStaffUser = (EQRContactNameItem *)object;
                }
            }];
        });
        
        
        
        
//        __block EQRContactNameItem* contactObject;
//        [webData queryWithLink:@"EQGetContactNameWithKey.php" parameters:topArray class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
//            
//            if ([muteArray count] > 0){
//                
//                contactObject = (EQRContactNameItem*)[muteArray objectAtIndex:0];
//            }
//        }];
        
        //__________ERROR HANDLING WHEN NO CURRENTSTAFFUSER EXISTS______________
        //This isn't doing it...
//        if (contactObject == nil){
//            
//            contactObject = [[EQRContactNameItem alloc] init];
//            contactObject.key_id = EQRErrorCode88888888;
//        }
        
        //set the current staffUser as the last previous user
//        staffUserManager.currentStaffUser = contactObject;
        
        
        
        
    }
    
    //set to demo mode if it was last in demo mode
    EQRModeManager* modeManager = [EQRModeManager sharedInstance];
    NSString *currentDemoMode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"demoModeIsOn"] objectForKey:@"demoModeIsOn"];
    if ([currentDemoMode isEqualToString:@"yes"]){
        modeManager.isInDemoMode = YES;
    }
    
    //________!!!!!!!!  set default email signature   !!!!!!!!!!_______
    // first, test if a signature already exists
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    NSArray *firstArray = @[@"context", @"emailSignature"];
    NSArray *topArray = @[firstArray];
    
    SEL thisSelector = @selector(receiveTextElementForEmailSignature:);
    
    [webData queryWithAsync:@"EQGetTextElementsWithContext.php" parameters:topArray class:@"EQRTextElement" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
        
        if (isLoadingFlagUp){
            
            if (!self.anEmailSigExists){
                
                NSString *theEmailSig = @"Equipment Room\nNorthwest Film Center\n934 SW Salmon St (street address)\n1219 SW Park Avenue (mailing address)\nPortland, OR 97205\nPhone: (503) 221-1156 x30\nwww.nwfilm.org\n\n---\n\nEquipment Room Hours\nMonday 9a- 5p\nTuesday - Thursday 12p - 7p\nFriday and Saturday 9a - 5p\nSunday CLOSED\n\nEdit Lab Hours*\nMonday 9a - 5p\nTuesday - Thursday 12p - 9p\nFriday and Saturday 9a - 5p\nSunday (by appointment)\n\n*(Edit lab availability is further restricted by class needs. Please contact the equipment room staff to schedule your lab time in advance)\n\nStay connected! Subscribe to the NWFC newsletter:\nhttp://www.nwfilm.org/enewsletter/";
                
                EQRWebData *webData2 = [EQRWebData sharedInstance];
                webData2.delegateDataFeed = self;
                NSArray *firstArray = @[@"text", theEmailSig];
                NSArray *secondArray = @[@"context", @"emailSignature"];
                NSArray *thirdArray = @[@"distinguishing_id", @"1"];
                NSArray *topArray = @[firstArray, secondArray, thirdArray];
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
                dispatch_async(queue, ^{
                    
                    [webData2 queryForStringwithAsync:@"EQSetNewTextElement.php" parameters:topArray completion:^(NSString *object) {
                        
                        //string of key_id
                        if (object){
                            
                            NSLog(@"this is the text element's key_id: %@", object);
                            
                        }else{
                            //error handling
                        }
                    }];
                });
            }
            
        }
    }];
    
    
    
    
    self.isInitialLaunch = YES;
    
    return YES;
}


-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    
    //abort if selector is unrecognized, otherwise crash
    if (![self respondsToSelector:action]){
        NSLog(@"inside EQRAppDelegate, cannot perform selector: %@", NSStringFromSelector(action));
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:action withObject:currentThing];
#pragma clang diagnostic pop
    
}

-(void)receiveTextElementForEmailSignature:(id)currentThing{
 
    if (currentThing){
        self.anEmailSigExists= YES;
    }
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

    //set initial seleted tab bar view
//    if (self.isInitialLaunch){
//        UITabBarController *rootViewController = (UITabBarController*)thisApp.keyWindow.rootViewController;
//        NSArray* originalArray2 = [(UITabBarController*)thisApp.keyWindow.rootViewController viewControllers];
//        for (UIViewController* VC in originalArray2){
//            if ([VC.title isEqualToString:@"Settings"]){
//                rootViewController.selectedViewController = VC;
//            }
//        }
//        self.isInitialLaunch = NO;
//    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Handle remote notifications

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo {
    
    CKNotification *cloudKitNotification = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
    
    NSLog(@"did receive cloud kit remote notification with userInfo: %@", cloudKitNotification);
    
    //___!!!!!!  This doesn't happen   !!!!____
    if (cloudKitNotification.notificationType == CKNotificationTypeQuery) {
        
        CKRecordID *recordID = [(CKQueryNotification *)cloudKitNotification recordID];
        NSLog(@"cloud kit recordID: %@", recordID);
    }
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
