//
//  EQREditorExtendedDateVC.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 8/15/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREditorExtendedDateVC.h"

@interface EQREditorExtendedDateVC ()

@end

@implementation EQREditorExtendedDateVC

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


-(NSDate*)retrievePickUpDate{
    
//    NSLog(@"inside extended date retrievePickUpDate method");
    
    //combine day and time pickers
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDateFormatter* dayFormatter = [[NSDateFormatter alloc] init];
    dayFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dayFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    
    NSString* dayString = [dayFormatter stringFromDate:self.pickupDateField.date];
    NSString* timeString = [timeFormatter stringFromDate:self.pickupTimeField.date];
    NSString* dateString = [NSString stringWithFormat:@"%@ %@", dayString, timeString];
    
    NSDate* newDate = [dateFormatter dateFromString:dateString];
    return newDate;
}


-(NSDate*)retrieveReturnDate{
    
    //combine day and time pickers
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDateFormatter* dayFormatter = [[NSDateFormatter alloc] init];
    dayFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dayFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    
    NSString* dayString = [dayFormatter stringFromDate:self.returnDateField.date];
    NSString* timeString = [timeFormatter stringFromDate:self.returnTimeField.date];
    NSString* dateString = [NSString stringWithFormat:@"%@ %@", dayString, timeString];
    
    NSDate* newDate = [dateFormatter dateFromString:dateString];
    return newDate;
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
