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




//@property (strong, nonatomic) IBOutlet UIView *button1Background;
//@property (strong, nonatomic) IBOutlet UIView *button2Background;


@end

@implementation EQRItineraryCellContent2VC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //register for notes
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    //receive complete or incomplete for this rows individual items editor
    [nc addObserver:self selector:@selector(dismissedCheckInOut:) name:EQRMarkItineraryAsCompleteOrNot object:nil];
    
    //add tap gesture to expand cell when it's collapsed
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandCellFromTapGesture)];
    [self.view addGestureRecognizer:tapGesture];
    
    
    

    
    
//    self.button2.alpha = 0.2;
    
    
    
    //---
    
//    UIImage *originalImage = self.button1.imageView.image;
//    UIImage *tintedImage = [originalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [self.button1 setImage:tintedImage forState:UIControlStateNormal];
//    self.button1.tintColor = [[colors colorDic] objectForKey:EQRColorStatusGoing];
    
//    UIImage *originalImage2 = self.button1.imageView.image;
//    UIImage *tintedImage2 = [originalImage2 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [self.button2 setImage:tintedImage2 forState:UIControlStateNormal];
//    self.button2.tintColor = [[colors colorDic] objectForKey:EQRColorStatusReturning];

    
}

-(void)viewDidAppear:(BOOL)animated{
        

    
    [super viewDidAppear:animated];
    
}


#pragma mark - switch methods


-(IBAction)switch1Fires:(id)sender{
    
    if ([sender tag] == 2){
        return;
    }
    
    //_______show check in out view
    NSDictionary* userDic = [NSDictionary dictionaryWithObjectsAndKeys:self.requestKeyId, @"scheduleKey",
                             [NSNumber numberWithBool:self.markedForReturning], @"marked_for_returning",
                             [NSNumber numberWithInteger:1], @"switch_num",
                             nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPresentCheckInOut object:nil userInfo:userDic];
    
}


-(IBAction)switch2Fires:(id)sender{
    
    if ([sender tag] == 1){
        return;
    }
    
    //_______show check in out view
    NSDictionary* userDic = [NSDictionary dictionaryWithObjectsAndKeys:self.requestKeyId, @"scheduleKey",
                             [NSNumber numberWithBool:self.markedForReturning], @"marked_for_returning",
                             [NSNumber numberWithInteger:2], @"switch_num",
                             nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPresentCheckInOut object:nil userInfo:userDic];
    
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
    
    [UIView animateWithDuration:0.15 animations:^{
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
    
        [self.delegate collapseTapped:self.requestKeyId isReturning:self.markedForReturning];

        self.bottomOfMainSubviewConstraint.constant = 0;
    }];


}

-(void)animateExpansionOfCell{
    
    self.topOfTextConstraint.constant = 0;
    self.bottomOfMainSubviewConstraint.constant = -60;

    [UIView animateWithDuration:0.15 animations:^{
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [self.delegate expandTapped:self.requestKeyId isReturning:self.markedForReturning];
        
        self.bottomOfMainSubviewConstraint.constant = 0;
        
    }];
    
}


#pragma mark - notes

