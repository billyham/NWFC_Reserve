//
//  EQRItineraryCellContent2VC.m
//  Gear
//
//  Created by Ray Smith on 7/7/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRItineraryCellContent2VC.h"
#import "EQRColors.h"
#import "EQRGlobals.h"
#import "EQRWebData.h"
#import "EQRStaffUserManager.h"

@interface EQRItineraryCellContent2VC ()
@property (strong, nonatomic) UIColor* myAssignedColor;
@property (strong, nonatomic) IBOutlet UIButton *detailsButton;
@end

@implementation EQRItineraryCellContent2VC
@synthesize delegate;

#pragma mark - api methods
//-(void)initialSetupWithRequestItem:(EQRScheduleRequestItem*) requestItem {
//    
//}
//
//-(void)updateButtonLabels:(EQRScheduleRequestItem *)requestItem {
//
//}

- (void)resetState {
    self.markedForReturning = NO;
    self.myStatus = 0;
    self.requestKeyId = nil;
    self.isCollapsed = NO;
    self.myAssignedColor = nil;
    [self.subViewFullSize setBackgroundColor:[UIColor lightGrayColor]];
    [self.subViewFullSize setAlpha:1.0];
    self.button1Status.hidden = YES;
    self.button2Status.hidden = YES;
    self.button2.userInteractionEnabled = YES;
    self.button2.alpha = 1.0;
    self.textOverButton2.alpha = 1.0;
    
    [self resetCellExpansion];
    
    [self resetButtonTint:self.button1];
    [self resetButtonTint:self.button2];
}

- (void)resetCellExpansion {
    self.topOfTextConstraint.constant = 0;
    self.bottomOfMainSubviewConstraint.constant = -60;
    self.topOfButton1Constraint.constant = 8;
    self.topOfButton2Constraint.constant = 8;
    self.collapseButton.hidden = NO;
    self.collapseButton.alpha = 1.0;
    [self.button1 setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    [self.button2 setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    self.textOverButton1.alpha = 1.0;
    self.textOverButton2.alpha = 1.0;
    self.textOverButton1.textColor = [UIColor blackColor];
    self.textOverButton2.textColor = [UIColor blackColor];
    self.bottomOfMainSubviewConstraint.constant = 0;
}

- (void)resetButtonTint:(UIButton *)button {
    UIImage *tintedImage = button.imageView.image;
    UIImage *originalImage = [tintedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [button setImage:originalImage forState:UIControlStateNormal];
    button.tintColor = nil;
}


#pragma mark - view methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //add tap gesture to expand cell when it's collapsed
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandCellFromTapGesture)];
    [self.view addGestureRecognizer:tapGesture];
}

-(void)viewWillAppear:(BOOL)animated{
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


#pragma mark - switch methods
-(IBAction)switch1Fires:(id)sender{
    if ([sender tag] == 2){
        return;
    }
    [self.delegate showCheckInOut:self.requestKeyId mark:self.markedForReturning switch:1 cellContent:self];
}

-(IBAction)switch2Fires:(id)sender{
    if ([sender tag] == 1){
        return;
    }
    [self.delegate showCheckInOut:self.requestKeyId mark:self.markedForReturning switch:2 cellContent:self];
}

-(IBAction)showQuickView:(id)sender{
    NSValue* rectValue = [NSValue valueWithCGRect:self.detailsButton.frame];
    UIView* thisView = self.view;
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         self.requestKeyId, @"key_ID",
                         [NSNumber numberWithBool:self.markedForReturning], @"marked_for_returning",
                         rectValue, @"rectValue",
                         thisView, @"thisView", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPresentItineraryQuickView object:nil userInfo:dic];
}


#pragma mark - collapse and expand actions
-(IBAction)collapseCell:(id)sender{
    if (self.isCollapsed){
        self.isCollapsed = NO;
        [self animateExpansionOfCell];
    }else{
        self.isCollapsed = YES;
        [self animateCollapseOfCell];
    }
}

-(void)expandCellFromTapGesture{
    if (self.isCollapsed){
        self.isCollapsed = NO;
        [self animateExpansionOfCell];
    }
}

-(void)animateCollapseOfCell{
    self.topOfTextConstraint.constant = -8;
    self.bottomOfMainSubviewConstraint.constant = 60;
    self.topOfButton1Constraint.constant = 16;
    self.topOfButton2Constraint.constant = 16;
    
    [UIView animateWithDuration:0.15 animations:^{
        [self.view layoutIfNeeded];
        self.collapseButton.alpha = 0.0;
        
        [self.button1 setTransform:CGAffineTransformMakeScale(.5, .5)];
        [self.button2 setTransform:CGAffineTransformMakeScale(.5, .5)];
        self.textOverButton1.alpha = 0.0;
        self.textOverButton2.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.collapseButton.hidden = YES;
        [self.delegate collapseTapped:self.requestKeyId isReturning:self.markedForReturning];
        self.bottomOfMainSubviewConstraint.constant = 0;
    }];
}

