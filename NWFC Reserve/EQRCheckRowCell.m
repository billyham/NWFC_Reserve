//
//  EQRCheckRowCell.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/27/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRCheckRowCell.h"
#import "EQRCheckCellContentVCntrllr.h"


@interface EQRCheckRowCell ()

@property (strong, nonatomic) EQRCheckCellContentVCntrllr* myCheckContent;

@end

@implementation EQRCheckRowCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



-(void)initialSetupWithEquipUnique:(EQRScheduleTracking_EquipmentUnique_Join*)equipJoin marked:(BOOL)mark_for_returning switch_num:(NSUInteger)switch_num{
    
    self.backgroundColor = [UIColor clearColor];
    
    EQRCheckCellContentVCntrllr* checkContent = [[EQRCheckCellContentVCntrllr alloc] initWithNibName:@"EQRCheckCellContentVCntrllr" bundle:nil];
    
    self.myCheckContent = checkContent;
    self.myCheckContent.myJoinKeyID = equipJoin.key_id;
    

    
    
    
    
    
    [self.contentView addSubview:self.myCheckContent.view];
    
    
    
    //assign label and switch status now, after adding the content subview
    if (!mark_for_returning){
        
        if (switch_num == 1){
            
            self.myCheckContent.joinPropertyToBeUpdated = @"prep_flag";
            
            if ([equipJoin.prep_flag isEqualToString:@"yes"]){
                
                self.myCheckContent.statusSwitch.on = YES;
                
                self.myCheckContent.status1Label.text = @"";
                self.myCheckContent.status2Label.text = @"Prepped";
                
            }else{
                
                self.myCheckContent.statusSwitch.on = NO;
                
                self.myCheckContent.status1Label.text = @"Not Prepped";
                self.myCheckContent.status2Label.text = @"";
                
            }
            
        }else {
            
            self.myCheckContent.joinPropertyToBeUpdated = @"checkout_flag";
            
            if ([equipJoin.checkout_flag isEqualToString:@"yes"]){
                
                self.myCheckContent.statusSwitch.on = YES;
                
                self.myCheckContent.status1Label.text = @"";
                self.myCheckContent.status2Label.text = @"Out";
                
            }else{
                
                self.myCheckContent.statusSwitch.on = NO;
                
                self.myCheckContent.status1Label.text = @"In";
                self.myCheckContent.status2Label.text = @"";
                
            }
            
        }
        
    }else{
        
        if (switch_num == 1){
            
            self.myCheckContent.joinPropertyToBeUpdated = @"checkin_flag";
            
            if ([equipJoin.checkin_flag isEqualToString:@"yes"]){
                
                self.myCheckContent.statusSwitch.on = YES;
                
                self.myCheckContent.status1Label.text = @"";
                self.myCheckContent.status2Label.text = @"In";
                
            }else{
                
                self.myCheckContent.statusSwitch.on = NO;
                
                self.myCheckContent.status1Label.text = @"Out";
                self.myCheckContent.status2Label.text = @"";
                
            }
            
        }else{
            
            self.myCheckContent.joinPropertyToBeUpdated = @"shelf_flag";
            
            if ([equipJoin.shelf_flag isEqualToString:@"yes"]){
                
                self.myCheckContent.statusSwitch.on = YES;
                
                self.myCheckContent.status1Label.text = @"";
                self.myCheckContent.status2Label.text = @"Shelved";
                
            }else{
                
                self.myCheckContent.statusSwitch.on = NO;
                
                self.myCheckContent.status1Label.text = @"Not Shelved";
                self.myCheckContent.status2Label.text = @"";
                
            }
            
        }
        
    }

    
    self.myCheckContent.equipNameLabel.text = equipJoin.name;
    self.myCheckContent.distIDLabel.text = equipJoin.distinquishing_id;
    
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
