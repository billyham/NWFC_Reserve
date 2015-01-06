//
//  EQRCheckPageRenderer.h
//  NWFC Reserve
//
//  Created by Ray Smith on 6/2/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRMultiColumnTextView.h"

@interface EQRCheckPageRenderer : UIPrintPageRenderer

@property (strong, nonatomic) NSString* name_text_value;
@property (strong, nonatomic) NSString* phone_text_value;
@property (strong, nonatomic) NSString* email_text_value;

@property (strong, nonatomic) UITextView* aTextView;
@property (strong, nonatomic) EQRMultiColumnTextView* aTwoColumnView;


@end
