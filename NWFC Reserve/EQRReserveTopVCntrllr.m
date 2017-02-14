//
//  EQRFirstViewController.m
//  NWFC Reserve
//
//  Created by Japhy Ryder on 11/6/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import "EQRReserveTopVCntrllr.h"
#import "EQRWebData.h"
#import "EQRContactNameCell.h"
#import "EQRContactNameItem.h"
#import "EQRClassCell.h"
#import "EQRClassItem.h"
#import "EQREquipSelectionVCntrllr.h"
#import "EQRClassRegistrationItem.h"
#import "EQRScheduleRequestManager.h"
#import "EQRScheduleRequestItem.h"
#import "EQRGlobals.h"
#import "EQREquipUniqueItem.h"
#import "EQRModeManager.h"
#import "EQRColors.h"


@interface EQRGetContactItemOperation : NSOperation
@property (strong, nonatomic) EQRContactNameItem *contactItem;
-(id)initWithKeyID:(NSString *)key_id;
@end

@interface EQRGetContactItemOperation ()
@property (strong, nonatomic) NSString *key_id;
@end

@implementation EQRGetContactItemOperation

-(id)initWithKeyID:(NSString *)key_id{
    _key_id = key_id;
    return [super init];
}

-(void)main{
    NSArray *topArray = @[ @[@"key_id", self.key_id]];
    EQRWebData *webData = [EQRWebData sharedInstance];
    [webData queryWithLink:@"EQGetContactCompleteWithKey.php" parameters:topArray class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
        if ([muteArray count] < 1){
            NSLog(@"EQRGetContactItemOperation > main, no contact returned with contact foreign key");
            return;
        }
        self.contactItem = [muteArray objectAtIndex:0];
    }];
}

@end


@interface EQRCreateNewRequestOperation : NSOperation
-(id)initWithContact:(EQRContactNameItem *)contact requestManager:(EQRScheduleRequestManager *)requestManager class:(EQRClassItem *)class renterType:(NSString *)renterType;
@end

@interface EQRCreateNewRequestOperation ()
@property (strong, nonatomic) EQRContactNameItem *contactNameItem;
@property (weak, nonatomic) EQRScheduleRequestManager *requestManager;
@property (weak, nonatomic) EQRClassItem *classItem;
@property (weak, nonatomic) NSString *chosenRenterType;
@end


@implementation EQRCreateNewRequestOperation

-(id)initWithContact:(EQRContactNameItem *)contact requestManager:(EQRScheduleRequestManager *)requestManager class:(EQRClassItem *)class renterType:(NSString *)renterType{
    _contactNameItem = contact;
    _requestManager = requestManager;
    _classItem = class;
    _chosenRenterType = renterType;

    return [super init];
}

-(void)main{
    
    if (!self.contactNameItem){
        if ([self.dependencies count] > 0){
            self.contactNameItem = [(EQRGetContactItemOperation *)[self.dependencies objectAtIndex:0] contactItem];
        }
    }
    
    // Despite the callback, this method is SYNCHRONOUS
    [self.requestManager createNewRequest:^(NSString *returnValue) {
        
    }];
    
    // Assign contact and class to the request
    // First to the object properties
    self.requestManager.request.contactNameItem = self.contactNameItem;
    self.requestManager.request.classItem = self.classItem;
    
    // Second to the data model properties
    self.requestManager.request.contact_foreignKey = self.requestManager.request.contactNameItem.key_id;
    self.requestManager.request.classSection_foreignKey = self.classItem.key_id;
    self.requestManager.request.classTitle_foreignKey = self.classItem.catalog_foreign_key;
    self.requestManager.request.contact_name = self.requestManager.request.contactNameItem.first_and_last;
    self.requestManager.request.renter_type = self.chosenRenterType;
}

@end



@interface EQRReserveTopVCntrllr ()

