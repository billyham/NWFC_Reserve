//
//  EQRWebData.m
//  NWFC Reserve
//
//  Created by Ray Smith on 11/12/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import "EQRWebData.h"
#import "EQRGlobals.h"
#import "EQREquipItem.h"
#import "EQRContactNameItem.h"
#import "EQRClassItem.h"
#import "EQRClassRegistrationItem.h"
#import "EQRClassCatalog_EquipTitleItem_Join.h"
#import "EQREquipUniqueItem.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRScheduleRequestItem.h"
#import "EQRModeManager.h"
#import "EQRTextElement.h"
#import "EQRCloudData.h"
#import "EQRCoreData.h"
#import "EQRTransaction.h"
#import "EQRXMLParserHelper.h"

@interface EQRWebData ()

@property (strong, nonatomic) NSSet *validElements;
@property (strong, nonatomic) NSSet *validStandardElements;

@property (strong, nonatomic) NSMutableArray* muteArray;
@property (strong, nonatomic) NSXMLParser* xmlParser;

@property (strong, nonatomic) NSString* currentProperty;
@property (strong, nonatomic) NSMutableString* currentValue;

@property (strong, nonatomic) NSString* variableClassString;
@property (strong, nonatomic) NSDate* variableClassDate;
@property (strong, nonatomic) NSObject* currentThing;
@property (strong, nonatomic) NSObject* currentThingAlternante;
@property (strong, nonatomic) EQREquipItem* currentEquip;
@property (strong, nonatomic) EQRContactNameItem* currentContactName;
@property (strong, nonatomic) EQRClassRegistrationItem* currentClassRegistration;

@property (strong, nonatomic) NSArray* alphaNumericaArray;
@property int returnClassInt;
@property BOOL abortXMLParsingFlag;
@property BOOL XMLParsingIsCompleteFlag;
@property BOOL completionBlockSignalFlag;

@property SEL aSyncSelector;


@end


const int intEQRScheduleRequestItem = 1;
const int intEQREquipItem = 2;
const int intEQRContactNameItem = 3;
const int intEQRClassItem = 4;
const int intEQRClassRegistrationItem = 5;
const int intEQRClassCatalog_EquipTitleItem_Join = 6;
const int intEQRScheduleTracking_EquipmentUnique_Join = 7;
const int intEQREquipUniqueItem = 8;
const int intEQRMiscJoin = 9;
const int intEQRTextElement = 10;
const int intEQRTransaction = 11;
const int intEQREquipCategory = 12;


@implementation EQRWebData

@synthesize delegateDataFeed;


#pragma mark - class methods

+(EQRWebData*)sharedInstance{
    
    NSString *useCloudKit = [[[NSUserDefaults standardUserDefaults] objectForKey:@"useCloudKit"] objectForKey:@"useCloudKit"];
    NSString *useCoreData = [[[NSUserDefaults standardUserDefaults] objectForKey:@"useCoreData"] objectForKey:@"useCoreData"];
    
    NSSet *validStandardElements = [EQRXMLParserHelper generateStandardElements];
    NSSet *validElements = [EQRXMLParserHelper generateValidElementsFromSets:@[validStandardElements]];
    
    if ([useCloudKit isEqualToString:@"yes"]){
        
        EQRCloudData *myInstance = [[EQRCloudData alloc] init];
        myInstance.validElements = validElements;
        myInstance.validStandardElements = validStandardElements;
        return myInstance;
        
    }else if ([useCoreData isEqualToString:@"yes"]){
        
        EQRCoreData *myInstance = [[EQRCoreData alloc] init];
        myInstance.validElements = validElements;
        myInstance.validStandardElements = validStandardElements;
        return myInstance;
        
    }else{
    
        EQRWebData* myInstance = [[EQRWebData alloc] init];
        myInstance.validElements = validElements;
        myInstance.validStandardElements = validStandardElements;
        return myInstance;
    }
}

#pragma mark - efficiency methods

-(void)assignIntToClassString:(NSString*)classString{
    
    if ([classString isEqualToString:@"EQRScheduleRequestItem"]){
        self.returnClassInt = intEQRScheduleRequestItem;
        return;
    }
    
    if ([classString isEqualToString:@"EQREquipItem"]){
        self.returnClassInt = intEQREquipItem;
        return;
    }
    
    if ([classString isEqualToString:@"EQRContactNameItem"]){
        self.returnClassInt = intEQRContactNameItem;
        return;
    }
    
    if ([classString isEqualToString:@"EQRClassItem"]){
        self.returnClassInt = intEQRClassItem;
        return;
    }
    
    if ([classString isEqualToString:@"EQRClassRegistrationItem"]){
        self.returnClassInt = intEQRClassRegistrationItem;
        return;
    }
    
    if ([classString isEqualToString:@"EQRClassCatalog_EquipTitleItem_Join"]){
        self.returnClassInt = intEQRClassCatalog_EquipTitleItem_Join;
        return;
    }
    
    if ([classString isEqualToString:@"EQRScheduleTracking_EquipmentUnique_Join"]){
        self.returnClassInt = intEQRScheduleTracking_EquipmentUnique_Join;
        return;
    }
    
    if ([classString isEqualToString:@"EQREquipUniqueItem"]){
        self.returnClassInt = intEQREquipUniqueItem;
        return;
    }
    
    if ([classString isEqualToString:@"EQRMiscJoin"]){
        self.returnClassInt = intEQRMiscJoin;
        return;
    }
    
    if ([classString isEqualToString:@"EQRTextElement"]){
        self.returnClassInt = intEQRTextElement;
        return;
    }
    
    if ([classString isEqualToString:@"EQRTransaction"]){
        self.returnClassInt = intEQRTransaction;
        return;
    }
    
    if ([classString isEqualToString:@"EQREquipCategory"]){
        self.returnClassInt = intEQREquipCategory;
        return;
    }
    
    NSLog(@"WEBDATA DID NOT FIND A MATCHING INT FOR THE RETURN CLASS OBJECT");
}

