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



@interface EQRReserveTopVCntrllr ()

@property (strong, nonatomic) NSArray* contactNameArray;
//@property (strong, nonatomic) NSArray* classArray;
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
//    [self.classListTable registerClass:[EQRClassCell class] forCellWithReuseIdentifier:@"Cell"];

    
    //register table view cells

    //populate renterTypeArray
    if (!self.renterTypeArray){
        
        self.renterTypeArray = [NSArray arrayWithObjects:
                                [EQRRenterStudent capitalizedString],
                                [EQRRenterFaculty capitalizedString],
                                [EQRRenterStaff capitalizedString],
                                [EQRRenterPublic capitalizedString],
                                [EQRRenterYouth capitalizedString],
                                [EQRRenterInClass capitalizedString],
                                nil];
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
                    NSArray* noneArray = [NSArray arrayWithObjects: nil];
                    
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
    
    //retrieve name item from shared nib
    EQRContactNameItem* myNameItem = [self.myContactPickerVC retrieveContactItem];
    
    
    
    //______****** cancel any existing scheduleRequestItems first???  ******___________
    
    //create a scheduleRequestItem instance
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    [requestManager createNewRequest];
    
    //assign contact and class to the request
    //first to the object properties
    requestManager.request.contactNameItem = myNameItem;
    requestManager.request.classItem = self.thisClassItem;
    
    //second to the data model properties
    requestManager.request.contact_foreignKey = requestManager.request.contactNameItem.key_id;
    requestManager.request.classSection_foreignKey = self.thisClassItem.key_id;
    requestManager.request.classTitle_foreignKey = self.thisClassItem.catalog_foreign_key;
    requestManager.request.contact_name = requestManager.request.contactNameItem.first_and_last;
    requestManager.request.renter_type = self.chosenRenterType;
    
    
    // requestManager maybe needs to load allEquipUniqueItems
    if (self.needsToRetrieveAllUniqueEquipItemsFlag){
        [requestManager retrieveAllEquipUniqueItems:^(NSMutableArray *muteArray) {
            [self retreiveSelectedNameItemStage2:muteArray];
        }];
    }else{
        [self performSegueWithIdentifier:@"lookAtDates" sender:self];
    }
}

-(void)retreiveSelectedNameItemStage2:(NSMutableArray *)returnArray{
    
    if (returnArray == nil){
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Cannot connect to equipment inventory. Ensure that wifi is on \"Private\" and database URL (in settings) is correct" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        
        [alertView show];
        
        //DON'T segue, cause you won't be able to complete the request succesfully
        return;
    }
    
    //perform segue to show date picker
    [self performSegueWithIdentifier:@"lookAtDates" sender:self];
}


#pragma mark - classPickerVC delegate method

