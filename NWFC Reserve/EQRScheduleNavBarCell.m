//
//  EQRHeaderForNavBar.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/26/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleNavBarCell.h"

@implementation EQRScheduleNavBarCell

-(void)initialSetupWithTitle:(NSString*) titleName{
    
    self.backgroundColor = [UIColor yellowColor];
    
    UILabel* thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 56, 50)];
    self.titleLabel = thisLabel;
    
    self.titleLabel.text = titleName;
    self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:10.f];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.titleLabel];
    
}


@end
