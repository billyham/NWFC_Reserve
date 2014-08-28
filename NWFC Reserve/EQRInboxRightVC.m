//
//  EQRInboxRightVC.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 8/27/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRInboxRightVC.h"

@interface EQRInboxRightVC ()

@end

@implementation EQRInboxRightVC

@synthesize delegateForRightSide;


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
    

    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    
    
    
    
    //________********* THIS ISN'T WOKRING AT ALL  *******______
    UISplitViewController *splitViewController = self.splitViewController;
    splitViewController.delegate = self;
    
    [super viewDidAppear:animated];
    
}


-(void)renewTheView{
    
    [self.delegateForRightSide selectedRequest:nil];
    
    NSLog(@"Yup, this is stupid alright");
}


#pragma mark - split view delegate methods

-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc{
    
    barButtonItem.title = @"Filters";
    [self.navigationController.navigationItem setLeftBarButtonItem:barButtonItem];
    
    self.popover = pc;
    
    
    
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
    
    [self.navigationController.navigationItem setLeftBarButtonItem:nil];
    
    self.popover = nil;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
