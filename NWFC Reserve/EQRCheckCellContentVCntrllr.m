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


#pragma mark - notification methods

-(void)receiveQRCodeMessage:(NSNotification*)note{
    
    NSString* equipKeyID = [[note userInfo] objectForKey:@"keyID"];
    
    NSLog(@"this is a row's equipUnique key: %@", self.equipUniteItem_foreignKey);
    
    if ([equipKeyID isEqualToString:self.equipUniteItem_foreignKey]){
        
        [self.statusSwitch setOn:YES];
        
        [self receiveSwitchChange:self.statusSwitch];
        
    }
    
}


#pragma mark - switch actions

-(IBAction)receiveSwitchChange:(id)sender{
    
    //send update to data join object
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    if ([sender isOn]){
        
        NSArray* firstArray = [NSArray arrayWithObjects:self.joinPropertyToBeUpdated, @"yes", nil];
        NSArray* secondArray = [NSArray arrayWithObjects:@"key_id", self.myJoinKeyID, nil];
        NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, nil];
        
        //update model
        [webData queryForStringWithLink:@"EQSetCheckOutInPrepScheduleEquipJoin.php" parameters:topArray];

        
        //____need to update ivar array
        NSString* verdict = @"yes";
        NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.myJoinKeyID, @"joinKeyID",
                                self.joinPropertyToBeUpdated, @"joinProperty",
                                verdict, @"markedAsYes",
                                nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRUpdateCheckInOutArrayOfJoins object:nil userInfo:newDic];
        
        
        //update status label
        if ([self.joinPropertyToBeUpdated isEqualToString:@"prep_flag"]){
            
            self.status1Label.text = @"";
            self.status2Label.text = @"Prepped";
            
        }else if ([self.joinPropertyToBeUpdated isEqualToString:@"checkout_flag"]){
            
            self.status1Label.text = @"";
            self.status2Label.text = @"Out";
            
        }else if([self.joinPropertyToBeUpdated isEqualToString:@"checkin_flag"]){
            
            self.status1Label.text = @"";
            self.status2Label.text = @"In";
            
        }else if([self.joinPropertyToBeUpdated isEqualToString:@"shelf_flag"]){
            
            self.status1Label.text = @"";
            self.status2Label.text = @"Shelved";
            
        }else{
            
            NSLog(@"error in checkCellContent > receiveSwitchChange didn't recognize the joingPropertyToBeUpdated ivar");
        }
        
        
    }else{
        
        NSArray* firstArray = [NSArray arrayWithObjects:self.joinPropertyToBeUpdated, @"nix", nil];
        NSArray* secondArray = [NSArray arrayWithObjects:@"key_id", self.myJoinKeyID, nil];
        NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, nil];
        
        //update model
        [webData queryForStringWithLink:@"EQSetCheckOutInPrepScheduleEquipJoin.php" parameters:topArray];
        
        
        //____need to update ivar array
        NSString* verdict = @"";
        NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.myJoinKeyID, @"joinKeyID",
                                self.joinPropertyToBeUpdated, @"joinProperty",
                                verdict, @"markedAsYes",
                                nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRUpdateCheckInOutArrayOfJoins object:nil userInfo:newDic];
        
        //update status label
        if ([self.joinPropertyToBeUpdated isEqualToString:@"prep_flag"]){
            
            self.status1Label.text = @"Not Prepped";
            self.status2Label.text = @"";
            
        }else if ([self.joinPropertyToBeUpdated isEqualToString:@"checkout_flag"]){
            
            self.status1Label.text = @"In";
            self.status2Label.text = @"";
            
        }else if([self.joinPropertyToBeUpdated isEqualToString:@"checkin_flag"]){
            
            self.status1Label.text = @"Out";
            self.status2Label.text = @"";
            
        }else if([self.joinPropertyToBeUpdated isEqualToString:@"shelf_flag"]){
            
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
