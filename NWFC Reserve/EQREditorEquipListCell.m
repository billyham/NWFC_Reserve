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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


-(void)initialSetupWithJoinObject:(EQRScheduleTracking_EquipmentUnique_Join*)joinObject deleteFlag:(BOOL)deleteFlag{
    
    self.myKey_id = joinObject.equipUniqueItem_foreignKey;
    self.toBeDeletedFlag = deleteFlag;
    
    EQREditorEquipListContentVC* contentView = [[EQREditorEquipListContentVC alloc] initWithNibName:@"EQREditorEquipListContentVC" bundle:nil];
    self.myContentVC = contentView;
    
    //add content view to view
    [self.contentView addSubview:self.myContentVC.view];
    
    
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
//    UIInterfaceOrientation thisOrientation = [[UIApplication sharedApplication] statusBarOrientation];
//    if (UIInterfaceOrientationIsLandscape(thisOrientation)){
//        
//        CGRect thisRect = CGRectMake(0, self.frame.origin.y, 602, self.frame.size.height);  //-128
//        self.frame = thisRect;
//        
//    }else {
//        
//        CGRect thisRect = CGRectMake(0, self.frame.origin.y, 346, self.frame.size.height);
//        self.frame = thisRect;
//    }
    
    //colors
    EQRColors* colors = [EQRColors sharedInstance];
    
    //delete button
    [self.myContentVC.myDeleteButton setTitle:thisButtonText forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
    [self.myContentVC.myDeleteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal & UIControlStateSelected];
    [self.myContentVC.myDeleteButton setTitleColor:[colors.colorDic objectForKey:EQRColorLightBlue] forState:UIControlStateHighlighted];
    self.myContentVC.myDeleteButton.reversesTitleShadowWhenHighlighted = YES;
    self.myContentVC.myDeleteButton.userInteractionEnabled = YES;
    
    //target of button
    [self.myContentVC.myDeleteButton addTarget:self action:@selector(deleteEquipItem:) forControlEvents:UIControlEventTouchUpInside];

    
    
    
    //label
    self.myContentVC.myLabel.text = joinObject.name;
    
    //dist id button
    [self.myContentVC.myDistIDButton setTitle:joinObject.distinquishing_id forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
    
    //service issue button
    if ([joinObject.issue_short_name isEqualToString:@""]){  //no service issues
        
        [self.myContentVC.myServiceIssue setHidden:YES];
        
    } else if([joinObject.status_level integerValue] < 2){   //service issue exists but it is resolved, so don't show
        
        [self.myContentVC.myServiceIssue setHidden:YES];
        
    } else {  //show service issues
        
        [self.myContentVC.myServiceIssue setHidden:NO];
        
        [self.myContentVC.myServiceIssue setTitle:joinObject.issue_short_name forState:UIControlStateHighlighted & UIControlStateNormal & UIControlStateSelected];
        
        //set color
        EQRColors* colors = [EQRColors sharedInstance];
        
        //if status level is 3 or above
        if ([joinObject.status_level integerValue] >= 5){  //damaged, make text red
            
            [self.myContentVC.myServiceIssue setTitleColor:[colors.colorDic objectForKey:EQRColorIssueSerious] forState:UIControlStateSelected & UIControlStateNormal & UIControlStateHighlighted];
            
        }else if (([joinObject.status_level integerValue] == 3) || ([joinObject.status_level integerValue] == 4)){
            
            [self.myContentVC.myServiceIssue setTitleColor:[colors.colorDic objectForKey:EQRColorIssueMinor] forState:UIControlStateSelected & UIControlStateNormal & UIControlStateHighlighted];
        }else{
            
            [self.myContentVC.myServiceIssue setTitleColor:[colors.colorDic objectForKey:EQRColorIssueDescriptive] forState:UIControlStateSelected & UIControlStateNormal & UIControlStateHighlighted];
        }
    }
    
}


-(IBAction)deleteEquipItem:(id)sender{
    
    if (!self.toBeDeletedFlag){
        
        //send view controller a note with key_id (or indexpath) to indicate it needs to be removed from the database
        
        NSDictionary* thisDic = [NSDictionary dictionaryWithObject:self.myKey_id forKey:@"key_id"];
        [[NSNotificationCenter defaultCenter] postNotificationName:EQREquipUniqueToBeDeleted object:nil userInfo:thisDic];
        
        //flag the color of the cell!!
        self.myContentVC.view.backgroundColor = [UIColor redColor];
        
        [self.myContentVC.myDeleteButton setTitle:@"Cancel" forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];

        self.toBeDeletedFlag = YES;
        
    }else {
        
        NSDictionary* thisDic = [NSDictionary dictionaryWithObject:self.myKey_id forKey:@"key_id"];
        [[NSNotificationCenter defaultCenter] postNotificationName:EQREquipUniqueToBeDeletedCancel object:nil userInfo:thisDic];
        
        self.myContentVC.view.backgroundColor = [UIColor whiteColor];
        
        [self.myContentVC.myDeleteButton setTitle:@"Delete" forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
        
        self.toBeDeletedFlag = NO;
    }
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
