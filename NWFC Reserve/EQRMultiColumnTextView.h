//
//  EQRTwoColumnTextView.h
//  Gear
//
//  Created by Ray Smith on 1/5/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRMultiColumnTextView : UIView

@property (strong, nonatomic) NSAttributedString* myDatesAttString;
@property (strong, nonatomic) NSAttributedString* myAttString;

@property (copy, nonatomic) NSTextStorage *textStorage;
@property (strong, nonatomic) NSArray *textOrigins;
@property (strong, nonatomic) NSLayoutManager *layoutManager;
@property NSInteger myColumnCount;


-(void)manuallySetTextWithColumnCount:(NSInteger)columnCount;

@end
