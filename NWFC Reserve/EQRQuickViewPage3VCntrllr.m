//
//  EQRQuickViewPage3VCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 8/11/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRQuickViewPage3VCntrllr.h"
#import "EQRWebData.h"

@interface EQRQuickViewPage3VCntrllr ()

@property (strong, nonatomic) EQRScheduleRequestItem* myScheduleRequest;

@end

@implementation EQRQuickViewPage3VCntrllr

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
    // Do any additional setup after loading the view from its nib.
}

-(void)initialSetupWithScheduleItem:(EQRScheduleRequestItem *)scheduleRequest{
    
    
    
}


-(IBAction)duplicate:(id)sender{
    
    
    //____show request editor and launch edit date popover?
     
    
    //webdata query
    
    //with myDeviceName
    //EQRegisterScheduleRequest
    
    //with key_id, contact_foreignKey, classSection_foreignKey, classTitle_foreignKey, request_date_begin, request_date_end, request_time_begin, request_time_end, contact_name, renter_type, time_of_request
    //EQSetNewScheduleRequest
    
    //loop with scheduleTracking_foreignKey, equipUniqueItem_foreignKey, equipTitleItem_foreignKey
    //EQSetNewScheduleEquipJoin
    
}


-(IBAction)split:(id)sender{
    
    
}


-(IBAction)print:(id)sender{
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
