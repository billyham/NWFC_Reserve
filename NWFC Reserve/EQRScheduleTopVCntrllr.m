//
//  EQRScheduleTopVCntrllr.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/7/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleTopVCntrllr.h"
#import "EQRGlobals.h"
#import "EQRCellTemplate.h"
#import "EQRScheduleCellContentVCntrllr.h"
#import "EQRScheduleRowCell.h"
#import "EQRScheduleRequestManager.h"
#import "EQRHeaderCellForSchedule.h"
#import "EQREquipUniqueItem.h"
#import "EQRWebData.h"


@interface EQRScheduleTopVCntrllr ()

@property (strong, nonatomic) IBOutlet UICollectionView* myMasterScheduleCollectionView;

//  YES!!!!
@property (strong, nonatomic) NSArray* equipUniqueArray;
@property (strong, nonatomic) NSMutableArray* equipUniqueArrayWithSections;
@property (strong, nonatomic) NSMutableArray* equipUniqueCategoriesList;



@end

@implementation EQRScheduleTopVCntrllr

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
	
    //register collection view cell
    [self.myMasterScheduleCollectionView registerClass:[EQRScheduleRowCell class] forCellWithReuseIdentifier:@"Cell"];
    
    //registar for header cell
    [self.myMasterScheduleCollectionView registerClass:[EQRHeaderCellForSchedule class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SupplementaryCell"];
    
    
    //_____******  initialize how sections are hidden or not hidden  *****_______
    
    
    
    
    
    //_____*****  this a repeat of what the EquipSelectionVCntrllr *****______
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSMutableArray* tempEquipMuteArray = [NSMutableArray arrayWithCapacity:1];
    
    //get the ENTIRE list of equiopment titles... for staff and faculty
    [webData queryWithLink:@"EQGetEquipUniqueItemsAndCategories.php" parameters:nil class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
        
        //do something with the returned array...
        for (EQREquipUniqueItem* equipItemThingy in muteArray){
            
            [tempEquipMuteArray addObject:equipItemThingy];
        }
    }];
    
    //... and save to ivar
    self.equipUniqueArray = [NSArray arrayWithArray:tempEquipMuteArray];
    
    //2. Go through this sinlge array and build a nested array to accommodate sections based on category
    
    if (!self.equipUniqueCategoriesList){
        
        self.equipUniqueCategoriesList = [NSMutableArray arrayWithCapacity:1];
    }
    
    //A. first test if array of categories is valid
    if ([self.equipUniqueCategoriesList count] < 1){
        
        NSMutableSet* tempSet = [NSMutableSet set];
        
        //create a list of unique categories names by looping through the array of equipTitles
        for (EQREquipUniqueItem* obj in self.equipUniqueArray){
            
            if ([tempSet containsObject:obj.category] == NO){
                
                [tempSet addObject:obj.category];
                [self.equipUniqueCategoriesList addObject:[NSString stringWithString:obj.category]];
            }
        }
        
        [tempSet removeAllObjects];
        tempSet = nil;
    }
    
    //sort the equipCatagoriesList
    NSSortDescriptor* sortDescAlpha = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray* sortArray = [NSArray arrayWithObject:sortDescAlpha];
    NSArray* tempSortArrayCat = [self.equipUniqueCategoriesList sortedArrayUsingDescriptors:sortArray];
    self.equipUniqueCategoriesList = [NSMutableArray arrayWithArray:tempSortArrayCat];
    
    //B.1 empty out the current ivar of arrayWithSections
    //create it if it doesn't exist yet
    if (!self.equipUniqueArrayWithSections){
        
        self.equipUniqueArrayWithSections = [NSMutableArray arrayWithCapacity:1];
        
    }else{
        
        [self.equipUniqueArrayWithSections removeAllObjects];
    }
    
    //B. with a valid list of categories....
    //create a new array by populating each nested array with equiptitle that match each category
    for (NSString* categoryItem in self.equipUniqueCategoriesList){
        
        NSMutableArray* subNestArray = [NSMutableArray arrayWithCapacity:1];
        
        for (EQREquipUniqueItem* equipItem in self.equipUniqueArray){
            
            if ([equipItem.category isEqualToString:categoryItem]){
                
                [subNestArray addObject: equipItem];
            }
        }
        
        //add subNested array to the master array
        [self.equipUniqueArrayWithSections addObject:subNestArray];
        
    }
    
    //we now have a master cateogry array with subnested equipTitle arrays
    
    //sort the subnested arrays
    NSMutableArray* tempSortedArrayWithSections = [NSMutableArray arrayWithCapacity:1];
    for (NSArray* obj in self.equipUniqueArrayWithSections)  {
        
        NSArray* tempSubNestArray = [obj sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            
            //first, adjust the distinquishing id by adding a 0 in front of single digits
            NSString* newDist1;
            if ([(NSString*)[(EQREquipUniqueItem*)obj1 distinquishing_id] length] < 2){
                
                newDist1 = [NSString stringWithFormat:@"0%@", (NSString*)[(EQREquipUniqueItem*)obj1 distinquishing_id]];
            }else{
                
                newDist1 =(NSString*)[(EQREquipUniqueItem*)obj1 distinquishing_id];
            }
            
            NSString* newDist2;
            if ([(NSString*)[(EQREquipUniqueItem*)obj2 distinquishing_id] length] < 2){
                
                newDist2 = [NSString stringWithFormat:@"0%@", (NSString*)[(EQREquipUniqueItem*)obj2 distinquishing_id]];
            }else{
                
                newDist2 =(NSString*)[(EQREquipUniqueItem*)obj2 distinquishing_id];
            }
            
            
            
            NSString* string1 = [NSString stringWithFormat:@"%@%@",
                                 [(EQREquipUniqueItem*)obj1 shortname], newDist1];
            NSString* string2 = [NSString stringWithFormat:@"%@%@",
                                 [(EQREquipUniqueItem*)obj2 shortname], newDist2];
            
            return [string1 compare:string2];
        }];
        
        [tempSortedArrayWithSections addObject:tempSubNestArray];
    };
    self.equipUniqueArrayWithSections = tempSortedArrayWithSections;
    
    
    //is this necessary_____???
    [self.myMasterScheduleCollectionView reloadData];
    
    //_________****************
    
    
    
}



