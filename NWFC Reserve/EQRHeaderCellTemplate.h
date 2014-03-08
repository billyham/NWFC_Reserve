//
//  EQRHeaderCellTemplate.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/7/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRHeaderCellTemplate : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel* titleLabel;
@property (strong ,nonatomic) IBOutlet UIButton* revealButton;


-(void)initialSetupWithTitle:(NSString*) titleName isHidden:(BOOL)yesHidden;

@end
