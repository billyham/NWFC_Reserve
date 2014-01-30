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

@interface EQREquipSelectionVCntrllr ()

@property (strong, nonatomic) NSArray* equipTitleArray;
@property (strong, nonatomic) NSMutableArray* equipTitleCategoriesList;
@property (strong, nonatomic) NSMutableArray* equipTitleArrayWithSections;

@end

@implementation EQREquipSelectionVCntrllr

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
    

    //register collection view cell
    [self.equipCollectionView registerClass:[EQREquipItemCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.equipCollectionView registerClass:[UICollectionViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SupplementaryCell"];
    
    //get class data from scheduleRequest object
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    NSString* classTitleKey = requestManager.request.classTitle_foreignKey;
    
    NSLog(@"this is the class title foreign key: %@", requestManager.request.classTitle_foreignKey);
    
    
    //set webData request for equiplist
    NSArray* firstParamArray = [NSArray arrayWithObjects:@"ClassCatalog_foreignKey", classTitleKey, nil];
    NSArray* secondParamArray = [NSArray arrayWithObjects:firstParamArray, nil];
    

    
    //1. get list of ClassCatalog_EquipTitleItem_Join
    EQRWebData* webData = [EQRWebData sharedInstance];
    [webData queryWithLink:@"EQGetClassCatalogEquipTitleItemJoins.php" parameters:secondParamArray class:@"EQRClassCatalog_EquipTitleItem_Join" completion:^(NSMutableArray* muteArrayFirst){
        
    
        NSLog(@"thisisthecountofmutearrayfirst: %u", [muteArrayFirst count]);
        
        //declare a mutable array
        NSMutableArray* tempEquipMuteArray = [NSMutableArray arrayWithCapacity:1];
        
        
        //do something with the returned array...
        [muteArrayFirst enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSLog(@"this is a list of equipTitle keys: %@", [(EQRClassCatalog_EquipTitleItem_Join*)obj equipTitleItem_foreignKey]);
            
            NSArray* equipParamArrayfirst = [NSArray arrayWithObjects:@"key_id",
                                             [(EQRClassCatalog_EquipTitleItem_Join*)obj equipTitleItem_foreignKey], nil];
            NSArray* equipParamArraySecond = [NSArray arrayWithObject:equipParamArrayfirst];
            
            EQRWebData* webDataNew = [EQRWebData sharedInstance];
            
            [webDataNew queryWithLink:@"EQGetEquipmentTitles.php" parameters:equipParamArraySecond class:@"EQREquipItem"
                        completion:^(NSMutableArray* muteArrayAlt){
                
                //do something with the returned array...
                if ([muteArrayAlt count] > 0){
                    
                    [tempEquipMuteArray addObject:[muteArrayAlt objectAtIndex:0]];
                }
            }];
        }];
        
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
        
        NSLog(@"count of items in equipTitleCategoriesList: %u", [self.equipTitleCategoriesList count]);
        
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
            
            NSLog(@"this is the cateoryItem: %@", categoryItem);
            
            NSMutableArray* subNestArray = [NSMutableArray arrayWithCapacity:1];
            
            for (EQREquipItem* equipItem in self.equipTitleArray){
                
                if ([equipItem.category isEqualToString:categoryItem]){
                    
                    [subNestArray addObject:equipItem];
                    NSLog(@"this subNestArray: %@ added an object", categoryItem);
                }
            }
            
            //add subNested array to the master array
            [self.equipTitleArrayWithSections addObject:subNestArray];
            
        }
        
        //we now have a master cateogry array with subnested equipTitle arrays
        NSLog(@"count of items in master array of equipTitles: %u", [self.equipTitleArrayWithSections count]);
        
        //is this necessary_____???
        [self.equipCollectionView reloadData];
    }];
}


#pragma mark - equipment cell buttons

-(IBAction)plusButtonActivated:(id)sender{
    
}


-(IBAction)minusButtonActivated:(id)sender{
    
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
    
//    cell.backgroundColor = [UIColor yellowColor];
//    [cell setOpaque:YES];
    
    
    if ([self.equipTitleArray count] > 0){
        
        [cell initialSetupWithTitle:[[(NSArray*)[self.equipTitleArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]  name] andEquipItem:[(NSArray*)[self.equipTitleArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
        
//        [cell initialSetupWithTitle:[(EQREquipItem*)[self.equipTitleArray objectAtIndex:indexPath.row] name] andEquipItem:[self.equipTitleArray objectAtIndex:indexPath.row]];
        
    }else{
        
        NSLog(@"no count in the equiptitlearray");
    }
    
    //__________add target to cell plus and minus buttons
    
    
    
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
