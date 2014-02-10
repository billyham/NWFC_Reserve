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


@interface EQRReserveTopVCntrllr ()

@property (strong, nonatomic) NSArray* contactNameArray;
@property (strong, nonatomic) NSArray* classArray;
@property (strong, nonatomic) NSArray* rentorTypeArray;
@property (strong, nonatomic) EQRClassItem* thisClassItem;
@property (strong, nonatomic) EQRClassRegistrationItem* thisClassRegistration;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint* rentorWidthContraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* rentorLeadingConstraint;

@property BOOL hideNameListFlag;
@property BOOL hideClassListFlag;



@end

@implementation EQRReserveTopVCntrllr

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set flags
    self.hideClassListFlag = YES;
    self.hideNameListFlag = YES;
    
    //register for notification
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    //observe for voiding schedule tracking item
    [nc addObserver:self selector:@selector(startNewDisplay:) name:EQRVoidScheduleItemObjects object:nil];
    

    //register colleciton view cell
    [self.classListTable registerClass:[EQRClassCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.nameListTable registerClass:[EQRContactNameCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.rentorTypeListTable registerClass:[EQRCellTemplate class] forCellWithReuseIdentifier:@"Cell"];

    //populate rentorTypeArray
    if (!self.rentorTypeArray){
        
        self.rentorTypeArray = [NSArray arrayWithObjects:
                                @"Student",
                                @"Faculty",
                                @"Staff",
                                @"Public",
                                @"Youth",
                                nil];
    }
    
    //expand size of rentor type list
//    self.rentorWidthContraint.constant = 230;
    self.rentorLeadingConstraint.constant = EQRRentorTypeLeadingSpace;
    
    //animate change
    [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
        
        
        [self.view layoutIfNeeded];
    }];

    
}


#pragma mark - return to start screen

-(void)startNewDisplay:(NSNotification*)note{
    
    //deselect type
    [self.rentorTypeListTable reloadData];
    
    //set flags
    self.hideNameListFlag = YES;
    self.hideClassListFlag = YES;
    
    //delete info in collection views
    [self.classListTable reloadData];
    [self.nameListTable reloadData];
//    [self.classListTable deleteSections:[NSIndexSet indexSetWithIndex:0]];
//    [self.nameListTable deleteSections:[NSIndexSet indexSetWithIndex:0]];
    
    //expand size of rentor type list
//    self.rentorWidthContraint.constant = 230;
    self.rentorLeadingConstraint.constant = EQRRentorTypeLeadingSpace;
    
    //animate change
    [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
       
        [self.view layoutIfNeeded];
    }];
    
}


