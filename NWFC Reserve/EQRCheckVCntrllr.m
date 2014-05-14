//
//  EQRCheckVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/14/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRCheckVCntrllr.h"

@interface EQRCheckVCntrllr ()

@property (strong, nonatomic) IBOutlet UITextField* nameTextField;
@property (strong, nonatomic) NSDictionary* myUserInfo;


@end

@implementation EQRCheckVCntrllr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)initialSetupWithInfo:(NSDictionary*)userInfo{
    
    
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];




}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