#pragma mark - collection view data source methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    
    return [(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:section] count];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    
    return [self.equipUniqueArrayWithSections count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"Cell";
    EQRScheduleRowCell* cell = [self.myMasterScheduleCollectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    //get the item name and distinquishing ID from the nested array
    NSString* myTitleString = [NSString stringWithFormat:@"%@  #%@",
                               [(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] shortname],
                               [(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] distinquishing_id]];
    
    [cell initialSetupWithTitle:myTitleString];
    
    //add content view from xib
    EQRScheduleCellContentVCntrllr* myContentViewController = [[EQRScheduleCellContentVCntrllr alloc] initWithNibName:@"EQRScheduleCellContentVCntrllr" bundle:nil];
    
    //add subview
    [cell.contentView addSubview:myContentViewController.view];
    
    
    //change label AFTER adding it to the view else defaults to XIB file
    myContentViewController.myRowLabel.text = myTitleString;
    
    
    
    
    return cell;
}



#pragma mark - section header data source methods

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"SupplementaryCell";
    EQRHeaderCellTemplate* cell = [self.myMasterScheduleCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //remove subviews
    for (UIView* thisSubview in cell.contentView.subviews){
        
        [thisSubview removeFromSuperview];
    }
    
    
    //_____test whether the section is collapsed or expanded
    BOOL iAmHidden = NO;
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    for (NSString* sectionString in requestManager.arrayOfEquipSectionsThatShouldBeHiddenInSchedule){
        
        if ([sectionString isEqualToString:[(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:0] category]]){
            
            //found a match in the array of hidden sections
            iAmHidden = YES;
            
            break;
        }
    }
    
    
    //get the category for a sample item in the nested array
    NSString* thisTitleString = [(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:0] category];
    
    //cell's initial setup method with label
    [cell initialSetupWithTitle:thisTitleString isHidden:NO];
    
    return cell;
    
}



#pragma mark - collection view delegate methods







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
