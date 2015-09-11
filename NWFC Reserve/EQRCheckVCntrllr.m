//
//  EQRCheckVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/14/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRCheckVCntrllr.h"
#import "EQRCheckRowCell.h"
#import "EQRCheckRowMiscItemCell.h"
#import "EQRMiscJoin.h"
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
#import "EQRContactNameItem.h"
#import "EQRColors.h"


@interface EQRCheckVCntrllr ()<AVCaptureMetadataOutputObjectsDelegate, UISearchBarDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) EQRScheduleRequestItem* myScheduleRequestItem;

@property (strong, nonatomic) IBOutlet UIView* mainSubView;
@property (strong, nonatomic) IBOutlet UIView *rightSubView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* mainSubTopGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* mainSubBottomGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* tableTopGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* tablebottomGuideConstraint;

@property (strong, nonatomic) IBOutlet UITextView* updateLabel;

@property (strong, nonatomic) IBOutlet UILabel* nameTextLabel;
@property (strong, nonatomic) NSString* notesText;
@property (strong, nonatomic) IBOutlet UITextView* noteView;
@property (strong, nonatomic) NSDictionary* myUserInfo;

@property (strong, nonatomic) NSString* myProperty;

@property (strong, nonatomic) IBOutlet UICollectionView* myEquipCollection;
@property (strong, nonatomic) NSMutableArray* arrayOfEquipJoins;
@property (strong, nonatomic) NSMutableArray* arrayOfMiscJoins;
@property (strong, nonatomic) NSArray* arrayOfEquipJoinsWithStructure;
@property (strong, nonatomic) NSMutableArray* arrayOfToBeDeletedEquipIDs;
@property (strong, nonatomic) NSMutableArray* arrayOfToBeDeletedMiscJoins;

@property NSInteger indexOfLastReturnedItem;
@property (strong, nonatomic) EQRWebData *webDataForFullyComplete;
@property (strong, nonatomic) EQRWebData *webDataForContactComplete;
@property (strong, nonatomic) EQRWebData *webDataForEquipJoins;
@property (strong, nonatomic) EQRWebData *webDataForMiscJoins;
@property BOOL didLoadFullyCompleteFlag;
@property BOOL didLoadContactCompleteFlag;
@property BOOL didLoadEquipJoinsFlag;
@property BOOL didLoadMiscJoinsFlag;
@property double timeOfLastCallback;
@property (strong, nonatomic) EQRContactNameItem *tempContact;

//searchController
@property (strong, nonatomic) UISearchController *mySearchController;
@property (strong, nonatomic) IBOutlet UIView *searchBoxView;
@property (strong, nonatomic) NSArray *searchResultArrayOfEquipTitles;
//@property (strong, nonatomic) NSArray *verticalConstraintsForSearchBar;
//@property (strong, nonatomic) NSArray *horizontalConstraintsForSearchBar;

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
    
    self.didLoadFullyCompleteFlag = NO;
    self.didLoadContactCompleteFlag = NO;
    self.myScheduleRequestItem = nil;
    self.tempContact = nil;
    
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
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    self.webDataForFullyComplete = webData;
    self.webDataForFullyComplete.delegateDataFeed = self;
    NSArray *firstArray = @[@"key_id", self.scheduleRequestKeyID];
    NSArray *topArray = @[firstArray];
    SEL thisSelector = @selector(addRequestObject:);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
       
        [self.webDataForFullyComplete queryWithAsync:@"EQGetScheduleRequestFullyComplete.php" parameters:topArray class:@"EQRScheduleRequestItem" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
            
            self.didLoadFullyCompleteFlag = YES;
            
            if (self.didLoadContactCompleteFlag){
                
                self.didLoadFullyCompleteFlag = NO;
                self.didLoadContactCompleteFlag = NO;
                
                //only continue if a valid request got returned
                if (self.myScheduleRequestItem){
                    [self initialSetupStage2];
                }
            }
        }];
    });
    
    //do asynchronous call to a different implementation of webdata for the contact info
    EQRWebData *webData2 = [EQRWebData sharedInstance];
    self.webDataForContactComplete = webData2;
    self.webDataForContactComplete.delegateDataFeed = self;
    SEL thisSelector2 = @selector(addContactComplete:);
    
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue2, ^{
       
        [self.webDataForContactComplete queryWithAsync:@"EQGetContactCompleteWithScheduleRequestKey.php" parameters:topArray class:@"EQRContactNameItem" selector:thisSelector2 completion:^(BOOL isLoadingFlagUp) {
            
            self.didLoadContactCompleteFlag = YES;
            
            if (self.didLoadFullyCompleteFlag){
                
                self.didLoadFullyCompleteFlag = NO;
                self.didLoadContactCompleteFlag = NO;
                
                //only continue if a valid request got returned
                if (self.myScheduleRequestItem){
                    [self initialSetupStage2];
                }
            }
        }];
    });
}


