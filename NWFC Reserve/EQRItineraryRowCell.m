//
//  EQRItineraryRowCell.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/14/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRItineraryRowCell.h"
#import "EQRItineraryCellContentVCntrllr.h"
#import "EQRGlobals.h"
#import "EQRWebData.h"

@interface EQRItineraryRowCell ()

@property (strong, nonatomic) EQRItineraryCellContentVCntrllr* myItineraryContent;

@end


@implementation EQRItineraryRowCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)initialSetupWithRequestItem:(EQRScheduleRequestItem*) requestItem{
    
//    if ([requestItem.key_id isEqualToString:@"535"]){
//        NSLog(@"inside itineraryRowCell initialSetup with request item contact name: %@", [requestItem contact_name]);
//    }
    
    self.backgroundColor = [UIColor clearColor];
    
    EQRItineraryCellContentVCntrllr* itineraryContent = [[EQRItineraryCellContentVCntrllr alloc] initWithNibName:@"EQRItineraryCellContentVCntrllr" bundle:nil];
    
    self.myItineraryContent = itineraryContent;
    
    //cascade the 'markedForReturning' bool ivar
    if (requestItem.markedForReturn == YES) {
        
        self.myItineraryContent.markedForReturning = YES;
        
    } else {
        
        self.myItineraryContent.markedForReturning = NO;
    }
    
    //save the request key_id to the view
    self.myItineraryContent.requestKeyId = requestItem.key_id;
    
    //a lot depends on whether the item is going or returning
    NSString* timeString;
    //format date for string
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"h:mm a";
    

    if (!requestItem.markedForReturn){
        
        //check the status
        if (!requestItem.staff_prep_date){
            
            self.myItineraryContent.myStatus = 0;
            
        }else{
            
            if (!requestItem.staff_checkout_date){
                
                self.myItineraryContent.myStatus = 1;

            }else{
                
                self.myItineraryContent.myStatus = 2;
            }
        }
        
    } else{
        
        //check the status
        if (!requestItem.staff_checkin_date){
            
            self.myItineraryContent.myStatus = 0;
            
        }else{
            
            if (!requestItem.staff_shelf_date){
                
                self.myItineraryContent.myStatus = 1;

            }else{
                
                self.myItineraryContent.myStatus = 2;

            }
        }
    }
    
    //______add the itinerary view to the cell's content view
    [self.contentView addSubview:self.myItineraryContent.view];
    
    //only if status is 0, disable the second switch
    if (self.myItineraryContent.myStatus < 1){
        
        //disable the second switch
        self.myItineraryContent.switchTap2.userInteractionEnabled = NO;
        self.myItineraryContent.switchTap2.alpha = 0.3;
        self.myItineraryContent.switchLabel2.alpha = 0.3;
        
    } else if (self.myItineraryContent.myStatus == 1){
        
        //set first swith to on
        self.myItineraryContent.switchTap1.innerCircleColor = [UIColor colorWithRed: 0 green: 0.657 blue: 0 alpha: 1];
        
    } else {
        // status must be equal to 2
        
        //set first and second swith to on
        self.myItineraryContent.switchTap1.innerCircleColor = [UIColor colorWithRed: 0 green: 0.657 blue: 0 alpha: 1];
        self.myItineraryContent.switchTap2.innerCircleColor = [UIColor colorWithRed: 0 green: 0.657 blue: 0 alpha: 1];
    }
    
    if (!requestItem.markedForReturn){
        
        //set time
        timeString = [dateFormatter stringFromDate:requestItem.request_time_begin];
        
        //set switch labels
        self.myItineraryContent.switchLabel1.text = @"Prepped";
        self.myItineraryContent.switchLabel2.text = @"Check Out";
        
        //set caution labels
        self.myItineraryContent.cautionLabel1.text = @"*Some items are not prepped";
        self.myItineraryContent.cautionLabel2.text = @"*Some items are not checked out";
        
    } else{
        
        //set time
        timeString = [dateFormatter stringFromDate:requestItem.request_time_end];
        
        //set switch labels
        self.myItineraryContent.switchLabel1.text = @"Check In";
        self.myItineraryContent.switchLabel2.text = @"Shelved";
        
        //set caution labels
        self.myItineraryContent.cautionLabel1.text = @"*Some items are not checked in";
        self.myItineraryContent.cautionLabel2.text = @"*Some items are not shelved";
    }
    
    //assign name and renter type
    self.myItineraryContent.firstLastName.text = requestItem.contact_name;
    self.myItineraryContent.renterType.text = requestItem.renter_type;
    self.myItineraryContent.renterType.hidden = YES;
    
    //assign time
    self.myItineraryContent.interactionTime.text = timeString;
    

    //__________SHOW any appropriate caution labels
//    
//    //get an array of joins for this row's schedule_key
//    EQRWebData* webData = [EQRWebData sharedInstance];
//    self.webData = webData;
//    self.webData.delegateDataFeed = self;
//    SEL thisSelector = @selector(itineraryRowCellLoadsJoins:);
//    NSArray* firstArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", self.myItineraryContent.requestKeyId, nil];
//    NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
//    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
//    dispatch_async(queue, ^{
//        [self.webData queryWithAsync:@"EQGetScheduleEquipJoinsForCheckWithScheduleTrackingKey.php" parameters:topArray class:@"EQRScheduleTracking_EquipmentUnique_Join" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
//            
//        }];
//    });
}

-(void)layoutSubviews{  
}


-(void)checkForJoinWarnings:(EQRScheduleTracking_EquipmentUnique_Join *)join{
    
    //only apply caution to switch 1 if it is on
    if (self.myItineraryContent.myStatus == 1){
        
        BOOL foundOutstandingItemSwitch1 = NO;
        
        //decide between returning or going
        
        if (!self.myItineraryContent.markedForReturning){     //going
            
            if (([join.prep_flag isEqualToString:@""]) || (join.prep_flag == nil)){
                
                foundOutstandingItemSwitch1 = YES;
            }
            
        }else{              //returning
            
            if (([join.checkin_flag isEqualToString:@""]) || (join.checkin_flag == nil)){
                
                foundOutstandingItemSwitch1 = YES;
            }
        }
        
        if (foundOutstandingItemSwitch1 == YES){
            
            self.myItineraryContent.cautionLabel1.hidden = NO;
        }
    }
    
    
    //only apply caution to switch 2 if it is on
    if (self.myItineraryContent.myStatus == 2){
        
        BOOL foundOutstandingItemSwitch2 = NO;
        
        //decide between returning or going
        
        if (!self.myItineraryContent.markedForReturning){
            //going
            
            if (([join.checkout_flag isEqualToString:@""]) || (join.checkout_flag == nil)){
                
                foundOutstandingItemSwitch2 = YES;
            }
            
        }else{
            //returning
            
            if (([join.shelf_flag isEqualToString:@""]) || (join.shelf_flag == nil)){
                
                foundOutstandingItemSwitch2 = YES;
            }
        }
        
        if (foundOutstandingItemSwitch2 == YES){
            
            self.myItineraryContent.cautionLabel2.hidden = NO;
        }
    }
}

#pragma mark - webdata delegate methods

#pragma mark - dealloc

- (void)dealloc{
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
