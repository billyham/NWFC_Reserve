//
//  EQRCheckVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/14/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRCheckVCntrllr.h"
#import "EQRCheckRowCell.h"
#import "EQRWebData.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRGlobals.h"
//#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
//#import <CoreImage/CoreImage.h>
#import "EQREquipUniqueItem.h"
#import "EQRCheckPageRenderer.h"
#import "EQRCheckPrintPage.h"
#import "EQRStaffUserManager.h"


@interface EQRCheckVCntrllr ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) IBOutlet UILabel* nameTextLabel;
@property (strong, nonatomic) NSDictionary* myUserInfo;

@property (strong, nonatomic) NSString* myProperty;

@property (strong, nonatomic) IBOutlet UICollectionView* myEquipCollection;
@property (strong, nonatomic) NSMutableArray* arrayOfEquipJoins;

//for qr code reader
@property(nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) NSMutableSet* setOfAlreadyCapturedQRs;




@end

@implementation EQRCheckVCntrllr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)initialSetupWithInfo:(NSDictionary*)userInfo{
    
    self.scheduleRequestKeyID = [userInfo objectForKey:@"scheduleKey"];
    self.marked_for_returning = [[userInfo objectForKey:@"marked_for_returning"] boolValue];
    self.switch_num = [[userInfo objectForKey:@"switch_num"] integerValue];
    
    //figure out the literal column name in the database to use
    if (!self.marked_for_returning){
        
        if (self.switch_num == 1){
            
            self.myProperty = @"prep_flag";
            
        }else {
            
            self.myProperty = @"checkout_flag";
        }
    }else{
        
        if (self.switch_num == 1){
            
            self.myProperty = @"checkin_flag";
            
        }else {
            
            self.myProperty = @"shelf_flag";
        }
    }
    
    //populate arrays using schedule key
    EQRWebData* webData = [EQRWebData sharedInstance];

    NSMutableArray* altMuteArray = [NSMutableArray arrayWithCapacity:1];
    NSArray* ayeArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", self.scheduleRequestKeyID, nil];
    NSArray* bigArray = [NSArray arrayWithObject:ayeArray];
    [webData queryWithLink:@"EQGetScheduleEquipJoinsForCheckWithScheduleTrackingKey.php" parameters:bigArray class:@"EQRScheduleTracking_EquipmentUnique_Join" completion:^(NSMutableArray *muteArray) {
        
        for (EQRScheduleTracking_EquipmentUnique_Join* object in muteArray){
                        
            [altMuteArray addObject:object];
        }
    }];
    
    if (!self.arrayOfEquipJoins){
        
        self.arrayOfEquipJoins = [NSMutableArray arrayWithCapacity:1];
    }
    
    [self.arrayOfEquipJoins removeAllObjects];
    
    [self.arrayOfEquipJoins addObjectsFromArray:altMuteArray];
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    //register collection view cell
    [self.myEquipCollection registerClass:[EQRCheckRowCell class] forCellWithReuseIdentifier:@"Cell"];
    
    //register for notes
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    //receive change in state from row items
    [nc addObserver:self selector:@selector(updateArrayOfJoins:) name:EQRUpdateCheckInOutArrayOfJoins object:nil];
    
    
    //cancel bar button
//    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
//    
//    [self.navigationItem setRightBarButtonItem:rightButton];


    //QR Code if application options bool is set in globals
    if (EQRIncludeQRCodeReader == YES){
        
        [self initiateQRCodeSteps];
    }
    
}


#pragma mark - test at printing

//-(void)printMe{
//    
//    //_______PRINTING_________!
//    
//    UIPrintInteractionController* printIntCont = [UIPrintInteractionController sharedPrintController];
//    
//    UIPrintInfo* printInfo = [UIPrintInfo printInfo] ;
//    printInfo.jobName = @"NWFC Reserve App: Request";
//    printInfo.outputType = UIPrintInfoOutputGrayscale;
//    
//    //assign printinfo to int cntrllr
//    printIntCont.printInfo = printInfo;
//    
//    //create page renderer
//    EQRCheckPageRenderer* pageRenderer = [[EQRCheckPageRenderer alloc] init];
//    
//    //assign properties
//    pageRenderer.headerHeight = 300.f;
//    pageRenderer.footerHeight = 500.f;
//    
//    //assign page renderer to int cntrllr
//    printIntCont.printPageRenderer = pageRenderer;
//    
//    
//    
//}


#pragma mark - QR Code reader methods

