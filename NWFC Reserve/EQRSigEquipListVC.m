//
//  EQRSigEquipListVC.m
//  Gear
//
//  Created by Ray Smith on 9/12/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRSigEquipListVC.h"
#import "EQRWebData.h"
#import "EQRMiscJoin.h"
#import "EQRReqeustDatesAndEquipListVM.h"
#import "EQRGlobals.h"


@interface EQRSigEquipListVC ()

@property (strong, nonatomic) IBOutlet UITextView *summarTextView;

@end

@implementation EQRSigEquipListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    
    // Do any additional setup after loading the view.
}

-(void)loadTheData{
    
    //______Misc Join List_______
    //gather any misc joins
    NSMutableArray* tempMiscMuteArray = [NSMutableArray arrayWithCapacity:1];
    NSArray* alphaArray = @[@"scheduleTracking_foreignKey", self.requestItem.key_id];
    NSArray* omegaArray = @[alphaArray];
    EQRWebData* webData = [EQRWebData sharedInstance];
    [webData queryWithLink:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:omegaArray class:@"EQRMiscJoin" completion:^(NSMutableArray *muteArray2) {
        for (id object in muteArray2){
            [tempMiscMuteArray addObject:object];
        }
    }];
    
    NSAttributedString *attString = [EQRReqeustDatesAndEquipListVM getSummaryTextWithRequest:self.requestItem ArrayOfMisc:tempMiscMuteArray];
    self.summarTextView.attributedText = attString;
    
}


-(IBAction)continueButton:(id)sender{
    
    //if is Public rental then show rental fee page
    if ([self.requestItem.renter_type isEqualToString:EQRRenterPublic]){
        
        [self performSegueWithIdentifier:@"sigRentalFee" sender:self];
        
    }else{         //otherwise, go straight to signature capture
        
        [self performSegueWithIdentifier:@"sigSignature" sender:self];
    }
    
}


-(IBAction)cancelButton:(id)sender{
    
    [[self navigationController] dismissViewControllerAnimated:YES completion:^{
        
        
    }];
}

-(IBAction)dismissGearView:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
}

-(IBAction)generatePDF:(id)sender{
    
    
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