-(NSString*)testForValidChar:(NSString*)myChar{
    
    //    NSLog(@"this here myChar: %@", myChar);
    
    //is it a return?
//    if ([myChar length] < 4) {
//        NSLog(@"myChar length is 3");
//    }
    
    if ([[myChar substringToIndex:1] isEqualToString: @"\n"]) {
//        NSLog(@"found a leading return: %@", [myChar substringFromIndex:1]);
        return @"";
    }else{
        return myChar;
    }
}

-(BOOL)propForEQRScheduleTracking_EquipmentUnique_Join:(NSString*)prop{
    
    if ([prop isEqualToString:@"key_id"]){
        
//        if ([self.currentThing respondsToSelector:@selector(key_id)]){
        
            [(EQRClassItem*)self.currentThing setKey_id:self.currentValue];
            
            self.currentValue = nil;
//        }
        return YES;
    }
    
    if ([prop isEqualToString:@"equipUniqueItem_foreignKey"]){
        
//        if ([self.currentThing respondsToSelector:@selector(equipUniqueItem_foreignKey)]){
        
            [(EQRScheduleTracking_EquipmentUnique_Join*)self.currentThing setEquipUniqueItem_foreignKey:self.currentValue];
            
            self.currentValue = nil;
//        }
        return YES;
    }
    
    if ([prop isEqualToString:@"scheduleTracking_foreignKey"]){
        
//        if ([self.currentThing respondsToSelector:@selector(scheduleTracking_foreignKey)]){
        
            [(EQRScheduleTracking_EquipmentUnique_Join*)self.currentThing setScheduleTracking_foreignKey:self.currentValue];
            
            self.currentValue = nil;
//        }
        return YES;
    }
    
    if ([prop isEqualToString:@"contact_name"]){
        
//        if ([self.currentThing respondsToSelector:@selector(contact_name)]){
        
            [(EQRScheduleTracking_EquipmentUnique_Join*)self.currentThing setContact_name:self.currentValue];
            
            self.currentValue = nil;
//        }
        return YES;
    }
    
    if ([prop isEqualToString:@"renter_type"]){
        
//        if ([self.currentThing respondsToSelector:@selector(renter_type)]){
        
            [(EQRScheduleTracking_EquipmentUnique_Join*)self.currentThing setRenter_type:self.currentValue];
            
            self.currentValue = nil;
//        }
        return YES;
    }
    
    
    if ([prop isEqualToString:@"request_date_begin"]){
        
//        if ([self.currentThing respondsToSelector:@selector(request_date_begin)]){
        
            //need to convert date string into dates
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            dateFormatter.dateFormat = @"yyyy-MM-dd";
            // HH:mm:ss
            
            [(EQRScheduleTracking_EquipmentUnique_Join*)self.currentThing setRequest_date_begin:[dateFormatter dateFromString:self.currentValue]];
            
            self.currentValue = nil;
//        }
        return YES;
    }
    
    if ([prop isEqualToString:@"request_date_end"]){
        
//        if ([self.currentThing respondsToSelector:@selector(request_date_end)]){
        
            //need to convert date string into dates
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            dateFormatter.dateFormat = @"yyyy-MM-dd";
            // HH:mm:ss
            
            [(EQRScheduleTracking_EquipmentUnique_Join*)self.currentThing setRequest_date_end:[dateFormatter dateFromString:self.currentValue]];
            
            self.currentValue = nil;
//        }
        return YES;
    }
    
    
    //if no match is found with a prop
    return NO;
}


#pragma mark - create the ck

-(NSString*)deriveTheCacheKillerAndThenSome{
    
    float ckFloat = arc4random() % 100000;
    //    NSString* ck = [NSString stringWithFormat:@"ck=%5.0f%@", ckFloat, thisFormattedDate];
    NSMutableString* ck = [NSMutableString stringWithFormat:@"ck=%5.0f", ckFloat];
    
    //______decide here if it needs to access the regular database or the alternate demo database_____
    EQRModeManager* modeManager = [EQRModeManager sharedInstance];
    NSString* isInDemoMode = @"0";
    
    if ([modeManager isInDemoMode]){
        
        isInDemoMode = @"1";
    }
    
    //_______add demo mode logic to the ck________
    [ck insertString:[NSString stringWithFormat:@"is_in_demo_mode=%@&", isInDemoMode] atIndex:0];
    
    return ck;
}


#pragma mark - query methods

