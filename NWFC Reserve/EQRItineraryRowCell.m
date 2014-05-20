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


-(void)initialSetupWithTitle:(NSString*) titleName{
    
    self.backgroundColor = [UIColor whiteColor];
    
    EQRItineraryCellContentVCntrllr* itineraryContent = [[EQRItineraryCellContentVCntrllr alloc] initWithNibName:@"EQRItineraryCellContentVCntrllr" bundle:nil];
    
    self.myItineraryContent = itineraryContent;
    
    [self.contentView addSubview:self.myItineraryContent.view];
    
    self.myItineraryContent.firstLastName.text = @"Hunky Dory";
    self.myItineraryContent.checkInOrOut.text = @"Check Out";
    self.myItineraryContent.interactionTime.text = @"3:15pm";
    self.myItineraryContent.renterType.text = EQRRenterStudent;
    

    
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
