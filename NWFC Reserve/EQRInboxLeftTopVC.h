//
//  EQInboxLeftTopVC.h
//  NWFC Reserve
//
//  Created by Ray Smith on 8/27/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRInboxLeftTableVC.h"

@interface EQRInboxLeftTopVC : UITableViewController <EQRInboxLeftTableDelegate>


//InboxLeftTableVC delegate method
-(NSString*)selectedInboxOrArchive;

@end