@property (strong, nonatomic) NSArray* contactNameArray;
@property (strong, nonatomic) NSArray* renterTypeArray;
@property (strong, nonatomic) EQRClassItem* thisClassItem;
@property (strong, nonatomic) EQRClassRegistrationItem* thisClassRegistration;
@property (strong, nonatomic) NSString* chosenRenterType;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *renterWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *classWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *nameWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *renterLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *nameListLeadingConstraint;

@property BOOL hideNameListFlag;
@property BOOL hideClassListFlag;
@property BOOL needsToRetrieveAllUniqueEquipItemsFlag;

//contact & class picker
@property (weak, nonatomic) EQRContactPickerVC* myContactPickerVC;
@property (weak, nonatomic) EQRClassPickerVC *myClassPickerVC;


@end

@implementation EQRReserveTopVCntrllr

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //register for notification
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    //observe for voiding schedule tracking item
    [nc addObserver:self selector:@selector(startNewDisplay:) name:EQRVoidScheduleItemObjects object:nil];
    //observe for change to the database
    [nc addObserver:self selector:@selector(startNewDisplay:) name:EQRAChangeWasMadeToTheDatabaseSource object:nil];
    
    //register collection view cells
    [self.rentorTypeListTable registerClass:[EQRCellTemplate class] forCellWithReuseIdentifier:@"Cell"];

    //populate renterTypeArray
    if (!self.renterTypeArray){
        
        self.renterTypeArray = @[ [EQRRenterStudent capitalizedString],
                                  [EQRRenterFaculty capitalizedString],
                                  [EQRRenterStaff capitalizedString],
                                  [EQRRenterPublic capitalizedString],
                                  [EQRRenterYouth capitalizedString],
                                  [EQRRenterInClass capitalizedString] ];
    }
    
    //peform startNewDisplay (to avoid dupicating code
    [self startNewDisplay:nil];
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
    
    [super viewWillAppear:animated];
}

-(void)viewDidLayoutSubviews{
    
    //________Accessing childviewcontrollers
    NSArray* arrayOfChildVCs = [self childViewControllers];
    
    //viewDidLayoutSubviews is called often (during a rotation). Only intitiate a view controller if it doesn't yet exist
    if (!self.myContactPickerVC){
        
        if ([arrayOfChildVCs count] > 0){
            
            for (UIViewController *childVCItem in arrayOfChildVCs){
                
                if ([childVCItem.title isEqualToString:@"NavForContact"] ){
                    
                    EQRContactPickerVC* contactPickerVC = (EQRContactPickerVC*)[(UINavigationController*)childVCItem topViewController];
                    
                    //assign to weak ivar
                    self.myContactPickerVC = contactPickerVC;
                    
                    //set self as delegate
                    self.myContactPickerVC.delegate = self;
                    
                    //initially, no content
                    NSArray* noneArray = @[];
                    
                    [self.myContactPickerVC replaceDefaultContactArrayWith:noneArray];
                    
                    //initially hide the view controller
                    [self.myContactPickerVC.view setHidden:YES];
                }
                
                if ([childVCItem.title isEqualToString:@"NavForClass"] ){
                    
                    EQRClassPickerVC* classPickerVC = (EQRClassPickerVC*)[(UINavigationController*)childVCItem topViewController];
                    
                    //assign to weak ivar
                    self.myClassPickerVC = classPickerVC;
                    
                    //set self as delegate
                    self.myClassPickerVC.delegate = self;
                }
            }
            
        }else{
            
            //error handling
        }
    }
}


#pragma mark - EQRContactPickerVC delegate methods

-(void)retrieveSelectedNameItem{
    
    // Retrieve name item from shared nib
    EQRContactNameItem* myNameItem = [self.myContactPickerVC retrieveContactItem];
    
    //______****** cancel any existing scheduleRequestItems first???  ******___________
    
    // Create a scheduleRequestItem instance
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"retrieveSelectedNameItem";
    queue.maxConcurrentOperationCount = 5;
    
    
    EQRCreateNewRequestOperation *createNewRequest = [[EQRCreateNewRequestOperation alloc] initWithContact:myNameItem
                                                                                            requestManager:requestManager
                                                                                                     class:self.thisClassItem
                                                                                                renterType:self.chosenRenterType];
    
    
    NSBlockOperation *performSegue = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
   
            [self performSegueWithIdentifier:@"lookAtDates" sender:self];
        });
    }];
    [performSegue addDependency:createNewRequest];
    
    
    [queue addOperation:createNewRequest];
    [queue addOperation:performSegue];
}


