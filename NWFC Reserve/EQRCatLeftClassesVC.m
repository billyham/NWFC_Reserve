//
//  EQRCatLeftClassesVC.m
//  Gear
//
//  Created by Ray Smith on 9/29/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import "EQRCatLeftClassesVC.h"
#import "EQRClassPickerVC.h"

@interface EQRCatLeftClassesVC ()
@property (weak, nonatomic) EQRClassPickerVC *classPicker;
@end

@implementation EQRCatLeftClassesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Access child VCs
    NSArray *arrayOfChildVCs = [self childViewControllers];
    
    if (!self.classPicker){
        for (UIViewController *childVC in arrayOfChildVCs){
            if ([childVC.title isEqualToString:@"classPicker"]){
                self.classPicker = (EQRClassPickerVC *) childVC;
                self.classPicker.delegate = self;
            }
        }
    }
}

//-(void)viewDidLayoutSubviews{
//    [super viewDidLayoutSubviews];
//}

//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//}

//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//}

#pragma mark - class picker delegate method

-(void)initiateRetrieveClassItem:(EQRClassItem *)selectedClassItem{
    
    if (!selectedClassItem){
        NSLog(@"no class selected");
    }else{
//        NSLog(@"this is the class: %@", selectedClassItem.section_name);
        
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