-(void)initiateQRCodeSteps{
    
    self.session = [[AVCaptureSession alloc] init];

    //sweep out the array of captured codes
    if (!self.setOfAlreadyCapturedQRs){
        
        self.setOfAlreadyCapturedQRs = [[NSMutableSet alloc] initWithCapacity:1];
    }
    
    [self.setOfAlreadyCapturedQRs removeAllObjects];
    
    
    // Get the Camera Device
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	AVCaptureDevice *camera = nil; //[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    for(camera in devices) {
        if(camera.position == AVCaptureDevicePositionBack) {
            break;
        }
    }
	
	// Create a AVCaptureInput with the camera device
	NSError *error=nil;
	AVCaptureDeviceInput *cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
	if (cameraInput == nil) {
        
		NSLog(@"Error to create camera capture:%@",error);
        
        //exit or it will crash
        return;
	}
    
 	// Add the input and output
	[self.session addInput:cameraInput];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:output];
    
    // see what types are supported (do this after adding otherwise the output reports nothing supported
    NSSet *potentialDataTypes = [NSSet setWithArray:@[AVMetadataObjectTypeQRCode]];
    
    NSMutableArray *supportedMetaDataTypes = [NSMutableArray array];
    for(NSString *availableMetadataObject in output.availableMetadataObjectTypes) {
        if([potentialDataTypes containsObject:availableMetadataObject]) {
            [supportedMetaDataTypes addObject:availableMetadataObject];
        }
    }
    
    [output setMetadataObjectTypes:supportedMetaDataTypes];
    
    // Get called back everytime something is recognised
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
	
	// Start the session running
	[self.session startRunning];
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    for(AVMetadataMachineReadableCodeObject *recognizedObject in metadataObjects) {
        
        BOOL alreadyInArray = NO;
        
        //check to see if the string value already has been captured
        for (NSString* stringObject in self.setOfAlreadyCapturedQRs){
            
            
            if ([stringObject isEqualToString:recognizedObject.stringValue]){
                
                alreadyInArray = YES;
                break;
            }
        }
        
        if (alreadyInArray == YES){
            
            //exit if the item has already been scanned
            break;
        }
        
        //otherwise... add to the set of found objects
        [self.setOfAlreadyCapturedQRs addObject:recognizedObject.stringValue];
        
        //derive just the equipItem key
        NSRange eqrRange = [recognizedObject.stringValue rangeOfString:@"eqr"];
        
        //will return NSNotFound for location and 0 for length if it doesn't find the string
        if (eqrRange.location == NSNotFound){
            
//            present a message that an object was scanned but not recognized by the system
            
            //exit the method
            break;
        }
        
        //derive the titleItem key
        NSInteger locationOfTitleKey = eqrRange.location + 3;
        NSInteger lengthOfTitleKey = [recognizedObject.stringValue length] - locationOfTitleKey;
        NSRange titleEqrRange = NSMakeRange(locationOfTitleKey, lengthOfTitleKey);
        
        //valuable sub strings
        NSString* uniqueItemSubString = [recognizedObject.stringValue substringToIndex:eqrRange.location];
        NSString* titleItemSubString = [recognizedObject.stringValue substringWithRange:titleEqrRange];
        
//        NSLog(@"this is the substring: %@", uniqueItemSubString);
//        NSLog(@"this is the title key, perhaps: %@", titleItemSubString);

        
        //_________FIRST respond to an exact equipUnique key id match
        BOOL foundAMatchingEquipKey = NO;
        for (EQRScheduleTracking_EquipmentUnique_Join* joinObject in self.arrayOfEquipJoins){
            
            if ([joinObject.equipUniqueItem_foreignKey isEqualToString:uniqueItemSubString]){
                
                //                        NSLog(@"FOUND A EquipKey MATCH");
                
                foundAMatchingEquipKey = YES;
                
                //alert matching row cell content with a notification
                NSDictionary* newDic = [NSDictionary dictionaryWithObject:uniqueItemSubString forKey:@"keyID"];
                [[NSNotificationCenter defaultCenter] postNotificationName:EQRQRCodeFlipsSwitchInRowCellContent object:nil userInfo:newDic];
            }
        }
        
        if (foundAMatchingEquipKey == YES){
            
            //exit the method
            break;
        }
        
        
        //___________SECOND respond to a matching title key id match and replace an existing unique item with the scanned item
        //___________in the case of c stands or sand bags that are not specified but they are tracked
        BOOL foundAMatchingTitleKey = NO;
        for (EQRScheduleTracking_EquipmentUnique_Join* joinObject in self.arrayOfEquipJoins){
            
            if ([joinObject.equipTitleItem_foreignKey isEqualToString:titleItemSubString]){
                
                //should also test the the item has not already been give a YES value for the 'myProperty' value
                //otherwise it continues to the next segment, adding it as a new item to the order
                
                //found a matching title key in the ivar array
                foundAMatchingTitleKey = YES;
                
                
            }
            
            //change the data layer
            
            //change the local ivar
            
            //change the row cell content distinguishing id, and flip switch
            
        }
        
        if (foundAMatchingTitleKey == YES){
            
            //exit the method
            break;
        }
        
        
        //_____________ THIRD respond to a new titleItem by adding it the the order (in the case of batteries)
        
        BOOL foundACatalogTitleKey = NO;
        EQRWebData* webData = [EQRWebData sharedInstance];
        NSArray* firstyArray = [NSArray arrayWithObjects:@"key_id", titleItemSubString, nil];
        NSArray* topyArray = [NSArray arrayWithObject:firstyArray];
        
        //confirm that the title key object exists
        
        NSString* resultString = [webData queryForStringWithLink:@"EQConfirmExistenceOfEquipTitleKey.php" parameters:topyArray];
        if ([resultString isEqualToString:@"1"]){
            
            foundACatalogTitleKey = YES;
            
        } else {
            
            //____show error message that the item wasn't found in the database
            //exit the method
            break;
        }
        
        //change the data layer
        //create a new schedule_equip_join object
        //retrieve the key_id of the join?
        
        NSArray* firstArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", self.scheduleRequestKeyID, nil];
        NSArray* secondArray = [NSArray arrayWithObjects:@"equipUniqueItem_foreignKey", uniqueItemSubString, nil];
        NSArray* thirdArray = [NSArray arrayWithObjects:@"equipTitleItem_foreignKey", titleItemSubString, nil];
        NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, thirdArray, nil];
        
        NSString* returnString = [webData queryForStringWithLink:@"EQSetNewScheduleEquipJoin.php" parameters:topArray];
        
