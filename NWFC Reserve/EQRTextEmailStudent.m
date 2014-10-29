//
//  EQRTextEmailStudent.m
//  Gear
//
//  Created by Ray Smith on 10/29/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRTextEmailStudent.h"

@implementation EQRTextEmailStudent


-(NSString*)composeEmailText{
    
    self.finalText = [NSMutableString stringWithFormat:@"Hello %@,\r\r", self.renterFirstName];
    
    [self.finalText appendString:@"This is a confirmation for your equipment rental. Equipment is scheduled to be picked up on "];
    
    [self.finalText appendString:[NSString stringWithFormat:@"%@ at %@", self.pickupDate, self.pickupTime]];
    
    [self.finalText appendString:@" and returned on "];
    
    [self.finalText appendString:[NSString stringWithFormat:@"%@ at %@.\r\r", self.returnDate, self.returnTime]];
    
    [self.finalText appendString:@"The following gear is reserved for you:\r\r"];
    
    
    
    
    
    [self.finalText appendString:@"Please feel free to call or email if you need to make any changes or have any questions or concerns.\r\r"];
    
    [self.finalText appendString:@"Thanks,\r"];
    
    [self.finalText appendString:[NSString stringWithFormat:@"%@\r\r", self.staffFirstName]];
    
    [self.finalText appendString:[NSString stringWithFormat:@"%@", self.emailSignature]];

    
    return [NSString stringWithString:self.finalText];
}


@end
