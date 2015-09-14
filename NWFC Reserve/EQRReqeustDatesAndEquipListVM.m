//
//  EQRReqeustDatesAndEquipListVM.m
//  Gear
//
//  Created by Ray Smith on 9/12/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRReqeustDatesAndEquipListVM.h"
#import "EQRDataStructure.h"
#import "EQREquipItem.h"
#import "EQRMiscJoin.h"

@implementation EQRReqeustDatesAndEquipListVM

+(NSAttributedString *)getSummaryTextWithRequest:(EQRScheduleRequestItem *)requestItem ArrayOfMisc:(NSArray *)arrayOfMisc{
    
    if (!requestItem){
        NSLog(@"EQRRequestDatesAndEquipListVM > initWithReqeust  no valid request item");
        return nil;
    }
    
    if (!arrayOfMisc){
        NSLog(@"EQRRequestDatesAndEquipListVM > initWithReqeust  no valid arrayOfMisc");
        return nil;
    }
    
    NSDateFormatter* pickUpFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [pickUpFormatter setLocale:usLocale];
    //    [pickUpFormatter setDateStyle:NSDateFormatterLongStyle];
    //    [pickUpFormatter setTimeStyle:NSDateFormatterShortStyle];
    [pickUpFormatter setDateFormat:@"EEE, MMM d, yyyy, h:mm aaa"];
    
    //nsattributedstrings
    UIFont* smallFont = [UIFont boldSystemFontOfSize:10];
    UIFont* normalFont = [UIFont systemFontOfSize:12];
    UIFont* boldFont = [UIFont boldSystemFontOfSize:14];
    
    //begin the total attribute string
    NSMutableAttributedString *summaryTotalAtt = [[NSMutableAttributedString alloc] initWithString:@""];
    
    
    
    //_______PICKUP DATE_____
    NSDictionary* arrayAtt6 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* pickupHead = [[NSAttributedString alloc] initWithString:@"\rPick Up: " attributes:arrayAtt6];
    [summaryTotalAtt appendAttributedString:pickupHead];
    
    NSDictionary* arrayAtt7 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* pickupAtt = [[NSAttributedString alloc] initWithString:[pickUpFormatter stringFromDate:requestItem.request_date_begin]  attributes:arrayAtt7];
    [summaryTotalAtt appendAttributedString:pickupAtt];
    
    //______RETURN DATE________
    NSDictionary* arrayAtt8 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* returnHead = [[NSAttributedString alloc] initWithString:@"            Return: " attributes:arrayAtt8];
    [summaryTotalAtt appendAttributedString:returnHead];
    
    NSDictionary* arrayAtt9 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* returnAtt = [[NSAttributedString alloc] initWithString:[pickUpFormatter stringFromDate:requestItem.request_date_end]  attributes:arrayAtt9];
    [summaryTotalAtt appendAttributedString:returnAtt];
    
    //________EQUIP LIST________
    
    NSDictionary* arrayAtt10 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* equipHead = [[NSAttributedString alloc] initWithString:@"\r\r\rEquipment Items:\r" attributes:arrayAtt10];
    [summaryTotalAtt appendAttributedString:equipHead];
    
    // 2. first, cycle through scheduleTracking_equip_joins
    //add structure to the array
    NSArray* arrayOfEquipmentJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:requestItem.arrayOfEquipmentJoins];
    
    //  3. cycle through subarrays and decompose scheduleTracking_EquipmentUniue_Joins to dictionaries with EquipTitleItems and quantities
    NSMutableArray* topArrayOfDecomposedEquipTitlesAndJoins = [NSMutableArray arrayWithCapacity:1];
    for (NSArray* arrayFun in arrayOfEquipmentJoinsWithStructure){
        
        NSArray* subArrayOfDecomposedEquipTitlesAndJoins = [EQRDataStructure decomposeJoinsToEquipTitlesWithQuantities:arrayFun];
        
        [topArrayOfDecomposedEquipTitlesAndJoins addObject:subArrayOfDecomposedEquipTitlesAndJoins];
    }
    
    
    for (NSArray* innerArray in topArrayOfDecomposedEquipTitlesAndJoins){
        
        //print equipment category
        NSDictionary* arrayAtt11 = [NSDictionary dictionaryWithObject:smallFont forKey:NSFontAttributeName];
        NSAttributedString* thisHereAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\r   %@\r", [(EQREquipItem*) [(NSDictionary*)[innerArray objectAtIndex:0] objectForKey:@"equipTitleObject" ] schedule_grouping]] attributes:arrayAtt11];
        
        [summaryTotalAtt appendAttributedString:thisHereAttString];
        
        for (NSDictionary* innerSubDictionary in innerArray){
            
            NSString* quantityFollowedByShortname = [NSString stringWithFormat:@"%@ x %@",
                                                     [innerSubDictionary objectForKey:@"quantity"],
                                                     [(EQREquipItem*)[innerSubDictionary objectForKey:@"equipTitleObject"] shortname]
                                                     ];
            
            NSDictionary* arrayAtt11 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
            NSAttributedString* thisHereAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r", quantityFollowedByShortname] attributes:arrayAtt11];
            
            [summaryTotalAtt appendAttributedString:thisHereAttString];
        }
    }
    
    
    //if miscJoins exist...
    if ([arrayOfMisc count] > 0){
        
        //print miscellaneous section
        NSDictionary* arrayAtt13 = @{NSFontAttributeName:smallFont};
        NSAttributedString *thisHereString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\r   %@\r",@"Miscellaneous"] attributes:arrayAtt13];
        [summaryTotalAtt appendAttributedString:thisHereString];
        
        for (EQRMiscJoin* miscJoin in arrayOfMisc){
            
            NSDictionary* arrayAtt14 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
            NSAttributedString* thisHereAttStringAgain = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r", miscJoin.name] attributes:arrayAtt14];
            
            [summaryTotalAtt appendAttributedString:thisHereAttStringAgain];
        }
    }
    
    //_______Notes___________
    if (requestItem.notes){
        if (![requestItem.notes isEqualToString:@""]){
            
            NSDictionary* arrayAtt15 = @{NSFontAttributeName:smallFont};
            NSAttributedString* thisHereString = [[NSAttributedString alloc] initWithString:@"\r   Notes\r" attributes:arrayAtt15];
            [summaryTotalAtt appendAttributedString:thisHereString];
            
            NSDictionary* arrayAtt16 = @{NSFontAttributeName:normalFont};
            NSAttributedString* thisHereString2 = [[NSAttributedString alloc] initWithString:requestItem.notes attributes:arrayAtt16];
            [summaryTotalAtt appendAttributedString:thisHereString2];
        }
    }
    
    return [[NSAttributedString alloc] initWithAttributedString:summaryTotalAtt];
}




