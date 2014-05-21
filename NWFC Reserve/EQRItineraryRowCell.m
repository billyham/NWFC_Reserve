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
    
    self.backgroundColor = [UIColor whiteColor];
    
    EQRItineraryCellContentVCntrllr* itineraryContent = [[EQRItineraryCellContentVCntrllr alloc] initWithNibName:@"EQRItineraryCellContentVCntrllr" bundle:nil];
    
    self.myItineraryContent = itineraryContent;
    
    [self.contentView addSubview:self.myItineraryContent.view];
    
    //format date for string
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"h:mm a";
    NSString* timeString = [dateFormatter stringFromDate:requestItem.request_time_begin];
    
    self.myItineraryContent.firstLastName.text = requestItem.contact_name;
    self.myItineraryContent.checkInOrOut.text = @"Check Out";
    self.myItineraryContent.interactionTime.text = timeString;
    self.myItineraryContent.renterType.text = requestItem.renter_type;
    

    
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
