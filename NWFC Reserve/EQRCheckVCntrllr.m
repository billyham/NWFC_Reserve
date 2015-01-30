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
#import "EQRCheckHeaderCell.h"
#import "EQRDataStructure.h"
#import "EQRStaffUserManager.h"
#import "EQRStaffUserPickerViewController.h"
#import "EQRModeManager.h"
#import "EQRScheduleRequestManager.h"
#import "EQRScheduleRequestItem.h"
#import "EQREquipSelectionGenericVCntrllr.h"
#import "EQRScheduleRequestManager.h"


@interface EQRCheckVCntrllr ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) EQRScheduleRequestItem* myScheduleRequestItem;

@property (strong, nonatomic) IBOutlet UIView* mainSubView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* mainSubTopGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* mainSubBottomGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* tableTopGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* tablebottomGuideConstraint;

@property (strong, nonatomic) IBOutlet UITextView* updateLabel;

@property (strong, nonatomic) IBOutlet UILabel* nameTextLabel;
@property (strong, nonatomic) IBOutlet UITextView* noteView;
@property (strong, nonatomic) NSDictionary* myUserInfo;

@property (strong, nonatomic) NSString* myProperty;

@property (strong, nonatomic) IBOutlet UICollectionView* myEquipCollection;
@property (strong, nonatomic) NSMutableArray* arrayOfEquipJoins;
@property (strong, nonatomic) NSArray* arrayOfEquipJoinsWithStructure;
@property (strong, nonatomic) NSMutableArray* arrayOfToBeDeletedEquipIDs;

//for staff user picker
@property (strong, nonatomic) UIPopoverController* myStaffUserPicker;

//for qr code reader
@property(nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) NSMutableSet* setOfAlreadyCapturedQRs;

//for dist id picker
@property (strong, nonatomic) UIPopoverController* distIDPopover;
//@property (strong, nonatomic) EQRDistIDPickerTableVC* distIDPickerVC;

//for add item popover
@property (strong, nonatomic) EQRScheduleRequestManager* privateRequestManager;
@property (strong, nonatomic) UIPopoverController* myEquipSelectionPopover;
@property (strong, nonatomic) IBOutlet UIButton* addButton;



@end

@implementation EQRCheckVCntrllr

#pragma mark - methods

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
    
    [self renewTheArrayWithScheduleTracking_foreignKey:self.scheduleRequestKeyID];
    
    
    //get scheduleRequest object using key
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.scheduleRequestKeyID, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    [webData queryWithLink:@"EQGetScheduleRequestComplete.php" parameters:topArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        if ([muteArray count] > 0){
            
            self.myScheduleRequestItem = [muteArray objectAtIndex:0];
        } else {
            
            //error handling if nothing is returned
            return;
        }
    }];
    
    
    //____set up private request manager______
    
    //create private request manager as ivar
    if (!self.privateRequestManager){
        
        self.privateRequestManager = [[EQRScheduleRequestManager alloc] init];
    }
    
    //set the request as ivar in requestManager
    self.privateRequestManager.request = self.myScheduleRequestItem;
    
    //important methods that initiate requestManager ivar arrays
    [self.privateRequestManager resetEquipListAndAvailableQuantites];
    [self.privateRequestManager retrieveAllEquipUniqueItems];
}


-(void)renewTheArrayWithScheduleTracking_foreignKey:(NSString*)scheduleRequestKeyID{
    
    //populate arrays using schedule key
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    NSMutableArray* altMuteArray = [NSMutableArray arrayWithCapacity:1];
    NSArray* ayeArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", scheduleRequestKeyID, nil];
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
    
    //add nested structure to the array of equup items
    self.arrayOfEquipJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfEquipJoins];
}


