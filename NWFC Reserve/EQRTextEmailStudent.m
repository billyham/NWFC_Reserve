//
//  EQRTextEmailStudent.m
//  Gear
//
//  Created by Ray Smith on 10/29/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRTextEmailStudent.h"
#import "EQREquipItem.h"
#import "EQRWebData.h"
#import "EQRMiscJoin.h"

@interface EQRTextEmailStudent()<EQRWebDataDelegate>

@property (strong, nonatomic) NSString* dateRange;
@property (strong, nonatomic) NSString* pickupDate;
@property (strong, nonatomic) NSString* pickupTime;
@property (strong, nonatomic) NSString* returnDate;
@property (strong, nonatomic) NSString* returnTime;

@property (strong, nonatomic) NSMutableAttributedString* finalText;

@property (strong, nonatomic) NSMutableArray *miscJoins;

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


-(void)composeEmailText:(CompletionBlockWithMutableAttributedString)cb{
    
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
        
        [self.finalText appendAttributedString:
         [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ x %@\n", [myDic objectForKey:@"quantity"], [(EQREquipItem*)[myDic objectForKey:@"equipTitleObject"] name]] attributes:normalDic]];
    }
    
    //______Misc Join List_______
    //gather any misc joins
    NSArray* alphaArray = @[@"scheduleTracking_foreignKey", self.request_keyID];
    NSArray* omegaArray = @[alphaArray];
    
    if (!self.miscJoins){
        self.miscJoins = [NSMutableArray arrayWithCapacity:1];
    }
    [self.miscJoins removeAllObjects];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    
    SEL selector = @selector(addMiscItemJoin:);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
       [webData queryWithAsync:@"EQGetMiscJoinsWithScheduleTrackingKey.php"
                    parameters:omegaArray class:@"EQRMiscJoin"
                      selector:selector
                    completion:^(BOOL isLoadingFlagUp) {
           
            //if miscJoins exist...
            if ([self.miscJoins count] > 0){
                
                //print miscellaneous section
                NSAttributedString *thisHereString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n",@"Additional items:"] attributes:normalDic];
                [self.finalText appendAttributedString:thisHereString];
                
                for (EQRMiscJoin* miscJoin in self.miscJoins){
                    
                    NSAttributedString* thisHereAttStringAgain = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", miscJoin.name] attributes:normalDic];
                    
                    [self.finalText appendAttributedString:thisHereAttStringAgain];
                }
            }
            
            //_______Notes___________
            if (self.notes){
                if (![self.notes isEqualToString:@""]){
                    
                    NSAttributedString* thisHereString = [[NSAttributedString alloc] initWithString:@"\nNotes:\n" attributes:normalDic];
                    [self.finalText appendAttributedString:thisHereString];
                    
                    NSAttributedString* thisHereString2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", self.notes] attributes:normalDic];
                    [self.finalText appendAttributedString:thisHereString2];
                }
            }
            
            [self.finalText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nPlease feel free to call or email if you need to make any changes or have any questions or concerns.\n\n" attributes:normalDic]];
            
            [self.finalText appendAttributedString:[[NSAttributedString alloc] initWithString:@"Thanks,\n" attributes:normalDic]];
            
            [self.finalText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", self.staffFirstName] attributes:normalDic]];
            
            //_______Email Signature_________
            if (self.emailSignature){
                if (![self.emailSignature isEqualToString:@""]){
                    
                    NSAttributedString *thisHereString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", self.emailSignature] attributes:normalDic];
                    [self.finalText appendAttributedString:thisHereString];
                }
            }
            
            cb(self.finalText);
       }];
    });
}

#pragma mark - EQRWebData Delegate methods

-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    
    if (![self respondsToSelector:action]){
        NSLog(@"EQRTextEmailStudent > cannot perform selector");
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:action withObject:currentThing];
#pragma clang diagnostic pop
}

-(void)addMiscItemJoin:(id)currentThing{
    if(!currentThing){
        return;
    }
    [self.miscJoins addObject:currentThing];
}


@end