-(void)initialSetupStage2{
    
    self.didLoadEquipJoinsFlag = NO;
    self.didLoadMiscJoinsFlag = NO;
    
    //stop existing xml stream
    [self.webDataForEquipJoins stopXMLParsing];
    [self.webDataForMiscJoins stopXMLParsing];
    
    //empty the existing collection view
    self.arrayOfEquipJoinsWithStructure = nil;
    [self.myEquipCollection reloadData];
    
    //remove any existing delaytimer
    self.timeOfLastCallback = 0;
    
    //set notes text
    self.noteView.text = self.notesText;
    
    //set name label
    if (self.myScheduleRequestItem.contactNameItem){
        self.nameTextLabel.text = self.myScheduleRequestItem.contactNameItem.first_and_last;
    }
    
    
    //initiate the nsmutable arrays if necessary
    if (!self.arrayOfEquipJoins){
        self.arrayOfEquipJoins = [NSMutableArray arrayWithCapacity:1];
    }
    [self.arrayOfEquipJoins removeAllObjects];
    
    if (!self.arrayOfMiscJoins){
        self.arrayOfMiscJoins = [NSMutableArray arrayWithCapacity:1];
    }
    [self.arrayOfMiscJoins removeAllObjects];
    
//    self.indexOfLastReturnedItem = -1;
    
    self.myScheduleRequestItem.contactNameItem = self.tempContact;
    
//    [self renewTheArrayWithScheduleTracking_foreignKey:self.scheduleRequestKeyID];
//    [self.myEquipCollection reloadData];

    //populate arrays using schedule key
    EQRWebData* webData = [EQRWebData sharedInstance];
    self.webDataForEquipJoins = webData;
    self.webDataForEquipJoins.delegateDataFeed = self;
    
    NSArray* ayeArray = @[@"scheduleTracking_foreignKey", self.scheduleRequestKeyID];
    NSArray* bigArray = @[ayeArray];
    SEL equipJoinSelector = @selector(addEquipJoinToArray:);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [self.webDataForEquipJoins queryWithAsync:@"EQGetScheduleEquipJoinsForCheckWithScheduleTrackingKey.php" parameters:bigArray class:@"EQRScheduleTracking_EquipmentUnique_Join" selector:equipJoinSelector completion:^(BOOL isLoadingFlagUp) {
            
            self.didLoadEquipJoinsFlag = isLoadingFlagUp;
            
            if (self.didLoadMiscJoinsFlag){
                self.didLoadMiscJoinsFlag = NO;
                self.didLoadEquipJoinsFlag = NO;
                
                //this delay has no real effect
                [self performSelector:@selector(initialSetupStage3) withObject:nil afterDelay:1.0];
            }
        }];
    });

    EQRWebData *webData2 = [EQRWebData sharedInstance];
    self.webDataForMiscJoins = webData2;
    self.webDataForMiscJoins.delegateDataFeed = self;
    SEL miscJoinsSelector = @selector(addMiscJoinToArray:);
    
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue2, ^{
       
        [self.webDataForMiscJoins queryWithAsync:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:bigArray class:@"EQRMiscJoin" selector:miscJoinsSelector completion:^(BOOL isLoadingFlagUp) {
            
            self.didLoadMiscJoinsFlag = isLoadingFlagUp;
            
            if (self.didLoadEquipJoinsFlag){
                self.didLoadEquipJoinsFlag = NO;
                self.didLoadMiscJoinsFlag = NO;
                
                //this delay has no real effect
                [self performSelector:@selector(initialSetupStage3) withObject:nil afterDelay:1.0];
            }
        }];
    });
}