//        NSLog(@"this is the new join key: %@", returnString);
        
        //________create a new join item to add to the local ivar
        EQRScheduleTracking_EquipmentUnique_Join* newJoinToAdd = [[EQRScheduleTracking_EquipmentUnique_Join alloc] init];
        newJoinToAdd.key_id = returnString;
        newJoinToAdd.scheduleTracking_foreignKey = self.scheduleRequestKeyID;
        newJoinToAdd.equipTitleItem_foreignKey = titleItemSubString;
        newJoinToAdd.equipUniqueItem_foreignKey = uniqueItemSubString;
        
        NSArray* fourthArray = [NSArray arrayWithObjects:@"key_id", uniqueItemSubString, nil];
        NSArray* tipTopArray = [NSArray arrayWithObject:fourthArray];
        
        [webData queryWithLink:@"EQGetEquipmentUnique.php" parameters:tipTopArray class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
            
            newJoinToAdd.name = [(EQREquipUniqueItem*)[muteArray objectAtIndex:0] name];
            newJoinToAdd.distinquishing_id = [(EQREquipUniqueItem*) [muteArray objectAtIndex:0] distinquishing_id];
        }];
        
        //add join object to array ivar
        [self.arrayOfEquipJoins addObject:newJoinToAdd];
        
        [self.myEquipCollection reloadData];
        
        //flip the switch in the row cell
        //alert matching row cell content with a notification
        NSDictionary* newDic = [NSDictionary dictionaryWithObject:uniqueItemSubString forKey:@"keyID"];
        
        [self performSelector:@selector(delayedNotification:) withObject:newDic afterDelay:0.25];
        
        
    
        
        
        
        //_____________FOURTH respond to code that has the "eqr" string  but doesn't find a matching title key in the data
        
        //present a message that an object was scanned but not found in the database
        
        
    }
}

-(void)delayedNotification:(NSDictionary*)myUserDic{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRQRCodeFlipsSwitchInRowCellContent object:nil userInfo:myUserDic];
    
    
}





#pragma mark - navigation buttons

//-(void)cancelAction{
//
//    [self dismissViewControllerAnimated:YES completion:^{
//
//
//    }];
//
//}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