- (void) queryWithLink:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithArray)completeBlock{
    
    self.abortXMLParsingFlag = NO;
    
    //for raysmith as localhost
//    NSString* urlRootString = @"http://localhost/nwfc/";
    
    //for remote server
//    NSString* urlRootString = @"http://kitschplayer.com/nwfc/";
    
    //for raysmith as remote
//    NSString* urlRootString = @"http://10.0.0.2/nwfc/";
    
    //get url string from user defaults
    NSString* urlRootString;
    NSString *useBackup = [[[NSUserDefaults standardUserDefaults] objectForKey:@"useBackup"] objectForKey:@"useBackup"];
    if ([useBackup isEqualToString:@"yes"]){
        urlRootString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"backupUrl"] objectForKey:@"backupUrl"];
    }else{
        urlRootString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"url"] objectForKey:@"url"];
    }
   
    //set variableClassString
    self.variableClassString = classString;
    
    //reset the ivar muteArray
    [self.muteArray removeAllObjects];
    
    //declare the input string
    NSString* inputString;
    //declare the parameter string
    NSMutableString* paraString = [NSMutableString stringWithString:@""];
    
    //define the return class with an integer
    self.returnClassInt = 0;
    [self assignIntToClassString:classString];
    
    //add a cache killer!!!
    NSString* ck = [self deriveTheCacheKillerAndThenSome];
    
    //test if any parameters exist
    if ([para count] > 0){
        
//        NSLog(@"this is the number of parameters: %lu", (unsigned long)[para count]);
        
        [para enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            //first parameter should exclude &
            if (idx == 0){
                
                [paraString appendString: [NSString stringWithFormat:@"%@=%@", [obj objectAtIndex:0], [obj objectAtIndex:1]]];
                
            }else{
                
                [paraString appendString: [NSString stringWithFormat:@"&%@=%@", [obj objectAtIndex:0], [obj objectAtIndex:1]]];
            }
        }];
        
        inputString = [NSString stringWithFormat:@"%@%@?%@&%@", urlRootString, link, paraString, ck];
        
    }else{
        
        inputString = [NSString stringWithFormat:@"%@%@?%@", urlRootString, link, ck];
    }
    
    
	//encode the url string
	NSString* urlString = [inputString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //remove new line commands
    NSString* newUrlString = [urlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    if (EQRLogInputStrings) NSLog(@"this is the inputstring: %@", newUrlString);

    
    //send the url request
	NSURL* url = [NSURL URLWithString:urlString];
	NSURLRequest* urlRequest = [NSURLRequest requestWithURL:url
												cachePolicy:NSURLRequestReturnCacheDataElseLoad
											timeoutInterval:30];
	
	NSData* urlData;
	NSURLResponse* response;
	NSError* error;
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest
									returningResponse:&response
												error:&error];
    
    if (!urlData) {
        
        NSLog(@"NSURLConnection failure with error: %@", error);
        
        return;
    }
    
    //_______*********** The incoming data is in latin1 and needs to be in utf8 for the xml parsing
    //convert data to string (and define the incoming encoding)
    NSString* urlDataString = [[NSString alloc] initWithData:urlData encoding:NSISOLatin1StringEncoding];
    
    //convert string back to data with utf8 encoding
    //_______*********** still have the problem that some utf8 characters are displaying as odd alphanumerics
    NSData* urlDataConverted = [urlDataString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    //create the parserer from the urldata
	if (urlData) self.xmlParser = [[NSXMLParser alloc] initWithData:urlDataConverted];
    
    //set parser delegate
    [self.xmlParser setDelegate:self];
    
    [self.xmlParser setShouldResolveExternalEntities:YES];
    
    BOOL success = [self.xmlParser parse];
    
    if (!success){
        
        NSLog(@"xml parser failure.");
        
        return;
    }else{
        
    }
    
    completeBlock(self.muteArray);
    
    //reset variable string
    self.variableClassString = nil;
    
    //reset the mutable array back to zero
    [self.muteArray removeAllObjects];
}


-(NSString*)queryForStringWithLink:(NSString*)link parameters:(NSArray*)para{
    
    self.abortXMLParsingFlag = NO;
    
    //get url string from user defaults
    NSString* urlRootString;
    NSString *useBackup = [[[NSUserDefaults standardUserDefaults] objectForKey:@"useBackup"] objectForKey:@"useBackup"];
    if ([useBackup isEqualToString:@"yes"]){
        urlRootString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"backupUrl"] objectForKey:@"backupUrl"];
    }else{
        urlRootString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"url"] objectForKey:@"url"];
    }

    //declare the input string
    NSString* inputString;
    //declare the parameter string
    NSMutableString* paraString = [NSMutableString stringWithString:@""];
    
    //add a cache killer!!!
    NSString* ck = [self deriveTheCacheKillerAndThenSome];
    
    //test if any parameters exist
    if ([para count] > 0){
        
        [para enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            //first parameter should exclude &
            if (idx == 0){
                
                [paraString appendString: [NSString stringWithFormat:@"%@=%@", [obj objectAtIndex:0], [obj objectAtIndex:1]]];
                
            }else{
                
                [paraString appendString: [NSString stringWithFormat:@"&%@=%@", [obj objectAtIndex:0], [obj objectAtIndex:1]]];
            }
        }];
        
        inputString = [NSString stringWithFormat:@"%@%@?%@&%@", urlRootString, link, paraString, ck];
        
    }else{
        
        inputString = [NSString stringWithFormat:@"%@%@?%@", urlRootString, link, ck];
    }
    
    
	//encode the url string
	NSString* urlString = [inputString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //remove new line commands
    NSString* newUrlString = [urlString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    
    if (EQRLogInputStrings) NSLog(@"this is the inputstring: %@", newUrlString);
    
    
    //send the url request
	NSURL* url = [NSURL URLWithString:urlString];
	NSURLRequest* urlRequest = [NSURLRequest requestWithURL:url
												cachePolicy:NSURLRequestReturnCacheDataElseLoad
											timeoutInterval:120];
	
	NSData* urlData;
	NSURLResponse* response;
	NSError* error;
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest
									returningResponse:&response
												error:&error];
    
    if (!urlData) {
        
        NSLog(@"NSURLConnection failure");
        
        return nil;
    }
    
    //_______*********** The incoming data is in latin1
    //convert data to string (and define the incoming encoding)
    NSString* urlDataString = [[NSString alloc] initWithData:urlData encoding:NSISOLatin1StringEncoding];
    
    return urlDataString;
}


