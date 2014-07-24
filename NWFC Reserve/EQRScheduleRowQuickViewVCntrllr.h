//
//  EQRScheduleRowQuickViewVCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 7/21/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRScheduleRowQuickViewVCntrllr : UIViewController

@property (strong, nonatomic) IBOutlet UILabel* contactName;
@property (strong, nonatomic) IBOutlet UILabel* pickUpDate;
@property (strong, nonatomic) IBOutlet UILabel* returnDate;
@property (strong, nonatomic) IBOutlet UILabel* classTitle;
@property (strong, nonatomic) IBOutlet UILabel* confirmedLabel;
@property (strong, nonatomic) IBOutlet UILabel* confirmedValue;
@property (strong, nonatomic) IBOutlet UILabel* preppedLabel;
@property (strong, nonatomic) IBOutlet UILabel* preppedValue;
@property (strong, nonatomic) IBOutlet UILabel* pickedUpLabel;
@property (strong, nonatomic) IBOutlet UILabel* pickedUpValue;
@property (strong, nonatomic) IBOutlet UILabel* returnedLabel;
@property (strong, nonatomic) IBOutlet UILabel* returnedValue;
@property (strong, nonatomic) IBOutlet UILabel* shelvedLabel;
@property (strong, nonatomic) IBOutlet UILabel* shelvedValue;
@property (strong, nonatomic) IBOutlet UITextView* notesView;
@property (strong, nonatomic) IBOutlet UIButton* editRequestButton;


-(void)initialSetupWithDic:(NSDictionary*)dictionary;

//-(IBAction)editRequest:(id)sender;

@end
