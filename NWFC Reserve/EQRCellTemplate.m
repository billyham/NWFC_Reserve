//
//  EQRCellTemplate.m
//  NWFC Reserve
//
//  Created by Ray Smith on 12/25/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import "EQRCellTemplate.h"
#import "EQRColors.h"

@implementation EQRCellTemplate

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
    
    self.backgroundColor = [UIColor whiteColor];
    
    //set custom bg color on selection
    EQRColors *colors = [EQRColors sharedInstance];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [colors.colorDic objectForKey:EQRColorSelectionBlue];
    [self setSelectedBackgroundView:bgColorView];
    
    UILabel* thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 5, 295, 45)];
    self.titleLabel = thisLabel;
    
    self.titleLabel.text = titleName;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    
    
    [self.contentView addSubview:self.titleLabel];
    
}


-(void)doHighlightCell{
    
//    self.titleLabel.textColor = [UIColor redColor];
}

-(void)cancelHighlightCell{
    
//    self.titleLabel.textColor = [UIColor blackColor];
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
