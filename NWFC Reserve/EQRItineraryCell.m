//
//  EQRItineraryRowCell2.m
//  Gear
//
//  Created by Ray Smith on 7/7/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRItineraryCell.h"
#import "EQRColors.h"
#import "EQRGlobals.h"

@interface EQRItineraryCell ()
@end

@implementation EQRItineraryCell

- (void)resetCellContentState {
    [self.contentVC resetState];
}

- (void)initialSetupWithRequestItem:(EQRScheduleRequestItem*) requestItem{
    
    [self resetCellContentState];
    
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
    // starting contentVC size needs to adhere to the current size of the cell (because it has a collapsed version)
    // otherwise it defaults to the NIB size
    self.contentVC.view.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    [self.contentView addSubview:self.contentVC.view];
    
    //make bg clear
    self.backgroundColor = [UIColor clearColor];
    
//    //assess if it is in the collapsed view or not
//    BOOL shouldBeCollapsed = NO;
//    if (requestItem.markedForReturn && requestItem.shouldCollapseReturningCell){
//        shouldBeCollapsed = YES;
//    }
//
//    if (!requestItem.markedForReturn && requestItem.shouldCollapseGoingCell){
//        shouldBeCollapsed = YES;
//    }
//
//    if (shouldBeCollapsed == YES){
//        self.contentVC.isCollapsed = YES;
//        self.contentVC.topOfTextConstraint.constant = -8;
//        self.contentVC.collapseButton.alpha = 0.0;
//        self.contentVC.collapseButton.hidden = YES;
//        self.contentVC.textOverButton1.alpha = 0.0;
//        self.contentVC.textOverButton2.alpha = 0.0;
//        self.contentVC.topOfButton1Constraint.constant = 16;
//        self.contentVC.topOfButton2Constraint.constant = 16;
//        [self.contentVC.button1 setTransform:CGAffineTransformMakeScale(.5, .5)];
//        [self.contentVC.button2 setTransform:CGAffineTransformMakeScale(.5, .5)];
//    }
    
    // Add constraints to the custom view that gets added to the cell's contentView, otherwise, the animation movement
    // of the cell gets glitchy
    self.contentVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = @{@"contentVC":self.contentVC.view};
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentVC]-0-|" options:0 metrics:nil views:viewsDictionary];
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentVC]-0-|" options:0 metrics:nil views:viewsDictionary];
    [[self.contentVC.view superview] addConstraints:constraint_POS_H];
    [[self.contentVC.view superview] addConstraints:constraint_POS_V];

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
    
    self.contentVC.collapseButton.tintColor = [colors.colorDic objectForKey:EQRColorButtonBlueOnGrayBG];
    UIImage *backgroundImage = [[self.contentVC.collapseButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.contentVC.collapseButton setImage:backgroundImage forState:UIControlStateNormal];
    
    
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
            [self makeCollapseButtonTinted:self.contentVC.collapseButton];
        }
    } else {           // status must be equal to 2
        //set first and second swith to on
        [self makeButtonTinted:self.contentVC.button1];
        self.contentVC.textOverButton1.textColor = [UIColor whiteColor];
        [self makeButtonTinted:self.contentVC.button2];
        self.contentVC.textOverButton2.textColor = [UIColor whiteColor];
        self.contentVC.bigArrow2.alpha = 0.7;
        self.contentVC.subViewFullSize.backgroundColor = [fullColor colorWithAlphaComponent:0.7];
        [self makeCollapseButtonTinted:self.contentVC.collapseButton];
    }
    
    
    //assess if it is in the collapsed view or not
    BOOL shouldBeCollapsed = NO;
    if (requestItem.markedForReturn && requestItem.shouldCollapseReturningCell){
        shouldBeCollapsed = YES;
    }
    
    if (!requestItem.markedForReturn && requestItem.shouldCollapseGoingCell){
        shouldBeCollapsed = YES;
    }
    
    if (shouldBeCollapsed == YES){
        self.contentVC.isCollapsed = YES;
        self.contentVC.topOfTextConstraint.constant = -8;
        self.contentVC.collapseButton.alpha = 0.0;
        self.contentVC.collapseButton.hidden = YES;
        self.contentVC.textOverButton1.alpha = 0.0;
        self.contentVC.textOverButton2.alpha = 0.0;
        self.contentVC.topOfButton1Constraint.constant = 16;
        self.contentVC.topOfButton2Constraint.constant = 16;
        [self.contentVC.button1 setTransform:CGAffineTransformMakeScale(.5, .5)];
        [self.contentVC.button2 setTransform:CGAffineTransformMakeScale(.5, .5)];
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
        }else{       //status must be 2
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
}

-(void)makeButtonTinted:(UIButton *)button{
    EQRColors *colors = [EQRColors sharedInstance];
    
    UIImage *originalImage = button.imageView.image;
    UIImage *tintedImage = [originalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:tintedImage forState:UIControlStateNormal];
    button.tintColor = [[colors colorDic] objectForKey:EQRColorButtonGreen];
}


-(void)makeCollapseButtonTinted:(UIButton *)button{
    //also make collapse button tinted
    EQRColors *colors = [EQRColors sharedInstance];
    button.tintColor = [colors.colorDic objectForKey:EQRColorButtonBlue];
    UIImage *backgroundImage = [[button imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:backgroundImage forState:UIControlStateNormal];
}


-(void)updateButtonLabels:(EQRScheduleRequestItem *)requestItem{
    //only apply caution to switch 1 if it is on
    if (!self.contentVC.markedForReturning){
        
        self.contentVC.button1Status.text = [NSString stringWithFormat:@"%ld of %ld items not %@", (long)requestItem.unTickedJoinCountForButton1, (long)requestItem.totalJoinCoint, @"Prepped"];
        
        self.contentVC.button2Status.text = [NSString stringWithFormat:@"%ld of %ld items not %@", (long)requestItem.unTickedJoinCountForButton2, (long)requestItem.totalJoinCoint, @"Checked Out"];
    }else{
        self.contentVC.button1Status.text = [NSString stringWithFormat:@"%ld of %ld items not %@", (long)requestItem.unTickedJoinCountForButton1, (long)requestItem.totalJoinCoint, @"Checked In"];
        
        self.contentVC.button2Status.text = [NSString stringWithFormat:@"%ld of %ld items not %@", (long)requestItem.unTickedJoinCountForButton2, (long)requestItem.totalJoinCoint, @"Shelved"];
    }
    
    //hide or unhide labels as appropriate
    if (self.contentVC.myStatus == 1){
        //definitely show label for button 2
        self.contentVC.button2Status.hidden = NO;

        //only show label for button 1 if there are outstanding items
        if (requestItem.unTickedJoinCountForButton1 > 0){
            self.contentVC.button1Status.hidden = NO;
        }else{
            self.contentVC.button1Status.hidden = YES;
        }
    }else if(self.contentVC.myStatus == 2){
        //only show label for button 2 if there are outstanding items
        if (requestItem.unTickedJoinCountForButton2 > 0){
            self.contentVC.button2Status.hidden = NO;
        }else{
            self.contentVC.button2Status.hidden = YES;
        }
    }else{  //must be status 0
        self.contentVC.button1Status.hidden = NO;
        self.contentVC.button2Status.hidden = YES;
    }
}




@end