-(void)animateExpansionOfCell{
    self.topOfTextConstraint.constant = 0;
    self.bottomOfMainSubviewConstraint.constant = -60;
    self.topOfButton1Constraint.constant = 8;
    self.topOfButton2Constraint.constant = 8;
    
    self.collapseButton.hidden = NO;

    [UIView animateWithDuration:0.15 animations:^{
        [self.view layoutIfNeeded];
        self.collapseButton.alpha = 1.0;
        
        [self.button1 setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        [self.button2 setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        self.textOverButton1.alpha = 1.0;
        if (self.myStatus < 1) {
            self.textOverButton2.alpha = 0.3;
        } else {
            self.textOverButton2.alpha = 1.0;
        }
    } completion:^(BOOL finished) {
        [self.delegate expandTapped:self.requestKeyId isReturning:self.markedForReturning];
        self.bottomOfMainSubviewConstraint.constant = 0;
    }];
}


#pragma mark - public methods
- (void)dismissedCheckInOut:(NSString *)scheduleKey
                   complete:(NSString *)completeOrIncomplete
                  returning:(BOOL)markedForReturning
                     switch:(NSUInteger)switchNum
                outstanding:(BOOL)foundOutstandingItem {

    if (([self.requestKeyId isEqualToString:scheduleKey]) && (markedForReturning == self.markedForReturning)){
        NSLog(@"found a match on key id: %@", self.requestKeyId);

        if ([completeOrIncomplete isEqualToString:@"complete"]){
            if (switchNum == 1){
                
                // Don't change status if it's at 2
                if (self.myStatus == 0){
                    self.myStatus = 1;
                }
                
                NSString* tag;
                if (!self.markedForReturning){
                    tag = @"staff_prep_date";
                }else {
                    tag = @"staff_checkin_date";
                }
                
                [self updateData:tag nix:NO callback:^{
                    NSDictionary* infoDic = @{ @"status": [NSNumber numberWithInteger:self.myStatus],
                                               @"markedForReturning": [NSNumber numberWithBool:self.markedForReturning],
                                               @"scheduleKey": scheduleKey };
                    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil userInfo:infoDic];
                }];
            }else{
                self.myStatus = 2;
                
                NSString* tag;
                if (!self.markedForReturning){
                    tag = @"staff_checkout_date";
                }else {
                    tag = @"staff_shelf_date";
                }
                
                [self updateData:tag nix:NO callback:^{
                    NSDictionary* infoDic = @{ @"status": [NSNumber numberWithInteger:self.myStatus],
                                               @"markedForReturning": [NSNumber numberWithBool:self.markedForReturning],
                                               @"scheduleKey": scheduleKey };
                    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil userInfo:infoDic];
                }];
            }
            
        }else{
            //marked as incomplete
            if (switchNum == 1){
                NSUInteger originalStatus = self.myStatus;
                self.myStatus = 0;
    
                NSString* tag;
                if (!self.markedForReturning){
                    tag = @"staff_prep_date";
                }else {
                    tag = @"staff_checkin_date";
                }
                
                [self updateData:tag nix:YES callback:^{
                    NSDictionary* infoDic = @{ @"status": [NSNumber numberWithInteger:self.myStatus],
                                               @"markedForReturning": [NSNumber numberWithBool:self.markedForReturning],
                                               @"scheduleKey": scheduleKey };
                    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil userInfo:infoDic];
                }];
                
                // Need to accommodate when switch 2 is ON and remove that from model as well
                if (originalStatus == 2){
                    
                    NSString* tag;
                    if (!self.markedForReturning){
                        tag = @"staff_checkout_date";
                    }else {
                        tag = @"staff_shelf_date";
                    }
                    
                    [self updateData:tag nix:YES callback:^{
                    }];
                }
            }else{
                self.myStatus = 1;
                NSString* tag;
                if (!self.markedForReturning){
                    tag = @"staff_checkout_date";
                }else {
                    tag = @"staff_shelf_date";
                }
                
                [self updateData:tag nix:YES callback:^{
                    NSDictionary* infoDic = @{ @"status": [NSNumber numberWithInteger:self.myStatus],
                                               @"markedForReturning": [NSNumber numberWithBool:self.markedForReturning],
                                               @"scheduleKey": scheduleKey };
                    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil userInfo:infoDic];
                }];
            }
        }
    }
}


-(void)updateData:(NSString*)tag nix:(BOOL)nix callback:(void (^)(void))cb{
    NSLog(@"update data fires");
    // Update the model
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    NSString *tagValue;
    if (nix){
        tagValue = @"nix";
    }else{
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        tagValue = [dateFormatter stringFromDate:[NSDate date]];
    }
    
    NSArray* topArray = @[ @[@"key_id", self.requestKeyId],
                           @[tag, tagValue],
                           @[@"staff_id", staffUserManager.currentStaffUser.key_id] ];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryForStringwithAsync:@"EQSetCheckOutInPrepScheduleRequest.php" parameters:topArray completion:^(NSString *returnString) {
            cb();
        }];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
