//
//  EQREquipSummaryVCntrllr.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 1/31/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREquipSummaryVCntrllr.h"
#import "EQRScheduleRequestManager.h"
#import "EQRScheduleRequestItem.h"
#import "EQRContactNameItem.h"


@interface EQREquipSummaryVCntrllr ()

@end

@implementation EQREquipSummaryVCntrllr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //load the request to populate the ivars
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];

//    NSString* contactKeyID = requestManager.request.contact_foreignKey;
    EQRContactNameItem* contactItem = requestManager.request.contactNameItem;
    self.rentorName.text = [contactItem.first_and_last substringFromIndex:2];
    self.rentorEmail.text = [contactItem.email substringFromIndex:2];
    self.rentorPhone.text = [contactItem.phone substringFromIndex:2];
    
    NSDateFormatter* pickUpFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [pickUpFormatter setLocale:usLocale];
    [pickUpFormatter setDateStyle:NSDateFormatterLongStyle];
    self.rentorPickupDateLabel.text = [pickUpFormatter stringFromDate:requestManager.request.request_date_begin];
    self.rentorReturnDateLabel.text = [pickUpFormatter stringFromDate:requestManager.request.request_date_end];
    
}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
