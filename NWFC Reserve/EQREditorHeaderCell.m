//
//  EQREditorHeaderCell.m
//  NWFC Reserve
//
//  Created by Ray Smith on 8/16/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREditorHeaderCell.h"
#import "EQRColors.h"

@interface EQREditorHeaderCell ()

//@property (strong, nonatomic) UILabel* titleLabel;

@end

@implementation EQREditorHeaderCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)initialSetupWithTitle:(NSString*) titleName{
    
    EQRColors* colors = [EQRColors sharedInstance];
    self.backgroundColor = [[colors colorDic] objectForKey:EQRColorVeryLightGrey];
    
    UILabel* thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 295, 20)];
    self.titleLabel = thisLabel;
    
    self.titleLabel.font = [UIFont systemFontOfSize:11];
    self.titleLabel.text = titleName;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
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
