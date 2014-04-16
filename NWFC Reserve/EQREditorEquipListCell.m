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

@property (nonatomic, strong) NSString* myKey_id;
@property (nonatomic, strong) IBOutlet UIButton* myDeleteButton;

@end

@implementation EQREditorEquipListCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)initialSetupWithTitle:(NSString*) titleName keyID:(NSString*)keyID deleteFlag:(BOOL)deleteFlag{
    
    self.myKey_id = keyID;
    self.toBeDeletedFlag = deleteFlag;
    
    NSString* thisButtonText;
    
    if (self.toBeDeletedFlag){
        
        self.backgroundColor = [UIColor redColor];
        thisButtonText = @"cancel";
        
    }else {
        
        self.backgroundColor = [UIColor whiteColor];
        thisButtonText = @"delete";
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
    UIButton* deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    deleteButton.frame = CGRectMake(0, 0, 100, self.frame.size.height);
    deleteButton.titleLabel.text = thisButtonText;
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [deleteButton setTitle:thisButtonText forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [deleteButton setTitle:thisButtonText forState:UIControlStateHighlighted];
    [deleteButton setTitleColor:[colors.colorDic objectForKey:EQRColorLightBlue] forState:UIControlStateHighlighted];
    [deleteButton setTitle: thisButtonText forState:UIControlStateSelected];
    [deleteButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    deleteButton.reversesTitleShadowWhenHighlighted = YES;
    deleteButton.userInteractionEnabled = YES;
    
    //target of button
    [deleteButton addTarget:self action:@selector(deleteEquipItem:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:deleteButton];
    
    self.myDeleteButton = deleteButton;
    
    //label
    UILabel* thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 295, 30)];
    self.titleLabel = thisLabel;
    self.titleLabel.text = titleName;
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.titleLabel];
    
}


-(IBAction)deleteEquipItem:(id)sender{
    
    if (!self.toBeDeletedFlag){
        
        //send view controller a note with key_id (or indexpath) to indicate it needs to be removed from the database
        
        NSDictionary* thisDic = [NSDictionary dictionaryWithObject:self.myKey_id forKey:@"key_id"];
        [[NSNotificationCenter defaultCenter] postNotificationName:EQREquipUniqueToBeDeleted object:nil userInfo:thisDic];
        
        //flag the color of the cell!!
        self.backgroundColor = [UIColor redColor];
        
        [self.myDeleteButton setTitle:@"cancel" forState:UIControlStateNormal];
        [self.myDeleteButton setTitle:@"cancel" forState:UIControlStateHighlighted];
        [self.myDeleteButton setTitle:@"cancel" forState:UIControlStateSelected];
        
        self.toBeDeletedFlag = YES;
        
    }else {
        
        NSDictionary* thisDic = [NSDictionary dictionaryWithObject:self.myKey_id forKey:@"key_id"];
        [[NSNotificationCenter defaultCenter] postNotificationName:EQREquipUniqueToBeDeletedCancel object:nil userInfo:thisDic];
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self.myDeleteButton setTitle:@"delete" forState:UIControlStateNormal];
        [self.myDeleteButton setTitle:@"delete" forState:UIControlStateHighlighted];
        [self.myDeleteButton setTitle:@"delete" forState:UIControlStateSelected];
        
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
