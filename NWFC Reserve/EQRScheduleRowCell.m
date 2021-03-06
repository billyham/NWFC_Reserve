//
//  EQRScheduleRowCell.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/20/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleRowCell.h"
#import "EQRScheduleNestedDayLayout.h"
#import "EQRGlobals.h"
#import "EQRColors.h"
#import "EQRScheduleNestedDayCell.h"
#import "EQRScheduleRequestManager.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRWebData.h"


@interface EQRScheduleRowCell()

@property (nonatomic, strong) NSIndexPath* rowCellIndexPath;
@property (strong, nonatomic) NSMutableArray* temporaryArrayOfEquipUniqueJoins;
@property (strong, nonatomic) EQRColors* myColors;

//and it's year and month???
@end

@implementation EQRScheduleRowCell


#pragma mark - setup
-(void)initialSetupWithTitle:(NSString*) titleName equipKey:(NSString*)uniqueKeyID indexPath:(NSIndexPath*)indexPath dateForShow:(NSDate*)dateForShow{
    
    //set ivar
    self.uniqueItem_keyID = uniqueKeyID;
    self.rowCellIndexPath = indexPath;
    
    //ivar colors
    self.myColors = [EQRColors sharedInstance];
    
    self.backgroundColor = [UIColor whiteColor];
    
    //_______does nothing with the titleName_______
//    UILabel* thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 5, 295, 45)];
//    self.titleLabel = thisLabel;
//    
//    self.titleLabel.text = titleName;
//    self.titleLabel.backgroundColor = [UIColor clearColor];
//    
//    [self.contentView addSubview:self.titleLabel];

    //create a uicollectionview object programatically
    EQRScheduleNestedDayLayout* thisNestedDayLayout = [[EQRScheduleNestedDayLayout alloc] init];
    
    //set subclass property
    thisNestedDayLayout.uniqueItem_keyID = self.uniqueItem_keyID;
    //assign the dateForShow property to the layout object
    thisNestedDayLayout.scheduleDateForShow = dateForShow;

    CGRect thisRect = CGRectMake(EQRScheduleLengthOfEquipUniqueLabel, 0, (1024 - EQRScheduleLengthOfEquipUniqueLabel), 30);
    UICollectionView* thisCollectionView = [[UICollectionView alloc] initWithFrame:thisRect collectionViewLayout:thisNestedDayLayout];
    self.myUniqueItemCollectionView = thisCollectionView;
    
    //register collection view cell
    [self.myUniqueItemCollectionView registerClass:[EQRScheduleNestedDayCell class] forCellWithReuseIdentifier:@"ThisCell"];
    
    [self.myUniqueItemCollectionView setDataSource:self];
    [self.myUniqueItemCollectionView setDelegate:self];
    //
    [self.contentView addSubview:self.myUniqueItemCollectionView];
    
    //______*******  ADD CONSTRAINTS TO THE SUB COLLECTION VIEW  ********__________
    
    self.myUniqueItemCollectionView.backgroundColor = [UIColor clearColor];
    
    //__*******  register its rect in an array that the flow layout can see???   *****____
}


//this is separate from initialSetup because the navBar subview (in the cell content nib) must exist before it can be called
-(void)signalToAssignNarrow{
    
    //indicate for the cell content if orientation is portrait
    UIInterfaceOrientation orientationOnLaunch = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientationOnLaunch)) {
        self.cellContentVC.navBarDates.isNarrowFlag = YES;
        self.cellContentVC.navBarWeeks.isNarrowFlag = YES;
    }else{
        self.cellContentVC.navBarDates.isNarrowFlag = NO;
        self.cellContentVC.navBarWeeks.isNarrowFlag = NO;
    }
    //refresh the view
    [self.cellContentVC.navBarDates setNeedsDisplay];
    [self.cellContentVC.navBarWeeks setNeedsDisplay];
}


