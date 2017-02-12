//
//  EQRCheckCellContentVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/27/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRCheckCellContentVCntrllr.h"
#import "EQRWebData.h"
#import "EQRGlobals.h"

@interface EQRCheckCellContentVCntrllr ()

@property (strong, nonatomic) IBOutlet UIButton* myDeleteButton;
@property BOOL toBeDeletedFlag;

@end

@implementation EQRCheckCellContentVCntrllr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - view methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    //receive a qrcode match
    [nc addObserver:self selector:@selector(receiveQRCodeMessage:) name:EQRQRCodeFlipsSwitchInRowCellContent object:nil];
    
}

-(void)initialSetupWithDeleteFlag:(BOOL)deleteFlag{
    
//    NSLog(@"checkCellContentVC > initialSetup is called with deleteFlag: %ul", deleteFlag);
    
    self.toBeDeletedFlag = deleteFlag;
    
    if (self.toBeDeletedFlag){
        
        self.view.backgroundColor = [UIColor redColor];
        [self.myDeleteButton setTitle:@"Cancel" forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
        
    }else {
        
        self.view.backgroundColor = [UIColor whiteColor];
        [self.myDeleteButton setTitle:@"Delete" forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
    }
}

-(IBAction)deleteEquipItem:(id)sender{
    
    if (!self.toBeDeletedFlag){
        
        //send view controller a note with join key_id (or indexpath) to indicate it needs to be removed from the database
        
        NSDictionary* thisDic = @{@"key_id":self.myJoinKeyID, @"isContentForMiscJoin":[NSNumber numberWithBool:self.isContentForMiscJoin]};
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRJoinToBeDeletedInCheckInOut object:nil userInfo:thisDic];
        
        //flag the color of the cell!!
        self.view.backgroundColor = [UIColor redColor];
        
        [self.myDeleteButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.myDeleteButton setTitle:@"Cancel" forState:UIControlStateHighlighted];
        [self.myDeleteButton setTitle:@"Cancel" forState:UIControlStateSelected];
        
        self.toBeDeletedFlag = YES;
        
    }else {
        
        NSDictionary* thisDic = @{@"key_id":self.myJoinKeyID, @"isContentForMiscJoin":[NSNumber numberWithBool:self.isContentForMiscJoin]};
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRJoinToBeDeletedInCheckInOutCancel object:nil userInfo:thisDic];
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        [self.myDeleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [self.myDeleteButton setTitle:@"Delete" forState:UIControlStateHighlighted];
        [self.myDeleteButton setTitle:@"Delete" forState:UIControlStateSelected];
        
        self.toBeDeletedFlag = NO;
    }
}


-(IBAction)distIDButton:(id)sender{
    
    NSDictionary* dic = @{ @"joinKey_id": self.myJoinKeyID,
                           @"equipTitleItem_foreignKey": self.equipTitleItem_foreignKey,
                           @"equipUniqueItem_foreignKey": self.equipUniqueItem_foreignKey,
                           @"indexPath": self.myIndexPath,
                           @"distButton": self.distIDLabel };
    
    // Send note to EQRCheckVCntrllr
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRDistIDPickerTapped object:nil userInfo:dic];
    
}


#pragma mark - notification methods

-(void)receiveQRCodeMessage:(NSNotification*)note{
    
    if (self.isContentForMiscJoin == YES){
        return;
    }
    
    NSString* equipKeyID = [[note userInfo] objectForKey:@"keyID"];
    
    if ([equipKeyID isEqualToString:self.equipUniqueItem_foreignKey]){
        
        [self.statusSwitch setOn:YES];
        
        [self receiveSwitchChange:self.statusSwitch];
    }
}


#pragma mark - switch actions

-(IBAction)receiveSwitchChange:(id)sender{
    
    NSString *verdict;
    NSString *dbValue;
    if ([sender isOn]){
        verdict = @"yes";
        dbValue = @"yes";
    }else{
        verdict = @"";
        dbValue = @"nix";
    }
    
    NSArray* topArray = @[ @[self.joinPropertyToBeUpdated, dbValue],
                           @[@"key_id", self.myJoinKeyID]];
    
    // Update model
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        EQRWebData* webData = [EQRWebData sharedInstance];
        if (self.isContentForMiscJoin == NO){
            [webData queryForStringwithAsync:@"EQSetCheckOutInPrepScheduleEquipJoin.php" parameters:topArray completion:^(NSString *returnString) {
                if (returnString) NSLog(@"EQRCheckCellContentVCtrllr > receiveSwitchData, failed to set db");
            }];
        }else{
            [webData queryForStringwithAsync:@"EQSetCheckOutInPrepScheduleMiscJoin.php" parameters:topArray completion:^(NSString *returnString) {
               if (returnString) NSLog(@"EQRCheckCellContentVCtrllr > receiveSwitchData, failed to set db");
            }];
        }
    });
    
    // Update array
    NSDictionary* newDic = @{ @"joinKeyID": self.myJoinKeyID,
                              @"joinProperty": self.joinPropertyToBeUpdated,
                              @"markedAsYes": verdict,
                              @"isContentForMiscJoin": [NSNumber numberWithBool:self.isContentForMiscJoin] };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRUpdateCheckInOutArrayOfJoins object:nil userInfo:newDic];
    
    // Render view
    [self renderSwitchWithProperty:self.joinPropertyToBeUpdated isOn:[sender isOn]];
}

-(void)renderSwitchWithProperty:(NSString *)property isOn:(BOOL)isOn{
    
    if (isOn){
        
        if ([property isEqualToString:@"prep_flag"]){
            
            self.status1Label.text = @"";
            self.status2Label.text = @"Prepped";
            
        }else if ([property isEqualToString:@"checkout_flag"]){
            
            self.status1Label.text = @"";
            self.status2Label.text = @"Out";
            
        }else if([property isEqualToString:@"checkin_flag"]){
            
            self.status1Label.text = @"";
            self.status2Label.text = @"In";
            
        }else if([property isEqualToString:@"shelf_flag"]){
            
            self.status1Label.text = @"";
            self.status2Label.text = @"Shelved";
            
        }else{
            
            NSLog(@"error in checkCellContent > receiveSwitchChange didn't recognize the joingPropertyToBeUpdated ivar");
        }
    }else{
        
        if ([property isEqualToString:@"prep_flag"]){
            
            self.status1Label.text = @"Not Prepped";
            self.status2Label.text = @"";
            
        }else if ([property isEqualToString:@"checkout_flag"]){
            
            self.status1Label.text = @"In";
            self.status2Label.text = @"";
            
        }else if([property isEqualToString:@"checkin_flag"]){
            
            self.status1Label.text = @"Out";
            self.status2Label.text = @"";
            
        }else if([property isEqualToString:@"shelf_flag"]){
            
            self.status1Label.text = @"Not Shelved";
            self.status2Label.text = @"";
            
        }else{
            
            NSLog(@"error in checkCellContent > receiveSwitchChange didn't recognize the joingPropertyToBeUpdated ivar");
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
