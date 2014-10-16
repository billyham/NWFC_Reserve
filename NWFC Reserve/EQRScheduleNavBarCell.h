//
//  EQRHeaderForNavBar.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/26/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRScheduleNavBarCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel* titleLabel;

-(void)initialSetupWithTitle:(NSString*) titleName;

@end