-(IBAction)markAsComplete:(id)sender{
    
    //make special note if any of the joins in the ivar array are not complete
    BOOL foundOutstandingItem = NO;
    
    for (EQRScheduleTracking_EquipmentUnique_Join* join in self.arrayOfEquipJoins){
        
        if ([join respondsToSelector:NSSelectorFromString(self.myProperty)]){
         
            SEL thisSelector = NSSelectorFromString(self.myProperty);

            NSString* thisLiteralProperty = [join performSelector:thisSelector];
            
            if (([thisLiteralProperty isEqualToString:@""]) || (thisLiteralProperty == nil)){
                
                foundOutstandingItem = YES;
                
            }
        }
        
    }
    
    
    NSDictionary* thisDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.scheduleRequestKeyID, @"scheduleKey",
                             @"complete", @"comleteOrIncomplete",
                             [NSNumber numberWithBool:self.marked_for_returning], @"marked_for_returning",
                             [NSNumber numberWithInteger:self.switch_num], @"switch_num",
                             self.myProperty, @"propertyToUpdate",
                             [NSNumber numberWithBool:foundOutstandingItem], @"foundOutstandingItem",
                             nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRMarkItineraryAsCompleteOrNot object:nil userInfo:thisDic];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

}
#pragma clang diagnostic pop




-(IBAction)printMeForReal:(id)sender{
    
    [self printPageWithScheduleRequestItemKey:self.scheduleRequestKeyID];
}



-(void)printPageWithScheduleRequestItemKey:(NSString*)scheduleKey{
    

    //get complete scheduleRequest item info
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* firstRequestArray = [NSArray arrayWithObjects:@"key_id", scheduleKey, nil];
    NSArray* secondRequestArray = [NSArray arrayWithObjects:firstRequestArray, nil];
    __block EQRScheduleRequestItem* chosenItem;
    [webData queryWithLink:@"EQGetScheduleRequestComplete.php" parameters:secondRequestArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        if ([muteArray count] > 0){
            
        chosenItem = [muteArray objectAtIndex:0];
        }
    }];
    

    
    //create printable page view controller
    EQRCheckPrintPage* pageForPrint = [[EQRCheckPrintPage alloc] initWithNibName:@"EQRCheckPrintPage" bundle:nil];
    
    //add the request item to the view controller
    [pageForPrint initialSetupWithScheduleRequestItem:chosenItem];
    
    //assign ivar variables
    pageForPrint.rentorNameAtt = chosenItem.contact_name;
    pageForPrint.rentorEmailAtt = @"test email address";
    pageForPrint.rentorPhoneAtt = @"test phone";
    
    
    //show the view controller
    [self presentViewController:pageForPrint animated:YES completion:^{
        
        
    }];
    
    
}



-(IBAction)markAsIncomplete:(id)sender{
    
    NSDictionary* thisDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.scheduleRequestKeyID, @"scheduleKey",
                             @"incomplete", @"comleteOrIncomplete",
                             [NSNumber numberWithBool:self.marked_for_returning], @"marked_for_returning",
                             [NSNumber numberWithInteger:self.switch_num], @"switch_num",
                             self.myProperty, @"propertyToUpdate",
                             [NSNumber numberWithBool:0], @"foundOutstandingItem",
                             nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRMarkItineraryAsCompleteOrNot object:nil userInfo:thisDic];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#pragma mark - receive messages from row content

-(void)updateArrayOfJoins:(NSNotification*)note{
    
    NSString* joinKeyID = [[note userInfo] objectForKey:@"joinKeyID"];
    NSString* joinProperty = [[note userInfo] objectForKey:@"joinProperty"];
    NSString* verdict = [[note userInfo] objectForKey: @"markedAsYes"];
    
    for (EQRScheduleTracking_EquipmentUnique_Join* joinItem in self.arrayOfEquipJoins){
        
        if ([joinItem.key_id isEqualToString:joinKeyID]){
            
            //gotta cutoff the "_flag" at the end or else is will capitalize the "F"
            NSUInteger thisLength = [joinProperty length];
            NSRange newRange = NSMakeRange(0, thisLength - 5);
            NSString* joinSubstring = [joinProperty substringWithRange:newRange];
            
            NSString* joinPropertyWithCap = [joinSubstring capitalizedString];
            NSString* joinPropertySetMethod = [NSString stringWithFormat:@"set%@_flag:", joinPropertyWithCap];
            SEL mySelector = NSSelectorFromString(joinPropertySetMethod);
            
            if ([joinItem respondsToSelector:mySelector]){
                
                [joinItem performSelector:mySelector withObject:verdict];
            }
        }
    }
}

#pragma clang diagnostic pop



#pragma mark - datasource methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return  [self.arrayOfEquipJoins count];
}


-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"Cell";
    
    EQRCheckRowCell* cell = [self.myEquipCollection dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //remove subviews
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    //and reset the cell's background color...
    cell.backgroundColor = [UIColor whiteColor];
    
    [cell initialSetupWithEquipUnique:[self.arrayOfEquipJoins objectAtIndex:indexPath.row] marked:self.marked_for_returning switch_num:self.switch_num];
    
    return cell;
};



#pragma mark - memory warning


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