#pragma mark - NSXMLParser Delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    
    if (self.abortXMLParsingFlag){
        return;
    }
    
    // Reset the currentValue to use for this element
    self.currentValue = nil;
    
    // Build an array of equipment items
    if ([elementName isEqualToString:@"entries"]){
        if (!self.muteArray){
            self.muteArray = [[NSMutableArray alloc] initWithCapacity:1];
        }
        return;
    }
    
    // This equip object
    if ([elementName isEqualToString:@"entry"]){
        //a variable property
        self.currentThing = [[NSClassFromString(self.variableClassString)  alloc] init];
        return;
    }
    
    if ([EQRXMLParserHelper isValidElement:elementName inSet:self.validElements]) {
        self.currentProperty = elementName;
    }
}


-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    if (self.abortXMLParsingFlag){
        return;
    }
    
    if (!self.currentValue){
        self.currentValue = [[NSMutableString alloc] initWithCapacity:1];
    }
    
    [self.currentValue appendString:string];
}



-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if (self.abortXMLParsingFlag){
        return;
    }
    
    if ([elementName isEqualToString:@"entry"]){
        
        //add item to ivar array
        if (self.currentThing){
            [self.muteArray addObject:self.currentThing];
        }
        
        //________********** TEST FOR ASYNC METHODS ***********___________
        //will only do anything if it has a delegate
        [self asyncDispatchWithObject:self.currentThing];

        self.currentThing = nil;
        
        return;
    }
    
    
    NSString* prop = self.currentProperty;
    
    //________*********START WITH TIME SAVING EFFICIENCY METHODS
    
    switch (self.returnClassInt) {
        case intEQRScheduleTracking_EquipmentUnique_Join:
            
            if ([self propForEQRScheduleTracking_EquipmentUnique_Join:prop]){
                return;
            }
            break;
            
        default:
            break;
    }
    //_______***********END OF EFFICIENCY METHODS
    
    
    //Properties for EquipTitle
    if ([prop isEqualToString:@"description_long"]){
        NSLog(@"--------- description_long --------%@", self.currentValue);
    }
    
    // Leverage helper method
    if ([EQRXMLParserHelper assignCurrentValue:self.currentValue toCurrentThing:self.currentThing forProp:prop forStandardSet:self.validStandardElements]) {
        
        self.currentValue = nil;
        return;
    }
    