-(void)initiateRetrieveClassItem:(EQRClassItem *)selectedClassItem{
    
    
    //discern between adult, youth and in class
    
    if ([self.chosenRenterType isEqualToString:EQRRenterYouth]){  //youth class
        
        //youth camp was selected
        
        //______****** cancel any existing scheduleRequestItems first???  ******___________
        
        //create a scheduleRequestItem instance
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        
        [requestManager createNewRequest];
        
        //1. the selected class Section
        self.thisClassItem = selectedClassItem;
        
        //assign contact and class to the request
        //first to the object properties
        requestManager.request.contactNameItem = nil;
        requestManager.request.classItem = self.thisClassItem;
        
        //second to the data model properties
        requestManager.request.contact_foreignKey = self.thisClassItem.instructor_foreign_key;
        requestManager.request.classSection_foreignKey = self.thisClassItem.key_id;
        requestManager.request.classTitle_foreignKey = self.thisClassItem.catalog_foreign_key;
        requestManager.request.contact_name = self.thisClassItem.first_and_last;
        requestManager.request.renter_type = self.chosenRenterType;
        
        //            NSLog(@"this is the instructor name: %@ and key: %@", self.thisClassItem.first_and_last, self.thisClassItem.instructor_foreign_key);
        
        //____error handling when no intructor_foreign_key exists_______
        if (([self.thisClassItem.instructor_foreign_key isEqualToString:@""]) || (self.thisClassItem.instructor_foreign_key == NULL)){
            
            //_____populate nameList table with names of faculty
            
            //instantiate mute array
            NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
            
            EQRWebData* webData2 = [EQRWebData sharedInstance];
            
            //pull a list of names, only ones with faculty bool set to 1
            [webData2 queryWithLink:@"EQGetFacultyNames.php" parameters:nil class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
                
                for (id obj in muteArray){
                    
                    [tempMuteArray  addObject:obj];
                }
            }];
            
            //alphabatize the name list
            NSArray* tempMuteArrayAlpha = [tempMuteArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                
                NSString* string1 = [(EQRContactNameItem*)obj1 first_and_last];
                NSString* string2 = [(EQRContactNameItem*)obj2 first_and_last];
                
                return [string1 compare:string2];
                
            }];
            
            self.contactNameArray = tempMuteArrayAlpha;
            
            //hand array to contactPickerVC
            [self.myContactPickerVC replaceDefaultContactArrayWith:self.contactNameArray];
            
            //********  reveal name list  **********
            [self.myContactPickerVC.view setHidden:NO];
            
        } else {
            
            //found instructor foreign key to proceed as per normal with the segue
            
            //perform segue to show date picker
            [self performSegueWithIdentifier:@"lookAtDates" sender:self];
        }
        
        
        
    }else if ([self.chosenRenterType isEqualToString:EQRRenterStudent]) {   //student in adult class
        
        //reveal name list
        [self.myContactPickerVC.view setHidden:NO];
        
        //initialize webData object
        EQRWebData* webData = [EQRWebData sharedInstance];
        
        //1. get key_id of selected class Section
        //2. get list of key_id contacts from class_registrations table
        //3. get list of student names
        
        //1. get key_id of selected class Section
        NSString*  classKeyId = selectedClassItem.key_id;
        //        NSLog(@"this is the classCatalog_foreignKey: %@", thisClass.key_id);
        
        //2. get list of key_id contacts from class_registrations table
        NSArray* regArray = [NSArray arrayWithObjects:@"classSection_foreignKey", classKeyId, nil];
        NSArray* regArray2= [NSArray arrayWithObject:regArray];
        [webData queryWithLink:@"EQGetClassRegistrationsForSectionKey.php" parameters:regArray2 class:@"EQRClassRegistrationItem" completion:^(NSMutableArray* muteArray){
            
            //array of contact key ids
            NSArray* arrayOfClassRegistrationItems = [NSArray arrayWithArray: muteArray];
            //zero out the muteArray
            muteArray = nil;
            
            //_____keep class item on an ivar to use when creating a new scheduleRequest
            self.thisClassItem = selectedClassItem;
            //            NSLog(@"this is the catalog_foreign_key: %@", thisClass.catalog_foreign_key);
            
            //3. get list of student names
            
            //declare a mutablearray
            NSMutableArray* contactNameMuteArray = [NSMutableArray arrayWithCapacity:1];
            
            //repeat this step... to add additional objects to the array
            [arrayOfClassRegistrationItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                //                NSLog(@"class of object: %@ and it's contact_foreingKey: %@", [obj class], [[obj contact_foreignKey] class]);
                
                NSArray* classParam = [NSArray arrayWithObjects: @"key_id", [(EQRClassRegistrationItem*)obj contact_foreignKey], nil];
                NSArray* classParamTotal = [NSArray arrayWithObject:classParam];
                
                //                NSLog(@"count of classParam: %lu", (unsigned long)[classParam count]);
                
                //get student names with query
                EQRWebData* webDataNew = [EQRWebData sharedInstance];
                [webDataNew queryWithLink:@"EQGetStudentNamesCurrent.php" parameters:classParamTotal class:@"EQRContactNameItem" completion:^(NSMutableArray* muteArray2){
                    
                    if ([muteArray2 count] > 0){
                        
                        //                        NSLog(@"muteArray2 has data");
                        
                        //there should only be one object in the returned array__________???
                        [contactNameMuteArray addObject:[muteArray2 objectAtIndex:0]];
                    }
                    
                    [muteArray2 removeAllObjects];
                    
                }];
            }];
            
            
            //alphabatize the class list
            NSArray* tempMuteArrayAlpha = [contactNameMuteArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                
                NSString* string1 = [(EQRContactNameItem*)obj1 first_and_last];
                NSString* string2 = [(EQRContactNameItem*)obj2 first_and_last];
                
                return [string1 compare:string2];
                
            }];
            
            self.contactNameArray = tempMuteArrayAlpha;
            
            //            NSLog(@"count of objects in contactNameMuteArray: %lu", (unsigned long)[contactNameMuteArray count]);
            
            //hand array to contactPickerVC
            [self.myContactPickerVC replaceDefaultContactArrayWith:self.contactNameArray];
            
            
            //is this necessary_____???
            //                [self.nameListTable reloadData];
        }];
        
    } else if ([self.chosenRenterType isEqualToString:EQRRenterInClass]){    //in class
        
        //____identical to youth selection______
        
        //in class was selected
        
        //______****** cancel any existing scheduleRequestItems first???  ******___________
        
        //create a scheduleRequestItem instance
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        
        [requestManager createNewRequest];
        
        //1. the selected class Section
        self.thisClassItem = selectedClassItem;
        
        //assign contact and class to the request
        //first to the object properties
        requestManager.request.contactNameItem = nil;
        requestManager.request.classItem = self.thisClassItem;
        
        //second to the data model properties
        requestManager.request.contact_foreignKey = self.thisClassItem.instructor_foreign_key;
        requestManager.request.classSection_foreignKey = self.thisClassItem.key_id;
        requestManager.request.classTitle_foreignKey = self.thisClassItem.catalog_foreign_key;
        requestManager.request.contact_name = self.thisClassItem.first_and_last;
        requestManager.request.renter_type = self.chosenRenterType;
        
        NSLog(@"this is the instructor name: %@ and key: %@", self.thisClassItem.first_and_last, self.thisClassItem.instructor_foreign_key);
        
        //____error handling when no intructor_foreign_key exists_______
        if (([self.thisClassItem.instructor_foreign_key isEqualToString:@""]) || (self.thisClassItem.instructor_foreign_key == NULL)){
            
            //_____populate nameList table with names of faculty
            
            //instantiate mute array
            NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
            
            EQRWebData* webData2 = [EQRWebData sharedInstance];
            
            //pull a list of names, only ones with faculty bool set to 1
            [webData2 queryWithLink:@"EQGetFacultyNames.php" parameters:nil class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
                
                for (id obj in muteArray){
                    
                    [tempMuteArray  addObject:obj];
                }
            }];
            
            //alphabatize the class list
            NSArray* tempMuteArrayAlpha = [tempMuteArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                
                NSString* string1 = [(EQRContactNameItem*)obj1 first_and_last];
                NSString* string2 = [(EQRContactNameItem*)obj2 first_and_last];
                
                return [string1 compare:string2];
                
            }];
            
            self.contactNameArray = tempMuteArrayAlpha;
            
            //hand array to contactPickerVC
            [self.myContactPickerVC replaceDefaultContactArrayWith:self.contactNameArray];
            
            //********  reveal name list  **********
            [self.myContactPickerVC.view setHidden:NO];
            
        } else {  //perform segue as per normal
            
            //_____use this opportunity to ensure that class catalog entry has both a contact foreign key AND a value in instructor_name
            //_____OR get rid of instructor_name in that database altogther
            
            //perform segue to show date picker
            [self performSegueWithIdentifier:@"lookAtDates" sender:self];
        }
    }
    
    
    
}

