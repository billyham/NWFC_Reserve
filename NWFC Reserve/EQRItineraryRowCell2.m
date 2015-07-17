//
//  EQRItineraryRowCell2.m
//  Gear
//
//  Created by Ray Smith on 7/7/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRItineraryRowCell2.h"
#import "EQRColors.h"
#import "EQRGlobals.h"


@interface EQRItineraryRowCell2 ()

@property (strong, nonatomic) EQRItineraryCellContent2VC *contentVC;

@end

@implementation EQRItineraryRowCell2

- (void)awakeFromNib {
    // Initialization code
}

-(void)initialSetupWithRequestItem:(EQRScheduleRequestItem*) requestItem{
    
    if (requestItem.markedForReturn == YES){
        
        EQRItineraryCellContent2VC *content = [[EQRItineraryCellContent2VC alloc] initWithNibName:@"EQRItineraryCellContentReturning1" bundle:nil];
        self.contentVC = content;
        
    }else{
        
        EQRItineraryCellContent2VC *content = [[EQRItineraryCellContent2VC alloc] initWithNibName:@"EQRItineraryCellContentGoing2" bundle:nil];
        self.contentVC = content;
    }
    

    
    //-----------------
    
    //cascade the 'markedForReturning' bool ivar
    if (requestItem.markedForReturn == YES) {
        self.contentVC.markedForReturning = YES;
    } else {
        self.contentVC.markedForReturning = NO;
    }
    
    //save the request key_id to the view
    self.contentVC.requestKeyId = requestItem.key_id;
    
    //a lot depends on whether the item is going or returning
    NSString* timeString;
    //format date for string
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"h:mm a";
    
    
    if (!requestItem.markedForReturn){
        
        //check the status
        if (!requestItem.staff_prep_date){
            
            self.contentVC.myStatus = 0;
            
        }else{
            
            if (!requestItem.staff_checkout_date){
                
                self.contentVC.myStatus = 1;
                
            }else{
                
                self.contentVC.myStatus = 2;
            }
        }
        
    } else{
        
        //check the status
        if (!requestItem.staff_checkin_date){
            
            self.contentVC.myStatus = 0;
            
        }else{
            
            if (!requestItem.staff_shelf_date){
                
                self.contentVC.myStatus = 1;
                
            }else{
                
                self.contentVC.myStatus = 2;
                
            }
        }
    }
    
    
    
    
    //______add the itinerary view to the cell's content view__________
    [self.contentView addSubview:self.contentVC.view];
    
    
    
    
    //derive colors
    EQRColors *colors = [EQRColors sharedInstance];
    
    UIColor *fullColor;
    UIColor *darkColor;
    
    if ([requestItem.renter_type isEqualToString:EQRRenterStudent]){
        fullColor = [colors.colorDic objectForKey:EQRColorStudentFull];
        darkColor = [colors.colorDic objectForKey:EQRColorStudentDark];
    }
    if ([requestItem.renter_type isEqualToString:EQRRenterPublic]){
        fullColor = [colors.colorDic objectForKey:EQRColorPublicFull];
        darkColor = [colors.colorDic objectForKey:EQRColorPublicDark];
    }
    if ([requestItem.renter_type isEqualToString:EQRRenterFaculty]){
        fullColor = [colors.colorDic objectForKey:EQRColorFacultyFull];
        darkColor = [colors.colorDic objectForKey:EQRColorFacultyDark];
    }
    if ([requestItem.renter_type isEqualToString:EQRRenterStaff]){
        fullColor = [colors.colorDic objectForKey:EQRColorStaffFull];
        darkColor = [colors.colorDic objectForKey:EQRColorStaffDark];
    }
    if ([requestItem.renter_type isEqualToString:EQRRenterYouth]){
        fullColor = [colors.colorDic objectForKey:EQRColorYouthFull];
        darkColor = [colors.colorDic objectForKey:EQRColorYouthDark];
    }
    if ([requestItem.renter_type isEqualToString:EQRRenterInClass]){
        fullColor = [colors.colorDic objectForKey:EQRColorInClassFull];
        darkColor = [colors.colorDic objectForKey:EQRColorInClassDark];
    }
    
    //apply colors
    self.contentVC.bigArrow1.image = [self.contentVC.bigArrow1.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.contentVC.bigArrow1 setTintColor:fullColor];
    
    self.contentVC.bigArrow2.image = [self.contentVC.bigArrow2.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.contentVC.bigArrow2 setTintColor:fullColor];
    self.contentVC.bigArrow2.alpha = 0.15;
    
    self.contentVC.arrow.image = [self.contentVC.arrow.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.contentVC.arrow setTintColor:darkColor];
    
    self.contentVC.requestRenterType.textColor = darkColor;
    
    
    
    
    //only if status is 0, disable the second switch
    if (self.contentVC.myStatus < 1){
        
        //disable the second switch
        self.contentVC.button2.userInteractionEnabled = NO;
        self.contentVC.button2.alpha = 0.3;
        self.contentVC.textOverButton2.alpha = 0.3;
        
    } else if (self.contentVC.myStatus == 1){
        
        //set first swith to on
        [self makeButtonTinted:self.contentVC.button1];
        self.contentVC.textOverButton1.textColor = [UIColor whiteColor];
        self.contentVC.bigArrow2.alpha = 0.9;
        
        //_________only if ignoring shelving, make background solid
        if (requestItem.markedForReturn){
            self.contentVC.bigArrow2.alpha = 0.7;
            self.contentVC.subViewFullSize.backgroundColor = [fullColor colorWithAlphaComponent:0.9];
        }
        
    } else {
        // status must be equal to 2
        
        //set first and second swith to on
        [self makeButtonTinted:self.contentVC.button1];
        self.contentVC.textOverButton1.textColor = [UIColor whiteColor];
        [self makeButtonTinted:self.contentVC.button2];
        self.contentVC.textOverButton2.textColor = [UIColor whiteColor];
        self.contentVC.bigArrow2.alpha = 0.7;
        self.contentVC.subViewFullSize.backgroundColor = [fullColor colorWithAlphaComponent:0.7];
    }
    
    if (!requestItem.markedForReturn){
        
        //set time
        timeString = [dateFormatter stringFromDate:requestItem.request_time_begin];
        
        //set switch labels
        if (self.contentVC.myStatus == 0){
            self.contentVC.textOverButton1.text = @"Prep";
            self.contentVC.textOverButton2.text = @"Check Out";
            
            //set caution labels
            self.contentVC.button1Status.textColor = [UIColor whiteColor];
            self.contentVC.button2Status.textColor = [UIColor whiteColor];
            
        }else if (self.contentVC.myStatus == 1){
            self.contentVC.textOverButton1.text = @"Prepped";
            self.contentVC.textOverButton2.text = @"Check Out";
            
            //set caution labels
            self.contentVC.button1Status.textColor = [UIColor redColor];
            self.contentVC.button2Status.textColor = [UIColor whiteColor];
            
        }else{ //status must be 2
            self.contentVC.textOverButton1.text = @"Prepped";
            self.contentVC.textOverButton2.text = @"Checked Out";

            //set caution labels
            self.contentVC.button1Status.textColor = [UIColor redColor];
            self.contentVC.button2Status.textColor = [UIColor redColor];
        }
        
    } else{
        
        //set time
        timeString = [dateFormatter stringFromDate:requestItem.request_time_end];
        
        //set switch labels
        if (self.contentVC.myStatus == 0){
            self.contentVC.textOverButton1.text = @"Check In";
            self.contentVC.textOverButton2.text = @"Shelve";
            
            //set caution labels
            self.contentVC.button1Status.textColor = [UIColor whiteColor];
            self.contentVC.button2Status.textColor = [UIColor whiteColor];
            
        }else if (self.contentVC.myStatus == 1){
            self.contentVC.textOverButton1.text = @"Checked In";
            self.contentVC.textOverButton2.text = @"Shelve";
            
            //set caution labels
            self.contentVC.button1Status.textColor = [UIColor redColor];
            self.contentVC.button2Status.textColor = [UIColor whiteColor];
            
        }else{  //must be 2
            self.contentVC.textOverButton1.text = @"Checked In";
            self.contentVC.textOverButton2.text = @"Shelved";
            
            //set caution labels
            self.contentVC.button1Status.textColor = [UIColor redColor];
            self.contentVC.button2Status.textColor = [UIColor redColor];
            
        }
    }
    
    //assign name and renter type
    self.contentVC.requestName.text = requestItem.contact_name;
    self.contentVC.requestRenterType.text = requestItem.renter_type;
    self.contentVC.requestClass.text =  requestItem.title;
    
    //assign time
    self.contentVC.requestTime.text = timeString;
    
    //update button label
    [self updateButtonLabels];
    

    
}

