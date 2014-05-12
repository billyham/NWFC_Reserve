//
//  EQRHeaderCellTemplate.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/7/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

@protocol EQRHeaderCellTemplateDelegate;


#import <UIKit/UIKit.h>

@interface EQRHeaderCellTemplate : UICollectionViewCell{
    
    __weak id <EQRHeaderCellTemplateDelegate> delegate;
}

@property (nonatomic, weak) id <EQRHeaderCellTemplateDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel* titleLabel;
@property (strong ,nonatomic) IBOutlet UIButton* revealButton;
@property (strong, nonatomic) IBOutlet UIButton* allButton;


-(void)initialSetupWithTitle:(NSString*) titleName isHidden:(BOOL)yesHidden;
-(IBAction)revealButtonTapped:(id)sender;

@end

@protocol EQRHeaderCellTemplateDelegate <NSObject>

-(NSArray*)retrieveArrayOfEquipSectionsThatShouldBeHidden;
-(void)collapseOrExpandSection:(NSString*)chosenSection WithAll:(BOOL)withAllFlag;


@end