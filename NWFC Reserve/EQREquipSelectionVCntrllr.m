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
    
    //this prevents the collection view from responding to touch events
    self.equipCollectionView.allowsSelection = NO;
    

    //register collection view cell
    [self.equipCollectionView registerClass:[EQREquipItemCell class] forCellWithReuseIdentifier:@"Cell"];
    
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
        
        //save as ivar
        self.equipTitleArray = [NSArray arrayWithArray:tempEquipMuteArray];
        
        //is this necessary_____???
        [self.equipCollectionView reloadData];
    }];
}


#pragma mark - equipment cell buttons

-(IBAction)plusButtonActivated:(id)sender{
    
    NSLog(@"plus button hit in EquipSelectionVCntrllr class");
}


-(IBAction)minusButtonActivated:(id)sender{
    
    
    
}


#pragma mark - view collection data source protocol methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [self.equipTitleArray count];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
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
        
        [cell initialSetupWithTitle:[(EQREquipItem*)[self.equipTitleArray objectAtIndex:indexPath.row] name] andEquipItem:[self.equipTitleArray objectAtIndex:indexPath.row]];
        
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
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