//    if ([prop isEqualToString:@"short_name"]){
//
//        if ([self.currentThing respondsToSelector:@selector(short_name)]){
//
//            NSString *previousValue = [(EQREquipItem*)self.currentThing short_name];
//            NSString *combinedValue;
//            if (previousValue != nil){
//                combinedValue = [NSString stringWithFormat:@"%@%@", previousValue, self.currentValue];
//            } else {
//                combinedValue = self.currentValue;
//            }
//            [(EQREquipItem*)self.currentThing setShortname: combinedValue];
//
//            self.currentValue = nil;
//        }
//        return;
//    }

    if ([prop isEqualToString:@"request_date_begin"]){
        
        if ([self.currentThing respondsToSelector:@selector(request_date_begin)]){
            
            //need to convert date string into dates
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            dateFormatter.dateFormat = @"yyyy-MM-dd";
            // HH:mm:ss
            
            [(EQRScheduleTracking_EquipmentUnique_Join*)self.currentThing setRequest_date_begin:[dateFormatter dateFromString:self.currentValue]];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"request_date_end"]){
        
        if ([self.currentThing respondsToSelector:@selector(request_date_end)]){
            
            //need to convert date string into dates
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            dateFormatter.dateFormat = @"yyyy-MM-dd";
            // HH:mm:ss
            
            [(EQRScheduleTracking_EquipmentUnique_Join*)self.currentThing setRequest_date_end:[dateFormatter dateFromString:self.currentValue]];
            
            self.currentValue = nil;
        }
            return;
    }

    if ([prop isEqualToString:@"request_time_begin"]){
        
        if ([self.currentThing respondsToSelector:@selector(request_time_begin)]){
            
            //________error handling. when request_time_begin has no value, substring will crash _______
            if ([self.currentValue length] < 5){
                [self.currentValue setString:@"00:01:00"];
            }
            
            //piggy back the time by adding it to the system reference date
            float secondsFromHours = [[self.currentValue substringToIndex:2] floatValue] * 60 * 60;
            float secondsFromMinutes = [[self.currentValue substringWithRange:NSMakeRange(3, 2)] floatValue] * 60;
            float combinedSeconds = secondsFromHours + secondsFromMinutes;
            NSDate* referenceDate = [NSDate dateWithTimeIntervalSinceReferenceDate:combinedSeconds];
            
            //______adjust by 8 hours
            float secondsForOffset = 28800;    //this is 9 hours = 32400, this is 8 hours = 28800;
            NSDate* timeAdjustedReferenceDate = [referenceDate dateByAddingTimeInterval:secondsForOffset];
            
            [(EQRScheduleTracking_EquipmentUnique_Join*)self.currentThing setRequest_time_begin:timeAdjustedReferenceDate];
                        
            self.currentValue = nil;
        }
    }
    
    if ([prop isEqualToString:@"request_time_end"]){
        
        if ([self.currentThing respondsToSelector:@selector(request_time_end)]){
            
            //________error handling when request_time_begin has no value, substring will crash_______
            if ([self.currentValue length] < 5){
                [self.currentValue setString:@"00:01:00"];
            }
            
            //piggy back the time by adding it to the system reference date
            float secondsFromHours = [[self.currentValue substringToIndex:2] floatValue] * 60 * 60;
            float secondsFromMinutes = [[self.currentValue substringWithRange:NSMakeRange(3, 2)] floatValue] * 60;
            float combinedSeconds = secondsFromHours + secondsFromMinutes;
            NSDate* referenceDate = [NSDate dateWithTimeIntervalSinceReferenceDate:combinedSeconds];

            //______adjust by 8 hours
            float secondsForOffset = 28800;    //this is 9 hours = 32400, this is 8 hours = 28800;
            NSDate* timeAdjustedReferenceDate = [referenceDate dateByAddingTimeInterval:secondsForOffset];
            
            [(EQRScheduleTracking_EquipmentUnique_Join*)self.currentThing setRequest_time_end:timeAdjustedReferenceDate];
            
            self.currentValue = nil;
        }
    }
    
    if ([prop isEqualToString:@"time_of_request"]){
        
        if ([self.currentThing respondsToSelector:@selector(time_of_request)]){
            
            //need to convert date string into dates
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            [(EQRScheduleRequestItem*)self.currentThing setTime_of_request:[dateFormatter dateFromString:self.currentValue]];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"staff_confirmation_date"]){
        
        if ([self.currentThing respondsToSelector:@selector(staff_confirmation_date)]){
            
            //need to convert date string into dates
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            [(EQRScheduleRequestItem*)self.currentThing setStaff_confirmation_date:[dateFormatter dateFromString:self.currentValue]];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"staff_prep_date"]){
        
        if ([self.currentThing respondsToSelector:@selector(staff_prep_date)]){
            
            //need to convert date string into dates
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            [(EQRScheduleRequestItem*)self.currentThing setStaff_prep_date:[dateFormatter dateFromString:self.currentValue]];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"staff_checkout_date"]){
        
        if ([self.currentThing respondsToSelector:@selector(staff_checkout_date)]){
            
            //need to convert date string into dates
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            [(EQRScheduleRequestItem*)self.currentThing setStaff_checkout_date:[dateFormatter dateFromString:self.currentValue]];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"staff_checkin_date"]){
        
        if ([self.currentThing respondsToSelector:@selector(staff_checkin_date)]){
            
            //need to convert date string into dates
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            [(EQRScheduleRequestItem*)self.currentThing setStaff_checkin_date:[dateFormatter dateFromString:self.currentValue]];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"staff_shelf_date"]){
        
        if ([self.currentThing respondsToSelector:@selector(staff_shelf_date)]){
            
            //need to convert date string into dates
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            [(EQRScheduleRequestItem*)self.currentThing setStaff_shelf_date:[dateFormatter dateFromString:self.currentValue]];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"payment_timestamp"]){
        
        if ([self.currentThing respondsToSelector:@selector(payment_timestamp)]){
            
            //need to convert date string into dates
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            [(EQRTransaction *)self.currentThing setPayment_timestamp:[dateFormatter dateFromString:self.currentValue]];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"pdf_timestamp"]){
        
        if ([self.currentThing respondsToSelector:@selector(pdf_timestamp)]){
            
            //need to convert date string in dates
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            [(EQRScheduleRequestItem *)self.currentThing setPdf_timestamp:[dateFormatter dateFromString:self.currentValue]];
            
            self.currentValue = nil;
        }
        return;
    }

}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"parse error occured: %@", parseError);
}


-(void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if([challenge previousFailureCount] == 0) {
        
        NSURLCredential *newCredential =[NSURLCredential credentialWithUser:@"username" password:@"password" persistence:NSURLCredentialPersistenceForSession];
        
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    }
    else {
        NSLog(@"previous authentication failure");
    }
}


