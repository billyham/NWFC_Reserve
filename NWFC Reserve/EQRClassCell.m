//
//  EQRClassCell.m
//  NWFC Reserve
//
//  Created by Ray Smith on 12/26/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import "EQRClassCell.h"

@implementation EQRClassCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - methods

-(void)initialSetupWithTitle:(NSString*) titleName{
    
    UILabel* thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 5, 700, 20)];
    self.titleLabel = thisLabel;
    
    self.titleLabel.text = titleName;
    
    [self.contentView addSubview:self.titleLabel];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
