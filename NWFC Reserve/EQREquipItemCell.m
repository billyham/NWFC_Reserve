//
//  EQEquipItemCell.m
//  NWFC Reserve
//
//  Created by Ray Smith on 12/25/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import "EQREquipItemCell.h"
#import "EQREquipContentViewVCntrllr.h"
//#import "EQRScheduleRequestManager.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRWebData.h"
#import "EQRGlobals.h"
#import "EQRColors.h"


@interface EQREquipItemCell ()

@property (strong, nonatomic) EQREquipItem* thisEquipTitleItem;
@property (strong, nonatomic) EQREquipContentViewVCntrllr* myEquipVCntrllr;
@property (strong, nonatomic) UIButton* myMinusButton;
@property (strong, nonatomic) UIButton* myPlusButton;
@property BOOL quantityLimitFlag;
@property BOOL unavailableDimFlag;


@end

@implementation EQREquipItemCell

@synthesize delegate;


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
    
    EQRColors* myColors = [EQRColors sharedInstance];
    
    //assign ivar
    self.thisEquipTitleItem = titleItemObject;
    
    //initial ivar values
    self.itemQuantity = 0;
    self.itemQuantityString = @"0";
    self.quantityLimitFlag = NO;
    
    //_______*******  programatically set the size (to accommodate the smaller popvover view ******_______
    
    
    
    EQREquipContentViewVCntrllr *controller = [[EQREquipContentViewVCntrllr alloc] initWithNibName:@"EQREquipContentViewVCntrllr" bundle:nil];
    
    //retain the view controller
    self.myEquipVCntrllr = controller;
    
    //add to content view
    [self.contentView addSubview:self.myEquipVCntrllr.view];

    //assign iboutlet values AFTER adding to the view otherwise it don't work
    //using the contentViewVCntrllr
    //_______*********  TABS are leading the equip list text. Must start string after them   *******_______
    self.myEquipVCntrllr.titleLabel.text = titleName;


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
    self.myPlusButton = plusButtonFoSho;
    
    [self.contentView addSubview:self.myPlusButton];
    
    //hide the button for now
    self.myPlusButton.hidden = YES;
    
    
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
    
    self.myMinusButton = minusButtonFoSho;
    [self.contentView addSubview:self.myMinusButton];
    
    //hide the button for now
    self.myMinusButton.hidden = YES;

    
    //hold onto the available quantity
    int quantityAvailableTemp = 0;
    
    
//    NSLog(@"this is the equip cell asking for the available quantity");
    
    //test if there exists any uniqueItems for this titleItem, gray out and make unavailable if not
    for (NSArray* testArray in [self.delegate retrieveArrayOfEquipTitlesWithCountOfUniqueItems]){
        
        if ([[testArray objectAtIndex:0] isEqualToString:self.thisEquipTitleItem.key_id]){
            
            //found a matching equipTitleItem with an available quantity of 0
            if ([[testArray objectAtIndex:1] isEqualToNumber:[NSNumber numberWithInt:0]]){
                
                self.myEquipVCntrllr.titleLabel.textColor = [UIColor lightGrayColor];
                
                [self setUserInteractionEnabled:NO];
                
                //stop initializing
                return;
                
            } else {
                
                quantityAvailableTemp = (int)[(NSNumber*)[testArray objectAtIndex:1]integerValue];
                
            }
        }
    }
    
    
    //________********** retrieve info from delegate requestManager to populate quantity text field.
    NSArray* arrayOfScheduleEquipJoins = [self.delegate retrieveArrayOfEquipJoins];
    
    //_______********** loop through array and find objects that match the equipTitle id???
    //add up count and list in quantity text field
    
    NSMutableArray* arrayOfMatchingItems = [NSMutableArray arrayWithCapacity:1];

    [arrayOfScheduleEquipJoins enumerateObjectsUsingBlock:^(EQRScheduleTracking_EquipmentUnique_Join* obj, NSUInteger idx, BOOL *stop) {
        
        if ([[obj equipTitleItem_foreignKey] isEqualToString:titleItemObject.key_id]){
            
            [arrayOfMatchingItems addObject:obj];
        }
    }];
    
    //identify that the quantity limit has been reached
    if ([arrayOfMatchingItems count] >= quantityAvailableTemp){
        
        self.quantityLimitFlag = YES;
    }
    
    //set temp quantity variable
    if ([arrayOfMatchingItems count] > 0){
        
        self.itemQuantity = (int)[arrayOfMatchingItems count];
        self.itemQuantityString = [NSString stringWithFormat:@"%u", self.itemQuantity];
        
        //set subview textfield value
        self.myEquipVCntrllr.quantityTextField.text = self.itemQuantityString;
        
        //set new subview background color
        self.myEquipVCntrllr.view.backgroundColor = [myColors.colorDic objectForKey:EQRColorSelectionBlue];
        
        //reveal plus minus buttons
        //_____BUT ONLY THE PLUS BUTTON IF THERE IS STILL AN AVAILABLE QUANTITY
        if (!self.quantityLimitFlag){
            
            self.myPlusButton.hidden = NO;
        }
        self.myMinusButton.hidden = NO;
    }
    
}


