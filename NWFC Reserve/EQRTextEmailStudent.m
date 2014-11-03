//
//  EQRTextEmailStudent.m
//  Gear
//
//  Created by Ray Smith on 10/29/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRTextEmailStudent.h"
#import "EQREquipItem.h"

@interface EQRTextEmailStudent()

@property (strong, nonatomic) NSString* dateRange;
@property (strong, nonatomic) NSString* pickupDate;
@property (strong, nonatomic) NSString* pickupTime;
@property (strong, nonatomic) NSString* returnDate;
@property (strong, nonatomic) NSString* returnTime;

@property (strong, nonatomic) NSMutableAttributedString* finalText;

@end


@implementation EQRTextEmailStudent


-(NSString*)composeEmailSubjectLine{
    
    //convert dates and times to strings
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"MMM d";
    
    //____________!!!!!  this is duplicating work    !!!!!_______
    self.pickupDate = [dateFormatter stringFromDate:self.pickupDateAsDate];
    self.returnDate = [dateFormatter stringFromDate:self.returnDateAsDate];
    
    //assign to local ivar
    self.dateRange = [NSString stringWithFormat:@"%@ - %@", self.pickupDate, self.returnDate];
    
    return [NSString stringWithFormat:@"Equipment Confirmation %@", self.dateRange];
}


-(NSMutableAttributedString*)composeEmailText{
    
    //set attributed string properties
    //_______  The bold font doesn't appear in the email  (sad face) _______
    //_______  Making this an attributed string was just a waste of time (more sad face) ________
    UIFont* normalFont = [UIFont systemFontOfSize:10];
    UIFont* boldFont = [UIFont boldSystemFontOfSize:10];
    NSDictionary* normalDic = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSDictionary* boldDic = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    
    //begin the total attribute string
    self.finalText = [[NSMutableAttributedString alloc] initWithString:@"" attributes:normalDic];
    
    
    //convert dates and times to strings
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"EEEE, MMM d";
    
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    timeFormatter.dateFormat = @"h:mm a";
    
    //assign to private ivars
    self.pickupDate = [dateFormatter stringFromDate:self.pickupDateAsDate];
    self.pickupTime = [timeFormatter stringFromDate:self.pickupTimeAsDate];
    self.returnDate = [dateFormatter stringFromDate:self.returnDateAsDate];
    self.returnTime = [timeFormatter stringFromDate:self.returnTimeAsDate];
    
    [self.finalText appendAttributedString: [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Hello %@,\n\n", self.renterFirstName] attributes:normalDic]];
    
    [self.finalText appendAttributedString:[[NSAttributedString alloc] initWithString:@"This is a confirmation for your equipment rental. Equipment is scheduled to be picked up on " attributes:normalDic]];
    
    [self.finalText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ at %@", self.pickupDate, self.pickupTime] attributes:boldDic]];
    
    [self.finalText appendAttributedString:[[NSAttributedString alloc] initWithString:@" and returned on " attributes:normalDic]];
    
    [self.finalText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ at %@.\n\n", self.returnDate, self.returnTime] attributes:boldDic]];
    
    [self.finalText appendAttributedString:[[NSAttributedString alloc] initWithString:@"The following gear is reserved for you:\n\n" attributes:normalDic]];
    
    
    for (NSDictionary* myDic in self.arrayOfEquipTitlesAndQtys){
        
        [self.finalText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ x %@\n",
                                                                                           [myDic objectForKey:@"quantity"],
                                                                                           [(EQREquipItem*)[myDic objectForKey:@"equipTitleObject"] name]
                                                                                           ] attributes:normalDic]];
    }
    
    
    [self.finalText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nPlease feel free to call or email if you need to make any changes or have any questions or concerns.\n\n" attributes:normalDic]];
    
    [self.finalText appendAttributedString:[[NSAttributedString alloc] initWithString:@"Thanks,\n" attributes:normalDic]];
    
    [self.finalText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", self.staffFirstName] attributes:normalDic]];
    
//    [self.finalText appendString:[NSString stringWithFormat:@"%@", self.emailSignature]];

    
    return self.finalText;
}


@end