- (void)viewDidLoad{
    
    [super viewDidLoad];

    //register collection view cell
    [self.myEquipCollection registerClass:[EQRCheckRowCell class] forCellWithReuseIdentifier:@"Cell"];
    
    //register for header cell
    [self.myEquipCollection registerClass:[EQRCheckHeaderCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SupplementaryCell"];
    
    //register for notes
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    //receive change in state from row items
    [nc addObserver:self selector:@selector(updateArrayOfJoins:) name:EQRUpdateCheckInOutArrayOfJoins object:nil];
    //receive notes from cell's content VCs when delete button is tapped
    [nc addObserver:self selector:@selector(addJoinKeyIDToBeDeletedArray:) name:EQRJoinToBeDeletedInCheckInOut object:nil];
    [nc addObserver:self selector:@selector(removeJoinKeyIDToBeDeletedArray:) name:EQRJoinToBeDeletedInCheckInOutCancel object:nil];
    //receive notes from cell's content when distIDPicker is tapped
    [nc addObserver:self selector:@selector(distIDPickerTapped:) name:EQRDistIDPickerTapped object:nil];
    
    
    //cancel bar button
//    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
//    
//    [self.navigationItem setRightBarButtonItem:rightButton];


    //QR Code if application options bool is set in globals
    if (EQRIncludeQRCodeReader == YES){
        
        [self initiateQRCodeSteps];
    }
    
    //instantiate mutableArray for deletion ivar
    if (!self.arrayOfToBeDeletedEquipIDs){
        
        self.arrayOfToBeDeletedEquipIDs = [NSMutableArray arrayWithCapacity:1];
        
    } else {
        
        [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
    }
    
    //derive the current user name
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    NSString* logText = [NSString stringWithFormat:@"Logged in as %@", staffUserManager.currentStaffUser.first_name];
    
    //uibar buttons
    //create fixed spaces
    UIBarButtonItem* twentySpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    twentySpace.width = 20;
    UIBarButtonItem* thirtySpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    thirtySpace.width = 30;
    
    //wrap buttons in barbuttonitem
    UIBarButtonItem* leftBarButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    
    //array that shit
    NSArray* arrayOfLeftButtons = [NSArray arrayWithObjects:leftBarButton, nil];
    
    //set leftBarButton item on SELF
    [self.navigationItem setLeftBarButtonItems:arrayOfLeftButtons];
    
    //right button
    UIBarButtonItem* staffUserBarButton = [[UIBarButtonItem alloc] initWithTitle:logText style:UIBarButtonItemStylePlain target:self action:@selector(showStaffUserPicker)];
    
    //array that shit
    NSArray* arrayOfRightButtons = [NSArray arrayWithObjects:staffUserBarButton, nil];
    
    //set rightBarButton item in SELF
    [self.navigationItem setRightBarButtonItems:arrayOfRightButtons];
    
    
    //___________
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    //update navigation bar
    EQRModeManager* modeManager = [EQRModeManager sharedInstance];
    if (modeManager.isInDemoMode){
        
        //set prompt
        self.navigationItem.prompt = @"!!! DEMO MODE !!!";
        
        //set color of navigation bar
        self.navigationController.navigationBar.barTintColor = [UIColor redColor];
        
    }else{
        
        //set prompt
        self.navigationItem.prompt = nil;
        
        //set color of navigation bar
        self.navigationController.navigationBar.barTintColor = nil;
    }
    
    [super viewWillAppear:animated];
    
    //add constraints
    //______this MUST be added programmatically because you CANNOT specify the topLayoutGuide of a VC in a nib______
    
    self.myEquipCollection.translatesAutoresizingMaskIntoConstraints = NO;
    id topGuide = self.topLayoutGuide;
    id bottomGuide = self.bottomLayoutGuide;
    
    NSDictionary *viewsDictionary = @{@"mainSubView":self.mainSubView, @"topGuide":topGuide, @"bottomGuide":bottomGuide};
    
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0-[mainSubView]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    
    
    NSArray *constraint_POS_VB = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[mainSubView]-0-[bottomGuide]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewsDictionary];
    
    //drop exisiting constraints
    //_____THIS IS NECESSARY BECAUSE NIBS REALLY HATE IT IF YOU LEAVE OUT ANY CONSTRAINTS __
    //_____THESE WERE ONLY TEMPORARY TO SATISIFY THE NIB FROM SCREAMING ERROR MESSAGES____
    [[self.mainSubView superview] removeConstraints:[NSArray arrayWithObjects:self.mainSubTopGuideConstraint, self.mainSubBottomGuideConstraint, nil]];
    
    //add replacement constraints
    [[self.mainSubView superview] addConstraints:constraint_POS_V];
    [[self.mainSubView superview] addConstraints:constraint_POS_VB];
    
    //reassign constraint ivars!!
    self.mainSubTopGuideConstraint = [constraint_POS_V objectAtIndex:0];
    self.mainSubBottomGuideConstraint = [constraint_POS_VB objectAtIndex:0];
    
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
    NSSet *potentialDataTypes = [NSSet setWithArray:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode39Code]];
    
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
//                NSLog(@"found OBJECT IN ALREADYCAPTURED QRS");
                
                break;
            }
        }
        
        if (alreadyInArray == YES){
            
            //advance to the next cycle if the item has already been scanned
            continue;
        }
        
        //otherwise... add to the set of found objects
        [self.setOfAlreadyCapturedQRs addObject:recognizedObject.stringValue];
        
        //derive just the equipItem key
        NSRange eqrRange = [recognizedObject.stringValue rangeOfString:@"eqr"];
        
        //will return NSNotFound for location and 0 for length if it doesn't find the string
        if (eqrRange.location == NSNotFound){
            
            //try capital letters
            eqrRange = [recognizedObject.stringValue rangeOfString:@"EQR"];
            
            if (eqrRange.location == NSNotFound){
                
                //present a message that an object was scanned but not recognized by the system???
                
                //exit the method
                continue;
            }
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


        
        //_____!!!!  when scanning generic objects, must start a timer to prevent rapid rescanning of the same generic title items !!!____
        //_____!!!!  or modal view that asks for a quantity for the generic title scananed...
        
        //__1__ Matching uniqueKey, just flip switch
          //continue to next scanned item
        
        //__2__ (Matching title key but not unique key, will replace existing title item (unflipped switch) with a different unique...  ?)
          //__4__ __A__ Generic item, matching title key and will flip switch
          //continue to next scanned item
        
        //__3__ No matching title key,
          //__confirm in DB, otherwise show error & continue to next scanned item
          //__is NOT generic, will add to list
          //__is GENERIC...
            //__4__ __B__ Generic item, no matching title, will add to list

        
        
        //__1__ respond to an exact equipUnique key id match
        BOOL foundAMatchingEquipKey = NO;
        for (EQRScheduleTracking_EquipmentUnique_Join* joinObject in self.arrayOfEquipJoins){
            
            if ([joinObject.equipUniqueItem_foreignKey isEqualToString:uniqueItemSubString]){
                
                //                        NSLog(@"FOUND A EquipKey MATCH");

                foundAMatchingEquipKey = YES;
                
                //________move collection view to row with new object.
                //________when cell is not in view (because at the bottom of a long list) the switch doesn't receive the notification and get flipped
                [self.arrayOfEquipJoinsWithStructure enumerateObjectsUsingBlock:^(NSArray* subArray, NSUInteger idx, BOOL *stop) {
                   
                    [subArray enumerateObjectsUsingBlock:^(EQRScheduleTracking_EquipmentUnique_Join* joinObj, NSUInteger subIdx, BOOL *stop) {
                        
                        if (joinObj == joinObject){
                            
//                            NSLog(@"found a match in subarray, %@", joinObject.name);
                            
                            NSIndexPath* matchingIndexPath = [NSIndexPath indexPathForRow:subIdx inSection:idx];
                            
                            [self.myEquipCollection scrollToItemAtIndexPath:matchingIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                        }
                    }];
                }];
                
                //alert matching row cell content with a notification
                NSDictionary* newDic = [NSDictionary dictionaryWithObject:uniqueItemSubString forKey:@"keyID"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:EQRQRCodeFlipsSwitchInRowCellContent object:nil userInfo:newDic];
                //send note with delay
                [self performSelector:@selector(delayedNotification:) withObject:newDic afterDelay:0.25f];
                
                //add text to the display update
                [self showUpdateDisplay:[NSString stringWithFormat:@"Checked: %@ #%@", joinObject.name, joinObject.distinquishing_id]];
                
                //found the match so break out of this sub loop
                break;
            }
        }
        
        if (foundAMatchingEquipKey == YES){
            
            //advance to the next cycle
            continue;
        }
        
        
        //___2__ respond to a matching title key id match
        //replace an existing unique item with the scanned item???
        //___________!!!!!!   THIS IS NO GOOD, IF YOU HAVE TWO BATTERIES TO SCAN IN, THIS METHOD PREVENTS THE SECOND FROM GETTING FLIPPED  !!!!______
        BOOL foundAMatchingTitleKey = NO;
        for (EQRScheduleTracking_EquipmentUnique_Join* joinObject in self.arrayOfEquipJoins){
            
            if ([joinObject.equipTitleItem_foreignKey isEqualToString:titleItemSubString]){
                
                //should also test the the item has not already been give a YES value for the 'myProperty' value
                //otherwise it continues to the next segment, adding it as a new item to the order
                if ([joinObject respondsToSelector:NSSelectorFromString(self.myProperty)]){
                    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    
                    SEL thisSelector = NSSelectorFromString(self.myProperty);
                    NSString* thisLiteralProperty = [joinObject performSelector:thisSelector];
                    if ([thisLiteralProperty isEqualToString:@""] || thisLiteralProperty == nil){
                        
#pragma clang diagnostic pop
                        
                        //found a matching title key in the ivar array
                        foundAMatchingTitleKey = YES;
                        
                        //____ !!!  could be a GENERIC item   !!!____
                        //__4__ __A__ Generic item, matching title key and will flip switch

                        
                        //do stuff, replace existing unqiueItem with NEW uniqueItem
                        
                        //change the data layer
                        
                        //change the local ivar
                        
                        //change the row cell content distinguishing id, and flip switch
                        
                        break;
                    }
                }
            }
        }
        
        if (foundAMatchingTitleKey == YES){
            
            //exit the method
//            continue;
        }
        
        
        //__3__ respond to a new titleItem by adding it the the order (in the case of batteries)
        
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
            //advance to the next cycle
            continue;
        }
        
        
        
        //evaluate if generic...
        if ([uniqueItemSubString isEqualToString:@"NA"]){
            
            //__4__ __B__ Generic item, no matching title, but title confirmed in DB and will add to list
            
            //check available quantity for this title, return error if none
            //derive a legitimate uniqueKey and assign to uniqueItemSubString to use in the following code...
            //use privateRequestManager... check the title for availability,
            //important methods that initiate requestManager ivar arrays
            
            //allocate method MUST be called only ONCE after the other two methods. or the count gets screwed up.  
            [self.privateRequestManager resetEquipListAndAvailableQuantites];
            [self.privateRequestManager retrieveAllEquipUniqueItems];
            [self.privateRequestManager allocateGearListWithDates:nil];
            
            BOOL isAvailable = [self.privateRequestManager confirmAvailabilityOfTitleItem:titleItemSubString];
            if (isAvailable){
                
                //... then use methods: addEquipItem, justConfirm
                EQREquipItem* titleItemObject  = [[EQREquipItem alloc] init];
                titleItemObject.key_id = titleItemSubString;
                [self.privateRequestManager addNewRequestEquipJoin:titleItemObject];
                
                //assign a valid equipUniqueItem to the array of joins in the request
                NSString* tempReturn = [self.privateRequestManager retrieveAnAvailableUniqueKeyFromTitleKey:titleItemSubString];
                
                if (tempReturn == nil){
                    
                    //error handling when nothing is returned
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Scan Error" message:[NSString stringWithFormat:@"Scan Failed, an error occurred when trying to select this item"]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alertView show];
                    
                    //advance the cycle
                    continue;
                    
                }else{
                    
                    //otherwise assign key to 
                    uniqueItemSubString = tempReturn;
                    
                    //set a delayed method to remove the particular code from the alreadyInArray after 2 seconds to allow multiple scans
                    [self performSelector:@selector(removeGenericQRCodeFromAlreadySet:) withObject:recognizedObject.stringValue afterDelay:2.0];
                }
                
            }else{
                
                //____send alert that item is not available____
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Not Available" message:[NSString stringWithFormat:@"Gear is no longer available for this date range"]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
                
                //advance the cycle
                continue;
            }
        }
        
        
        //confirm that the unique key object exists!!!
        //________create a new join item to add to the local ivar
        EQRScheduleTracking_EquipmentUnique_Join* newJoinToAdd = [[EQRScheduleTracking_EquipmentUnique_Join alloc] init];
        NSArray* fourthArray = [NSArray arrayWithObjects:@"key_id", uniqueItemSubString, nil];
        NSArray* tipTopArray = [NSArray arrayWithObject:fourthArray];
        [webData queryWithLink:@"EQGetEquipmentUnique.php" parameters:tipTopArray class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
            
            if ([muteArray count] > 0){
                
                //only continue with a confirmed Unique Item present
                //change the data layer
                //create a new schedule_equip_join object
                //retrieve the key_id of the join?
                
                
                newJoinToAdd.name = [(EQREquipUniqueItem*)[muteArray objectAtIndex:0] name];
                newJoinToAdd.distinquishing_id = [(EQREquipUniqueItem*) [muteArray objectAtIndex:0] distinquishing_id];
                newJoinToAdd.scheduleTracking_foreignKey = self.scheduleRequestKeyID;
                newJoinToAdd.equipTitleItem_foreignKey = titleItemSubString;
                newJoinToAdd.equipUniqueItem_foreignKey = uniqueItemSubString;
                
                //create the join object in the database and retrieve key_id
                NSArray* firstArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", self.scheduleRequestKeyID, nil];
                NSArray* secondArray = [NSArray arrayWithObjects:@"equipUniqueItem_foreignKey", uniqueItemSubString, nil];
                NSArray* thirdArray = [NSArray arrayWithObjects:@"equipTitleItem_foreignKey", titleItemSubString, nil];
                NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, thirdArray, nil];
                
                NSString* returnString = [webData queryForStringWithLink:@"EQSetNewScheduleEquipJoin.php" parameters:topArray];
                
                newJoinToAdd.key_id = returnString;
                
                //2 arrays to update
                //add join object to array property
                [self.arrayOfEquipJoins addObject:newJoinToAdd];
                self.arrayOfEquipJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfEquipJoins];
                
                [self.myEquipCollection reloadData];
                
                //move collection view to row with new object.
                //when cell is not in view (because at the bottom of a long list) the switch doesn't receive the notification and get flipped
                [self.arrayOfEquipJoinsWithStructure enumerateObjectsUsingBlock:^(NSArray* subArray, NSUInteger idx, BOOL *stop) {
                    
                    [subArray enumerateObjectsUsingBlock:^(EQRScheduleTracking_EquipmentUnique_Join* joinObj, NSUInteger subIdx, BOOL *stop) {
                        
                        if (joinObj == newJoinToAdd){
                            
                            NSIndexPath* matchingIndexPath = [NSIndexPath indexPathForRow:subIdx inSection:idx];
                            
                            [self.myEquipCollection scrollToItemAtIndexPath:matchingIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                        }
                    }];
                }];
                
                //flip the switch in the row cell
                //alert matching row cell content with a notification
                NSDictionary* newDic = [NSDictionary dictionaryWithObject:uniqueItemSubString forKey:@"keyID"];
                
                [self performSelector:@selector(delayedNotification:) withObject:newDic afterDelay:0.25];
                
                //add text to the display update
                [self showUpdateDisplay:[NSString stringWithFormat:@"Added: %@ #%@", newJoinToAdd.name, newJoinToAdd.distinquishing_id]];
                
            }else{
                
                //can't find this uniqueKey in the database
                //exit and alert user
                //____!!!!!!  NEED TO INCLUDE THE TITLE ITEM NAME  !!!!!_______
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Not Found" message:[NSString stringWithFormat:@"Cannot find this item in the database"]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                
                [alertView show];
            }
        }];
        
        
    }
}

