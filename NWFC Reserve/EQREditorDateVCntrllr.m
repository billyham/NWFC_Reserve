//
//  EQREditorDateVCntrllr.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 4/1/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREditorDateVCntrllr.h"

@interface EQREditorDateVCntrllr ()



@end

@implementation EQREditorDateVCntrllr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


#pragma mark - save

-(IBAction)saveAction:(id)sender{
    
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
