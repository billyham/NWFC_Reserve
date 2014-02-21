//
//  EQREquipSelectionVCntrllrViewController.m
//  NWFC Reserve
//
//  Created by Ray Smith on 11/12/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import "EQREquipSelectionVCntrllr.h"
#import "EQRWebData.h"
#import "EQREquipItem.h"
#import "EQREquipItemCell.h"
#import "EQRScheduleRequestManager.h"
#import "EQRScheduleRequestItem.h"
#import "EQRClassCatalog_EquipTitleItem_Join.h"
#import "EQRGlobals.h"
#import "EQREquipUniqueItem.h"

@interface EQREquipSelectionVCntrllr ()

@property (strong, nonatomic) NSArray* equipTitleArray;
@property (strong, nonatomic) NSMutableArray* equipTitleCategoriesList;
@property (strong, nonatomic) NSMutableArray* equipTitleArrayWithSections;

@end

@implementation EQREquipSelectionVCntrllr

#pragma mark - methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //add longpress gesture recognizer, need to circumvent existing longpress gesture first
//    UILongPressGestureRecognizer* pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
//    
//    NSArray* recognizers = [self.equipCollectionView gestureRecognizers];
//    
//    //make the default gesture recognizer wait until the custom fails
//    for (UIGestureRecognizer* aRecognizer in recognizers) {
//        
//        if ([aRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
//            
//            [aRecognizer requireGestureRecognizerToFail:pressGesture];
//        }
//    }
    
    //________this prevents the collection view from responding to touch events
    //________but is unnecessary, the plus and minus buttons will work with or without this disabled.
