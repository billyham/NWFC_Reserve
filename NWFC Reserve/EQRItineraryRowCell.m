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
    
//    NSLog(@"inside itineraryRowCell initialSetup with request item contact name: %@", [requestItem contact_name]);
    
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
        self.myItineraryContent.switch2.userInteractionEnabled = NO;
        self.myItineraryContent.switch2.alpha = 0.3;
        self.myItineraryContent.switchLabel2.alpha = 0.3;
        
    } else if (self.myItineraryContent.myStatus == 1){
        
        //set first swith to on
        [self.myItineraryContent.switch1 setOn:YES];
        
        
    } else {
        // status must be equal to 2
        
        //set first and second swith to on
        [self.myItineraryContent.switch1 setOn:YES];
        [self.myItineraryContent.switch2 setOn:YES];
        
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