#pragma mark - return to start screen

-(void)startNewDisplay:(NSNotification*)note{
    
    //deselect type
    [self.rentorTypeListTable reloadData];
    
    //deselect chosenType
    self.chosenRenterType = @"UNKNOWN";
    
    //delesect class item and registration
    self.thisClassItem = nil;
    self.thisClassRegistration = nil;
    
    //set flags
    self.hideNameListFlag = YES;
    self.hideClassListFlag = YES;
    
    //delete info in collection views
    [self.myClassPickerVC reloadTheData];
    
    //expand size of rentor type list
    self.renterWidthConstraint.constant = 230;
    self.classWidthConstraint.constant = 0;
    self.renterLeadingConstraint.constant = EQRRentorTypeLeadingSpace;
    self.nameListLeadingConstraint.constant = 1 - EQRRentorTypeLeadingSpace;
    
    //animate change
    [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        //empty content in name list
        NSArray* noneArray = [NSArray arrayWithObjects: nil];
        [self.myContactPickerVC replaceDefaultContactArrayWith:noneArray];
    }];
    
    
//    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
//    
//    //refresh the list of ALL equipUniqueItems
//    //_______!!!!!!!!!   if this fails because the database url is wrong, it doesn't get loaded until AFTER the first request is made
//    //________!!!!!!!!!  resulting in the WRONG equipUnique key (Canon XA10 key)
//    NSArray *returnArray = [requestManager retrieveAllEquipUniqueItems];
//    
//    if (returnArray == nil){
////        NSLog(@"returned array is nil");
//        
//        self.needsToRetrieveAllUniqueEquipItemsFlag = YES;
//    }
    
    //hide name list until a type is selected
    [self.myContactPickerVC.view setHidden:YES];
}