-(void)initialSetupStage3{
    
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


//-(void)renewTheArrayWithScheduleTracking_foreignKey:(NSString*)scheduleRequestKeyID{
//    
//
//    NSMutableArray* altMuteArray = [NSMutableArray arrayWithCapacity:1];
//
//    
//    //initiate the nsmutable array if necessary
//    if (!self.arrayOfEquipJoins){
//        self.arrayOfEquipJoins = [NSMutableArray arrayWithCapacity:1];
//    }
//    [self.arrayOfEquipJoins removeAllObjects];
//    
//    [self.arrayOfEquipJoins addObjectsFromArray:altMuteArray];
//    
//
//    //gather any misc joins
//    NSMutableArray* tempMiscMuteArray = [NSMutableArray arrayWithCapacity:1];
//    NSArray* alphaArray = @[@"scheduleTracking_foreignKey", scheduleRequestKeyID];
//    NSArray* omegaArray = @[alphaArray];
//    [webData queryWithLink:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:omegaArray class:@"EQRMiscJoin" completion:^(NSMutableArray *muteArray2) {
//        for (id object in muteArray2){
//            [tempMiscMuteArray addObject:object];
//        }
//    }];
//    
//    //initiate the nsmutable array if necessary
//    if (!self.arrayOfMiscJoins){
//        self.arrayOfMiscJoins = [NSMutableArray arrayWithCapacity:1];
//    }
//    [self.arrayOfMiscJoins removeAllObjects];
//
//    [self.arrayOfMiscJoins addObjectsFromArray:tempMiscMuteArray];
//    
//    
//    
//    //add nested structure to the array of equip items
//    self.arrayOfEquipJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfEquipJoins withMiscJoins:self.arrayOfMiscJoins];
//}


- (void)viewDidLoad{
    
    [super viewDidLoad];

    //register collection view cells
    [self.myEquipCollection registerClass:[EQRCheckRowCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.myEquipCollection registerClass:[EQRCheckRowMiscItemCell class] forCellWithReuseIdentifier:@"CellForMiscJoin"];
    
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
    
    //instantiate mutableArray for deletion miscJoins
    if (!self.arrayOfToBeDeletedMiscJoins){
        self.arrayOfToBeDeletedMiscJoins = [NSMutableArray arrayWithCapacity:1];
    } else {
        [self.arrayOfToBeDeletedMiscJoins removeAllObjects];
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
    
    //searchcontroller setup
    self.mySearchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    self.mySearchController.searchResultsUpdater = self;
    
    self.mySearchController.dimsBackgroundDuringPresentation = NO;
    self.mySearchController.hidesNavigationBarDuringPresentation = NO;
    
    self.mySearchController.searchBar.frame = CGRectMake(0, 0, self.searchBoxView.frame.size.width, self.searchBoxView.frame.size.height);
    
    [self.searchBoxView addSubview:self.mySearchController.searchBar];
    
    //search bar needs constraints???
    
    
    self.mySearchController.searchBar.delegate = self;
    self.mySearchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    //what does this do?
    self.definesPresentationContext = YES;
    

    
}


-(void)viewWillAppear:(BOOL)animated{
    
    //update navigation bar
    EQRModeManager* modeManager = [EQRModeManager sharedInstance];
    if (modeManager.isInDemoMode){
        
        //set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = @"!!! DEMO MODE !!!";
        
        //set color of navigation bar
        EQRColors* colors = [EQRColors sharedInstance];
        self.navigationController.navigationBar.barTintColor = [colors.colorDic objectForKey:EQRColorDemoMode];
        [UIView setAnimationsEnabled:YES];
        
    }else{
        
        //set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = nil;
        
        //set color of navigation bar
        self.navigationController.navigationBar.barTintColor = nil;
        [UIView setAnimationsEnabled:YES];
    }
    
 
    
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
    
    
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{

    //this doesn't really help...
//    [UIView animateWithDuration:0.1 animations:^{
//        self.mySearchController.searchBar.frame = CGRectMake(0, 0, self.searchBoxView.frame.size.width, self.searchBoxView.frame.size.height);
//    }];
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
    
    //test if in search, tap out
    if (self.mySearchController.active){
        return;
    }
    
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


        
        //_____!!!!  a modal view that asks for a quantity for the generic title scananed?...
        
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
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                
                //should also test the the item has not already been give a YES value for the 'myProperty' value
                //otherwise it continues to the next segment, adding it as a new item to the order
                if ([joinObject respondsToSelector:NSSelectorFromString(self.myProperty)]){
                    
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
                self.arrayOfEquipJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfEquipJoins withMiscJoins:self.arrayOfMiscJoins];
                
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
    self.tableTopGuideConstraint.constant = 150.f;
    
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
        NSArray* ayeArray = [NSArray arrayWithObjects:@"key_id", thisKeyID, nil];
        NSArray* beeArray = [NSArray arrayWithObject:ayeArray];
        [webData queryForStringWithLink:@"EQDeleteScheduleEquipJoin.php" parameters:beeArray];
    }
    
    //delete the marked miscJoin
    for (NSString* thisKeyID in self.arrayOfToBeDeletedMiscJoins){
        
        //send php message to delete with the join key_id
        NSArray* ayeArray = [NSArray arrayWithObjects:@"key_id", thisKeyID, nil];
        NSArray* beeArray = [NSArray arrayWithObject:ayeArray];
        [webData queryForStringWithLink:@"EQDeleteMiscJoin.php" parameters:beeArray];
    }
    
    
    //empty the arrays
    [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
    [self.arrayOfToBeDeletedMiscJoins removeAllObjects];
    
    //renew the array of equipment
//    [self renewTheArrayWithScheduleTracking_foreignKey:self.scheduleRequestKeyID];
    [self initialSetupStage2];
    
    //reload the collection view
//    [self.myEquipCollection reloadData];
    
    //send note to schedule that a change has been saved
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
}



#pragma mark - navigation buttons

-(void)cancelAction{

    [self.webDataForEquipJoins stopXMLParsing];
    [self.webDataForMiscJoins stopXMLParsing];
    self.webDataForMiscJoins.delegateDataFeed = nil;
    self.webDataForEquipJoins.delegateDataFeed = nil;
    
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
    
    //2 strings to use in message text
    NSString *userName = staffManager.currentStaffUser.first_and_last;
    NSString *typeOfMark;
    if ([self.myProperty isEqualToString:@"prep_flag"]){
        typeOfMark = @"Prepped";
    }else if ([self.myProperty isEqualToString:@"checkout_flag"]){
        typeOfMark = @"Checked Out";
    }else if ([self.myProperty isEqualToString:@"checkin_flag"]){
        typeOfMark = @"Checked in";
    }else if ([self.myProperty isEqualToString:@"shelf_flag"]) {
        typeOfMark = @"Shelved";
    }else{
        typeOfMark = @"Error in TypeOfMark";
    }

    UIAlertView *alertConfirmation = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Mark as %@", typeOfMark] message:[NSString stringWithFormat:@"Stamped with staff signature: %@", userName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    [alertConfirmation show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1){
        [self confirmMarkAsComplete];
    }
}

-(void)confirmMarkAsComplete{
    
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
    
    //make special note if any of the joins in the ivar array are not complete **NOW for MiscJoins**
    for (EQRMiscJoin* join in self.arrayOfMiscJoins){
        
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
    [webData queryWithLink:@"EQGetScheduleRequestInComplete.php" parameters:secondRequestArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        if ([muteArray count] > 0){
            
        chosenItem = [muteArray objectAtIndex:0];
        }
    }];
    
    //add the notes
    chosenItem.notes = self.notesText;
//    NSLog(@"these are the notes >>%@<<", chosenItem.notes);
    
    //add contact information
    NSString* email;
    NSString* phone;
    if (self.myScheduleRequestItem.contactNameItem){
        email = self.myScheduleRequestItem.contactNameItem.email;
        phone = self.myScheduleRequestItem.contactNameItem.phone;
        
        chosenItem.contactNameItem = self.myScheduleRequestItem.contactNameItem;
    }

    
    //create printable page view controller
    EQRCheckPrintPage* pageForPrint = [[EQRCheckPrintPage alloc] initWithNibName:@"EQRCheckPrintPage" bundle:nil];
    
    //add the request item to the view controller
    [pageForPrint initialSetupWithScheduleRequestItem:chosenItem];
    
    //assign ivar variables
    pageForPrint.rentorNameAtt = chosenItem.contact_name;
    pageForPrint.rentorEmailAtt = email;
    pageForPrint.rentorPhoneAtt = phone;
    
    
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
    BOOL isContentForMiscJoin = [[[note userInfo] objectForKey:@"isContentForMiscJoin"] boolValue];
    
    if (isContentForMiscJoin == NO){
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
                break;
            }
        }
        
    }else{
        
        for (EQRMiscJoin* miscJoin in self.arrayOfMiscJoins){
            
            if ([miscJoin.key_id isEqualToString:joinKeyID]){
                
                //gotta cutoff the "_flag" at the end or else is will capitalize the "F"
                NSUInteger thisLength = [joinProperty length];
                NSRange newRange = NSMakeRange(0, thisLength - 5);
                NSString* joinSubstring = [joinProperty substringWithRange:newRange];
                
                NSString* joinPropertyWithCap = [joinSubstring capitalizedString];
                NSString* joinPropertySetMethod = [NSString stringWithFormat:@"set%@_flag:", joinPropertyWithCap];
                SEL mySelector = NSSelectorFromString(joinPropertySetMethod);
                
                if ([miscJoin respondsToSelector:mySelector]){
                    
                    [miscJoin performSelector:mySelector withObject:verdict];
                }
                break;
            }
        }
    }
}
#pragma clang diagnostic pop



-(void)addJoinKeyIDToBeDeletedArray:(NSNotification*)note{
    
    BOOL isContentForMiscJoin = [[note.userInfo objectForKey:@"isContentForMiscJoin"] boolValue];
    
    if (isContentForMiscJoin == NO){
        [self.arrayOfToBeDeletedEquipIDs addObject:[note.userInfo objectForKey:@"key_id"]];
    }else{
        [self.arrayOfToBeDeletedMiscJoins addObject:[note.userInfo objectForKey:@"key_id"]];
    }
    
}

-(void)removeJoinKeyIDToBeDeletedArray:(NSNotification*)note{
    
    BOOL isContentForMiscJoin = [[note.userInfo objectForKey:@"isContentForMiscJoin"] boolValue];
    
    NSString* stringToBeRemoved;
    
    if (isContentForMiscJoin == NO){
        for (NSString* thisString in self.arrayOfToBeDeletedEquipIDs){
            
            if ([thisString isEqualToString:[note.userInfo objectForKey:@"key_id"]]){
                
                stringToBeRemoved = thisString;
            }
        }
        [self.arrayOfToBeDeletedEquipIDs removeObject:stringToBeRemoved];
        
    }else{
        
        for (NSString* thisString in self.arrayOfToBeDeletedMiscJoins){
            
            if ([thisString isEqualToString:[note.userInfo objectForKey:@"key_id"]]){
                
                stringToBeRemoved = thisString;
            }
        }
        [self.arrayOfToBeDeletedMiscJoins removeObject:stringToBeRemoved];
    }
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
    CGRect fixedRect6 = [thisButton.superview.superview.superview.superview.superview.superview convertRect:fixedRect5 fromView:thisButton.superview.superview.superview.superview.superview];
//    CGRect fixedRect7 = [thisButton.superview.superview.superview.superview.superview.superview.superview convertRect:fixedRect6 fromView:thisButton.superview.superview.superview.superview.superview.superview];
//    CGRect fixedRect8 = [thisButton.superview.superview.superview.superview.superview.superview.superview.superview convertRect:fixedRect7 fromView:thisButton.superview.superview.superview.superview.superview.superview.superview];
    
    //present popover
    [self.distIDPopover presentPopoverFromRect:fixedRect6 inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
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
    self.arrayOfEquipJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfEquipJoins withMiscJoins:self.arrayOfMiscJoins];
    
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
//    [self renewTheArrayWithScheduleTracking_foreignKey:self.myScheduleRequestItem.key_id];
    [self initialSetupStage2];
    
    
    //this is necessary
//    [self.myEquipCollection reloadData];
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


#pragma mark - capture signature

-(IBAction)captureSig:(id)sender{
    
    UIStoryboard *captureStoryboard = [UIStoryboard storyboardWithName:@"SigCapture" bundle:nil];
    UINavigationController *newView = [captureStoryboard instantiateViewControllerWithIdentifier:@"main"];
    newView.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:newView animated:YES completion:^{
        
        
        
    }];
    
}


#pragma mark - webdata delegate methods

-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    
    //abort if selector is unrecognized, otherwise crash
    if (![self respondsToSelector:action]){
        NSLog(@"inside EQRCheckVC, cannot perform selector: %@", NSStringFromSelector(action));
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    [self performSelector:action withObject:currentThing];
    
#pragma clang diagnostic pop
    
}

-(void)addRequestObject:(id)currentThing{
    
    if (!currentThing){
        return;
    }
    
    //set reqeust item property
    self.myScheduleRequestItem = currentThing;
    
    //set notes for dispaly
    self.notesText = self.myScheduleRequestItem.notes;
    
    
}

-(void)addContactComplete:(id)currentThing{
    
    if (!currentThing){
        return;
    }
    
    //set property
    self.tempContact = currentThing;
    
}

-(void)addEquipJoinToArray:(id)currentThing{
 
    float delayTime = 0.0;
    
    double currentTime = [[NSDate date] timeIntervalSince1970];
    
    if (!self.timeOfLastCallback || (self.timeOfLastCallback == 0)){
        self.timeOfLastCallback = currentTime;
    }
    
    //delay between calls is 0.05 seconds
    delayTime = self.timeOfLastCallback - currentTime  + 0.1;
    
    //guard against a negative delay
    if (delayTime < 0.05) delayTime = 0.05;
    
    self.timeOfLastCallback = currentTime + delayTime;
    
    NSLog(@"this is the delay time: %f", delayTime);
    
    [self performSelector:@selector(addEquipJoinToArrayAfterDelay:) withObject:currentThing afterDelay:delayTime];
    
}



-(void)addMiscJoinToArray:(id)currentThing{
    
    if (!currentThing){
        return;
    }
    
    [self.arrayOfMiscJoins addObject:currentThing];
    [self genericAddItemToArray:currentThing];
}

-(void)addEquipJoinToArrayAfterDelay:(id)currentThing{
    
    
    if (!currentThing){
        return;
    }
    
    [self.arrayOfEquipJoins addObject:currentThing];
    [self genericAddItemToArray:currentThing];
    
}


-(void)genericAddItemToArray:(id)currentThing{
    
    if (!currentThing){
        return;
    }
    
    __block NSInteger indexPathSection;
    __block NSInteger indexPathRow;
    
    //sort
    self.arrayOfEquipJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfEquipJoins withMiscJoins:self.arrayOfMiscJoins];
    
    [self.arrayOfEquipJoinsWithStructure enumerateObjectsUsingBlock:^(NSArray *subArray, NSUInteger idx, BOOL *stop) {
        
        [subArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx2, BOOL *stop2) {
            
            if (obj == currentThing){
                indexPathRow = idx2;
                indexPathSection = idx;
            }
        }];
    }];
    
    //test if need to create new section
    BOOL createNewSection = NO;
    NSInteger countOfSectionInCollectionView;
    countOfSectionInCollectionView = [self.myEquipCollection numberOfSections];
    if (([self.arrayOfEquipJoinsWithStructure count] - countOfSectionInCollectionView) > 0 ){
        createNewSection = YES;
    }
    
    //the new index of the newly added item
    NSIndexPath *chosenIndexPath = [NSIndexPath indexPathForRow:indexPathRow inSection:indexPathSection];
    
    //    NSLog(@"this is the indexPathRow and Section for equipItem: %ld, %ld", (long)indexPathRow, (long)indexPathSection);
    //    NSLog(@"this is the current number for sections in the collection: %ld", (long)[self.myEquipCollection numberOfSections]);
    
    //uptick on the index
    //    self.indexOfLastReturnedItem = self.indexOfLastReturnedItem + 1;

    
    
    [self.myEquipCollection performBatchUpdates:^{
    
        //if necessary, insert section in collection view
        if (createNewSection){
            //            NSLog(@"yes, i'm creating a new section");
            NSIndexSet *indexSet;
            indexSet = [NSIndexSet indexSetWithIndex:indexPathSection];
            [self.myEquipCollection insertSections:indexSet];
        }
        
        //insert row in the collection view
        NSMutableArray *tempArray = [NSMutableArray arrayWithObject:chosenIndexPath];
        [self.myEquipCollection insertItemsAtIndexPaths:tempArray];
        
    } completion:^(BOOL finished) {
        NSLog(@"finished batch updates");
    }];

    

    
    
}