- (void)parserDidEndDocument:(NSXMLParser *)parser{
    // Only if completion block is up, then send block
    self.XMLParsingIsCompleteFlag = YES;
    if (self.completionBlockSignalFlag){
        [self sendAsyncCompletionBlock];
    }
}


#pragma mark - abort method

-(void)stopXMLParsing{
    
    self.abortXMLParsingFlag = YES;
    self.aSyncSelector = nil;
    
    //this does nothing
//    self.XMLParsingIsCompleteFlag = NO;
//    self.completionBlockSignalFlag = NO;
//    self.delayedCompletionBlock = nil;
    
    [self.xmlParser abortParsing];
}


#pragma mark - Asynchronous methods

-(void)queryForStringwithAsync:(NSString *)link parameters:(NSArray *)para completion:(CompletionBlockWithUnknownObject)completeBlock{
    
    
    if ([link isEqualToString:@"EQSetNewContact.php"]){
        
        //run the local method to set the data and retrieve a string of the key
        NSString *returnedKeyID = [self queryForStringWithLink:link parameters:para];
        
        //... but return the Contact object
        NSArray *firstArray = @[@"key_id", returnedKeyID];
        NSArray *topArray = @[firstArray];
        
        [self queryWithLink:@"EQGetContactCompleteWithKey.php" parameters:topArray class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
           
            if ([muteArray count] > 0){
                
                EQRContactNameItem *contactObject = [muteArray objectAtIndex:0];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(contactObject);
                });
            }
        }];
        return;
    }
    
    if ([link isEqualToString:@"EQGetContactNameWithKey.php"]){
        
        // Return the Contact object
        [self queryWithLink:@"EQGetContactNameWithKey.php" parameters:para class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
            
            if ([muteArray count] > 0){
                
                EQRContactNameItem *contactObject = [muteArray objectAtIndex:0];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(contactObject);
                });
            }
        }];
        return;
    }
    
    if ([link isEqualToString:@"EQGetClassCatalogTitleWithKey.php"]){
        
        NSString *returnString = [self queryForStringWithLink:@"EQGetClassCatalogTitleWithKey.php" parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        return;
    }
    
    if ([link isEqualToString:@"EQSetNewClassCatalog.php"]){
        
        NSString *returnString = [self queryForStringWithLink:@"EQSetNewClassCatalog.php" parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        return;
    }
    
    if ([link isEqualToString:@"EQSetNewClassSection.php"]){
        
        NSString *returnString = [self queryForStringWithLink:@"EQSetNewClassSection.php" parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        
        return;
    }
    
    if ([link isEqualToString:@"EQSetNewTransaction.php"]){
        
        NSString *returnString = [self queryForStringWithLink:@"EQSetNewTransaction.php" parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        
        return;
    }
    
    if ([link isEqualToString:@"EQGetTransactionWithScheduleRequestKey.php"]){
        
        //return the Transaction object
        [self queryWithLink:@"EQGetTransactionWithScheduleRequestKey.php" parameters:para class:@"EQRTransaction" completion:^(NSMutableArray *muteArray) {
            
            if ([muteArray count] > 0){
                
                EQRTransaction *transaction = [muteArray objectAtIndex:0];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(transaction);
                });
                
            }else{
                
                //no object got returned, pass this error downstream... with nil
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(nil);
                });
            }
        }];
        return;
    }
    
    if ([link isEqualToString:@"EQAlterTransactionDaysForPrice.php"]){
        
        NSString *returnString = [self queryForStringWithLink:@"EQAlterTransactionDaysForPrice.php" parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        
        return;
    }
    
    if ([link isEqualToString:@"EQAlterCostOfScheduleEquipJoin.php"]){
        
        NSString *returnString = [self queryForStringWithLink:@"EQAlterCostOfScheduleEquipJoin.php" parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        
        return;
    }

    if ([link isEqualToString:@"EQAlterCostOfMiscJoin.php"]){
        
        NSString *returnString = [self queryForStringWithLink:@"EQAlterCostOfMiscJoin.php" parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        
        return;
    }
    
    if ([link isEqualToString:@"EQAlterDepositOfScheduleEquipJoin.php"]){
        
        NSString *returnString = [self queryForStringWithLink:@"EQAlterDepositOfScheduleEquipJoin.php" parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        
        return;
    }
    
    if ([link isEqualToString:@"EQAlterDepositOfMiscJoin.php"]){
        
        NSString *returnString = [self queryForStringWithLink:@"EQAlterDepositOfMiscJoin.php" parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        
        return;
    }
    
    if ([link isEqualToString:@"EQSetNewTextElement.php"]){
        
        NSString *returnString = [self queryForStringWithLink:@"EQSetNewTextElement.php" parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        
        return;
    }
    
    if ([link isEqualToString:@"EQAlterTransactionTotals.php"]){
        
        NSString *returnString = [self queryForStringWithLink:@"EQAlterTransactionTotals.php" parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        
        return;
    }
    
    if ([link isEqualToString:@"EQAlterTransactionMarkAsPaid.php"]){
        
        NSString *returnString = [self queryForStringWithLink:@"EQAlterTransactionMarkAsPaid.php" parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        
        return;
    }
    
    if ([link isEqualToString:@"EQAlterTransactiontRenterPricing.php"]){
        
        NSString *returnString = [self queryForStringWithLink:@"EQAlterTransactiontRenterPricing.php" parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        
        return;
    }
    
    if ([link isEqualToString:@"EQGetScheduleRequestInComplete.php"]){
        
        //return the Request object
        [self queryWithLink:@"EQGetScheduleRequestInComplete.php" parameters:para class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
            
            if ([muteArray count] > 0){
                
                EQRScheduleRequestItem *request = [muteArray objectAtIndex:0];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(request);
                });
                
            }else{
                
                //no object got returned, pass this error downstream... with nil
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(nil);
                });
            }
        }];
        return;
    }
    
    if ([link isEqualToString:@"EQAlterPDFInScheduleRequest.php"]){
        
        NSString *returnString = [self queryForStringWithLink:@"EQAlterPDFInScheduleRequest.php" parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        return;
    }
    
    if ([link isEqualToString:@"EQAlterNotesInScheduleRequest.php"]){
        NSString *returnString = [self queryForStringWithLink:@"EQAlterNotesInScheduleRequest.php" parameters:para];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        return;
    }
    
    if ([link isEqualToString:@"EQSetNewMiscJoin.php"]){
        NSString *returnString = [self queryForStringWithLink:@"EQSetNewMiscJoin.php" parameters:para];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        return;
    }
    
    if ([link isEqualToString:@"EQAlterPhoneInContact.php"]){
        NSString *returnString = [self queryForStringWithLink:@"EQAlterPhoneInContact.php" parameters:para];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        return;
    }
    
    if ([link isEqualToString:@"EQAlterEmailInContact.php"]){
        NSString *returnString = [self queryForStringWithLink:@"EQAlterEmailInContact.php" parameters:para];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        return;
    }
    
    if ([link isEqualToString:@"EQAlterMiscJoinName.php"]){
        NSString *returnString = [self queryForStringWithLink:@"EQAlterMiscJoinName.php" parameters:para];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        return;
    }
    
    if ([link isEqualToString:@"EQGetContactCompleteWithKey.php"]){
        // Return the Contact object
        [self queryWithLink:@"EQGetContactCompleteWithKey.php" parameters:para class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
            
            if ([muteArray count] > 0){
                EQRContactNameItem *nameItem = [muteArray objectAtIndex:0];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(nameItem);
                });
            }else{
                // No object got returned, pass this error downstream... with nil
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(nil);
                });
            }
        }];
        return;
    }
    
    if ([link isEqualToString:@"EQSetConfirmation.php"]){
        NSString *returnString = [self queryForStringWithLink:@"EQSetConfirmation.php" parameters:para];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        return;
    }
    
    if ([link isEqualToString:@"EQSetCheckOutInPrepScheduleEquipJoin.php"]){
        NSString *returnString = [self queryForStringWithLink:@"EQSetCheckOutInPrepScheduleEquipJoin.php" parameters:para];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        return;
    }
    
    if ([link isEqualToString:@"EQSetCheckOutInPrepScheduleMiscJoin.php"]){
        NSString *returnString = [self queryForStringWithLink:@"EQSetCheckOutInPrepScheduleMiscJoin.php" parameters:para];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        return;
    }
    
    if ([link isEqualToString:@"EQAlterScheduleEquipJoin.php"]){
        NSString *returnString = [self queryForStringWithLink:@"EQAlterScheduleEquipJoin.php" parameters:para];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        return;
    }
    
    if ([link isEqualToString:@"EQSetCheckOutInPrepScheduleRequest.php"]){
        NSString *returnString = [self queryForStringWithLink:@"EQSetCheckOutInPrepScheduleRequest.php" parameters:para];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(returnString);
        });
        return;
    }
    
