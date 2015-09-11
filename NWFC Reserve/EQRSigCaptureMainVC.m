//
//  EQRSigCaptureMainVC.m
//  Gear
//
//  Created by Ray Smith on 6/23/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRSigCaptureMainVC.h"
#import "PPSSignatureView.h"
#import <OpenGLES/ES2/glext.h>
//#import "EQRSigConfirmationVC.h"

@interface EQRSigCaptureMainVC ()

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *returnDateLabel;
@property (strong, nonatomic) IBOutlet UITextView *agreementTextView;
@property (strong, nonatomic) IBOutlet PPSSignatureView *signatureView;

@end

@implementation EQRSigCaptureMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self.childViewControllers count] > 0){
        
        UIViewController *signatureViewController = [self.childViewControllers objectAtIndex:0];
        
        if ([signatureViewController class] == [GLKViewController class]){
            
            self.signatureView = (PPSSignatureView *)[signatureViewController view];
        }
    }
    
    NSString* text2Content = @"I hereby assume full responsibility for the above listed equipment provided by the Northwest Film Center. Financial responsibility includes payment for all repairs, up to the full replacement value of equipment, and the full replacement value for all stolen or lost equipment. Financial responsibility also includes the rental fee for the time period in which damaged equipment is out for repair, or until replacement payment is received. I have inspected the contents of rental equipment and acknowledge that all parts and pieces are present and in working order unless otherwise noted.";
    NSString* text3Content = @"Projects produced through School of Film classes must include www.nwfilm.org and the following phrase in the credits: Produced through the Northwest Film Center School of Film (spelling out \"Northwest Film Center\").";
    NSString* text4Content = @"Penalties will be given to students for the following reasons: Returns equipment after the assigned date and time, shows blatant disregard for equipments's well being, no-shows for equipment reservations.";
    NSString* text5Content = @"I confirm that the equipment is in working order upon check-out and have been made aware of any pre-existing conditions. If returned equipment requires more than 10 min. cleaning, a $25 cleaning fee will be assessed.";
    
    UIFont *bodyTypeFont = [UIFont systemFontOfSize:13];
//    UIFont *boldFont = [UIFont systemFontOfSize:13 weight:2.0];
    
    NSDictionary *fontDictionary = @{bodyTypeFont:NSFontAttributeName};
    NSMutableAttributedString *attMuteString = [[NSMutableAttributedString alloc] initWithString:@"" attributes:fontDictionary];
    
    NSAttributedString *attString1 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", text2Content] attributes:fontDictionary];
    NSAttributedString *attString2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", text3Content] attributes:fontDictionary];
    NSAttributedString *attString3 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", text4Content] attributes:fontDictionary];
    NSAttributedString *attString4 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", text5Content] attributes:fontDictionary];
    
    [attMuteString appendAttributedString:attString1];
    [attMuteString appendAttributedString:attString2];
    [attMuteString appendAttributedString:attString3];
    [attMuteString appendAttributedString:attString4];
    
    self.agreementTextView.attributedText = attMuteString;
    
    
    
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

-(IBAction)enterButton:(id)sender{
    
//    EQRSigConfirmationVC *confirmVC = [[EQRSigConfirmationVC alloc] initWithNibName:@"EQRSigConfirmationVC" bundle:nil];
//    
//    [self.navigationController pushViewController:confirmVC animated:YES];
    
    [self performSegueWithIdentifier:@"sigConfirmation" sender:self];
    
}

-(IBAction)otherOptionsButton:(id)sender{
    
}

-(IBAction)clearButton:(id)sender{
    
    [self.signatureView erase];
}

-(IBAction)viewGearListButton:(id)sender{
    
    
}


@end
