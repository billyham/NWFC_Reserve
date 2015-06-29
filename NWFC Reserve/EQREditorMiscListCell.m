//
//  EQREditorMiscListCell.m
//  Gear
//
//  Created by Ray Smith on 2/3/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQREditorMiscListCell.h"
#import "EQRColors.h"
#import "EQRWebData.h"

@interface EQREditorMiscListCell ()
@property (strong, nonatomic) EQRMiscJoin* myMiscJoin;
@property (nonatomic, strong) NSString* myKey_id;

@property (nonatomic, strong) EQRGenericTextEditor *myGenericTextEditor;

@end

@implementation EQREditorMiscListCell

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


-(void)initialSetupWithMiscJoin:(EQRMiscJoin*)miscJoin deleteFlag:(BOOL)deleteFlag editMode:(BOOL)editModeFlag{
    
    //retaining the joinObject seems like a bad idea, but... need to use it for the distIDPicker
    self.myMiscJoin = miscJoin;
    
    self.myKey_id = miscJoin.key_id;
    self.toBeDeletedFlag = deleteFlag;
    
    EQREditorMiscListContentVC* contentView = [[EQREditorMiscListContentVC alloc] initWithNibName:@"EQREditorMiscListContentVC" bundle:nil];
    self.myContentVC = contentView;
    
    //add content view to view
    [self.contentView addSubview:self.myContentVC.view];
    
    //hide or show the delete button
    if (editModeFlag == NO){
        [self.myContentVC.myDeleteButton setHidden:YES];
        [self.myContentVC.myMiscEditButton setHidden:YES];
        
        self.myContentVC.labelTrailingConstraint.constant = 2.f;
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
    
    //target of delete button
    [self.myContentVC.myDeleteButton addTarget:self action:@selector(deleteEquipItem:) forControlEvents:UIControlEventTouchUpInside];
    
    //target of edit button
    [self.myContentVC.myMiscEditButton addTarget:self action:@selector(editMiscText:) forControlEvents:UIControlEventTouchUpInside];
    
    //label
    self.myContentVC.myLabel.text = miscJoin.name;
    
}


-(void)enterEditMode{
    
    //shorten issue text and show edit button
    self.myContentVC.labelTrailingConstraint.constant = 100.f;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.myContentVC.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [self.myContentVC.myDeleteButton setHidden:NO];
        [self.myContentVC.myMiscEditButton setHidden:NO];
    }];
}


-(void)leaveEditMode{
    
    //lengthen issue text and hide edit button
    self.myContentVC.labelTrailingConstraint.constant = 2.f;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.myContentVC.view layoutIfNeeded];
        
        [self.myContentVC.myDeleteButton setHidden:YES];
        [self.myContentVC.myMiscEditButton setHidden:YES];
        
    } completion:^(BOOL finished) {
        
    }];
}


-(IBAction)deleteEquipItem:(id)sender{
    
    if (!self.toBeDeletedFlag){
        
        //send view controller a note with key_id (or indexpath) to indicate it needs to be removed from the database
        
        [self.delegate tagMiscJoinToDelete:self.myKey_id];
        
        //flag the color of the cell!!
        self.myContentVC.view.backgroundColor = [UIColor redColor];
        
        [self.myContentVC.myDeleteButton setTitle:@"Cancel" forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
        
        self.toBeDeletedFlag = YES;
        
    }else {
        
        [self.delegate tagMiscJoinToCancelDelete:self.myKey_id];
 
        self.myContentVC.view.backgroundColor = [UIColor whiteColor];
        
        [self.myContentVC.myDeleteButton setTitle:@"Delete" forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
        
        self.toBeDeletedFlag = NO;
    }
}


-(IBAction)editMiscText:(id)sender{
    
    EQRGenericTextEditor *textEditor = [[EQRGenericTextEditor alloc] initWithNibName:@"EQRGenericTextEditor" bundle:nil];
    self.myGenericTextEditor = textEditor;
    self.myGenericTextEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    self.myGenericTextEditor.delegate = self;
    
    [self.myGenericTextEditor initalSetupWithTitle:@"Edit Miscellaneous" subTitle:@"Change Text" currentText:self.myMiscJoin.name keyboard:nil returnMethod:@"miscTextDidChange:"];
    
    [self.myContentVC presentViewController:self.myGenericTextEditor animated:YES completion:^{
        
        
    }];
    
    
}

-(void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod{
    
    self.myGenericTextEditor.delegate = nil;
    
    [self.myGenericTextEditor dismissViewControllerAnimated:YES completion:^{
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:NSSelectorFromString(returnMethod) withObject:returnText];
#pragma clang diagnostic pop
        
        self.myGenericTextEditor = nil;
    }];
}


-(void)miscTextDidChange:(NSString *)returnText{
    
    self.myMiscJoin.name = returnText;
    self.myContentVC.myLabel.text = returnText;
    
    //_____!!!!!  send to data layer  !!!_______
    EQRWebData *webData = [EQRWebData sharedInstance];
    NSArray *oneArray = @[@"name", returnText];
    NSArray *twoArray = @[@"key_id", self.myMiscJoin.key_id];
    NSArray *topArray = @[oneArray, twoArray];
    
    NSString *returnKey = [webData queryForStringWithLink:@"EQAlterMiscJoinName.php" parameters:topArray];
    NSLog(@"this is the return key: %@", returnKey);
}


@end