#pragma mark - table datasource methods


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  
    //discern between two different tables
    
    if (collectionView == self.nameListTable){
        
        if (self.hideNameListFlag){
            
            return 0;
            
        }else{
            
            return [self.contactNameArray count];
        }
        
    } else if (collectionView == self.classListTable){
        
        if (self.hideClassListFlag){
            
            return 0;
            
        }else {

            return [self.classArray count];
        }
        
    } else if (collectionView == self.rentorTypeListTable){
        
        return [self.rentorTypeArray count];
    }
    
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //discern between different tables
    
    if (collectionView == self.nameListTable){
        
        static NSString* CellIdentifier = @"Cell";
        EQRContactNameCell* cell = [self.nameListTable dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //remove all subviews
        for (UIView* view in cell.contentView.subviews){
            
            [view removeFromSuperview];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        [cell setOpaque:YES];
        
        if ([self.contactNameArray count] > 0){
            
            NSLog(@"this is the class of objects: %@", [[self.contactNameArray objectAtIndex:indexPath.row] class]);
            
            [cell initialSetupWithTitle:[(EQRContactNameItem*)[self.contactNameArray objectAtIndex:indexPath.row] first_and_last]];
            
        }else{
            
            NSLog(@"no count in the contact name array");
        }
        
        return cell;
        
    }else if (collectionView == self.classListTable){
        
        static NSString* CellIdentifier = @"Cell";
        EQRClassCell* cell = [self.classListTable dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //remove subviews
        for (UIView* view in cell.contentView.subviews){
            
            [view removeFromSuperview];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        [cell setOpaque:YES];
        
        if ([self.classArray count] > 0){
            
            [cell initialSetupWithTitle:[(EQRClassItem*)[self.classArray objectAtIndex:indexPath.row] section_name]];
        } else {
            
            NSLog(@"no count in the class array");
        }
        
        return cell;
        
    }else if(collectionView == self.rentorTypeListTable){
    
        static NSString* CellIdentifier  = @"Cell";
        EQRCellTemplate* cell = [self.rentorTypeListTable dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //remove subviews
        for (UIView* view in cell.contentView.subviews){
            
            [view removeFromSuperview];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        [cell setOpaque:YES];
        
        if ([self.rentorTypeArray count] > 0) {
            
            [cell initialSetupWithTitle:[self.rentorTypeArray objectAtIndex:indexPath.row]];
        } else {
            
            NSLog(@"No count in the rentor type array");
        }
        
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
    
    
    if (collectionView == self.classListTable){
        
        //reveal name list
        self.hideNameListFlag = NO;
        
        //initialize webData object
        EQRWebData* webData = [EQRWebData sharedInstance];
        
        //1. get key_id of selected class Section
        //2. get list of key_id contacts from class_registrations table
        //3. get list of student names
        
        //1. get key_id of selected class Section
        EQRClassItem* thisClass = [self.classArray objectAtIndex:indexPath.row];
        NSString*  classKeyId = thisClass.key_id;
        NSLog(@"this is the classCatalog_foreignKey: %@", thisClass.key_id);
        
        //2. get list of key_id contacts from class_registrations table
        NSArray* regArray = [NSArray arrayWithObjects:@"classSection_foreignKey", classKeyId, nil];
        NSArray* regArray2= [NSArray arrayWithObject:regArray];
        [webData queryWithLink:@"EQGetClassRegistrationsForSectionKey" parameters:regArray2 class:@"EQRClassRegistrationItem" completion:^(NSMutableArray* muteArray){
            
            //array of contact key ids
            NSArray* arrayOfClassRegistrationItems = [NSArray arrayWithArray: muteArray];
            //zero out the muteArray
            muteArray = nil;
            
            //_____keep class item on an ivar to use when creating a new scheduleRequest
            self.thisClassItem = thisClass;
            NSLog(@"this is the catalog_foreign_key: %@", thisClass.catalog_foreign_key);
            
            //3. get list of student names
            
            //declare a mutablearray
            NSMutableArray* contactNameMuteArray = [NSMutableArray arrayWithCapacity:1];
            
            //repeat this step... to add additional objects to the array
            [arrayOfClassRegistrationItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                NSLog(@"class of object: %@ and it's contact_foreingKey: %@", [obj class], [[obj contact_foreignKey] class]);
            
                
                NSArray* classParam = [NSArray arrayWithObjects: @"key_id", [(EQRClassRegistrationItem*)obj contact_foreignKey], nil];
                NSArray* classParamTotal = [NSArray arrayWithObject:classParam];
                
                NSLog(@"count of classParam: %lu", (unsigned long)[classParam count]);
                
                //get student names with query
                EQRWebData* webDataNew = [EQRWebData sharedInstance];
                [webDataNew queryWithLink:@"EQGetStudentNamesCurrent.php" parameters:classParamTotal class:@"EQRContactNameItem" completion:^(NSMutableArray* muteArray2){
                    
                    if ([muteArray2 count] > 0){
                        
                        NSLog(@"muteArray2 has data");
                        
                        //there should only be one object in the returned array__________???
                        [contactNameMuteArray addObject:[muteArray2 objectAtIndex:0]];
                    }
                    
                    [muteArray2 removeAllObjects];
                    
                }];
            }];
            
            //save as ivar
            self.contactNameArray = contactNameMuteArray;
            
            NSLog(@"count of objects in contactNameMuteArray: %lu", (unsigned long)[contactNameMuteArray count]);
            
            //is this necessary_____???
            [self.nameListTable reloadData];
        }];

    } else if (collectionView == self.nameListTable){
        
        //name list was selected
        
        //______****** cancel any existing scheduleRequestItems first???  ******___________
        
        //create a scheduleRequestItem instance
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        
        [requestManager createNewRequest];
        
        //assign contact and class to the request
        //first to the object properties
        requestManager.request.contactNameItem = [self.contactNameArray objectAtIndex:indexPath.row];
        requestManager.request.classItem = self.thisClassItem;

        //second to the data model properties
        requestManager.request.contact_foreignKey = requestManager.request.contactNameItem.key_id;
        requestManager.request.classSection_foreignKey = self.thisClassItem.key_id;
        requestManager.request.classTitle_foreignKey = self.thisClassItem.catalog_foreign_key;
        
        
        //perform segue to show date picker
        [self performSegueWithIdentifier:@"lookAtDates" sender:self];
        
    } else if (collectionView == self.rentorTypeListTable){
        
        //reveal class list
        self.hideClassListFlag = NO;
        
        
        
        //rentor type is selected
        switch (indexPath.row) {
                
            case (0):{ //student (adult)
                
                //contact size of rentor type list
//                self.rentorWidthContraint.constant = 120;
                self.rentorLeadingConstraint.constant = 0.0;
                
                //animate change
                [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
                    
                    [self.view layoutIfNeeded];
                }];
                
                
                //get current term from user defaults
                NSString* termString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"term"] objectForKey:@"term"];
                
                //load class table with current term classes and display in collection view
                EQRWebData* webData = [EQRWebData sharedInstance];
                
                //params for class section query is the current term
                NSArray* termArray = [NSArray arrayWithObjects:@"term", termString, nil];
                NSArray* classqueryArray = [NSArray arrayWithObject:termArray];
                
                [webData queryWithLink:@"EQGetClassesCurrent.php" parameters:classqueryArray class:@"EQRClassItem" completion:^(NSMutableArray* muteArray){
                    
                    self.classArray = [NSArray arrayWithArray:muteArray];
                }];
                
                //yes, this is necessary
                [self.classListTable reloadData];
                
                break;
                
            } case (1):{ //faculty
                
                //contact size of rentor type list
                self.rentorLeadingConstraint.constant = EQRRentorTypeLeadingSpace;
                
                //animate change
                [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
                    
                    [self.view layoutIfNeeded];
                }];
                
                //remove whatever currently exists in the class and contact tables
                self.classArray = nil;
                [self.classListTable reloadData];
                self.contactNameArray = nil;
                [self.nameListTable reloadData];
                
            }case (2):{ //staff
                
                //contact size of rentor type list
                self.rentorLeadingConstraint.constant = EQRRentorTypeLeadingSpace;
                
                //animate change
                [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
                    
                    [self.view layoutIfNeeded];
                }];
                
                //remove whatever currently exists in the class and contact tables
                self.classArray = nil;
                [self.classListTable reloadData];
                self.contactNameArray = nil;
                [self.nameListTable reloadData];
                
            }case (3):{ //public
                
                //contact size of rentor type list
                self.rentorLeadingConstraint.constant = EQRRentorTypeLeadingSpace;
                
                //animate change
                [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
                    
                    [self.view layoutIfNeeded];
                }];
                
                //remove whatever currently exists in the class and contact tables
                self.classArray = nil;
                [self.classListTable reloadData];
                self.contactNameArray = nil;
                [self.nameListTable reloadData];
                
                
            }case (4):{ //youth camp
                
                //contact size of rentor type list
                self.rentorLeadingConstraint.constant = EQRRentorTypeLeadingSpace;
                
                //animate change
                [UIView animateWithDuration:EQRResizingCollectionViewTime animations:^{
                    
                    [self.view layoutIfNeeded];
                }];
                
                //remove whatever currently exists in the class and contact tables
                self.classArray = nil;
                [self.classListTable reloadData];
                self.contactNameArray = nil;
                [self.nameListTable reloadData];
                
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
