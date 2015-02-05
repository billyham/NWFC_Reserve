//
//  EQRCheckRowMiscItemCell.m
//  Gear
//
//  Created by Ray Smith on 2/4/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRCheckRowMiscItemCell.h"
#import "EQRGlobals.h"
#import "EQRColors.h"
#import "EQRCheckCellContentVCntrllr.h"

@interface EQRCheckRowMiscItemCell()

@property (strong, nonatomic) EQRCheckCellContentVCntrllr* myCheckContent;

@end



@implementation EQRCheckRowMiscItemCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)initialSetupWithMiscJoin:(EQRMiscJoin*)miscJoin
                         marked:(BOOL)mark_for_returning
                     switch_num:(NSUInteger)switch_num
              markedForDeletion:(BOOL)deleteFlag
                      indexPath:(NSIndexPath*)indexPath{
    
    self.backgroundColor = [UIColor clearColor];
    
    EQRCheckCellContentVCntrllr* checkContent = [[EQRCheckCellContentVCntrllr alloc] initWithNibName:@"EQRCheckCellContentVCntrllr" bundle:nil];
    
    self.myCheckContent = checkContent;
    self.myCheckContent.myIndexPath = indexPath;
    self.myCheckContent.myJoinKeyID = miscJoin.key_id;
    
    
    [self.contentView addSubview:self.myCheckContent.view];
    
    
    
    //assign label and switch status now, after adding the content subview
    if (!mark_for_returning){
        
        if (switch_num == 1){
            
            self.myCheckContent.joinPropertyToBeUpdated = @"prep_flag";
            
            if ([miscJoin.prep_flag isEqualToString:@"yes"]){
                
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
            
            if ([miscJoin.checkout_flag isEqualToString:@"yes"]){
                
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
            
            if ([miscJoin.checkin_flag isEqualToString:@"yes"]){
                
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
            
            if ([miscJoin.shelf_flag isEqualToString:@"yes"]){
                
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
    
    self.myCheckContent.equipNameLabel.text = miscJoin.name;
    
    //hide the dist_id label and service issue button
    [self.myCheckContent.distIDLabel setHidden:YES];
    [self.myCheckContent.serviceIssue setHidden:YES];
    
    //change leading constraint on the name label
    self.myCheckContent.nameLabelWidthContraint.constant = 200.f;
    //make label 2 lines
    self.myCheckContent.equipNameLabel.numberOfLines = 2;
    
    //setup deletion button and background color based on deletionFlag
    [self.myCheckContent initialSetupWithDeleteFlag:deleteFlag];
    
    //turn off QR code receiving function
    self.myCheckContent.isContentForMiscJoin = YES;
}



@end