#pragma mark - collection view data source methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    //put schedule_unique_joins here to count
    NSMutableArray* temporaryMuteArray = [NSMutableArray arrayWithCapacity:1];
    
    for (EQRScheduleTracking_EquipmentUnique_Join* join in requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins){
        if ([join.equipUniqueItem_foreignKey isEqualToString:self.uniqueItem_keyID]){
            [temporaryMuteArray addObject:join];
        }
    }
    
    //assign to loco ivar
    if (!self.temporaryArrayOfEquipUniqueJoins){
        self.temporaryArrayOfEquipUniqueJoins  = [NSMutableArray arrayWithCapacity:1];
    }
    [self.temporaryArrayOfEquipUniqueJoins removeAllObjects];
    [self.temporaryArrayOfEquipUniqueJoins addObjectsFromArray:temporaryMuteArray];
    
    if ([temporaryMuteArray count] > 0){
        return [temporaryMuteArray count];
    }else{
        return 0;
    }
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    static NSString* CellIdentifier = @"ThisCell";
    EQRScheduleNestedDayCell* cell = [self.myUniqueItemCollectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    for (UIView* view in cell.contentView.subviews){
        [view removeFromSuperview];
    }

    //get the name from the locally saved array
    NSString* contact_name = [(EQRScheduleTracking_EquipmentUnique_Join*)[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] contact_name];
    
    //get the renter type
    NSString* renter_type = [(EQRScheduleTracking_EquipmentUnique_Join*)[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] renter_type];
    
    //get the join's key_id
    NSString* key_id = [(EQRScheduleTracking_EquipmentUnique_Join*)[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] key_id];
    
    //get the join's titleItem foreign key
    NSString* equipTitleItem_foreignKey = [(EQRScheduleTracking_EquipmentUnique_Join*)[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] equipTitleItem_foreignKey];
        
    [cell initialSetupWithTitle:contact_name joinKeyID:key_id joinTitleKeyID:equipTitleItem_foreignKey indexPath:self.rowCellIndexPath];
    
    
    //restrict label to the cell
    cell.contentView.clipsToBounds = YES;
    
    //cell color based on renter type
    if ([renter_type isEqualToString:EQRRenterStudent]){
        
        cell.contentView.backgroundColor = [self.myColors.colorDic objectForKey:EQRColorCalStudent];
        
    }else if([renter_type isEqualToString:EQRRenterPublic]){
        
        cell.contentView.backgroundColor = [self.myColors.colorDic objectForKey:EQRColorCalPublic];
        
    }else if([renter_type isEqualToString:EQRRenterStaff]){
        
        cell.contentView.backgroundColor = [self.myColors.colorDic objectForKey:EQRColorCalStaff];
        
    }else if([renter_type isEqualToString:EQRRenterFaculty]){
        
        cell.contentView.backgroundColor = [self.myColors.colorDic objectForKey:EQRColorCalFaculty];
        
    }else if([renter_type isEqualToString:EQRRenterYouth]){
        
        cell.contentView.backgroundColor = [self.myColors.colorDic objectForKey:EQRColorCalYouth];
        
    }else if([renter_type isEqualToString:EQRRenterInClass]){
        
        cell.contentView.backgroundColor = [self.myColors.colorDic objectForKey:EQRColorCalInClass];
    }
    
    //_______********  ..maybe color should change if it is currently out?
    
    //make background semitransparent to see overlaps
    cell.backgroundView.alpha = 0.0;

    return cell;
}


#pragma mark - collection view delegate methods
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    //get the remaining join information...
    NSArray* firstArray = @[@"key_id", [[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] scheduleTracking_foreignKey]];
    NSArray* secondArray = @[firstArray];
    EQRWebData* webData = [EQRWebData sharedInstance];
    __block EQRScheduleRequestItem* thisRequestItem;
    [webData queryWithLink:@"EQGetScheduleRequestQuickViewData.php" parameters:secondArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        if ([muteArray count] > 0){
             thisRequestItem = [muteArray objectAtIndex:0];
        }
    }];
    
    //get the cgRect of the selected cell
    UICollectionViewCell* cellOfSelectedNestedDayCell = [collectionView cellForItemAtIndexPath:indexPath];
