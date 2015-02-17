//
//  EQRDateRangeVC.h
//  Gear
//
//  Created by Ray Smith on 2/16/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRInboxLeftTableVC.h"


@interface EQRDateRangeVC : UIViewController <EQRInboxLeftTableDelegate>


//InboxLeftTableVC delegate method
-(NSString*)selectedInboxOrArchive;
-(NSDictionary*)getDateRange;

@end
