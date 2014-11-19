//
//  EQREditorRenterVCntrllrViewController.h
//  NWFC Reserve
//
//  Created by Ray Smith on 4/17/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EQRRenterTypeDelegate;

@interface EQREditorRenterVCntrllr : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    
    __weak id <EQRRenterTypeDelegate> delegate;
}

@property (weak, nonatomic) id <EQRRenterTypeDelegate> delegate;


//@property (nonatomic, strong) IBOutlet UIPickerView* renterTypePicker;
//@property (strong, nonatomic) IBOutlet UIButton* saveButton;


-(void)initialSetupWithRenterTypeString:(NSString*)presetRenter;
-(id)retrieveRenterType;

@end


@protocol EQRRenterTypeDelegate <NSObject>

-(void)initiateRetrieveRenterItem;

@end