-(void)delayedNotification:(NSDictionary*)myUserDic{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRQRCodeFlipsSwitchInRowCellContent object:nil userInfo:myUserDic];
}


-(void)removeGenericQRCodeFromAlreadySet:(NSString*)QRCodeString{
    
    if (self.setOfAlreadyCapturedQRs){
        if ([self.setOfAlreadyCapturedQRs count] > 0){
            [self.setOfAlreadyCapturedQRs removeObject:QRCodeString];
        }
    }
}


-(void)showUpdateDisplay:(NSString*)updateText{

    //add new text to the existing display text
    self.updateLabel.text = [self.updateLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@    \n", updateText]];
    
    //lower collectionView to reveal update display
    self.tableTopGuideConstraint.constant = 100.f;
    
    [self.myEquipCollection setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.25f animations:^{
       
        //scroll update label to bottom
        [self.updateLabel scrollRangeToVisible:NSMakeRange(0,[self.updateLabel.text length])];
        
        //generally use the topmost view
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - equip list buttons

-(IBAction)deleteMarkedItemsButton:(id)sender{
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    //delete the marked scheduleTracking_equip_joins
    for (NSString* thisKeyID in self.arrayOfToBeDeletedEquipIDs){
        
        //send php message to delete with the join key_id
        NSArray* ayeArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", thisKeyID, nil];
        NSArray* beeArray = [NSArray arrayWithObject:ayeArray];
        NSString* returnString = [webData queryForStringWithLink:@"EQRDeleteScheduleEquipJoin.php" parameters:beeArray];
        
        NSLog(@"this is the result: %@", returnString);
    }
    
    //empty the arrays
    [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
    
    //renew the array of equipment
    [self renewTheArrayWithScheduleTracking_foreignKey:self.scheduleRequestKeyID];
    
    //reload the collection view
    [self.myEquipCollection reloadData];
    
    //send note to schedule that a change has been saved
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
}



#pragma mark - navigation buttons

-(void)cancelAction{

    [self dismissViewControllerAnimated:YES completion:^{


    }];

}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

-(IBAction)markAsComplete:(id)sender{
    
    //MUST CHECK THAT THE USER HAS LOGGED IN FIRST:
    EQRStaffUserManager* staffManager = [EQRStaffUserManager sharedInstance];
    if (!staffManager.currentStaffUser){
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Current User" message:@"Please log in as a user before marking an item complete or incomplete" delegate:[self presentingViewController] cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            [alert show];
        }];
        
        return;
    }
    
    
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
    
    //MUST CHECK THAT THE USER HAS LOGGED IN FIRST:
    EQRStaffUserManager* staffManager = [EQRStaffUserManager sharedInstance];
    if (!staffManager.currentStaffUser){
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Current User" message:@"Please log in as a user before marking an item complete or incomplete" delegate:[self presentingViewController] cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            [alert show];
        }];
        
        return;
    }
    
    
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


#pragma mark - receive messages from row content

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

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



-(void)addJoinKeyIDToBeDeletedArray:(NSNotification*)note{
    
    [self.arrayOfToBeDeletedEquipIDs addObject:[note.userInfo objectForKey:@"key_id"]];
    
}

-(void)removeJoinKeyIDToBeDeletedArray:(NSNotification*)note{
    
    NSString* stringToBeRemoved;
    
    for (NSString* thisString in self.arrayOfToBeDeletedEquipIDs){
        
        if ([thisString isEqualToString:[note.userInfo objectForKey:@"key_id"]]){
            
            stringToBeRemoved = thisString;
        }
    }
    
    [self.arrayOfToBeDeletedEquipIDs removeObject:stringToBeRemoved];
}


-(void)distIDPickerTapped:(NSNotification*)note{
    
    //get cell's equipUniqueKey and IndexPath and button's frame?? UIButton??
//    NSString* joinKey_ID = [[note userInfo] objectForKey:@"joinKey_id"];
    NSString* equipTitleItem_foreignKey = [[note userInfo] objectForKey:@"equipTitleItem_foreignKey"];
    NSString* equipUniqueItem_foreignKey = [[note userInfo] objectForKey:@"equipUniqueItem_foreignKey"];
//    NSIndexPath* thisIndexPath = [[note userInfo] objectForKey:@"indexPath"];
    CGRect buttonRect = [(UIButton*)[[note userInfo] objectForKey:@"distButton"] frame];
    UIButton* thisButton = (UIButton*)[[note userInfo] objectForKey:@"distButton"];
    
    
    EQRDistIDPickerTableVC* distIDPickerVC = [[EQRDistIDPickerTableVC alloc] initWithNibName:@"EQRDistIDPickerTableVC" bundle:nil];
//    self.distIDPickerVC = distIDPickerVC;
    
    //initial setup
    [distIDPickerVC initialSetupWithOriginalUniqueKeyID:equipUniqueItem_foreignKey equipTitleKey:equipTitleItem_foreignKey scheduleItem:self.myScheduleRequestItem];
    distIDPickerVC.delegate = self;
    
    UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:distIDPickerVC];
    [popOver setPopoverContentSize:CGSizeMake(320.f, 300.f)];
    popOver.delegate = self;
    self.distIDPopover = popOver;
    
//    CGRect fixedRect1 = [thisButton.superview convertRect:buttonRect fromView:thisButton];
    CGRect fixedRect2 = [thisButton.superview.superview convertRect:buttonRect fromView:thisButton.superview];
    CGRect fixedRect3 = [thisButton.superview.superview.superview convertRect:fixedRect2 fromView:thisButton.superview.superview];
    CGRect fixedrect4 = [thisButton.superview.superview.superview.superview convertRect:fixedRect3 fromView:thisButton.superview.superview.superview];
    CGRect fixedRect5 = [thisButton.superview.superview.superview.superview.superview convertRect:fixedrect4 fromView:thisButton.superview.superview.superview.superview];
//    CGRect fixedRect6 = [thisButton.superview.superview.superview.superview.superview.superview convertRect:fixedRect5 fromView:thisButton.superview.superview.superview.superview.superview];
//    CGRect fixedRect7 = [thisButton.superview.superview.superview.superview.superview.superview.superview convertRect:fixedRect6 fromView:thisButton.superview.superview.superview.superview.superview.superview];
//    CGRect fixedRect8 = [thisButton.superview.superview.superview.superview.superview.superview.superview.superview convertRect:fixedRect7 fromView:thisButton.superview.superview.superview.superview.superview.superview.superview];
    
    //present popover
    [self.distIDPopover presentPopoverFromRect:fixedRect5 inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}


-(void)distIDSelectionMadeWithOriginalEquipUniqueKey:(NSString*)originalKeyID equipUniqueItem:(id)distEquipUniqueItem{
    
    //____!!!!!! INDEXPATH IS MEANINGLESS! BECAUSE THAT'S THE PATH IN THE STRUCTRED ARRAY, BUT WE NEED TO UPDATE THE
    //____!!!!!! UNSTRUCTURED ARRAY AS WELL  !!!____
    //retrieve key id of selected equipUniqueItem AND indexPath of the collection cell that initiated the distID picker
    //tell content of the cell to use replace the dist ID
    //update the data model > schedule_equip_join has new unique_foreignKey
    
    //extract the unique's key as a string
    NSString* thisIsTheKey = [(EQREquipUniqueItem*)distEquipUniqueItem key_id];
    NSString* thisIsTheDistID = [(EQREquipUniqueItem*)distEquipUniqueItem distinquishing_id];
    NSLog(@"this is the issue_service_name text: %@", [(EQREquipUniqueItem*)distEquipUniqueItem issue_short_name]);
    NSString* thisIsTheIssueShortName = [(EQREquipUniqueItem*)distEquipUniqueItem issue_short_name];
    NSString* thisIsTheStatusLevel = [(EQREquipUniqueItem*)distEquipUniqueItem status_level];
    
    
    EQRScheduleTracking_EquipmentUnique_Join* saveThisJoin;
    
    //update local ivar arrays
    for (EQRScheduleTracking_EquipmentUnique_Join* joinObj in self.arrayOfEquipJoins){
        
        if ([joinObj.equipUniqueItem_foreignKey isEqualToString:originalKeyID]){
            
            [joinObj setEquipUniqueItem_foreignKey:thisIsTheKey];
            [joinObj setDistinquishing_id:thisIsTheDistID];
            
            //_____need to know what service issues are a part of this new equipUnique and assign to local var in array______
            [joinObj setIssue_short_name:thisIsTheIssueShortName];
            [joinObj setStatus_level:thisIsTheStatusLevel];
            
            saveThisJoin = joinObj;
            break;
        }
    }
    self.arrayOfEquipJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfEquipJoins];
    
    //renew the collection view
    [self.myEquipCollection reloadData];
    
    
    //update the data layer
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", [saveThisJoin key_id], nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"equipUniqueItem_foreignKey", [saveThisJoin equipUniqueItem_foreignKey], nil];
    NSArray* thirdArray = [NSArray arrayWithObjects:@"equipTitleItem_foreignKey", [saveThisJoin equipTitleItem_foreignKey], nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, thirdArray, nil];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSString* returnString = [webData queryForStringWithLink:@"EQAlterScheduleEquipJoin.php" parameters:topArray];
    NSLog(@"this is the return string: %@", returnString);
    
    
    //remove the popover
    [(EQRDistIDPickerTableVC*)self.distIDPopover.contentViewController setDelegate:nil];
    
    [self.distIDPopover dismissPopoverAnimated:YES];
    
    //gracefully dealloc all the objects in the content VC
    [(EQRDistIDPickerTableVC*)self.distIDPopover.contentViewController killThisThing];
    
    //_______THIS IS SUPER DUPER DUPER SUPER IMPORTANT!!!!!_______
    self.distIDPopover = nil;
    
    //send note to schedule that a change has been saved
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
}


#pragma mark - popover delegate methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    //there are 3 popovers:
    //myStaffUserPicker
    //distIDPopover
    //myEquipSelectionPopover
    
    if (popoverController == self.myEquipSelectionPopover){
        
        self.myEquipSelectionPopover = nil;
        
    }else if (popoverController == self.distIDPopover){
        
        [(EQRDistIDPickerTableVC*)self.distIDPopover.contentViewController setDelegate:nil];
        
        //gracefully dealloc all the objects in the content VC
        [(EQRDistIDPickerTableVC*)self.distIDPopover.contentViewController killThisThing];
        
        //_______THIS IS SUPER DUPER DUPER SUPER IMPORTANT!!!!!_______
        self.distIDPopover = nil;
        
    }else if (popoverController == self.myStaffUserPicker){
        
        self.myStaffUserPicker = nil;
    }
}