#pragma mark - classPickerVC delegate method

-(void)initiateRetrieveClassItem:(EQRClassItem *)selectedClassItem{
    
    self.thisClassItem = selectedClassItem;
    
    // Discern between a student renter and an inClass (faculty) renter
    if ([self.chosenRenterType isEqualToString:EQRRenterYouth] || [self.chosenRenterType isEqualToString:EQRRenterInClass]){
        
        //______****** cancel any existing scheduleRequestItems first?
        
        // When no intructor_foreign_key exists
        if (([self.thisClassItem.instructor_foreign_key isEqualToString:@""]) || (self.thisClassItem.instructor_foreign_key == NULL)){

            [self populateNamesWithRequest:@"EQGetFacultyNames.php" params:nil];
            
        } else {
            
            // Create a scheduleRequestItem instance
            EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            queue.name = @"foundClassInstructor";
            queue.maxConcurrentOperationCount = 1;
            
            EQRGetContactItemOperation *getContactItem = [[EQRGetContactItemOperation alloc] initWithKeyID:self.thisClassItem.instructor_foreign_key];
            
            
            EQRCreateNewRequestOperation *createNewRequest = [[EQRCreateNewRequestOperation alloc] initWithContact:nil
                                                                                                    requestManager:requestManager
                                                                                                             class:self.thisClassItem
                                                                                                        renterType:self.chosenRenterType];
            [createNewRequest addDependency:getContactItem];
            
            
            NSBlockOperation *segue = [NSBlockOperation blockOperationWithBlock:^{
               dispatch_async(dispatch_get_main_queue(), ^{
                   [self performSegueWithIdentifier:@"lookAtDates" sender:self];
               });
            }];
            [segue addDependency:createNewRequest];
            
            
            [queue addOperation:getContactItem];
            [queue addOperation:createNewRequest];
            [queue addOperation:segue];
        }
        
    }else if ([self.chosenRenterType isEqualToString:EQRRenterStudent]) {
        
        NSArray* params = @[ @[@"classSection_foreignKey", self.thisClassItem.key_id] ];
        [self populateNamesWithRequest:@"EQGetStudentNamesWithSectionKey.php" params:params];
        
    } else {
        
        NSLog(@"EQRReserverTopVC > initiateRetrieveClassItem, unregonized selection type");
    }
    
}


#pragma mark - helper functions for populating name list

-(void)populateNamesWithRequest:(NSString *)request params:(NSArray *)params{
    
    // Show name list
    [self.myContactPickerVC.view setHidden:NO];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"selectInstructor";
    queue.maxConcurrentOperationCount = 1;
    
    
    NSBlockOperation *getFacultyNames = [NSBlockOperation blockOperationWithBlock:^{
        
        EQRWebData* webData2 = [EQRWebData sharedInstance];
        [webData2 queryWithLink:request parameters:params class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
            if (!muteArray){
                NSLog(@"EQRReserveTopVC > initiate..., failed to get faculty names");
                return;
            }
            
            // Alphabatize the name list
            NSArray* tempMuteArrayAlpha = [muteArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSString* string1 = [(EQRContactNameItem*)obj1 first_and_last];
                NSString* string2 = [(EQRContactNameItem*)obj2 first_and_last];
                return [string1 compare:string2];
            }];
            
            self.contactNameArray = tempMuteArrayAlpha;
        }];
    }];
    
    
    NSBlockOperation *populateNameArray = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.myContactPickerVC replaceDefaultContactArrayWith:self.contactNameArray];
        });
    }];
    [populateNameArray addDependency:getFacultyNames];
    
    
    [queue addOperation:getFacultyNames];
    [queue addOperation:populateNameArray];
}


