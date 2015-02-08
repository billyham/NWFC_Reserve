//
//  EQRScheduleDateBarLayout.m
//  Gear
//
//  Created by Ray Smith on 2/7/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleDateBarLayout.h"
#import "EQRGlobals.h"


@implementation EQRScheduleDateBarLayout

- (CGSize)collectionViewContentSize{
    
    //________********  should set size based on current orientation   *********_____
    
    CGSize newSize = CGSizeMake(824, EQRScheduleItemHeightForDay);
    
    return newSize;
    
    
}



- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    NSMutableArray* arrayOfLayoutAttributes = [NSMutableArray arrayWithCapacity:1];
    
    int i;
    for (i=0 ; i<=30 ; i++){
    
        //derive indexpath
        NSIndexPath* thisIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        //create corresponding attributes, SIZE and CENTER
        UICollectionViewLayoutAttributes* theseAttributes = [self layoutAttributesForItemAtIndexPath:thisIndexPath];
        
        //assign attributes to the array
        [arrayOfLayoutAttributes addObject:theseAttributes];
        
    }
    
    return  arrayOfLayoutAttributes;
}



- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    int objectWidth;
    UIInterfaceOrientation orientationOnLunch = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientationOnLunch)) {
        
        objectWidth = EQRScheduleItemWidthForDayNarrow;
        
    }else{
        
        objectWidth = EQRScheduleItemWidthForDay;
    }
    
    //create a layout attributes, then set its attributes
    UICollectionViewLayoutAttributes* theseAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    //SIZE
    CGSize newSize = CGSizeMake(objectWidth, EQRScheduleItemHeightForDay);
    
    //CENTER
    float newXValue = (objectWidth * (indexPath.row + 1)) - (objectWidth) + (objectWidth - 15);
    CGPoint newCenter = CGPointMake(newXValue, EQRScheduleItemHeightForDay / 2);
    
    //assign values to attributes
    theseAttributes.size = newSize;
    theseAttributes.center = newCenter;
    
    return  theseAttributes;
}


@end