#pragma mark - collectionView datasource methods


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  
    //discern between two different tables
    
//    if (collectionView == self.nameListTable){
//        
//        if (self.hideNameListFlag){
//            
//            return 0;
//            
//        }else{
//            
//            return [self.contactNameArray count];
//        }
    
//     if (collectionView == self.classListTable){
//        
//        if (self.hideClassListFlag){
//            
//            return 0;
//            
//        }else {
//
//            return [self.classArray count];
//        }
//        
//    } else
    
    if (collectionView == self.rentorTypeListTable){
        
        return [self.renterTypeArray count];
    }
    
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //discern between different tables
    
//    if (collectionView == self.nameListTable){
//        
//        static NSString* CellIdentifier = @"Cell";
//        EQRContactNameCell* cell = [self.nameListTable dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
//        
//        //remove all subviews
//        for (UIView* view in cell.contentView.subviews){
//            
//            [view removeFromSuperview];
//        }
//        
//        cell.backgroundColor = [UIColor clearColor];
//        [cell setOpaque:YES];
//        
//        if ([self.contactNameArray count] > 0){
//            
//            NSLog(@"this is the class of objects: %@", [[self.contactNameArray objectAtIndex:indexPath.row] class]);
//            
//            NSLog(@"this is the fist and last: %@", [(EQRContactNameItem*)[self.contactNameArray objectAtIndex:indexPath.row] first_and_last]);
//            
//            [cell initialSetupWithTitle:[(EQRContactNameItem*)[self.contactNameArray objectAtIndex:indexPath.row] first_and_last]];
//            
//        }else{
//            
//            NSLog(@"no count in the contact name array");
//        }
//        
//        return cell;
    
//    if (collectionView == self.classListTable){
//        
//        static NSString* CellIdentifier = @"Cell";
//        EQRClassCell* cell = [self.classListTable dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
//        
//        //remove subviews
//        for (UIView* view in cell.contentView.subviews){
//            
//            [view removeFromSuperview];
//        }
//        
//        cell.backgroundColor = [UIColor clearColor];
////        [cell setOpaque:YES];
//        
//        if ([self.classArray count] > 0){
//            
//            [cell initialSetupWithTitle:[(EQRClassItem*)[self.classArray objectAtIndex:indexPath.row] section_name]];
//        } else {
//            
//            NSLog(@"no count in the class array");
//        }
//        
//        return cell;
//        
//    }else
    
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
            
            NSLog(@"No count in the rentor type array");
        }
        
        cell.backgroundColor = [UIColor clearColor];
        return cell;
        
    } else{
        
        NSLog (@"no identified collection view");
        
        //is this OK???_____
        return nil;
    }
};


#pragma mark - table view data source methods

//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    
//    return 1;
//}
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    
//    
//}
//
//-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    
//    
//}



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
//                [self.nameListTable reloadData];
                
                
                
                //get current term from user defaults
//                NSString* termString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"term"] objectForKey:@"term"];
//                
//                //load class table with current term classes and display in collection view
//                EQRWebData* webData = [EQRWebData sharedInstance];
//                
//                //instantiate mute array
//                NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
//                
//                //params for class section query is the current term
//                NSArray* termArray = [NSArray arrayWithObjects:@"term", termString, nil];
//                NSArray* classqueryArray = [NSArray arrayWithObject:termArray];
//                
//                [webData queryWithLink:@"EQGetClassesCurrent.php" parameters:classqueryArray class:@"EQRClassItem" completion:^(NSMutableArray* muteArray){
//                    
//                    for (id object in muteArray){
//                        
//                        [tempMuteArray addObject:object];
//
//                    }
//                }];
//                
//                //alphabatize the class list
//                NSArray* tempMuteArrayAlpha = [tempMuteArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                    
//                    NSString* string1 = [(EQRClassItem*)obj1 section_name];
//                    NSString* string2 = [(EQRClassItem*)obj2 section_name];
//                    
//                    return [string1 compare:string2];
//                    
//                }];
//                
//                self.classArray = tempMuteArrayAlpha;      
//                
//                //yes, this is necessary???
//                [self.classListTable reloadData];
                
                
                
                //empty out the contactPicker table
                NSArray* noneArray = [NSArray arrayWithObjects: nil];
                
                //hand array to contactPickerVC
                [self.myContactPickerVC replaceDefaultContactArrayWith:noneArray];
                
                //hide name list until a type is selected
                [self.myContactPickerVC.view setHidden:YES];
                
                break;
                
            } case (1):{ //faculty
                
                //set rentorType for request object
                self.chosenRenterType = EQRRenterFaculty;
                
                //contact size of renter type list
                self.renterWidthConstraint.constant = 230;
                self.classWidthConstraint.constant = 0;
                //contact size of rentor type list
                self.renterLeadingConstraint.constant = EQRRentorTypeLeadingSpace;
                self.nameListLeadingConstraint.constant = 1 - EQRRentorTypeLeadingSpace;
                
                //animate change
                [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
                    
                    [self.view layoutIfNeeded];
                }];
                
                //remove whatever currently exists in the class and contact tables
                self.contactNameArray = nil;
                
