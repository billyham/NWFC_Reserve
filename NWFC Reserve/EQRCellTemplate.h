//
//  EQRCellTemplate.h
//  NWFC Reserve
//
//  Created by Ray Smith on 12/25/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRCellTemplate : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel* titleLabel;


-(void)initialSetupWithTitle:(NSString*) titleName;
-(void)doHighlightCell;
-(void)cancelHighlightCell;

@end