-(void)makeButtonTinted:(UIButton *)button{
    
    EQRColors *colors = [EQRColors sharedInstance];
    
    UIImage *originalImage = button.imageView.image;
    UIImage *tintedImage = [originalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:tintedImage forState:UIControlStateNormal];
    button.tintColor = [[colors colorDic] objectForKey:EQRColorButtonGreen];
    
}


-(BOOL)checkForJoinWarnings:(EQRScheduleTracking_EquipmentUnique_Join *)join{
    
    BOOL returnValue = NO;
//    NSString *buttonText;
    
    //only apply caution to switch 1 if it is on
    if (self.contentVC.myStatus == 1){
        
        BOOL foundOutstandingItemSwitch1 = NO;
        
        //decide between returning or going
        
        if (!self.contentVC.markedForReturning){     //going
            
            //            NSLog(@"this is the prep_flag value: %@ this is the join's key_id: %@", join.prep_flag, join.key_id);
            
            if (([join.prep_flag isEqualToString:@""]) || (join.prep_flag == nil)){
                
                foundOutstandingItemSwitch1 = YES;
//                buttonText = @"Prepped";
            }
            
        }else{              //returning
            
            if (([join.checkin_flag isEqualToString:@""]) || (join.checkin_flag == nil)){
                
                foundOutstandingItemSwitch1 = YES;
//                buttonText = @"Checked In";
            }
        }
        
        if (foundOutstandingItemSwitch1 == YES){
            
            self.unTickedJoinCountForButton1++;
            returnValue = YES;
            
            //update button labels
//            self.contentVC.button1Status.text = [NSString stringWithFormat:@"%ld of %ld items not %@", (long)self.unTickedJoinCountForButton1, (long)self.totalJoinCoint, buttonText];
            
            self.contentVC.button1Status.hidden = NO;
        }
    }
    
    //only apply caution to switch 2 if it is on
    if (self.contentVC.myStatus == 2){
        
        BOOL foundOutstandingItemSwitch2 = NO;
        
        //decide between returning or going
        
        if (!self.contentVC.markedForReturning){
            //going
            
            if (([join.checkout_flag isEqualToString:@""]) || (join.checkout_flag == nil)){
                
                foundOutstandingItemSwitch2 = YES;
//                buttonText = @"Checked Out";
            }
            
        }else{
            //returning
            
            if (([join.shelf_flag isEqualToString:@""]) || (join.shelf_flag == nil)){
                
                foundOutstandingItemSwitch2 = YES;
//                buttonText = @"Shelved";
            }
        }
        
        if (foundOutstandingItemSwitch2 == YES){
        
            self.unTickedJoinCountForButton2++;
            returnValue = YES;
            
            //update button labels
//            self.contentVC.button2Status.text = [NSString stringWithFormat:@"%ld of %ld items not %@", (long)self.unTickedJoinCountForButton2, (long)self.totalJoinCoint, buttonText];
            
            self.contentVC.button2Status.hidden = NO;
        }
    }
    return returnValue;
}

-(void)updateButtonLabels{
    
    //only apply caution to switch 1 if it is on
    if (!self.contentVC.markedForReturning){
        
        self.contentVC.button1Status.text = [NSString stringWithFormat:@"%ld of %ld items not %@", (long)self.unTickedJoinCountForButton1, (long)self.totalJoinCoint, @"Prepped"];
        
        self.contentVC.button2Status.text = [NSString stringWithFormat:@"%ld of %ld items not %@", (long)self.unTickedJoinCountForButton2, (long)self.totalJoinCoint, @"Checked Out"];
        
    }else{
        
        self.contentVC.button1Status.text = [NSString stringWithFormat:@"%ld of %ld items not %@", (long)self.unTickedJoinCountForButton1, (long)self.totalJoinCoint, @"Checked In"];
        
        self.contentVC.button2Status.text = [NSString stringWithFormat:@"%ld of %ld items not %@", (long)self.unTickedJoinCountForButton2, (long)self.totalJoinCoint, @"Shelved"];
        
    }
    
}




@end
