//
//  EQRScheduleFlowLayout.m
//  NWFC Reserve
//
//  Created by Ray Smith on 3/23/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleFlowLayout.h"
#import "EQRGlobals.h"
#import "EQRScheduleRowCell.h"

@implementation EQRScheduleFlowLayout

//
//- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
//    
//    
//    NSArray* superArray = [super layoutAttributesForElementsInRect:rect];
//    
//    NSLog(@"layoutAttributesForElementsInRect called");
//
//    NSMutableArray* newArray = [NSMutableArray arrayWithCapacity:1];
//    
//    [superArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes* layoutAtt, NSUInteger idx, BOOL *stop) {
//
//        
//        //_______********  NEED TO ACCESS INFORMATION ABOUT THE OBJECT AT EACH INDEXPATH FROM A COMMON SOURCE  ******_____
//        
//        //_____hardcoded how to adjust center with size
//        float hardcodedSizeAdjustment = 30.0;
//        
//        
//        //________********  should set size based on current orientation   *********_____
//        //set the size
//        CGSize newSize = CGSizeMake(EQRScheduleItemWidthForDay + hardcodedSizeAdjustment, EQRScheduleItemHeightForDay);
//        
//        //assign size to attributes
//        layoutAtt.size = newSize;
//        
//        
//        //set the center
//        float newXValue = layoutAtt.center.x + (idx * EQRScheduleItemWidthForDay) + (hardcodedSizeAdjustment / 2);
//        
//        layoutAtt.center = CGPointMake(newXValue, layoutAtt.center.y);
//        
//        
//        
//        //assign layoutAttributes to an array
//        [newArray addObject:layoutAtt];
//
//        
//        
//    } ];
//
//    
//    return [NSArray arrayWithArray:newArray];
//    
//}



//________********  THIS METHOD IS NEVER CALLED  ******_________
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewLayoutAttributes* theseAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    //_______reassign theseAttributes.center and .size
    
    
    float newXOrigin = theseAttributes.center.x + (indexPath.row * 30);
    
    CGPoint newCenterPoint = CGPointMake(newXOrigin, theseAttributes.center.y);
    
    //assign new center point
    theseAttributes.center = newCenterPoint;
    
    
    //new size
    CGSize newSize = CGSizeMake(80, 50);
    
    theseAttributes.size = newSize;
    
    return  theseAttributes;
    
}


@end
