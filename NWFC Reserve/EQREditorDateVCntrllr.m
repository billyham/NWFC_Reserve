//
//  EQREditorDateVCntrllr.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 4/1/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREditorDateVCntrllr.h"

@interface EQREditorDateVCntrllr ()

@property (nonatomic, strong) NSDate *pickupDate;
@property (nonatomic, strong) NSDate *returnDate;

@property (strong, nonatomic) IBOutlet UIDatePicker* pickupDateField;
@property (strong, nonatomic) IBOutlet UIDatePicker* returnDateField;

@property (strong, nonatomic) IBOutlet UIButton* showOrHideExtendedButton;
@property (strong, nonatomic) NSString *showExtendedMethod;
@property (strong, nonatomic) id showExtendedTarget;

@property (strong, nonatomic) IBOutlet UIButton* saveButton;
@property (strong, nonatomic) NSString *saveMethod;
@property (strong, nonatomic) id saveTarget;

@property (strong, nonatomic) NSString *pickupMethod;
@property (strong, nonatomic) NSString *returnMethod;
@property (strong, nonatomic) id dateTarget;

@end

@implementation EQREditorDateVCntrllr

#pragma mark - init and view
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self renderDates];
}

#pragma mark - render method
- (void)renderDates {
    self.pickupDateField.date = self.pickupDate;
    self.returnDateField.date = self.returnDate;
    
    if (self.saveMethod){
        SEL saveSelector = NSSelectorFromString(self.saveMethod);
        [self.saveButton addTarget:self.saveTarget action:saveSelector forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.showExtendedMethod) {
        SEL showHideSelector = NSSelectorFromString(self.showExtendedMethod);
        [self.showOrHideExtendedButton addTarget:self.showExtendedTarget action:showHideSelector forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.pickupMethod && self.returnMethod) {
        SEL pickupSelector = NSSelectorFromString(self.pickupMethod);
        SEL returnSelector = NSSelectorFromString(self.returnMethod);
        [self.pickupDateField addTarget:self.dateTarget action:pickupSelector forControlEvents:UIControlEventValueChanged];
        [self.returnDateField addTarget:self.dateTarget action:returnSelector forControlEvents:UIControlEventValueChanged];
    }
}


#pragma mark - public render methods
- (void)setReturnDateAnimated:(NSDate *)date {
    [self.returnDateField setDate:date animated:YES];
}

- (void)setReturnMax:(NSDate *)date {
    self.returnDateField.maximumDate = date;
}

- (void)setReturnMin:(NSDate *)date {
    self.returnDateField.minimumDate = date;
}


#pragma mark - public setter methods
- (void)setPickupDate:(NSDate *)puDate returnDate:(NSDate *)reDate {
    self.pickupDate = puDate;
    self.returnDate = reDate;
    
    [self renderDates];
}

- (void)setShowExtended:(NSString *)method withTarget:(id)target {
    self.showExtendedTarget = target;
    self.showExtendedMethod = method;
    
    [self renderDates];
}


- (void)setSaveSelector:(NSString *)method forTarget:(id)target {
    self.saveTarget = target;
    self.saveMethod = method;
    
    [self renderDates];
}


- (void)setPickupAction:(NSString *)pickupMethod returnAction:(NSString *)returnMethod forTarget:(id)target {
    self.pickupMethod = pickupMethod;
    self.returnMethod = returnMethod;
    self.dateTarget = target;
    
    [self renderDates];
}

#pragma mark - public getter methods
-(NSDate*)retrievePickUpDate{
    return self.pickupDateField.date;
}


-(NSDate*)retrieveReturnDate{
    return self.returnDateField.date;
}


#pragma mark - memory warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