//    self.equipCollectionView.allowsSelection = NO;
    
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    
    //_______********  try allocating the gear list here... *****______
    
    //must entirely build or rebuild list available equipment as the user could go back and change the dates at anytime
    [requestManager resetEquipListAndAvailableQuantites];
    
    //...now factor in the gear already scheduled for the chosen dates in the available quantities.
    [self allocateGearList];

    //-------*******
    
    
    //register collection view cell
    [self.equipCollectionView registerClass:[EQREquipItemCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.equipCollectionView registerClass:[UICollectionViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SupplementaryCell"];
    
    //______*********  this should only apply to students  ******_______
    //get class data from scheduleRequest object
    
    NSString* classTitleKey = requestManager.request.classTitle_foreignKey;
    
    //set webData request for equiplist
    NSArray* firstParamArray = [NSArray arrayWithObjects:@"ClassCatalog_foreignKey", classTitleKey, nil];
    NSArray* secondParamArray = [NSArray arrayWithObjects:firstParamArray, nil];
    
    //1. get list of ClassCatalog_EquipTitleItem_Join
    //declare a mutable array
    __block NSMutableArray* tempEquipMuteArray = [NSMutableArray arrayWithCapacity:1];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    if ([requestManager.request.renter_type isEqualToString:@"student"]){
        
        //get a list of allocated gear using SQL with INNER JOIN
        
        [webData queryWithLink:@"EQGetEquipTitlesWithClassCatalogKey.php" parameters:secondParamArray class:@"EQREquipItem" completion:^(NSMutableArray *muteArray) {
            
            if ([muteArray count] > 0){
                
                for (id something in muteArray){
                    
                    [tempEquipMuteArray addObject:something];
                }
            }
        }];
        
        
        
        //get a list of allocated gear...
//        [webData queryWithLink:@"EQGetClassCatalogEquipTitleItemJoins.php" parameters:secondParamArray class:@"EQRClassCatalog_EquipTitleItem_Join" completion:^(NSMutableArray* muteArrayFirst){
//            
//            
//            
//            //do something with the returned array...
//            [muteArrayFirst enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                
//                NSArray* equipParamArrayfirst = [NSArray arrayWithObjects:@"key_id",
//                                                 [(EQRClassCatalog_EquipTitleItem_Join*)obj equipTitleItem_foreignKey], nil];
//                NSArray* equipParamArraySecond = [NSArray arrayWithObject:equipParamArrayfirst];
//                
//                EQRWebData* webDataNew = [EQRWebData sharedInstance];
//                
//                [webDataNew queryWithLink:@"EQGetEquipmentTitles.php" parameters:equipParamArraySecond class:@"EQREquipItem"
//                               completion:^(NSMutableArray* muteArrayAlt){
//                                   
//                                   //do something with the returned array...
//                                   if ([muteArrayAlt count] > 0){
//                                       
//                                       [tempEquipMuteArray addObject:[muteArrayAlt objectAtIndex:0]];
//                                   }
//                               }];
//            }];
//        }];
        
        
        
        
    } else{
        
        //_____*****  this a repeat of what the ReserveTopVCntrllr does, maybe use that instead???  **_____
        //get the ENTIRE list of equiopment titles... for staff and faculty
        [webData queryWithLink:@"EQGetEquipmentTitlesAll.php" parameters:nil class:@"EQREquipItem" completion:^(NSMutableArray *muteArray) {
            
            //do something with the returned array...
            for (EQREquipItem* equipItemThingy in muteArray){
                
                [tempEquipMuteArray addObject:equipItemThingy];
            }
        }];
    }
    
    
    //... and save to ivar
    self.equipTitleArray = [NSArray arrayWithArray:tempEquipMuteArray];
    
    //2. Go through this sinlge array and build a nested array to accommodate sections based on category
    
    if (!self.equipTitleCategoriesList){
        
        self.equipTitleCategoriesList = [NSMutableArray arrayWithCapacity:1];
    }
    
    //A. first test if array of categories is valid
    if ([self.equipTitleCategoriesList count] < 1){
        
        NSMutableSet* tempSet = [NSMutableSet set];
        
        //create a list of unique categories names by looping through the array of equipTitles
        for (EQREquipItem* obj in self.equipTitleArray){
            
            if ([tempSet containsObject:obj.category] == NO){
                
                [tempSet addObject:obj.category];
                [self.equipTitleCategoriesList addObject:[NSString stringWithString:obj.category]];
            }
        }
        
        [tempSet removeAllObjects];
        tempSet = nil;
    }
    
    //sort the equipCatagoriesList
    NSSortDescriptor* sortDescAlpha = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray* sortArray = [NSArray arrayWithObject:sortDescAlpha];
    NSArray* tempSortArrayCat = [self.equipTitleCategoriesList sortedArrayUsingDescriptors:sortArray];
    self.equipTitleCategoriesList = [NSMutableArray arrayWithArray:tempSortArrayCat];
    
    //B.1 empty out the current ivar of arrayWithSections
    //create it if it doesn't exist yet
    if (!self.equipTitleArrayWithSections){
        
        self.equipTitleArrayWithSections = [NSMutableArray arrayWithCapacity:1];
        
    }else{
        
        [self.equipTitleArrayWithSections removeAllObjects];
    }
    
    //B. with a valid list of categories....
    //create a new array by populating each nested array with equiptitle that match each category
    for (NSString* categoryItem in self.equipTitleCategoriesList){
        
        NSMutableArray* subNestArray = [NSMutableArray arrayWithCapacity:1];
        
        for (EQREquipItem* equipItem in self.equipTitleArray){
            
            if ([equipItem.category isEqualToString:categoryItem]){
                
                [subNestArray addObject: equipItem];
            }
        }
        
        //add subNested array to the master array
        [self.equipTitleArrayWithSections addObject:subNestArray];
        
    }
    
    //we now have a master cateogry array with subnested equipTitle arrays
    
    //sort the subnested arrays
    NSMutableArray* tempSortedArrayWithSections = [NSMutableArray arrayWithCapacity:1];
    for (NSArray* obj in self.equipTitleArrayWithSections)  {
        
        NSArray* tempSubNestArray = [obj sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            
            NSString* string1 = [(EQREquipItem*)obj1 name];
            NSString* string2 = [(EQREquipItem*)obj2 name];
            
            return [string1 compare:string2];
        }];
        
        [tempSortedArrayWithSections addObject:tempSubNestArray];
    };
    self.equipTitleArrayWithSections = tempSortedArrayWithSections;
    
    
    
    
    
    
    //is this necessary_____???
    [self.equipCollectionView reloadData];
}


#pragma mark - cancel

-(IBAction)cancelTheThing:(id)sender{
    
    //go back to first page in nav
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //send note to reset eveything back to 0
//    [[NSNotificationCenter defaultCenter] postNotificationName:EQRVoidScheduleItemObjects object:nil];
    
    //reset eveything back to 0 (which in turn sends an nsnotification)
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    [requestManager dismissRequest];
    
}

#pragma mark - equipment cell buttons

-(IBAction)plusButtonActivated:(id)sender{
    
}


-(IBAction)minusButtonActivated:(id)sender{
    
}


#pragma mark - allocation of gear items


-(IBAction)receiveContinueAction:(id)sender{
    
//    [self allocateGearList];

}



-(void)allocateGearList{
    

    //get a list of uniqueItems that fall within the rental dates.
    //1. get scheduleTracking objects within the dates (sql script?)
    //2. gather matching scheduleTracking_equip_joins (using scheduleTracking_foreignKey in schedule_equipUnique_joins)
    //3. gather key_ids for equipUniqueItems (using equipUniqueItem_foreignKey in scheduleTracking_equipUnique_joins)
    
    //subtract out the quantity of uniqueItems available per titleItems
    //compare with the quantitys requested, then pause and alert user if quantities are exceeded. Identified where excesses are.
    //1. create a subnested array of titleItems with quantities (similar to the requestManager's ivar
    //2. cycle through and add quantities from this request
    //3. cycle through, comparing with titleItem key_ids in requestManager's ivar,

    
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    //begin and end dates in sql format
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString* dateBeginString = [dateFormatter stringFromDate:requestManager.request.request_date_begin];
    NSString* dateEndString = [dateFormatter stringFromDate:requestManager.request.request_date_end];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    NSArray* arrayWithBeginDate = [NSArray arrayWithObjects:@"request_date_begin", dateBeginString, nil];
    NSArray* arrayWithEndDate = [NSArray arrayWithObjects:@"request_date_end", dateEndString, nil];
    NSArray* arrayTopDate = [NSArray arrayWithObjects:arrayWithBeginDate, arrayWithEndDate, nil];
    
    NSMutableArray* arrayOfScheduleTrackingKeyIDs = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray* arrayOfEquipUniqueItems = [NSMutableArray arrayWithCapacity:1];
    
    [webData queryWithLink:@"EQGetScheduleItemsInDateRange.php" parameters:arrayTopDate class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        NSLog(@"result from schedule request Date range: %@", muteArray);
        
        //populate array with key_ids
        for (EQRScheduleRequestItem* objKey in muteArray){
            
            [arrayOfScheduleTrackingKeyIDs addObject:objKey];
            
            //cycle through and get equipUniqueItem key IDs
            
        }
    }];
    
    
    //Use sql with inner join...
    //  get reserved EquipUniqueItem objects With ScheduleTrackingKeys
    
    for (EQRScheduleTracking_EquipmentUnique_Join* objThingy in arrayOfScheduleTrackingKeyIDs){
        
        NSArray* arrayWithTrackingKey = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", objThingy.key_id, nil];
        NSArray* topArrayWithTrackingKey = [NSArray arrayWithObject:arrayWithTrackingKey];
        
        [webData queryWithLink:@"EQGetUniqueItemKeysWithScheduleTrackingKeys.php" parameters:topArrayWithTrackingKey class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray2) {
            
            for (EQREquipUniqueItem* objUniqueItem in muteArray2){
                
                NSLog(@"this is EquipUniqueItem key_id: %@  and titleItem key_id: %@ and name: %@",
                      objUniqueItem.key_id, objUniqueItem.equipTitleItem_foreignKey, objUniqueItem.name);
                
                [arrayOfEquipUniqueItems addObject:objUniqueItem];
            }
        }];
    }
    
    
    //_____*******  add structure to the array by sections with titleKey???
    
    
    //_____********  NOW HAVE ARRAY OF UNIQUEITEMS BUT NOT SAVING IT ANYWHERE YET____*******
    //arrayOfEquipUniqueItems
    
    //SUBTRACT OUT the scheduled gear from the requestManager array of titles with qty count
    //loop through arrayOfEquipUniqueItems
    for (EQREquipUniqueItem* eqritem in arrayOfEquipUniqueItems){
        
        for (NSMutableArray* checkArray in requestManager.arrayOfEquipTitlesWithCountOfUniqueItems){
            
            if ([eqritem.equipTitleItem_foreignKey isEqualToString:[checkArray objectAtIndex:0]] ){
                
                //found a matching title item, now reduce the count of available items by one
                //... but only if the current available quantity is above 0 (to prevent going into negative integers)
                
                if ([(NSNumber*)[checkArray objectAtIndex:1] integerValue] > 0){
                    
                    int newIntValue = [(NSNumber*)[checkArray objectAtIndex:1] intValue] - 1;
                    NSNumber* newNumber = [NSNumber numberWithInt: newIntValue];
                    [checkArray replaceObjectAtIndex:1 withObject:newNumber];
                }
            }
        }
    }
    
}




