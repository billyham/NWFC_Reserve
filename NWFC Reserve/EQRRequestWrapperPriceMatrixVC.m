//
//  EQRRequestWrapperPriceMatrixVC.m
//  Gear
//
//  Created by Ray Smith on 9/14/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRRequestWrapperPriceMatrixVC.h"
#import "EQREquipSummaryGenericVCntrllr.h"
#import "EQRScheduleRequestManager.h"
#import "EQRModeManager.h"
#import "EQRColors.h"
#import "EQRGlobals.h"
#import "EQRPriceMatrixVC.h"



@interface EQRRequestWrapperPriceMatrixVC ()

@property (strong, nonatomic) IBOutlet UIView *mainSubView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* topGuideLayoutThingy;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* bottomGuideLayoutThingy;

@property BOOL privateRequestManagerFlag;

@property (weak, nonatomic) EQRPriceMatrixVC *myPriceMatrixVC;

@end

@implementation EQRRequestWrapperPriceMatrixVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //add the cancel button
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButton:)];
    
    //add button to the current navigation item
    [self.navigationItem setRightBarButtonItem:cancelButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    
    //update navigation bar
    self.navigationItem.title = @"Pricing Details";
    
    // Update navigation bar
    EQRModeManager* modeManager = [EQRModeManager sharedInstance];
    if (modeManager.isInDemoMode){
        
        // Set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = @"DEMO MODE";
        
        // Set colors of navigation bar and item
        [modeManager alterNavigationBar:self.navigationController.navigationBar navigationItem:self.navigationItem isInDemo:YES];
        
        [UIView setAnimationsEnabled:YES];
        
    }else{
        
        // Set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = nil;
        
        // Set colors of navigation bar and item
        [modeManager alterNavigationBar:self.navigationController.navigationBar navigationItem:self.navigationItem isInDemo:NO];
        
        [UIView setAnimationsEnabled:YES];
    }
    
    
    //add constraints
    //______this MUST be added programmatically because you CANNOT specify the topLayoutGuide of a VC in a nib______
    
    self.mainSubView.translatesAutoresizingMaskIntoConstraints = NO;
    id topGuide = self.topLayoutGuide;
    id bottomGuide = self.bottomLayoutGuide;
    
    NSDictionary *viewsDictionary = @{@"mainSubView":self.mainSubView, @"topGuide":topGuide, @"bottomGuide":bottomGuide};
    
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0-[mainSubView]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    
    
    NSArray *constraint_POS_VB = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[mainSubView]-0-[bottomGuide]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewsDictionary];
    
    //drop exisiting constraints
    [[self.mainSubView superview] removeConstraints:[NSArray arrayWithObjects:self.topGuideLayoutThingy, self.bottomGuideLayoutThingy, nil]];
    
    //add replacement constraints
    [[self.mainSubView superview] addConstraints:constraint_POS_V];
    [[self.mainSubView superview] addConstraints:constraint_POS_VB];
    
    
    [super viewWillAppear:animated];
}

-(void)viewDidLayoutSubviews{
    
    //________Accessing childviewcontrollers
    NSArray* arrayOfChildVCs = [self childViewControllers];
    
    //viewDidLayoutSubviews is called often (during a rotation). Only intitiate a view controller if it doesn't yet exist
    if (!self.myPriceMatrixVC){
        
        if ([arrayOfChildVCs count] > 0){
            
            for (UIViewController *childVCItem in arrayOfChildVCs){
                
                if ([childVCItem.title isEqualToString:@"Pricing"] ){
                    
                    EQRPriceMatrixVC* priceMatrixVC = (EQRPriceMatrixVC *)childVCItem;
                    
                    //assign to weak ivar
                    self.myPriceMatrixVC = priceMatrixVC;
                    
                    //set self as delegate???
                    
                    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
                    [self.myPriceMatrixVC startNewTransaction:requestManager.request];
                    
                }
            }
        }
    }
}


#pragma mark - actions


-(IBAction)continueButton:(id)sender{
    
    EQREquipSummaryGenericVCntrllr* summaryVCntrllr = [[EQREquipSummaryGenericVCntrllr alloc] initWithNibName:@"EQREquipSummaryGenericVCntrllr" bundle:nil];
    
    summaryVCntrllr.edgesForExtendedLayout = UIRectEdgeAll;
    
    [self.navigationController pushViewController:summaryVCntrllr animated:YES];
}


-(IBAction)cancelButton:(id)sender{
    
    //go back to first page in nav
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    [requestManager dismissRequest:YES];
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
