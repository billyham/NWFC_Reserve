//
//  EQREditorEquipListCell.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/31/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREditorEquipListCell.h"
#import "EQRColors.h"
#import "EQRGlobals.h"

@interface EQREditorEquipListCell ()

@property (nonatomic, strong) EQRScheduleTracking_EquipmentUnique_Join* myJoinObject;
@property (nonatomic, strong) NSString* myKey_id;

@end

@implementation EQREditorEquipListCell

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


-(void)initialSetupWithJoinObject:(EQRScheduleTracking_EquipmentUnique_Join*)joinObject deleteFlag:(BOOL)deleteFlag editMode:(BOOL)editModeFlag{
    
    //retaining the joinObject seems like a bad idea, but... need to use it for the distIDPicker
    self.myJoinObject = joinObject;
    
    self.myKey_id = joinObject.equipUniqueItem_foreignKey;
    self.toBeDeletedFlag = deleteFlag;
    
    EQREditorEquipListContentVC* contentView = [[EQREditorEquipListContentVC alloc] initWithNibName:@"EQREditorEquipListContentVC" bundle:nil];
    self.myContentVC = contentView;
    
    //add content view to view
    [self.contentView addSubview:self.myContentVC.view];
    
    //hide or show the delete button
    if (editModeFlag == NO){
        [self.myContentVC.myDeleteButton setHidden:YES];
        
        self.myContentVC.issueTrailingConstraint.constant = 0;
        
        EQRColors *colors = [EQRColors sharedInstance];
        self.myContentVC.myDistIDButton.backgroundColor = [colors.colorDic objectForKey:EQRColorVeryLightGrey];
        [self.myContentVC.myDistIDButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
        [self.myContentVC.myDistIDButton setUserInteractionEnabled:NO];
    }else{
        
        EQRColors *colors = [EQRColors sharedInstance];
        self.myContentVC.myDistIDButton.backgroundColor = [colors.colorDic objectForKey:EQRColorEditModeBGBlue];
        [self.myContentVC.myDistIDButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
        [self.myContentVC.myDistIDButton setUserInteractionEnabled:YES];
    }
    
    //_____ add constraints to content view
    self.myContentVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* viewsDictionary = @{@"myContentVC":self.myContentVC.view};
    
    NSArray* constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[myContentVC]-0-|" options:0 metrics:nil views:viewsDictionary];
    
    NSArray* constraint_POS_VB = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[myContentVC]-0-|" options:0 metrics:nil views:viewsDictionary];
    
    [[self.myContentVC.view superview] addConstraints:constraint_POS_V];
    [[self.myContentVC.view superview] addConstraints:constraint_POS_VB];
    
    
    
    NSString* thisButtonText;
    
    if (self.toBeDeletedFlag){
        
        self.myContentVC.view.backgroundColor = [UIColor redColor];
        thisButtonText = @"Cancel";
        
    }else {
        
        self.myContentVC.view.backgroundColor = [UIColor whiteColor];
        thisButtonText = @"Delete";
    }
    
    //size of cell depends on size of collection view based on orientation
    //____moved to VC and handled in CollectionViewFlowLayoutDelegate method
    
    //colors
    EQRColors* colors = [EQRColors sharedInstance];
    
    //delete button
    [self.myContentVC.myDeleteButton setTitle:thisButtonText forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
    [self.myContentVC.myDeleteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal & UIControlStateSelected];
    [self.myContentVC.myDeleteButton setTitleColor:[colors.colorDic objectForKey:EQRColorSelectionBlue] forState:UIControlStateHighlighted];
    self.myContentVC.myDeleteButton.reversesTitleShadowWhenHighlighted = YES;
    self.myContentVC.myDeleteButton.userInteractionEnabled = YES;
    
    //target of button
    [self.myContentVC.myDeleteButton addTarget:self action:@selector(deleteEquipItem:) forControlEvents:UIControlEventTouchUpInside];

    
    //label
    self.myContentVC.myLabel.text = joinObject.name;
    
    
    //dist id button
    [self.myContentVC.myDistIDButton setTitle:joinObject.distinquishing_id forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
    
    //dist id button target
    [self.myContentVC.myDistIDButton addTarget:self action:@selector(distIDPickerButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //service issue button
    if ([joinObject.issue_short_name isEqualToString:@""]){  //no service issues
        
        [self.myContentVC.myServiceIssue setHidden:YES];
        
    } else if([joinObject.status_level integerValue] < EQRThresholdForDescriptiveNote){   //service issue exists but it is resolved, so don't show
        
        [self.myContentVC.myServiceIssue setHidden:YES];
        
    } else {  //show service issues
        
        [self.myContentVC.myServiceIssue setHidden:NO];
        
        [self.myContentVC.myServiceIssue setTitle:joinObject.issue_short_name forState:UIControlStateHighlighted & UIControlStateNormal & UIControlStateSelected];
        
        //set color
        EQRColors* colors = [EQRColors sharedInstance];
        
        //if status level is 3 or above
        if ([joinObject.status_level integerValue] >= EQRThresholdForSeriousIssue){  //damaged, make text red
            
            [self.myContentVC.myServiceIssue setTitleColor:[colors.colorDic objectForKey:EQRColorIssueSerious] forState:UIControlStateSelected & UIControlStateNormal & UIControlStateHighlighted];
            
        }else if (([joinObject.status_level integerValue] >= EQRThresholdForMinorIssue) && ([joinObject.status_level integerValue] < EQRThresholdForSeriousIssue)){
            
            [self.myContentVC.myServiceIssue setTitleColor:[colors.colorDic objectForKey:EQRColorIssueMinor] forState:UIControlStateSelected & UIControlStateNormal & UIControlStateHighlighted];
        }else{
            
            [self.myContentVC.myServiceIssue setTitleColor:[colors.colorDic objectForKey:EQRColorIssueDescriptive] forState:UIControlStateSelected & UIControlStateNormal & UIControlStateHighlighted];
        }
    }
    
}


-(void)enterEditMode{
    
    //shorten issue text and show edit button
    self.myContentVC.issueTrailingConstraint.constant = 50.f;
    
    EQRColors *colors = [EQRColors sharedInstance];
    self.myContentVC.myDistIDButton.backgroundColor = [colors.colorDic objectForKey:EQRColorEditModeBGBlue];
    [self.myContentVC.myDistIDButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
    [self.myContentVC.myDistIDButton setUserInteractionEnabled:YES];
    
    [UIView animateWithDuration:0.25 animations:^{
       
        [self.myContentVC.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [self.myContentVC.myDeleteButton setHidden:NO];
    }];
}


-(void)leaveEditMode{
    
    //lengthen issue text and hide edit button
    self.myContentVC.issueTrailingConstraint.constant = 0;
    
    EQRColors *colors = [EQRColors sharedInstance];
    self.myContentVC.myDistIDButton.backgroundColor = [colors.colorDic objectForKey:EQRColorVeryLightGrey];
    [self.myContentVC.myDistIDButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
    [self.myContentVC.myDistIDButton setUserInteractionEnabled:NO];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.myContentVC.view layoutIfNeeded];
        
        [self.myContentVC.myDeleteButton setHidden:YES];
        
    } completion:^(BOOL finished) {
        
    }];
}


-(IBAction)deleteEquipItem:(id)sender{
    
    if (!self.toBeDeletedFlag){
        
        //send view controller a note with key_id (or indexpath) to indicate it needs to be removed from the database
        
        //__1. use delegate methods
        [self.delegate tagEquipUniqueToDelete:self.myKey_id];
        
        //__2. or.... use notification
//        NSDictionary* thisDic = [NSDictionary dictionaryWithObject:self.myKey_id forKey:@"key_id"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:EQREquipUniqueToBeDeleted object:nil userInfo:thisDic];
        
        //flag the color of the cell!!
        self.myContentVC.view.backgroundColor = [UIColor redColor];
        
        [self.myContentVC.myDeleteButton setTitle:@"Cancel" forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];

        self.toBeDeletedFlag = YES;
        
    }else {
        
        //___1. use delegate method
        [self.delegate tagEquipUniqueToCancelDelete:self.myKey_id];
        
        //___2. or... use notification
//        NSDictionary* thisDic = [NSDictionary dictionaryWithObject:self.myKey_id forKey:@"key_id"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:EQREquipUniqueToBeDeletedCancel object:nil userInfo:thisDic];
        
        self.myContentVC.view.backgroundColor = [UIColor whiteColor];
        
        [self.myContentVC.myDeleteButton setTitle:@"Delete" forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
        
        self.toBeDeletedFlag = NO;
    }
}

-(IBAction)distIDPickerButton:(id)sender{
    
    //send cell's equipUniqueKey, titleKey, button
//    NSString* equipTitleItem_foreignKey = [infoDictionary objectForKey:@"equipTitleItem_foreignKey"];
//    NSString* equipUniqueItem_foreignKey = [infoDictionary objectForKey:@"equipUniqueItem_foreignKey"];
//    UIButton* thisButton = (UIButton*)[infoDictionary objectForKey:@"distButton"];
    
    NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.myJoinObject.equipTitleItem_foreignKey, @"equipTitleItem_foreignKey",
                            self.myJoinObject.equipUniqueItem_foreignKey, @"equipUniqueItem_foreignKey",
                            self.myContentVC.myDistIDButton, @"distButton",
                            nil];
    
    [self.delegate distIDPickerTapped:newDic];
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
