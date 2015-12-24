//
//  EQREquipSummaryGenericVCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 5/7/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQREnterPhoneVC.h"
#import "EQREnterEmail.h"
#import "EQRContactPickerVC.h"

@interface EQREquipSummaryGenericVCntrllr : UIViewController <UITextViewDelegate, EQREnterPhoneDelegate, UIPopoverControllerDelegate, EQRContactPickerDelegate, EQREnterEmailDelegate>

//why did I add these if they never get used???
//@property (nonatomic, strong) NSAttributedString* rentorNameAtt;
//@property (nonatomic, strong) NSAttributedString* rentorPhoneAtt;
//@property (nonatomic, strong) NSAttributedString* rentorEmailAtt;
//@property (nonatomic, strong) NSAttributedString* rentorPickupDateAtt;
//@property (nonatomic, strong) NSAttributedString* rentorReturnDateAtt;
//@property (nonatomic, strong) NSAttributedString* rentorEquipListAtt;



//enterPhone delegate method
-(void)phoneEntered:(NSString*)phoneNumber;

//enterEmail delegte method
-(void)emailEntered:(NSString *)email;

//changeContact delegate method
-(void)retrieveSelectedNameItem;
-(void)retrieveSelectedNameItemWithObject:(id)contactObject;

@end