#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    if (self.mySearchController.active){
        
    }
    
    
    NSString *searchString = [self.mySearchController.searchBar text];
    
    if ([searchString isEqualToString:@""]){
        searchString = @" ";
    }
    
    //    NSLog(@"inside updateSearchResultsForSearchController with search text: %@", searchString);
    
    NSString *scope = nil;
    
    [self filterContentForSearchText:searchString scope:scope];
    
    [self.myEquipCollection reloadData];
}

#pragma mark - UISearchBarDelegate

// Workaround for bug: -updateSearchResultsForSearchController: is not called when scope buttons change
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.mySearchController];
}



- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
}


#pragma mark - Content Filtering

//Basically, a predicate is an expression that returns a Boolean value (true or false). You specify the search criteria in the format of NSPredicate and use it to filter data in the array. As the search is on the name of recipe, we specify the predicate as “name contains[c] %@”. The “name” refers to the name property of the Recipe object. NSPredicate supports a wide range of filters including: BEGINSWITH, ENDSWITH, LIKE, MATCHES, CONTAINS. Here we choose to use the “contains” filter. The operator “[c]” means the comparison is case-insensitive.

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    self.searchResultArrayOfEquipTitles = [self.arrayOfEquipJoins filteredArrayUsingPredicate:resultPredicate];
}