//-(instancetype)initWithRequest:(EQRScheduleRequestItem *)requestItem ArrayOfEquip:(NSArray *)arrayOfEquip ArrayOfMisc:(NSArray *)arrayOfMisc{
//
//    if (!requestItem){
//        NSLog(@"eQRRequestDatesAndEquipListVM > initWithReqeust  no valid request item");
//        return nil;
//    }
//    
//    if (!arrayOfEquip){
//        NSLog(@"eQRRequestDatesAndEquipListVM > initWithReqeust  no valid arrayOfEquip");
//        return nil;
//    }
//    
//    if (!arrayOfMisc){
//        NSLog(@"eQRRequestDatesAndEquipListVM > initWithReqeust  no valid arrayOfMisc");
//        return nil;
//    }
//
//
//    NSDateFormatter* pickUpFormatter = [[NSDateFormatter alloc] init];
//    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//    [pickUpFormatter setLocale:usLocale];
//    //    [pickUpFormatter setDateStyle:NSDateFormatterLongStyle];
//    //    [pickUpFormatter setTimeStyle:NSDateFormatterShortStyle];
//    [pickUpFormatter setDateFormat:@"EEE, MMM d, yyyy, h:mm aaa"];
//    
//    //nsattributedstrings
//    UIFont* smallFont = [UIFont boldSystemFontOfSize:10];
//    UIFont* normalFont = [UIFont systemFontOfSize:12];
//    UIFont* boldFont = [UIFont boldSystemFontOfSize:14];
//    
//    //begin the total attribute string
//    NSMutableAttributedString *summaryTotalAtt = [[NSMutableAttributedString alloc] initWithString:@""];
//    
//
//    
//    //_______PICKUP DATE_____
//    NSDictionary* arrayAtt6 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
//    NSAttributedString* pickupHead = [[NSAttributedString alloc] initWithString:@"\rPick Up: " attributes:arrayAtt6];
//    [summaryTotalAtt appendAttributedString:pickupHead];
//    
//    NSDictionary* arrayAtt7 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
//    NSAttributedString* pickupAtt = [[NSAttributedString alloc] initWithString:[pickUpFormatter stringFromDate:requestItem.request_date_begin]  attributes:arrayAtt7];
//    [summaryTotalAtt appendAttributedString:pickupAtt];
//    
//    //______RETURN DATE________
//    NSDictionary* arrayAtt8 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
//    NSAttributedString* returnHead = [[NSAttributedString alloc] initWithString:@"            Return: " attributes:arrayAtt8];
//    [summaryTotalAtt appendAttributedString:returnHead];
//    
//    NSDictionary* arrayAtt9 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
//    NSAttributedString* returnAtt = [[NSAttributedString alloc] initWithString:[pickUpFormatter stringFromDate:requestItem.request_date_end]  attributes:arrayAtt9];
//    [summaryTotalAtt appendAttributedString:returnAtt];
//    
//    //________EQUIP LIST________
//    
//    NSDictionary* arrayAtt10 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
//    NSAttributedString* equipHead = [[NSAttributedString alloc] initWithString:@"\r\r\rEquipment Items:\r" attributes:arrayAtt10];
//    [summaryTotalAtt appendAttributedString:equipHead];
//    
//    // 2. first, cycle through scheduleTracking_equip_joins
//    //add structure to the array
//    NSArray* arrayOfEquipmentJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:requestItem.arrayOfEquipmentJoins];
//    
//    //  3. cycle through subarrays and decompose scheduleTracking_EquipmentUniue_Joins to dictionaries with EquipTitleItems and quantities
//    NSMutableArray* topArrayOfDecomposedEquipTitlesAndJoins = [NSMutableArray arrayWithCapacity:1];
//    for (NSArray* arrayFun in arrayOfEquipmentJoinsWithStructure){
//        
//        NSArray* subArrayOfDecomposedEquipTitlesAndJoins = [EQRDataStructure decomposeJoinsToEquipTitlesWithQuantities:arrayFun];
//        
//        [topArrayOfDecomposedEquipTitlesAndJoins addObject:subArrayOfDecomposedEquipTitlesAndJoins];
//    }
//    
//    
//    for (NSArray* innerArray in topArrayOfDecomposedEquipTitlesAndJoins){
//        
//        //print equipment category
//        NSDictionary* arrayAtt11 = [NSDictionary dictionaryWithObject:smallFont forKey:NSFontAttributeName];
//        NSAttributedString* thisHereAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\r   %@\r", [(EQREquipItem*) [(NSDictionary*)[innerArray objectAtIndex:0] objectForKey:@"equipTitleObject" ] schedule_grouping]] attributes:arrayAtt11];
//        
//        [summaryTotalAtt appendAttributedString:thisHereAttString];
//        
//        for (NSDictionary* innerSubDictionary in innerArray){
//            
//            NSString* quantityFollowedByShortname = [NSString stringWithFormat:@"%@ x %@",
//                                                     [innerSubDictionary objectForKey:@"quantity"],
//                                                     [(EQREquipItem*)[innerSubDictionary objectForKey:@"equipTitleObject"] shortname]
//                                                     ];
//            
//            NSDictionary* arrayAtt11 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
//            NSAttributedString* thisHereAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r", quantityFollowedByShortname] attributes:arrayAtt11];
//            
//            [summaryTotalAtt appendAttributedString:thisHereAttString];
//        }
//    }
//    
//    //if miscJoins exist...
//    if ([arrayOfMisc count] > 0){
//        
//        //print miscellaneous section
//        NSDictionary* arrayAtt13 = @{NSFontAttributeName:smallFont};
//        NSAttributedString *thisHereString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\r   %@\r",@"Miscellaneous"] attributes:arrayAtt13];
//        [summaryTotalAtt appendAttributedString:thisHereString];
//        
//        for (EQRMiscJoin* miscJoin in arrayOfMisc){
//            
//            NSDictionary* arrayAtt14 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
//            NSAttributedString* thisHereAttStringAgain = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r", miscJoin.name] attributes:arrayAtt14];
//            
//            [summaryTotalAtt appendAttributedString:thisHereAttStringAgain];
//        }
//    }
//    
//    //_______Notes___________
//    if (requestItem.notes){
//        if (![requestItem.notes isEqualToString:@""]){
//            
//            NSDictionary* arrayAtt15 = @{NSFontAttributeName:smallFont};
//            NSAttributedString* thisHereString = [[NSAttributedString alloc] initWithString:@"\r   Notes\r" attributes:arrayAtt15];
//            [summaryTotalAtt appendAttributedString:thisHereString];
//            
//            NSDictionary* arrayAtt16 = @{NSFontAttributeName:normalFont};
//            NSAttributedString* thisHereString2 = [[NSAttributedString alloc] initWithString:requestItem.notes attributes:arrayAtt16];
//            [summaryTotalAtt appendAttributedString:thisHereString2];
//        }
//    }
//    
//    self.summaryString = [[NSAttributedString alloc] initWithAttributedString:summaryTotalAtt];
//    
//    return [super init];
//}

@end
