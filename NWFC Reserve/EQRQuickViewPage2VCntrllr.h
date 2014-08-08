//
//  EQRQuickViewPage2VCntrllr.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 8/8/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRQuickViewPage2VCntrllr : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView* myTable;
@property (strong, nonatomic) NSArray* myArray;

@end
