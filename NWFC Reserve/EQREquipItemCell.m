//
//  EQEquipItemCell.m
//  NWFC Reserve
//
//  Created by Ray Smith on 12/25/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import "EQREquipItemCell.h"
#import "EQREquipContentViewVCntrllr.h"
#import "EQRScheduleRequestManager.h"
#import "EQRWebData.h"
#import "EQRGlobals.h"


@interface EQREquipItemCell ()

@property (strong, nonatomic) EQREquipItem* thisEquipTitleItem;
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

-(void)initialSetupWithTitle:(NSString*)titleName andEquipItem:(EQREquipItem*)titleItemObject{
    
    //assign ivar
    self.thisEquipTitleItem = titleItemObject;
    
    //initial ivar values
    self.itemQuantity = 0;
    self.itemQuantityString = @"0";
    
    EQREquipContentViewVCntrllr *controller = [[EQREquipContentViewVCntrllr alloc] initWithNibName:@"EQREquipContentViewVCntrllr" bundle:nil];
    
    //retain the view controller
    self.myEquipVCntrllr = controller;
    
    //add to content view
    [self.contentView addSubview:self.myEquipVCntrllr.view];

    //assign iboutlet values AFTER adding to the view otherwise it don't work
    //using the contentViewVCntrllr
    //_______*********  TABS are leading the equip list text. Must start string after them   *******_______
    self.myEquipVCntrllr.titleLabel.text = [titleName substringFromIndex:2];


    //set user enabled
    
    //_________********** when set to YES: this and this alone prevents the collectionView delegate from receiving tap actions
    [self.myEquipVCntrllr.view setUserInteractionEnabled:NO];
    
    [self.myEquipVCntrllr.plusButton setUserInteractionEnabled:YES];
    
    //add target to the plus and minus buttons
    [self.myEquipVCntrllr.plusButton addTarget:self action:@selector(plusHit:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    //create buttons programmatically
    //___plus button
    UIButton* plusButtonFoSho = [UIButton buttonWithType:UIButtonTypeSystem];
    plusButtonFoSho.frame = CGRectMake(100, 0, 46, 32);
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
    
    //_________******* target of button is the self
    [plusButtonFoSho addTarget:self action:@selector(plusHit:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:plusButtonFoSho];
    
    
    //___minus button
    UIButton* minusButtonFoSho = [UIButton buttonWithType:UIButtonTypeSystem];
    minusButtonFoSho.frame = CGRectMake(0, 0, 46, 32);
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
    
    //_________******* target of button is self
    [minusButtonFoSho addTarget:self action:@selector(minusHit:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:minusButtonFoSho];

    //________********** retrieve info from scheduleRequestItem to populate quantity text field.
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    NSArray* arrayOfScheduleEquipJoins = [requestManager retrieveArrayOfEquipJoins];
    
    //_______********** loop through array and find objects that match the equipTitle id???
    //add up count and list in quantity text field
    
    NSMutableArray* arrayOfMatchingItems = [NSMutableArray arrayWithCapacity:1];

    [arrayOfScheduleEquipJoins enumerateObjectsUsingBlock:^(EQRScheduleTracking_EquipmentUnique_Join* obj, NSUInteger idx, BOOL *stop) {
        
//        NSLog(@"inside the arrayOfScheduleEquipJoins with obj equipUniqueItem_foreignKey: %@", [obj equipUniqueItem_foreignKey]);
        
        //_____****** uniqueforeignKey is currently hard coded!!!! ****_____
        if ([[obj equipTitleItem_foreignKey] isEqualToString:titleItemObject.key_id]){
            
            [arrayOfMatchingItems addObject:obj];
        }
    }];
    
    //set temp quantity variable
    if ([arrayOfMatchingItems count] > 0){
        
        self.itemQuantity = [arrayOfMatchingItems count];
        self.itemQuantityString = [NSString stringWithFormat:@"%u", self.itemQuantity];
        
        //set subview textfield value
        self.myEquipVCntrllr.quantityTextField.text = self.itemQuantityString;
        
        //set new subview background color
        self.myEquipVCntrllr.view.backgroundColor = [UIColor colorWithRed:0.7 green:0.9 blue:0.9 alpha:1.0];
    }
    
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
    
    //add addition to scheduleTrackingRequest as a new join object
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    [requestManager addNewRequestEquipJoin:self.thisEquipTitleItem];
    
    //_______pass the touch event up the responder chain...
//    [self.nextResponder touchesBegan:touches withEvent:event];
    
    //highlight the background color
    if (self.itemQuantity > 0){
        
        self.myEquipVCntrllr.view.backgroundColor = [UIColor yellowColor];
        
        //set color after delay
        [self.myEquipVCntrllr.view performSelector:@selector(setBackgroundColor:) withObject:[UIColor colorWithRed:0.7 green:0.9 blue:0.9 alpha:1.0] afterDelay:EQRHighlightTappingTime];
    }
}

-(IBAction)minusHit:(id)sender{
    
    if (self.itemQuantity > 0){
        
        //remove a join object from scheduleTrackingRequest
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        [requestManager removeRequestEquipJoin:self.thisEquipTitleItem];
        
        self.itemQuantity = self.itemQuantity - 1;
    }
    
    //set outlet string value and background color
    if (self.itemQuantity != 0){
        
        self.itemQuantityString = [NSString stringWithFormat:@"%u", self.itemQuantity];
        
    } else {
        
        self.itemQuantityString = @"";
        
        self.myEquipVCntrllr.view.backgroundColor = [UIColor yellowColor];
        
        //set color after delay
        [self.myEquipVCntrllr.view performSelector:@selector(setBackgroundColor:) withObject:[UIColor clearColor] afterDelay:EQRHighlightTappingTime];

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
