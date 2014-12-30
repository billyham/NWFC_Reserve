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
#import "EQRScheduleTracking_EquipmentUnique_Join.h"

@interface EQREditorEquipListCell ()

@property (nonatomic, strong) EQRScheduleTracking_EquipmentUnique_Join* myJoinObject;
@property (nonatomic, strong) NSString* myKey_id;
@property (nonatomic, strong) IBOutlet UIButton* myDeleteButtonx;

@end

@implementation EQREditorEquipListCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


-(void)initialSetupWithTitle:(NSString*) titleName keyID:(NSString*)keyID deleteFlag:(BOOL)deleteFlag{
    
    self.myKey_id = keyID;
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
    UIInterfaceOrientation thisOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(thisOrientation)){
        
        CGRect thisRect = CGRectMake(0, self.frame.origin.y, 602, self.frame.size.height);  //-128
        self.frame = thisRect;
        
    }else {
        
        CGRect thisRect = CGRectMake(0, self.frame.origin.y, 346, self.frame.size.height);
        self.frame = thisRect;
    }
    
    //colors
    EQRColors* colors = [EQRColors sharedInstance];
    
    //delete button
//    UIButton* deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    deleteButton.frame = CGRectMake(0, 0, 100, self.frame.size.height);
    
//    deleteButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.myContentVC.myDeleteButton setTitle:thisButtonText forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
    [self.myContentVC.myDeleteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal & UIControlStateSelected];
    [self.myContentVC.myDeleteButton setTitleColor:[colors.colorDic objectForKey:EQRColorLightBlue] forState:UIControlStateHighlighted];
    self.myContentVC.myDeleteButton.reversesTitleShadowWhenHighlighted = YES;
    self.myContentVC.myDeleteButton.userInteractionEnabled = YES;
    
    //target of button
    [self.myContentVC.myDeleteButton addTarget:self action:@selector(deleteEquipItem:) forControlEvents:UIControlEventTouchUpInside];

    
    
    
    //label
//    UILabel* thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 295, 30)];
//    self.titleLabel = thisLabel;
//    self.myContentVC.myLabel.font = [UIFont systemFontOfSize:12];
//    self.myContentVC.myLabel.backgroundColor = [UIColor clearColor];
    self.myContentVC.myLabel.text = titleName;
    
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
