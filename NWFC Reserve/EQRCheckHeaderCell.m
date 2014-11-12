//
//  EQRCheckHeaderCell.m
//  Gear
//
//  Created by Ray Smith on 11/12/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRCheckHeaderCell.h"

@implementation EQRCheckHeaderCell

- (void)awakeFromNib {
    // Initialization code
}


-(void)initialSetupWithCategoryText:(NSString*)categoryLabel{
    
    //label
    CGRect thisRect = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, 590.f, self.contentView.frame.size.height);
    UILabel* thisLabel = [[UILabel alloc] initWithFrame:thisRect];
    self.categoryLabel = thisLabel;
    
    self.categoryLabel.text = categoryLabel;
    self.categoryLabel.font = [UIFont boldSystemFontOfSize:12];
    self.categoryLabel.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.categoryLabel];
    
    
    
    
    //add constraints
    self.categoryLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = @{@"titleView":self.categoryLabel};
    
    //vertical constraits
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[titleView]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    NSArray *constraint_POS_VB = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleView]-1-|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewsDictionary];
    
    //horizontal constraints (fixed width and centered in superview)
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[titleView(560)]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];

    NSLayoutConstraint *constraint_center_horizontally = [NSLayoutConstraint constraintWithItem:self.categoryLabel
                                                                                      attribute:NSLayoutAttributeCenterX
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:[self.categoryLabel superview]
                                                                                      attribute:NSLayoutAttributeCenterX
                                                                                     multiplier:1.0
                                                                                       constant:0.0];
    
    [[self.categoryLabel superview] addConstraints:constraint_POS_H];
    [[self.categoryLabel superview] addConstraints:constraint_POS_V];
    [[self.categoryLabel superview] addConstraint:constraint_center_horizontally];
    [[self.categoryLabel superview] addConstraints:constraint_POS_VB];
    
    
}


@end
