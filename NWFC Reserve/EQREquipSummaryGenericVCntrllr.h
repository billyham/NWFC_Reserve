//
//  EQREquipSummaryGenericVCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 5/7/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQREquipSummaryGenericVCntrllr : UIViewController

//why did I add these if they never get used???
//@property (nonatomic, strong) NSAttributedString* rentorNameAtt;
//@property (nonatomic, strong) NSAttributedString* rentorPhoneAtt;
//@property (nonatomic, strong) NSAttributedString* rentorEmailAtt;
//@property (nonatomic, strong) NSAttributedString* rentorPickupDateAtt;
//@property (nonatomic, strong) NSAttributedString* rentorReturnDateAtt;
//@property (nonatomic, strong) NSAttributedString* rentorEquipListAtt;

@property (nonatomic, strong) NSString* rentorNameAtt;
@property (nonatomic, strong) NSString* rentorPhoneAtt;
@property (nonatomic, strong) NSString* rentorEmailAtt;


@property (nonatomic, strong) IBOutlet UITextView* summaryTextView;
@property (nonatomic, strong) NSTextStorage* summaryTextStorage;
@property (nonatomic, strong) NSMutableAttributedString* summaryTotalAtt;


@end