#pragma mark - return to start screen

-(void)startNewDisplay:(NSNotification*)note{
    
    // Deselect type
    [self.rentorTypeListTable reloadData];
    
    // Deselect chosenType
    self.chosenRenterType = @"UNKNOWN";
    
    // Delesect class item and registration
    self.thisClassItem = nil;
    self.thisClassRegistration = nil;
    
    // Set flags
    self.hideNameListFlag = YES;
    self.hideClassListFlag = YES;
    
    // Delete info in collection views
    [self.myClassPickerVC reloadTheData];
    
    // Expand size of rentor type list
    self.renterWidthConstraint.constant = 230;
    self.classWidthConstraint.constant = 0;
    self.renterLeadingConstraint.constant = EQRRentorTypeLeadingSpace;
    self.nameListLeadingConstraint.constant = 1 - EQRRentorTypeLeadingSpace;
    
    // Animate change
    [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        // Empty content in name list
        NSArray* noneArray = @[];
        [self.myContactPickerVC replaceDefaultContactArrayWith:noneArray];
    }];
    
    //hide name list until a type is selected
    [self.myContactPickerVC.view setHidden:YES];
}


#pragma mark - collectionView datasource methods


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (collectionView == self.rentorTypeListTable){
        return [self.renterTypeArray count];
    }
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(collectionView == self.rentorTypeListTable){
        
        static NSString* CellIdentifier  = @"Cell";
        EQRCellTemplate* cell = [self.rentorTypeListTable dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //remove subviews
        for (UIView* view in cell.contentView.subviews){
            
            [view removeFromSuperview];
        }
        
        if ([self.renterTypeArray count] > 0) {
            
            [cell initialSetupWithTitle:[self.renterTypeArray objectAtIndex:indexPath.row]];
        } else {
            
            NSLog(@"No count in the renter type array");
        }
        
        cell.backgroundColor = [UIColor clearColor];
        return cell;
        
    } else{
        
        NSLog (@"no identified collection view");
        
        //is this OK???_____
        return nil;
    }
};