#pragma mark - datasource methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    //test if in search, tap out with 1
    if (self.mySearchController.active){
        return 1;
    }else{
        return [self.arrayOfEquipJoinsWithStructure count];
    }
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    //test if in search, tap out with count of search array
    if (self.mySearchController.active){
        return [self.searchResultArrayOfEquipTitles count];
    }
    
    return  [[self.arrayOfEquipJoinsWithStructure objectAtIndex:section] count];
}


-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //__1__ An equipUniqueJoin item
    //__2__ A MiscJoin Item
    
    //_______determine either search results table or normal table
    if (self.mySearchController.active) {
        
        EQRCheckRowCell* cell = [self.myEquipCollection dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        
        //remove subviews
        for (UIView* view in cell.contentView.subviews){
            
            [view removeFromSuperview];
        }
        
        //and reset the cell's background color...
        cell.backgroundColor = [UIColor whiteColor];
        
        //tell the cell's contentVC to be marked for deletion or not
        BOOL toBeDeleted = NO;
        for (NSString* keyToDelete in self.arrayOfToBeDeletedEquipIDs){
            
            if ([keyToDelete isEqualToString:[[self.searchResultArrayOfEquipTitles objectAtIndex:indexPath.row] key_id]]){
                
                toBeDeleted = YES;
            }
        }
        
        //cell setup
        [cell initialSetupWithEquipUnique:[self.searchResultArrayOfEquipTitles objectAtIndex:indexPath.row]
                                   marked:self.marked_for_returning
                               switch_num:self.switch_num
                        markedForDeletion:toBeDeleted
                                indexPath:indexPath];
        
        return cell;
    }
    
    if ([[[self.arrayOfEquipJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] respondsToSelector:@selector(schedule_grouping)]){
        
        EQRCheckRowCell* cell = [self.myEquipCollection dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        
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
        
    }else{
        
        EQRCheckRowMiscItemCell* cell = [self.myEquipCollection dequeueReusableCellWithReuseIdentifier:@"CellForMiscJoin" forIndexPath:indexPath];
        
        //remove subviews
        for (UIView* view in cell.contentView.subviews){
            
            [view removeFromSuperview];
        }
        
        //and reset the cell's background color...
        cell.backgroundColor = [UIColor whiteColor];
        
        //tell the cell's contentVC to be marked for deletion or not
        BOOL toBeDeleted = NO;
        for (NSString* keyToDelete in self.arrayOfToBeDeletedMiscJoins){
            
            if ([keyToDelete isEqualToString:[[[self.arrayOfEquipJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] key_id]]){
                
                toBeDeleted = YES;
                break;
            }
        }
        
        //cell setup
        [cell initialSetupWithMiscJoin:[(NSArray*)[self.arrayOfEquipJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]
                                   marked:self.marked_for_returning
                               switch_num:self.switch_num
                        markedForDeletion:toBeDeleted
                                indexPath:indexPath];
        
        return cell;
    }
};


#pragma mark - section header data source methods

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"SupplementaryCell";
    EQRCheckHeaderCell* cell = [self.myEquipCollection dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //remove subviews?????
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    //test if in search mode, and tap out
    if (self.mySearchController.active){
        [cell initialSetupWithCategoryText:@"Search Results"];
        return  cell;
    }
    
    if ([[[self.arrayOfEquipJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:0] respondsToSelector:@selector(schedule_grouping)]){
        NSString* categoryStringValue = [(EQRScheduleTracking_EquipmentUnique_Join*)[(NSArray*)[self.arrayOfEquipJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] schedule_grouping];
        
        [cell initialSetupWithCategoryText:categoryStringValue];
    }else{
        
        [cell initialSetupWithCategoryText:@"Miscellaneous"];
    }
    
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
