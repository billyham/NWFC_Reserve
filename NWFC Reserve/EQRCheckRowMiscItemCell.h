//
//  EQRCheckRowMiscItemCell.h
//  Gear
//
//  Created by Ray Smith on 2/4/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRMiscJoin.h"

@interface EQRCheckRowMiscItemCell : UICollectionViewCell

-(void)initialSetupWithMiscJoin:(EQRMiscJoin*)miscJoin
                            marked:(BOOL)mark_for_returning
                        switch_num:(NSUInteger)switch_num
                 markedForDeletion:(BOOL)deleteFlag
                         indexPath:(NSIndexPath*)indexPath;

@end