#pragma mark - collection view delegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //highlight cell manually (booo)
    EQRCellTemplate* selectedCell = (EQRCellTemplate*)[collectionView cellForItemAtIndexPath:indexPath];
    [selectedCell doHighlightCell];
    
    //unhighlight all other visible cells
    NSArray* arrayOfVisibleCells =  [collectionView visibleCells];
    [arrayOfVisibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ((EQRCellTemplate*)obj != selectedCell){
            
            [obj cancelHighlightCell];
        }
    }];
    
    if (collectionView == self.rentorTypeListTable){
        
        //reveal class list
        self.hideClassListFlag = NO;
        
        //rentor type is selected
        switch (indexPath.row) {
                
            case (0):{ //student (adult)
                
                //set rentorType for request object
                self.chosenRenterType = EQRRenterStudent;
                
                //contact size of renter type list
                self.renterWidthConstraint.constant = 120;
                self.classWidthConstraint.constant = 354;
                self.renterLeadingConstraint.constant = 0.0;
                self.nameListLeadingConstraint.constant = 2.0;
                [self.myClassPickerVC goToSegmentNumber:1];
                
                //animate change
                [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
                    
                    [self.view layoutIfNeeded];
                }];
                
                //remove whatever currently exists in the contact tables
                self.contactNameArray = nil;
                
                //empty out the contactPicker table
                NSArray* noneArray = @[];
                
                //hand array to contactPickerVC
                [self.myContactPickerVC replaceDefaultContactArrayWith:noneArray];
                
                //hide name list until a type is selected
                [self.myContactPickerVC.view setHidden:YES];
                
                break;
                
            } case (1):{ //faculty
                
                //set rentorType for request object
                self.chosenRenterType = EQRRenterFaculty;
                
                // Contact size of renter type list
                self.renterWidthConstraint.constant = 230;
                self.classWidthConstraint.constant = 0;
                self.renterLeadingConstraint.constant = EQRRentorTypeLeadingSpace;
                self.nameListLeadingConstraint.constant = 1 - EQRRentorTypeLeadingSpace;
                
                // Animate change
                [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
                    [self.view layoutIfNeeded];
                }];
                
                // Remove whatever currently exists in the class and contact tables
                self.contactNameArray = nil;

                // Populate nameList table with names of faculty
                [self populateNamesWithRequest:@"EQGetFacultyNames.php" params:nil];
                
                break;
                
            }case (2):{ //staff
                
                //set rentorType for request object
                self.chosenRenterType = EQRRenterStaff;
                
                //contact size of renter type list
                self.renterWidthConstraint.constant = 230;
                self.classWidthConstraint.constant = 0;
                self.renterLeadingConstraint.constant = EQRRentorTypeLeadingSpace;
                self.nameListLeadingConstraint.constant = 1 - EQRRentorTypeLeadingSpace;
                
                //animate change
                [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
                    
                    [self.view layoutIfNeeded];
                }];
                
                //remove whatever currently exists in the class and contact tables
                self.contactNameArray = nil;
                
                //_____populate nameList table with names of staff
                [self populateNamesWithRequest:@"EQGetStaffNames.php" params:nil];
                
                break;
                
            }case (3):{ //public
                
                //set rentorType for request object
                self.chosenRenterType = EQRRenterPublic;
                
                //contact size of renter type list
                self.renterWidthConstraint.constant = 230;
                self.classWidthConstraint.constant = 0;
                self.renterLeadingConstraint.constant = EQRRentorTypeLeadingSpace;
                self.nameListLeadingConstraint.constant = 1 - EQRRentorTypeLeadingSpace;
                
                //animate change
                [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
                    [self.view layoutIfNeeded];
                }];
                
                //remove whatever currently exists in the class and contact tables
                self.contactNameArray = nil;
                
                [self.myContactPickerVC replaceDefaultContactArrayWith:nil];
                
                //********  reveal name list  **********
                [self.myContactPickerVC.view setHidden:NO];
                
                break;
                
            }case (4):{ //youth camp
                
                //set rentorType for request object
                self.chosenRenterType = EQRRenterYouth;
                
                //contact size of renter type list
                self.renterWidthConstraint.constant = 120;
                self.classWidthConstraint.constant = 354;
                //contact size of rentor type list
                self.renterLeadingConstraint.constant = 0.0;
                self.nameListLeadingConstraint.constant = 2.0;
                [self.myClassPickerVC goToSegmentNumber:2];
                
                //animate change
                [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
                    
                    [self.view layoutIfNeeded];
                }];
                
                //remove whatever currently exists in the class and contact tables
                self.contactNameArray = nil;
                
                //empty out the contactPicker table
                NSArray* noneArray = @[];
                
                //hand array to contactPickerVC
                [self.myContactPickerVC replaceDefaultContactArrayWith:noneArray];
                
                //hide name list until a type is selected
                [self.myContactPickerVC.view setHidden:YES];
                
                break;
                
            }case (5):{  //in class
                
                //set rentorType for request object
                self.chosenRenterType = EQRRenterInClass;
                
                //contact size of rentor type list
                self.renterWidthConstraint.constant = 120;
                self.classWidthConstraint.constant = 354;
                self.renterLeadingConstraint.constant = 0.0;
                self.nameListLeadingConstraint.constant = 2.0;
                [self.myClassPickerVC goToSegmentNumber:1];
                
                //animate change
                [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
                    
                    [self.view layoutIfNeeded];
                }];
                
                //remove whatever currently exists in the contact tables
                self.contactNameArray = nil;
                
                //empty out the contactPicker table
                NSArray* noneArray = @[];
                
                //hand array to contactPickerVC
                [self.myContactPickerVC replaceDefaultContactArrayWith:noneArray];
                
                //hide name list until a type is selected
                [self.myContactPickerVC.view setHidden:YES];
                
                break;
            }
                
            default:
                break;
        }
        
        
    }
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
