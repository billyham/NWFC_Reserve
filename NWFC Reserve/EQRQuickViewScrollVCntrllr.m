//
//  EQRQuickViewScrollVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 8/3/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRQuickViewScrollVCntrllr.h"

@interface EQRQuickViewScrollVCntrllr ()

@end

@implementation EQRQuickViewScrollVCntrllr

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

    //notifications
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    //register for keyboard changes
    [nc addObserver:self selector:@selector(keyboardDidAppear) name:UIKeyboardDidShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardDidDisappear) name:UIKeyboardDidHideNotification object:nil];
    
}

     
     

-(IBAction)slideRight:(id)sender{
    
    if (self.myScrollView.contentOffset.x > 150.f){
        
        [self.myScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
    
}


-(IBAction)slideLeft:(id)sender{
        
    if (self.myScrollView.contentOffset.x < 150.f){
    
        [self.myScrollView setContentOffset:CGPointMake(300, 0) animated:YES];
    }
    
}
     

-(void)keyboardDidAppear{
    
    CGRect originalRect = self.myScheduleRowQuickView.notesView.frame;
    CGRect newRect = CGRectMake(originalRect.origin.x, originalRect.origin.y - 250, originalRect.size.width, originalRect.size.height + 250);
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.myScheduleRowQuickView.notesView.frame = newRect;
    }];
    
}


-(void)keyboardDidDisappear{
    
    CGRect originalRect = self.myScheduleRowQuickView.notesView.frame;
    CGRect newRect = CGRectMake(originalRect.origin.x, originalRect.origin.y + 250, originalRect.size.width, originalRect.size.height - 250);
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.myScheduleRowQuickView.notesView.frame = newRect;
    }];
}


#pragma mark - scroll view delegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    NSLog(@"scroll view says scrollig will begin dragging");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