-(IBAction)plusHit:(id)sender{
    
    EQRColors* myColors = [EQRColors sharedInstance];
    
    self.itemQuantity = self.itemQuantity + 1;
    
    //set outlet string value
    if (self.itemQuantity != 0){
        
        self.itemQuantityString = [NSString stringWithFormat:@"%u", self.itemQuantity];
        
        self.myMinusButton.hidden = NO;
        self.myPlusButton.hidden = NO;
        
    } else {
        
        self.itemQuantityString = @"";
    }
    
    //set subview textfield value
    self.myEquipVCntrllr.quantityTextField.text = self.itemQuantityString;
    
//    NSLog(@"plus hit test in EquipItemCell with total: %u", self.itemQuantity);
    
    //add addition to scheduleTrackingRequest as a new join object
    [self.delegate addNewRequestEquipJoin:self.thisEquipTitleItem];
    
    //_______pass the touch event up the responder chain...
//    [self.nextResponder touchesBegan:touches withEvent:event];
    
    //highlight the background color
    if (self.itemQuantity > 0){
        
        self.myEquipVCntrllr.view.backgroundColor = [myColors.colorDic objectForKey:EQRColorSelectionYellow];
        
        //set color after delay
        [self.myEquipVCntrllr.view performSelector:@selector(setBackgroundColor:) withObject:[myColors.colorDic objectForKey:EQRColorSelectionBlue] afterDelay:EQRHighlightTappingTime];
    }
    
    //______******  test if we have hit the total count of Unique items for this title item
    //gray out PLUS sign if so
    for (NSMutableArray* quantityArray in [self.delegate retrieveArrayOfEquipTitlesWithCountOfUniqueItems]){
        
        if ([self.thisEquipTitleItem.key_id isEqualToString:[quantityArray objectAtIndex:0]]){
            //found a matching titleItem key
            
            if (self.itemQuantity >= [[quantityArray objectAtIndex:1] intValue]){
                
                self.myPlusButton.hidden = YES;
                
                //raise the flag
                self.quantityLimitFlag = YES;
            }
        }
    }
    
}

-(IBAction)minusHit:(id)sender{
    
    EQRColors* myColors = [EQRColors sharedInstance];
    
    if (self.itemQuantity > 0){
        
        //remove a join object from scheduleTrackingRequest
        [self.delegate removeRequestEquipJoin:self.thisEquipTitleItem];
        
        self.itemQuantity = self.itemQuantity - 1;
        
        self.myEquipVCntrllr.view.backgroundColor = [myColors.colorDic objectForKey:EQRColorSelectionYellow];
        
        //set color after delay
        [self.myEquipVCntrllr.view performSelector:@selector(setBackgroundColor:) withObject:[myColors.colorDic objectForKey:EQRColorSelectionBlue] afterDelay:EQRHighlightTappingTime];
        
        //____***** reactivate plus button if one is in effect
        if (self.quantityLimitFlag){
            
            self.myPlusButton.hidden = NO;
            
            //lower the flag
            self.quantityLimitFlag = NO;
        }
        
    }
    
    //set outlet string value and background color
    if (self.itemQuantity != 0){
        
        self.itemQuantityString = [NSString stringWithFormat:@"%u", self.itemQuantity];
        
    } else {
        
        self.itemQuantityString = @"";
        
        self.myEquipVCntrllr.view.backgroundColor = [myColors.colorDic objectForKey:EQRColorSelectionYellow];
        
        //set color after delay
        [self.myEquipVCntrllr.view performSelector:@selector(setBackgroundColor:) withObject:[UIColor clearColor] afterDelay:EQRHighlightTappingTime];
        
        //disappear plus and minus buttons
        self.myMinusButton.hidden = YES;
        self.myPlusButton.hidden = YES;
        

    }
    
    //set subview textfield value
    self.myEquipVCntrllr.quantityTextField.text = self.itemQuantityString;
    
//    NSLog(@"minus hit test in EquipoItemCell with total: %u", self.itemQuantity);
    
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
