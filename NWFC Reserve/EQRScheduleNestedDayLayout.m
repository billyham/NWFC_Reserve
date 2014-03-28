//
//  EQRScheduleFlowLayout.m
//  NWFC Reserve
//
//  Created by Ray Smith on 3/23/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleNestedDayLayout.h"
#import "EQRGlobals.h"
#import "EQRScheduleRowCell.h"
#import "EQRScheduleRequestManager.h"

@interface EQRScheduleNestedDayLayout()

@property (strong, nonatomic) NSMutableArray* temporaryArrayOfEquipUniqueJoins;

@end

@implementation EQRScheduleNestedDayLayout


#pragma mark - layout methods to be subclassed

- (void)prepareLayout{
    
    
    
}


- (CGSize)collectionViewContentSize{
    
    //________********  should set size based on current orientation   *********_____
    
    CGSize newSize = CGSizeMake(824, 30);
    
    return newSize;
    
    
}



- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    //look into the array to derive the index paths for all objects in collection view
    //cycle through and assign attributes
    
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    //temporary array
    NSMutableArray* arrayOfMatchingJoins = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray* arrayOfLayoutAttributes = [NSMutableArray arrayWithCapacity:1];

    
    [requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins enumerateObjectsUsingBlock:^(EQRScheduleTracking_EquipmentUnique_Join* join, NSUInteger idx, BOOL *stop) {
       
        if ([join.equipUniqueItem_foreignKey isEqualToString:self.uniqueItem_keyID]){
            
            [arrayOfMatchingJoins addObject:join];
            
        }
        
    }];
    
    //assign to local ivar
    if (!self.temporaryArrayOfEquipUniqueJoins){
        
        self.temporaryArrayOfEquipUniqueJoins = [NSMutableArray arrayWithCapacity:1];
    }
    
    //clear it out
    [self.temporaryArrayOfEquipUniqueJoins removeAllObjects];
    [self.temporaryArrayOfEquipUniqueJoins addObjectsFromArray:arrayOfMatchingJoins];
    
    
    [arrayOfMatchingJoins enumerateObjectsUsingBlock:^(EQRScheduleTracking_EquipmentUnique_Join* join, NSUInteger idx, BOOL *stop) {
        
        //derive indexpath
        NSIndexPath* thisIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        
        //create corresponding attributes, SIZE and CENTER
        UICollectionViewLayoutAttributes* theseAttributes = [self layoutAttributesForItemAtIndexPath:thisIndexPath];
        
        //assign attributes to the array
        [arrayOfLayoutAttributes addObject:theseAttributes];
        
    }];
    
    return  arrayOfLayoutAttributes;
}



- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //create a layout attributes, then set its attributes
    UICollectionViewLayoutAttributes* theseAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    //________********  should set size based on current orientation   *********_____
//    NSDateFormatter* justDayFormatter = [[NSDateFormatter alloc] init];
//    justDayFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//    justDayFormatter.dateFormat = @"dd";
    
    //figure out thet start date and end date
    NSString* startDayString = [(NSString*)[(EQRScheduleTracking_EquipmentUnique_Join*)[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] request_date_begin] substringFromIndex:8];
    NSString* endDayString = [(NSString*)[(EQRScheduleTracking_EquipmentUnique_Join*)[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] request_date_end] substringFromIndex:8];
    
    int startDayInt = (int)[startDayString integerValue];
    int endDayInt = (int)[endDayString integerValue];
    
    int distanceOffset = (startDayInt - 1) * EQRScheduleItemWidthForDay;
    
    //trim 1 points off the end otherwise two objects next to each other blend as one long object
    int objectWidth = (((endDayInt + 1) - startDayInt) * EQRScheduleItemWidthForDay) - 1 ;
    
    
    //SIZE
    CGSize newSize = CGSizeMake(objectWidth, EQRScheduleItemHeightForDay);
    
    //CENTER
    float newXValue = objectWidth / 2 + distanceOffset;
    CGPoint newCenter = CGPointMake(newXValue, 15.f);
    
    //assign values to attributes
    theseAttributes.size = newSize;
    theseAttributes.center = newCenter;
    
    return  theseAttributes;
}


@end