//                self.classArray = nil;
//                [self.classListTable reloadData];

                //_____populate nameList table with names of faculty
                
                //instantiate mute array
                NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
                
                EQRWebData* webData2 = [EQRWebData sharedInstance];
                
                //pull a list of names, only ones with faculty bool set to 1
                [webData2 queryWithLink:@"EQGetFacultyNames.php" parameters:nil class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
                    
                    for (id obj in muteArray){
                        
                        [tempMuteArray  addObject:obj];
                    }
                }];
                
                //alphabatize the class list
                NSArray* tempMuteArrayAlpha = [tempMuteArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    
                    NSString* string1 = [(EQRContactNameItem*)obj1 first_and_last];
                    NSString* string2 = [(EQRContactNameItem*)obj2 first_and_last];
                    
                    return [string1 compare:string2];
                    
                }];
                
                self.contactNameArray = tempMuteArrayAlpha;
                
                //hand array to contactPickerVC
                [self.myContactPickerVC replaceDefaultContactArrayWith:self.contactNameArray];
                
                //********  reveal name list  **********
                [self.myContactPickerVC.view setHidden:NO];
                
                //is this necessary_____???
//                [self.nameListTable reloadData];
                
                break;
                
                
            }case (2):{ //staff
                
                //set rentorType for request object
                self.chosenRenterType = EQRRenterStaff;
                
                //contact size of renter type list
                self.renterWidthConstraint.constant = 230;
                self.classWidthConstraint.constant = 0;
                //contact size of rentor type list
                self.renterLeadingConstraint.constant = EQRRentorTypeLeadingSpace;
                self.nameListLeadingConstraint.constant = 1 - EQRRentorTypeLeadingSpace;
                
                //animate change
                [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
                    
                    [self.view layoutIfNeeded];
                }];
                
                //remove whatever currently exists in the class and contact tables
                self.contactNameArray = nil;
//                [self.nameListTable reloadData];
                
//                self.classArray = nil;
//                [self.classListTable reloadData];
                
                //_____populate nameList table with names of staff
                
                //instantiate mute array
                NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
                
                EQRWebData* webData2 = [EQRWebData sharedInstance];
                
                //pull a list of names where rentor_type_staff = 1 
                [webData2 queryWithLink:@"EQGetStaffNames.php" parameters:nil class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
                    
                    for (id obj in muteArray){
                        
                        [tempMuteArray  addObject:obj];
                    }
                }];
                
                //alphabatize the list
                NSArray* tempMuteArrayAlpha = [tempMuteArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    
                    NSString* string1 = [(EQRContactNameItem*)obj1 first_and_last];
                    NSString* string2 = [(EQRContactNameItem*)obj2 first_and_last];
                    
                    return [string1 compare:string2];
                    
                }];
                
                self.contactNameArray = tempMuteArrayAlpha;
                
                //hand array to contactPickerVC
                [self.myContactPickerVC replaceDefaultContactArrayWith:self.contactNameArray];
                
                //********  reveal name list  **********
                [self.myContactPickerVC.view setHidden:NO];
                
                //is this necessary_____???
//                [self.nameListTable reloadData];
                
                break;
                
            }case (3):{ //public
                
                //set rentorType for request object
                self.chosenRenterType = EQRRenterPublic;
                
                //contact size of renter type list
                self.renterWidthConstraint.constant = 230;
                self.classWidthConstraint.constant = 0;
                //contact size of rentor type list
                self.renterLeadingConstraint.constant = EQRRentorTypeLeadingSpace;
                self.nameListLeadingConstraint.constant = 1 - EQRRentorTypeLeadingSpace;
                
                //animate change
                [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
                    
                    [self.view layoutIfNeeded];
                }];
                
                //remove whatever currently exists in the class and contact tables
                self.contactNameArray = nil;
                