//    CGRect rectOfSelectedNestedDayCell = cellOfSelectedNestedDayCell.frame;
    
    //original point with offset ...  I HAVE NO IDEA WHY THE X VALUE NEEDS TO REFERENCE THE CONTENTVIEW, BUT OTHERWISE IT DON'T WORK
    CGPoint originPoint = CGPointMake(
                                      cellOfSelectedNestedDayCell.contentView.frame.origin.x + EQRScheduleLengthOfEquipUniqueLabel,
                                      cellOfSelectedNestedDayCell.frame.origin.y);
    
    //Size is OK
    CGSize originSize = CGSizeMake(cellOfSelectedNestedDayCell.frame.size.width, cellOfSelectedNestedDayCell.frame.size.height);
    
    //________there is an easier option... send both the CGRect and also the View, instead of converting the point into superviews_______
    //convert values to other superview coordinates
    CGPoint convertedPointForX = [cellOfSelectedNestedDayCell convertPoint:originPoint toView:cellOfSelectedNestedDayCell.superview];
    CGPoint convertedPointForY = [cellOfSelectedNestedDayCell convertPoint:convertedPointForX toView:cellOfSelectedNestedDayCell.superview.superview.superview.superview.superview];
    
    //final CGRect
    CGRect frameSizeInSuperViewCooridnates = CGRectMake(convertedPointForX.x, convertedPointForY.y, originSize.width, originSize.height);
 
    NSValue* valueOfRect = [NSValue valueWithCGRect:frameSizeInSuperViewCooridnates];
    
    // send the Key_id and let the editor object run a SQL script to pull the scheduleTrackingRequest
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [(EQRScheduleTracking_EquipmentUnique_Join*)[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] scheduleTracking_foreignKey], @"key_ID",
                         [(EQRScheduleTracking_EquipmentUnique_Join*)[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] contact_name], @"contact_name",
                          [(EQRScheduleTracking_EquipmentUnique_Join*)[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] renter_type], @"renter_type",
                           [(EQRScheduleTracking_EquipmentUnique_Join*)[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] request_date_begin], @"request_date_begin",
                         [(EQRScheduleTracking_EquipmentUnique_Join*)[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] request_date_end], @"request_date_end",
                         [(EQRScheduleTracking_EquipmentUnique_Join*)[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] request_time_begin], @"request_time_begin",
                         [(EQRScheduleTracking_EquipmentUnique_Join*)[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] request_time_end], @"request_time_end",
                         valueOfRect, @"rectOfSelectedNestedDayCell",
                         nil];
    
    //add in information from quickviewData request
    if (thisRequestItem){
        if (thisRequestItem.notes)[dic setObject:thisRequestItem.notes forKey:@"notes"];
        if (thisRequestItem.classTitle_foreignKey) [dic setObject:thisRequestItem.classTitle_foreignKey forKey:@"classTitle_foreignKey"];
        if (thisRequestItem.staff_confirmation_id) [dic setObject:thisRequestItem.staff_confirmation_id forKey:@"staff_confirmation_id"];
        if (thisRequestItem.staff_confirmation_date) [dic setObject:thisRequestItem.staff_confirmation_date     forKey:@"staff_confirmation_date"];
        if (thisRequestItem.staff_prep_id) [dic setObject:thisRequestItem.staff_prep_id forKey:@"staff_prep_id"];
        if (thisRequestItem.staff_prep_date) [dic setObject:thisRequestItem.staff_prep_date forKey:@"staff_prep_date"];
        if (thisRequestItem.staff_checkout_id) [dic setObject:thisRequestItem.staff_checkout_id forKey:@"staff_checkout_id"];
        if (thisRequestItem.staff_checkout_date) [dic setObject:thisRequestItem.staff_checkout_date forKey:@"staff_checkout_date"];
        if (thisRequestItem.staff_checkin_id) [dic setObject:thisRequestItem.staff_checkin_id forKey:@"staff_checkin_id"];
        if (thisRequestItem.staff_checkin_date) [dic setObject:thisRequestItem.staff_checkin_date forKey:@"staff_checkin_date"];
        if (thisRequestItem.staff_shelf_id) [dic setObject:thisRequestItem.staff_shelf_id forKey:@"staff_shelf_id"];
        if (thisRequestItem.staff_shelf_date) [dic setObject:thisRequestItem.staff_shelf_date forKey:@"staff_shelf_date"];
    }
    //sends note to scheduleTopVCntrllr
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPresentScheduleRowQuickView object:nil userInfo:dic];
}


#pragma mark - collection view flow layout delegate
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    //______this is overridden in the flow layout subclass method______ Grrrr!!
//    CGSize newSize = CGSizeMake(EQRScheduleItemWidthForDay, EQRScheduleItemHeightForDay);
//    return newSize;
//}


@end
