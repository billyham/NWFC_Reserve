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
    
    NSDictionary* EQRCurrentTermCode = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"F13", @"term",
                                        nil];
    
    NSDictionary* EQRCurrentCampTermCode = [NSDictionary dictionaryWithObjectsAndKeys:
                                            @"SC14", @"campTerm",
                                            nil];
    
    NSDictionary* EQRDefaultStaffUserKeyID = [NSDictionary dictionaryWithObjectsAndKeys:
                                              @"", @"staffUserKey"
                                              , nil];
    
    
    NSDictionary* appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 EQRWebDataUrl, @"url",
                                 EQRCurrentTermCode, @"term",
                                 EQRCurrentCampTermCode, @"campTerm",
                                 EQRDefaultStaffUserKeyID, @"staffUserKey"
                                 , nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    
    //instantiate system colors
    EQRColors* myColors = [EQRColors sharedInstance];
    [myColors loadColors];
    
    NSString* keyID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"staffUserKey"] objectForKey:@"staffUserKey"];
    
    if (![keyID isEqualToString:@""]){
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        
        NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", keyID, nil];
        NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
        __block EQRContactNameItem* contactObject;
        [webData queryWithLink:@"EQGetContactNameWithKey.php" parameters:topArray class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
            
            if (muteArray > 0){
                
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
        EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
        
        staffUserManager.currentStaffUser = contactObject;
        
        
        
            
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
