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
    
    //get dates
    NSDate* startDayDate = [(EQRScheduleTracking_EquipmentUnique_Join*)[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] request_date_begin];
    NSDate* endDayDate = [(EQRScheduleTracking_EquipmentUnique_Join*)[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] request_date_end];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    //convert dates to strings
    //figure out thet start date and end date
    NSString* startDayString = [[dateFormatter stringFromDate:startDayDate] substringFromIndex:8];
    NSString* endDayString = [[dateFormatter stringFromDate:endDayDate] substringFromIndex:8];
    
    //figure out the start month and end month
    NSString* startMonthString = [[dateFormatter stringFromDate:startDayDate] substringWithRange:NSMakeRange(5, 2)];
    NSString* endMonthString = [[dateFormatter stringFromDate:endDayDate] substringWithRange:NSMakeRange(5, 2)];
    NSString* startYearString = [[dateFormatter stringFromDate:startDayDate] substringToIndex:4];
    NSString* endYearString = [[dateFormatter stringFromDate:endDayDate] substringToIndex:4];
    NSString* dateForShowMonthString = [[dateFormatter stringFromDate:self.scheduleDateForShow] substringWithRange:NSMakeRange(5, 2)];
    NSString* dateForShowYearString = [[dateFormatter stringFromDate:self.scheduleDateForShow] substringToIndex:4];
    
//    NSLog(@"this is the startYearString: %@  this is the dateForShowYearString: %@", startYearString, dateForShowYearString);
    
    int startDayInt = (int)[startDayString integerValue];
    int endDayInt = (int)[endDayString integerValue];
    
    int startMonthInt = (int)[startMonthString intValue];
    int endMonthInt = (int)[endMonthString intValue];
    int startYearInt = (int)[startYearString intValue];
    int endYearInt = (int)[endYearString intValue];
    int dateForShowMonthInt = (int)[dateForShowMonthString intValue];
    int dateForShowYearInt = (int)[dateForShowYearString intValue];
    
    //accommodate when the start or end date is in a different month (and year)
    //________********  limit end to actual number of days in the month instead of defaulting to 31  ********_______
    
    if ((startMonthInt < dateForShowMonthInt) || (startYearInt < dateForShowYearInt)){
        
        startDayInt = 1;
    }
    
    if ((endMonthInt > dateForShowMonthInt) || (endYearInt > dateForShowYearInt)){
        
        endDayInt = 31;
    }
    
    
    int distanceOffset = (startDayInt - 1) * EQRScheduleItemWidthForDay;
    
    //trim 2 points off the end otherwise two objects next to each other blend as one long object
    int objectWidth = (((endDayInt + 1) - startDayInt) * EQRScheduleItemWidthForDay) - 1 ;  //originally - 2
    
    
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
