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
    
    NSLog(@"inside itineraryRowCell initialSetup with request item contact name: %@", [requestItem contact_name]);
    
    self.backgroundColor = [UIColor clearColor];
    
    EQRItineraryCellContentVCntrllr* itineraryContent = [[EQRItineraryCellContentVCntrllr alloc] initWithNibName:@"EQRItineraryCellContentVCntrllr" bundle:nil];
    
    self.myItineraryContent = itineraryContent;
    
    //cascade the 'markedForReturning' bool ivar
    if (requestItem.markedForReturn == YES) {
        
        self.myItineraryContent.markedForReturning = YES;
        
    } else {
        
        self.myItineraryContent.markedForReturning = NO;
    }
    
    [self.contentView addSubview:self.myItineraryContent.view];
    
    //format date for string
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"h:mm a";
    
    //a lot depends on whether the item is going or returning
    NSString* timeString;
    
    
    if (!requestItem.markedForReturn){
        
        timeString = [dateFormatter stringFromDate:requestItem.request_time_begin];
        self.myItineraryContent.switchLabel1.text = @"Prepped";
        self.myItineraryContent.switchLabel2.text = @"Check Out";
        
    } else{
        
        timeString = [dateFormatter stringFromDate:requestItem.request_time_end];
        self.myItineraryContent.switchLabel1.text = @"Check In";
        self.myItineraryContent.switchLabel2.text = @"Shelved";
    }
    
    //disable the second switch
    self.myItineraryContent.switch2.userInteractionEnabled = NO;
    self.myItineraryContent.switch2.alpha = 0.3;
    self.myItineraryContent.switchLabel2.alpha = 0.3;
    
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
