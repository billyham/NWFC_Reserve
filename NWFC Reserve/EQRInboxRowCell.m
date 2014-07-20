//
//  EQRInboxRowCell.m
//  NWFC Reserve
//
//  Created by Ray Smith on 7/19/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRInboxRowCell.h"
#import "EQRInboxCellContentVCntrllr.h"

@interface EQRInboxRowCell ()

@property (strong, nonatomic) EQRInboxCellContentVCntrllr* inboxRowContent;

@end

@implementation EQRInboxRowCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)initialSetupWithTitle:(NSString *)titleName{
    
    self.inboxRowContent = [[EQRInboxCellContentVCntrllr alloc] initWithNibName:@"EQRInboxCellContentVCntrllr" bundle:nil];
    
    
    
    
    
    
    //add the cell content view controller to the row
    [self.contentView addSubview:self.inboxRowContent.view];
    
    self.inboxRowContent.titleLabel.text = titleName;

    
    
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