#pragma mark - handle add equip item

-(IBAction)addEquipItem:(id)sender{
    
    EQREquipSelectionGenericVCntrllr* genericEquipVCntrllr = [[EQREquipSelectionGenericVCntrllr alloc] initWithNibName:@"EQREquipSelectionGenericVCntrllr" bundle:nil];
    
    //need to specify a privateRequestManager for the equip selection v cntrllr
    //also sets ivar isInPopover to YES
    [genericEquipVCntrllr overrideSharedRequestManager:self.privateRequestManager];
    
    UIPopoverController* popOverMe = [[UIPopoverController alloc] initWithContentViewController:genericEquipVCntrllr];
    self.myEquipSelectionPopover = popOverMe;
    self.myEquipSelectionPopover.delegate = self;
    
    //must manually set the size, cannot be wider than 600px!!!!???? But seems to work ok at 800 anyway???
    self.myEquipSelectionPopover.popoverContentSize = CGSizeMake(700, 600);
    
    CGRect rect1 = [self.addButton.superview.superview convertRect:self.addButton.frame fromView:self.addButton.superview];
    
    [self.myEquipSelectionPopover presentPopoverFromRect:rect1 inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated: YES];
    
    //need to reprogram the target of the save button
    [genericEquipVCntrllr.continueButton removeTarget:genericEquipVCntrllr action:NULL forControlEvents:UIControlEventAllEvents];
    [genericEquipVCntrllr.continueButton addTarget:self action:@selector(continueAddEquipItem:) forControlEvents:UIControlEventTouchUpInside];
}


