//
//  EQEquipItemCell.m
//  NWFC Reserve
//
//  Created by Ray Smith on 12/25/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import "EQREquipItemCell.h"
#import "EQREquipContentViewVCntrllr.h"

@interface EQREquipItemCell ()

@property (strong, nonatomic) EQREquipContentViewVCntrllr* myEquipVCntrllr;

@end

@implementation EQREquipItemCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - methods

-(void)initialSetupWithTitle:(NSString*) titleName{

    UILabel* thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 280, 20)];
    self.titleLabel = thisLabel;
    
    self.titleLabel.text = titleName;
    self.titleLabel.userInteractionEnabled = NO;
    
//    [self.contentView addSubview:self.titleLabel];
    

    EQREquipContentViewVCntrllr *controller = [[EQREquipContentViewVCntrllr alloc] initWithNibName:@"EQREquipContentViewVCntrllr" bundle:nil];
    
    //retain the view controller
    self.myEquipVCntrllr = controller;
    
    //add to content view
    [self.contentView addSubview:self.myEquipVCntrllr.view];

    //assign iboutlet values AFTER adding to the view otherwise it don't work
    //using the contentViewVCntrllr
    self.myEquipVCntrllr.titleLabel.text = titleName;


    //set user enabled
    
    //_________********** when set to YES: this and this alone prevents the collectionView delegeat from receiving tap actions
    [self.myEquipVCntrllr.view setUserInteractionEnabled:NO];
    
    [self.myEquipVCntrllr.plusButton setUserInteractionEnabled:YES];
    
    //add target to the plus and minus buttons
    [self.myEquipVCntrllr.plusButton addTarget:self action:@selector(plusHit:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    //create button programmatically
    //create temp button with custom property to retain the brown item
    UIButton* calButton = [[UIButton alloc] init];
    calButton.frame = CGRectMake(0, 0, 88, 44);
    [calButton setTitle:@"Add To Cal" forState:UIControlStateNormal];
    [calButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [calButton setTitle:@"Adding To Cal" forState:UIControlStateHighlighted];
    [calButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [calButton setTitle:@"Added To Cal" forState:UIControlStateSelected];
    [calButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    //set font size
    calButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    calButton.reversesTitleShadowWhenHighlighted = YES;
    
    
        //set font color
        calButton.titleLabel.textColor = [UIColor redColor];
        
        //set user interaction
        calButton.userInteractionEnabled = YES;
        
        //target of calendar button is the rootviewcontroller
        [calButton addTarget:self action:@selector(plusHit:) forControlEvents:UIControlEventTouchUpInside];
        
    [self.contentView addSubview:calButton];
    


    
    
}


-(IBAction)plusHit:(id)sender{
    
    NSLog(@"plus hit test in EquipItemCell");
}


//override the hitTest method so that only subviews respond to events and not this view (the container view)
//-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    
//    id hitView = [super hitTest:point withEvent:event];
//    
//    if (hitView == self) return nil;
//    
//    else return hitView;
//    
//    //**GENIUS!!!!  http://vectorvector.tumblr.com/post/2130331861/ignore-touches-to-uiview-subclass-but-not-to-its
//    
//}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
