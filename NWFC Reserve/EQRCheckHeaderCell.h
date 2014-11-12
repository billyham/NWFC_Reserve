//
//  EQRCheckHeaderCell.h
//  Gear
//
//  Created by Ray Smith on 11/12/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRCheckHeaderCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel* categoryLabel;

-(void)initialSetupWithCategoryText:(NSString*)categoryLabel;

@end