-(IBAction)continueAddEquipItem:(id)sender{
    
    //replaces the uniqueItem key from "1" to an accurate value
    [self.privateRequestManager justConfirm];
    
    [self.myEquipSelectionPopover dismissPopoverAnimated:YES];
    self.myEquipSelectionPopover = nil;

    //renew the list of joins by going to the data layer
    [self renewTheArrayWithScheduleTracking_foreignKey:self.myScheduleRequestItem.key_id];
    
    //this is necessary
    [self.myEquipCollection reloadData];
}


#pragma mark - staff picker method

-(void)showStaffUserPicker{
    
    EQRStaffUserPickerViewController* staffUserPicker = [[EQRStaffUserPickerViewController alloc] initWithNibName:@"EQRStaffUserPickerViewController" bundle:nil];
    self.myStaffUserPicker = [[UIPopoverController alloc] initWithContentViewController:staffUserPicker];
    self.myStaffUserPicker.delegate = self;
    
    //set size
    [self.myStaffUserPicker setPopoverContentSize:CGSizeMake(400, 400)];
    
    //present popover
    [self.myStaffUserPicker presentPopoverFromBarButtonItem:[self.navigationItem.rightBarButtonItems objectAtIndex:0]  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //set target of continue button
    [staffUserPicker.continueButton addTarget:self action:@selector(dismissStaffUserPicker) forControlEvents:UIControlEventTouchUpInside];
    
}


-(void)dismissStaffUserPicker{
    
    //do stuff with the iboutlet of the
    EQRStaffUserPickerViewController* thisStaffUserPicker = (EQRStaffUserPickerViewController*)[self.myStaffUserPicker contentViewController];
    int selectedRow = (int)[thisStaffUserPicker.myPicker selectedRowInComponent:0];
    
    //assign contact name object to shared staffUserManager
    EQRContactNameItem* selectedNameObject = (EQRContactNameItem*)[thisStaffUserPicker.arrayOfContactObjects objectAtIndex:selectedRow];
    
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    staffUserManager.currentStaffUser = selectedNameObject;
    
    //set title on bar button item
    NSString* newUserString = [NSString stringWithFormat:@"Logged in as %@", selectedNameObject.first_name];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setTitle:newUserString];
    
    //save as default
    NSDictionary* newDic = [NSDictionary dictionaryWithObject:selectedNameObject.key_id forKey:@"staffUserKey"];
    [[NSUserDefaults standardUserDefaults] setObject:newDic forKey:@"staffUserKey"];
    
    //dismiss the picker
    [self.myStaffUserPicker dismissPopoverAnimated:YES];
    self.myStaffUserPicker = nil;
    
}