#pragma mark - view collection data source protocol methods

//Section Methods

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"SupplementaryCell";
    UICollectionViewCell* cell = [self.equipCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //remove subviews
    for (UIView* thisSubview in cell.contentView.subviews){
        
        [thisSubview removeFromSuperview];
    }
    
    CGRect thisRect = CGRectMake(cell.contentView.frame.origin.x, cell.contentView.frame.origin.y, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
    UILabel* newLabel = [[UILabel alloc] initWithFrame:thisRect];
    
    newLabel.text = [self.equipTitleCategoriesList objectAtIndex:indexPath.section];
//    newLabel.textAlignment = NSTextAlignmentCenter;
    
    [cell.contentView addSubview:newLabel];
    
    cell.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
    
    
    return cell;
}



//Cell Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSArray* tempArray = [self.equipTitleArrayWithSections objectAtIndex:section];
    return [tempArray count];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return [self.equipTitleArrayWithSections count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"Cell";
    EQREquipItemCell* cell = [self.equipCollectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    //and ensure cell has user interaction enabled
    [cell setUserInteractionEnabled:YES];
    
//    cell.backgroundColor = [UIColor yellowColor];
//    [cell setOpaque:YES];
    
    
    if ([self.equipTitleArray count] > 0){
        
        [cell initialSetupWithTitle:[[(NSArray*)[self.equipTitleArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]  shortname] andEquipItem:[(NSArray*)[self.equipTitleArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
        
//        [cell initialSetupWithTitle:[(EQREquipItem*)[self.equipTitleArray objectAtIndex:indexPath.row] name] andEquipItem:[self.equipTitleArray objectAtIndex:indexPath.row]];
        
    }else{
        
        NSLog(@"no count in the equiptitlearray");
    }
    
    return cell;
}


//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    
//}


#pragma mark - collection view delegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    NSLog(@"view collection delegate fires touch");
    
    //if the selected cell has 0 for quantity, add one. otherwise, do nothing
    EQREquipItemCell* selectedCell = (EQREquipItemCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if ([selectedCell itemQuantity] < 1){
        
        [selectedCell plusHit:nil];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