//    if ([link isEqualToString:@"EQGetEquipCategoriesAll.php"]){
//        // Return the Contact object
//        [self queryWithLink:@"EQGetEquipCategoriesAll.php" parameters:para class:@"EQREquipCategory" completion:^(NSMutableArray *muteArray) {
//            if ([muteArray count] > 0){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    completeBlock(muteArray);
//                });
//            }else{
//                // No object got returned, pass this error downstream... with nil
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    completeBlock(nil);
//                });
//            }
//        }];
//        return;
//    }
    
}


-(void)queryWithAsync:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString selector:(SEL)action completion:(CompletionBlockWithBool)completeBlock{
    
    self.completionBlockSignalFlag = NO;
    self.XMLParsingIsCompleteFlag = NO;
    self.abortXMLParsingFlag = NO;
    
    
    //set chosen selector
    self.aSyncSelector = action;
    
    //set the flag
//    self.cancelTheScheduleDownloadFlag = NO;
    
//    [self asyncDispatchWithObject:nil];
    
    
    
    //______
    
    //for raysmith as localhost
    //    NSString* urlRootString = @"http://localhost/nwfc/";
    
    //for remote server
    //    NSString* urlRootString = @"http://kitschplayer.com/nwfc/";
    
    //for raysmith as remote
    //    NSString* urlRootString = @"http://10.0.0.2/nwfc/";
    
    //get url string from user defaults
    NSString* urlRootString;
    NSString *useBackup = [[[NSUserDefaults standardUserDefaults] objectForKey:@"useBackup"] objectForKey:@"useBackup"];
    if ([useBackup isEqualToString:@"yes"]){
        urlRootString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"backupUrl"] objectForKey:@"backupUrl"];
    }else{
        urlRootString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"url"] objectForKey:@"url"];
    }
    
    //set variableClassString
    self.variableClassString = classString;
    
    //reset the ivar muteArray
    [self.muteArray removeAllObjects];
    
    //declare the input string
    NSString* inputString;
    //declare the parameter string
    NSMutableString* paraString = [NSMutableString stringWithString:@""];
    
    //define the return class with an integer
    self.returnClassInt = 0;
    [self assignIntToClassString:classString];
    
    //add a cache killer!!!
    NSString* ck = [self deriveTheCacheKillerAndThenSome];
    
    //test if any parameters exist
    if ([para count] > 0){
        
        //        NSLog(@"this is the number of parameters: %lu", (unsigned long)[para count]);
        
        [para enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            //first parameter should exclude &
            if (idx == 0){
                
                [paraString appendString: [NSString stringWithFormat:@"%@=%@", [obj objectAtIndex:0], [obj objectAtIndex:1]]];
                
            }else{
                
                [paraString appendString: [NSString stringWithFormat:@"&%@=%@", [obj objectAtIndex:0], [obj objectAtIndex:1]]];
            }
        }];
        
        inputString = [NSString stringWithFormat:@"%@%@?%@&%@", urlRootString, link, paraString, ck];
        
    }else{
        
        inputString = [NSString stringWithFormat:@"%@%@?%@", urlRootString, link, ck];
    }
    
    
	//encode the url string
	NSString* urlString = [inputString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //remove new line commands
    NSString* newUrlString = [urlString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    
    if (EQRLogInputStrings) NSLog(@"this is the inputstring: %@", newUrlString);
    
    
    //send the url request
	NSURL* url = [NSURL URLWithString:urlString];
	NSURLRequest* urlRequest = [NSURLRequest requestWithURL:url
												cachePolicy:NSURLRequestReturnCacheDataElseLoad
											timeoutInterval:120];
	
	NSData* urlData;
	NSURLResponse* response;
	NSError* error;
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest
									returningResponse:&response
												error:&error];
    
    if (!urlData) {
        
        NSLog(@"NSURLConnection failure");
        
        return;
    }
    
    //_______*********** The incoming data is in latin1 and needs to be in utf8 for the xml parsing
    //convert data to string (and define the incoming encoding)
    NSString* urlDataString = [[NSString alloc] initWithData:urlData encoding:NSISOLatin1StringEncoding];
    
    //convert string back to data with utf8 encoding
    //_______*********** still have the problem that some utf8 characters are displaying as odd alphanumerics
    NSData* urlDataConverted = [urlDataString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    //create the parserer from the urldata
	if (urlData) self.xmlParser = [[NSXMLParser alloc] initWithData:urlDataConverted];
    
    //set parser delegate
    [self.xmlParser setDelegate:self];
    
    [self.xmlParser setShouldResolveExternalEntities:YES];
    
    //_______________THIS IS THE TIME CONSUMING ELEMENT__________________
    BOOL success = [self.xmlParser parse];
    
    if (!success){
        
        NSLog(@"xml parser failure");
        
        return;
    }else{
        
    }
    
//    NSLog(@"at end of query method and assiging completion block property");
    
    //copy completion block to use later, when XML parsing is finished
    self.delayedCompletionBlock = completeBlock;
    
    //only if xml parsing is complete, send completion block
    self.completionBlockSignalFlag = YES;
    if (self.XMLParsingIsCompleteFlag){
        [self sendAsyncCompletionBlock];
    }
    
    //__________NOTE, IT IS REQUIRED TO SEND THE COMPLETION BLOCK ON THE MAIN THREAD!!!!_____________
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        //send completion block to indicate when loading is finished
//        completeBlock(YES);
//    });
    
    //reset variable string
    self.variableClassString = nil;
    
    //reset the mutable array back to zero
    [self.muteArray removeAllObjects];
    
}

-(void)asyncDispatchWithObject:(id)currentThing {
    
//    NSLog(@"Webdata > is transmitting async dispatch with object" );

    if (self.abortXMLParsingFlag){
        return;
    }
    
    if (self.delegateDataFeed != nil){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.delegateDataFeed addASyncDataItem:currentThing toSelector:self.aSyncSelector];
        });
    }
}

-(void)sendAsyncCompletionBlock{
    
    self.XMLParsingIsCompleteFlag = NO;
    self.completionBlockSignalFlag = NO;
    
    //___doesn't send the completion block if the parsing is aborted!!!
    if (self.abortXMLParsingFlag == YES){
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //___Very importand that this if statement is INSIDE the dispatch
        if (self.delayedCompletionBlock != nil){
            
//            NSLog(@"Webdata > says it is sending a completion block" );
            
            self.delayedCompletionBlock(YES);
            self.delayedCompletionBlock = nil;
        }
    });
    
}






@end