#pragma mark - datasource methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return [self.arrayOfEquipJoinsWithStructure count];
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return  [[self.arrayOfEquipJoinsWithStructure objectAtIndex:section] count];
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
    
    //tell the cell's contentVC to be marked for deletion or not
    BOOL toBeDeleted = NO;
    for (NSString* keyToDelete in self.arrayOfToBeDeletedEquipIDs){
        
        if ([keyToDelete isEqualToString:[[[self.arrayOfEquipJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] key_id]]){
            
            toBeDeleted = YES;
        }
    }
    
    //cell setup
    [cell initialSetupWithEquipUnique:[(NSArray*)[self.arrayOfEquipJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]
                               marked:self.marked_for_returning
                           switch_num:self.switch_num
                    markedForDeletion:toBeDeleted
                            indexPath:indexPath];
    
    
    return cell;
};


#pragma mark - section header data source methods

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"SupplementaryCell";
    EQRCheckHeaderCell* cell = [self.myEquipCollection dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //remove subviews?????
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }

    NSString* categoryStringValue = [(EQRScheduleTracking_EquipmentUnique_Join*)[(NSArray*)[self.arrayOfEquipJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] schedule_grouping];
    
    [cell initialSetupWithCategoryText:categoryStringValue];
    
    
    return cell;
}


-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.privateRequestManager = nil;
}

#pragma mark - memory warning


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
