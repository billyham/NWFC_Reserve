//
//  EQRCheckRowCell.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/27/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRCheckRowCell.h"
#import "EQRCheckCellContentVCntrllr.h"
#import "EQRColors.h"


@interface EQRCheckRowCell ()

@property (strong, nonatomic) EQRCheckCellContentVCntrllr* myCheckContent;
//@property BOOL toBeDeletedFlag;

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



-(void)initialSetupWithEquipUnique:(EQRScheduleTracking_EquipmentUnique_Join*)equipJoin
                            marked:(BOOL)mark_for_returning
                        switch_num:(NSUInteger)switch_num
                 markedForDeletion:(BOOL)deleteFlag
                         indexPath:(NSIndexPath*)indexPath{
    
//    NSLog(@"inside initialsetupwith equipUnique... new dist id: %@", equipJoin.distinquishing_id);
    
    self.backgroundColor = [UIColor clearColor];
    
    EQRCheckCellContentVCntrllr* checkContent = [[EQRCheckCellContentVCntrllr alloc] initWithNibName:@"EQRCheckCellContentVCntrllr" bundle:nil];
    
    self.myCheckContent = checkContent;
    self.myCheckContent.myIndexPath = indexPath;
    self.myCheckContent.myJoinKeyID = equipJoin.key_id;
    self.myCheckContent.equipUniqueItem_foreignKey = equipJoin.equipUniqueItem_foreignKey;
    self.myCheckContent.equipTitleItem_foreignKey = equipJoin.equipTitleItem_foreignKey;
        
    
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
    [self.myCheckContent.distIDLabel setTitle:equipJoin.distinquishing_id forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
    
    //service issue button
    if ([equipJoin.issue_short_name isEqualToString:@""]){  //no service issues
        
        [self.myCheckContent.serviceIssue setHidden:YES];
        
    } else if([equipJoin.status_level integerValue] < 2){   //service issue exists but it is resolved, so don't show
        
        [self.myCheckContent.serviceIssue setHidden:YES];
        
    } else {  //show service issues
        
        [self.myCheckContent.serviceIssue setHidden:NO];
        
        [self.myCheckContent.serviceIssue setTitle:equipJoin.issue_short_name forState:UIControlStateHighlighted & UIControlStateNormal & UIControlStateSelected];
        
        //set color
        EQRColors* colors = [EQRColors sharedInstance];
        
        //if status level is 3 or above
        if ([equipJoin.status_level integerValue] >= 5){  //damaged, make text red
            
            [self.myCheckContent.serviceIssue setTitleColor:[colors.colorDic objectForKey:EQRColorIssueSerious] forState:UIControlStateSelected & UIControlStateNormal & UIControlStateHighlighted];
            
        }else if (([equipJoin.status_level integerValue] == 3) || ([equipJoin.status_level integerValue] == 4)){
            
            [self.myCheckContent.serviceIssue setTitleColor:[colors.colorDic objectForKey:EQRColorIssueMinor] forState:UIControlStateSelected & UIControlStateNormal & UIControlStateHighlighted];
        }else{
            
            [self.myCheckContent.serviceIssue setTitleColor:[colors.colorDic objectForKey:EQRColorIssueDescriptive] forState:UIControlStateSelected & UIControlStateNormal & UIControlStateHighlighted];
        }
    }
    
    
    //setup deletion button and background color based on deletionFlag
    [self.myCheckContent initialSetupWithDeleteFlag:deleteFlag];
    
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
