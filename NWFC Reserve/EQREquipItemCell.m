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
@property int itemQuantity;
@property (strong, nonatomic) IBOutlet NSString* itemQuantityString;

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

    //initial ivar values
    self.itemQuantity = 0;
    self.itemQuantityString = @"0";
    
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
    
    
    
    
    //create buttons programmatically
    //___plus button
    UIButton* plusButtonFoSho = [UIButton buttonWithType:UIButtonTypeSystem];
    plusButtonFoSho.frame = CGRectMake(0, 0, 46, 32);
    //set font size
    plusButtonFoSho.titleLabel.text = @"+";
    plusButtonFoSho.titleLabel.font = [UIFont systemFontOfSize:32];
    [plusButtonFoSho setTitle:@"+" forState:UIControlStateNormal];
    [plusButtonFoSho setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [plusButtonFoSho setTitle:@"+" forState:UIControlStateHighlighted];
//  [plusButtonFoSho setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [plusButtonFoSho setTitle:@"+" forState:UIControlStateSelected];
    [plusButtonFoSho setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    //set font size
    plusButtonFoSho.reversesTitleShadowWhenHighlighted = YES;
    
    //set user interaction
    plusButtonFoSho.userInteractionEnabled = YES;
    
    //target of calendar button is the rootviewcontroller
    [plusButtonFoSho addTarget:self action:@selector(plusHit:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:plusButtonFoSho];
    
    
    //___minus button
    UIButton* minusButtonFoSho = [UIButton buttonWithType:UIButtonTypeSystem];
    minusButtonFoSho.frame = CGRectMake(69, 0, 46, 32);
    minusButtonFoSho.titleLabel.text = @"–";
    minusButtonFoSho.titleLabel.font = [UIFont systemFontOfSize:32];
    [minusButtonFoSho setTitle:@"–" forState:UIControlStateNormal];
    [minusButtonFoSho setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [minusButtonFoSho setTitle:@"–" forState:UIControlStateHighlighted];
    [minusButtonFoSho setTitle:@"–" forState:UIControlStateSelected];
    [minusButtonFoSho setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    //set font size
    minusButtonFoSho.reversesTitleShadowWhenHighlighted = YES;
    
    //set user interaction
    minusButtonFoSho.userInteractionEnabled = YES;
    
    //target of calendar button is the rootviewcontroller
    [minusButtonFoSho addTarget:self action:@selector(minusHit:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:minusButtonFoSho];


    
    
}


-(IBAction)plusHit:(id)sender{
    
    self.itemQuantity = self.itemQuantity + 1;
    
    //set outlet string value
    if (self.itemQuantity != 0){
        
        self.itemQuantityString = [NSString stringWithFormat:@"%u", self.itemQuantity];
        
    } else {
        
        self.itemQuantityString = @"";
    }
    
    //set subview textfield value
    self.myEquipVCntrllr.quantityTextField.text = self.itemQuantityString;
    
    NSLog(@"plus hit test in EquipItemCell with total: %u", self.itemQuantity);
    
    //_______pass the touch event up the responder chain...
//    [self.nextResponder touchesBegan:touches withEvent:event];
}

-(IBAction)minusHit:(id)sender{
    
    if (self.itemQuantity > 0){
        
        self.itemQuantity = self.itemQuantity - 1;
    }
    
    //set outlet string value
    if (self.itemQuantity != 0){
        
        self.itemQuantityString = [NSString stringWithFormat:@"%u", self.itemQuantity];
        
    } else {
        
        self.itemQuantityString = @"";
    }
    
    //set subview textfield value
    self.myEquipVCntrllr.quantityTextField.text = self.itemQuantityString;
    
    NSLog(@"minus hit test in EquipoItemCell with total: %u", self.itemQuantity);
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
