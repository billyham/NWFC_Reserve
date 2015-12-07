//
//  EQRQuickViewPage3VCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 8/11/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EQRQuickViewPage3VCntrllr : UIViewController <UIDocumentInteractionControllerDelegate>

@property BOOL fromItinerary;

-(void)initialSetupWithKeyID:(NSString*)keyID andUserInfoDic:(NSDictionary*)userInfo;

-(IBAction)duplicate:(id)sender;
-(IBAction)split:(id)sender;
-(IBAction)print:(id)sender;

-(IBAction)pdf:(id)sender;
-(IBAction)viewPdf:(id)sender;

@end
