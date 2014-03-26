//
//  EQRScheduleNestedDayCell.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/25/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleNestedDayCell.h"

@implementation EQRScheduleNestedDayCell


-(void)initialSetupWithTitle:(NSString*) titleName{
    
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel* thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 295, 30)];
    self.titleLabel = thisLabel;
    
    self.titleLabel.text = titleName; 
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:9.f];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.titleLabel];
    
}

@end
