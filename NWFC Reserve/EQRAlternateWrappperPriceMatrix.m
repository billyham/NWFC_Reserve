//
//  EQRAlternateWrappperPriceMatrix.m
//  Gear
//
//  Created by Ray Smith on 9/14/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRAlternateWrappperPriceMatrix.h"
#import "EQRModeManager.h"
#import "EQRColors.h"
#import "EQRPriceMatrixVC.h"



@interface EQRAlternateWrappperPriceMatrix ()

@property (strong, nonatomic) IBOutlet UIView *mainSubView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* topGuideLayoutThingy;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* bottomGuideLayoutThingy;

@property (weak, nonatomic) EQRPriceMatrixVC *myPriceMatrixVC;

//@property BOOL privateRequestManagerFlag;

@end

@implementation EQRAlternateWrappperPriceMatrix

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(void)viewWillAppear:(BOOL)animated{
    
    EQRModeManager* modeManager = [EQRModeManager sharedInstance];
    if (modeManager.isInDemoMode){
        
        //set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = @"!!! DEMO MODE !!!";
        
        //set color of navigation bar
        EQRColors* colors = [EQRColors sharedInstance];
        self.navigationController.navigationBar.barTintColor = [colors.colorDic objectForKey:EQRColorDemoMode];
        [UIView setAnimationsEnabled:YES];
        
    }else{
        
        //set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = nil;
        
        //set color of navigation bar
        self.navigationController.navigationBar.barTintColor = nil;
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
                    
                }
            }
        }
    }
}




#pragma mark - public methods

-(void)provideScheduleRequest:(EQRScheduleRequestItem *)requestItem{
    
    if (self.myPriceMatrixVC){
        [self.myPriceMatrixVC editExistingTransaction:requestItem];
    }
    
}


-(IBAction)dismissMe:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self.delegate aChangeWasMadeToPriceMatrix];
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