//                self.classArray = nil;
//                [self.classListTable reloadData];


//                //_____populate with list of ALL names in database____?
//                //instantiate mute array
//                NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
//                
//                EQRWebData* webData2 = [EQRWebData sharedInstance];
//                
//                //pull a list of all names
//                [webData2 queryWithLink:@"EQGetAllContactNames.php" parameters:nil class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
//                    
//                    for (id obj in muteArray){
//                        
//                        [tempMuteArray  addObject:obj];
//                    }
//                }];
//                
//                //alphabatize the list
//                NSArray* tempMuteArrayAlpha = [tempMuteArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                    
//                    NSString* string1 = [(EQRContactNameItem*)obj1 first_and_last];
//                    NSString* string2 = [(EQRContactNameItem*)obj2 first_and_last];
//                    
//                    return [string1 compare:string2];
//                    
//                }];
//                
//                self.contactNameArray = tempMuteArrayAlpha;
//                
//                //hand array to contactPickerVC
//                [self.myContactPickerVC replaceDefaultContactArrayWith:self.contactNameArray];
                [self.myContactPickerVC replaceDefaultContactArrayWith:nil];
                
                //********  reveal name list  **********
                [self.myContactPickerVC.view setHidden:NO];
                
                //is this necessary_____???
//                [self.nameListTable reloadData];
                
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
//                [self.nameListTable reloadData];
                
                
                
//                self.classArray = nil;
//                [self.classListTable reloadData];
//                
//                //get current term from user defaults
//                NSString* termString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"campTerm"] objectForKey:@"campTerm"];
//                
//                //load class table with current term classes and display in collection view
//                EQRWebData* webData = [EQRWebData sharedInstance];
//                
//                NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
//                
//                //params for class section query is the current term
//                NSArray* termArray = [NSArray arrayWithObjects:@"term", termString, nil];
//                NSArray* classqueryArray = [NSArray arrayWithObject:termArray];
//                
//                [webData queryWithLink:@"EQGetClassesCurrent.php" parameters:classqueryArray class:@"EQRClassItem" completion:^(NSMutableArray* muteArray){
//                    
//                    for (id object in muteArray){
//                        
//                        [tempMuteArray addObject:object];
//                    }
//                    
//                }];
//                
//                //alphabatize the class list
//                NSArray* tempMuteArrayAlpha = [tempMuteArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                    
//                    NSString* string1 = [(EQRClassItem*)obj1 section_name];
//                    NSString* string2 = [(EQRClassItem*)obj2 section_name];
//                    
//                    return [string1 compare:string2];
//                    
//                }];
//                
//                self.classArray = tempMuteArrayAlpha;
//                
////                NSLog(@"this is the array top item %@", [[self.classArray objectAtIndex:0] instructor_name]);
//                
//                //yes, this is necessary
//                [self.classListTable reloadData];
                
                //empty out the contactPicker table
                NSArray* noneArray = [NSArray arrayWithObjects: nil];
                
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
                
                
                
                //get current term from user defaults
//                NSString* termString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"term"] objectForKey:@"term"];
//                
//                //load class table with current term classes and display in collection view
//                EQRWebData* webData = [EQRWebData sharedInstance];
//                
//                //instantiate mute array
//                NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
//                
//                //params for class section query is the current term
//                NSArray* termArray = [NSArray arrayWithObjects:@"term", termString, nil];
//                NSArray* classqueryArray = [NSArray arrayWithObject:termArray];
//                
//                [webData queryWithLink:@"EQGetClassesCurrent.php" parameters:classqueryArray class:@"EQRClassItem" completion:^(NSMutableArray* muteArray){
//                    
//                    for (id object in muteArray){
//                        
//                        [tempMuteArray addObject:object];
//                        
//                    }
//                }];
//                
//                //alphabatize the class list
//                NSArray* tempMuteArrayAlpha = [tempMuteArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                    
//                    NSString* string1 = [(EQRClassItem*)obj1 section_name];
//                    NSString* string2 = [(EQRClassItem*)obj2 section_name];
//                    
//                    return [string1 compare:string2];
//                    
//                }];
//                
//                self.classArray = tempMuteArrayAlpha;
//                
//                //yes, this is necessary
//                [self.classListTable reloadData];
                
                
                
                //empty out the contactPicker table
                NSArray* noneArray = [NSArray arrayWithObjects: nil];
                
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


#pragma mark - table view delegate methods

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    if (tableView == self.nameListTable){
//        
//        //name list was selected
//        
//        
//    }
//}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