-(void)dismissedCheckInOut:(NSNotification*)note{
    
    //_______********  still need to update the data model and local ivar   *******_______
    
    //[NSNumber numberWithBool:self.marked_for_returning], @"marked_for_returning",
    //self.myProperty, @"propertyToUpdate",
    
    
    NSString* scheduleKey = [[note userInfo] objectForKey:@"scheduleKey"];
    NSString* completeOrIncomplete = [[note userInfo] objectForKey:@"comleteOrIncomplete"];
    BOOL markedForReturning = [(NSNumber*)[[note userInfo] objectForKey:@"marked_for_returning"] boolValue];
    NSUInteger switch_num = [[[note userInfo] objectForKey:@"switch_num"] integerValue];
    BOOL foundOutstandingItem = [[[note userInfo] objectForKey:@"foundOutstandingItem"] boolValue];
    
    if (([self.requestKeyId isEqualToString:scheduleKey]) && (markedForReturning == self.markedForReturning)){
        
        if ([completeOrIncomplete isEqualToString:@"complete"]){
            
            if (switch_num == 1){
                
                //don't change status if it's at 2
                if (self.myStatus == 0){
                    
                    self.myStatus = 1;
                }
                
                //change color of inside of tap button

                
                //enable switch2

                
                //change status color

                
                //change color of second status bar

                
                //turn on caution label
                if (foundOutstandingItem){

                    
                }else{

                }
                
                
                //update the model
                EQRWebData* webData = [EQRWebData sharedInstance];
                EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
                
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                
                NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.requestKeyId, nil];
                NSArray* secondArray;
                if (!self.markedForReturning){
                    secondArray = [NSArray arrayWithObjects:@"staff_prep_date",  [dateFormatter stringFromDate:[NSDate date]], nil];
                }else {
                    secondArray = [NSArray arrayWithObjects:@"staff_checkin_date",  [dateFormatter stringFromDate:[NSDate date]], nil];
                }
                NSArray* thirdArray = [NSArray arrayWithObjects:@"staff_id", staffUserManager.currentStaffUser.key_id, nil];
                NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, thirdArray, nil];
                
                NSString* resultString = [webData queryForStringWithLink:@"EQSetCheckOutInPrepScheduleRequest.php" parameters:topArray];
                NSLog(@"%@", resultString);
                
                //________*********  also update the value in the itinarary object's ivar arrayOfScheduleRequests
                //include the new status
                NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:self.myStatus], @"status",
                                         [NSNumber numberWithBool:self.markedForReturning], @"markedForReturning",
                                         nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil userInfo:infoDic];
                
            }else{
                
                //swtichNum == 2
                
                self.myStatus = 2;
                
                //change color of inside of tap button

                
                //change status color

                
                //change color of second status bar

                
                //turn on caution label
                if (foundOutstandingItem){

                    
                }else{
                    
     
                }
                
                
                //update the model
                EQRWebData* webData = [EQRWebData sharedInstance];
                EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
                
                
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                
                NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.requestKeyId, nil];
                NSArray* secondArray;
                if (!self.markedForReturning){
                    secondArray = [NSArray arrayWithObjects:@"staff_checkout_date",  [dateFormatter stringFromDate:[NSDate date]], nil];
                }else{
                    secondArray = [NSArray arrayWithObjects:@"staff_shelf_date",  [dateFormatter stringFromDate:[NSDate date]], nil];
                }
                NSArray* thirdArray = [NSArray arrayWithObjects:@"staff_id", staffUserManager.currentStaffUser.key_id, nil];
                NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, thirdArray, nil];
                
                NSString* resultString = [webData queryForStringWithLink:@"EQSetCheckOutInPrepScheduleRequest.php" parameters:topArray];
                NSLog(@"%@", resultString);
                
                //________*********  also update the value in the itinarary object's ivar arrayOfScheduleRequests
                NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:self.myStatus], @"status",
                                         [NSNumber numberWithBool:self.markedForReturning], @"markedForReturning",
                                         nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil userInfo:infoDic];
                
                
            }
            
        }else{
            //marked as incomplete
            
            if (switch_num == 1){
                
                self.myStatus = 0;
                
                //change color of inside of tap button

                
                //disable switch2

                
                //also change color of inside of switch2 tap button

                
                //change status color

                
                //change color of second status bar


                
                
                //update the model
                EQRWebData* webData = [EQRWebData sharedInstance];
                EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
                
                
                NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.requestKeyId, nil];
                NSArray* secondArray;
                if (!self.markedForReturning){
                    secondArray = [NSArray arrayWithObjects:@"staff_prep_date",  @"nix", nil];
                }else {
                    secondArray = [NSArray arrayWithObjects:@"staff_checkin_date",  @"nix", nil];
                }
                
                NSArray* thirdArray = [NSArray arrayWithObjects:@"staff_id", staffUserManager.currentStaffUser.key_id, nil];
                NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, thirdArray, nil];
                
                NSLog(@"this is the array 1: %@, 2: %@, 3: %@", firstArray, secondArray, thirdArray);
                
                NSString* resultString = [webData queryForStringWithLink:@"EQSetCheckOutInPrepScheduleRequest.php" parameters:topArray];
                NSLog(@"%@", resultString);
                
                //________*********  also update the value in the itinarary object's ivar arrayOfScheduleRequests
                NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:self.myStatus], @"status",
                                         [NSNumber numberWithBool:self.markedForReturning], @"markedForReturning",
                                         nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil userInfo:infoDic];
                
                
                
                //_______ need to accommodate when switch 2 is ON and remove that from model as well
                if (self.myStatus == 2){
                    
                    EQRWebData* webData = [EQRWebData sharedInstance];
                    
                    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.requestKeyId, nil];
                    NSArray* secondArray;
                    if (!self.markedForReturning){
                        secondArray = [NSArray arrayWithObjects:@"staff_checkout_date",  @"nix", nil];
                    }else{
                        secondArray = [NSArray arrayWithObjects:@"staff_shelf_date",  @"nix", nil];
                    }
                    NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, nil];
                    
                    [webData queryForStringWithLink:@"EQSetCheckOutInPrepScheduleRequest.php" parameters:topArray];
                }
                
                
            }else{
                
                //swtichNum == 2
                
                self.myStatus = 1;
                
                //change color of inside of tap button
   
                
                //change status color

                
                //change color of second status bar
     
                
          
                
                
                //update the model
                EQRWebData* webData = [EQRWebData sharedInstance];
                EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
                
                
                NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.requestKeyId, nil];
                NSArray* secondArray;
                if (!self.markedForReturning){
                    secondArray = [NSArray arrayWithObjects:@"staff_checkout_date",  @"nix", nil];
                }else{
                    secondArray = [NSArray arrayWithObjects:@"staff_shelf_date",  @"nix", nil];
                }
                NSArray* thirdArray = [NSArray arrayWithObjects:@"staff_id", staffUserManager.currentStaffUser.key_id, nil];
                NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, thirdArray, nil];
                
                [webData queryForStringWithLink:@"EQSetCheckOutInPrepScheduleRequest.php" parameters:topArray];
                
                //________*********  also update the value in the itinarary object's ivar arrayOfScheduleRequests
                NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:self.myStatus], @"status",
                                         [NSNumber numberWithBool:self.markedForReturning], @"markedForReturning",
                                         nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil userInfo:infoDic];
                
            }
        }
    }
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
