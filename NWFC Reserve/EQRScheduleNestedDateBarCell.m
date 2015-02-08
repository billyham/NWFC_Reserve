//
//  EQRScheduleNestedDateBarCell.m
//  Gear
//
//  Created by Ray Smith on 2/7/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleNestedDateBarCell.h"

@interface EQRScheduleNestedDateBarCell ()

@property (strong, nonatomic) UILabel* dateLabel;
@property (strong, nonatomic) UILabel* dayOfWeekLabel;


@end


@implementation EQRScheduleNestedDateBarCell

-(void)initialSetupWithDate:(NSString*)date DayOfWeek:(NSString*)dayOfWeek{
    
    self.backgroundColor = [UIColor clearColor];
    
    UILabel* thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(-11.f, -3.f, 50, 50)];
    self.dateLabel = thisLabel;
    self.dateLabel.text = date;
    self.dateLabel.font = [UIFont fontWithName:@"Helvetica" size:9.f];
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel* thatLabel = [[UILabel alloc] initWithFrame:CGRectMake(-11.f, -17.f, 50, 50)];
    self.dayOfWeekLabel = thatLabel;
    self.dayOfWeekLabel.text = dayOfWeek;
    self.dayOfWeekLabel.font = [UIFont fontWithName:@"Helvetica" size:9.f];
    self.dayOfWeekLabel.backgroundColor = [UIColor clearColor];
    self.dayOfWeekLabel.textAlignment = NSTextAlignmentCenter;
    
    
    
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.dayOfWeekLabel];
    
}

@end
