//
//  EQRWebData.m
//  NWFC Reserve
//
//  Created by Ray Smith on 11/12/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import "EQRWebData.h"
#import "EQREquipItem.h"
#import "EQRContactNameItem.h"
#import "EQRClassItem.h"
#import "EQRClassRegistrationItem.h"
#import "EQRClassCatalog_EquipTitleItem_Join.h"
#import "EQREquipUniqueItem.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRScheduleRequestItem.h"

@interface EQRWebData ()

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

@end


@implementation EQRWebData


+(EQRWebData*)sharedInstance{
    
//    static EQRWebData* myInstance = nil;
//    
//    if (!myInstance){
//        
//        myInstance = [[EQRWebData alloc] init];
//    }

    EQRWebData* myInstance = [[EQRWebData alloc] init];
    
    return myInstance;
}


- (void) queryWithLink:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithArray)completeBlock{
    
    //for raysmith as localhost
//    NSString* urlRootString = @"http://localhost/nwfc/";
    
    //for remote server
//    NSString* urlRootString = @"http://kitschplayer.com/nwfc/";
    
    //for raysmith as remote
//    NSString* urlRootString = @"http://10.0.0.2/nwfc/";
    
    //get url string from user defaults
    NSString* urlRootString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"url"] objectForKey:@"url"];

    
    //set variableClassString
    self.variableClassString = classString;
    
    //reset the ivar muteArray
    [self.muteArray removeAllObjects];
    
    //declare the input string
    NSString* inputString;
    //declare the parameter string
    NSMutableString* paraString = [NSMutableString stringWithString:@""];
    
    //add a cache killer!!!
    //a combination of timestamp and a random number
    NSDate* ckDate = [NSDate date];
    NSString* thisFormattedDate= [NSDateFormatter localizedStringFromDate:ckDate dateStyle:NSDateFormatterNoStyle
                                                                timeStyle:NSDateFormatterLongStyle ];
    float ckFloat = arc4random() % 100000;
    NSString* ck = [NSString stringWithFormat:@"ck=%5.0f%@", ckFloat, thisFormattedDate];
    
    //test if any parameters exist
    if ([para count] > 0){
        
        NSLog(@"this is the number of parameters: %lu", (unsigned long)[para count]);
        
        [para enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSLog(@"inside the block");
            
            //first parameter should exclude &
            if (idx == 0){
                
                NSLog(@"this is the key after sent to webdata: %@",[obj objectAtIndex:0]);
                
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

    
    NSLog(@"this is the inputstring: %@", newUrlString);

    
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
    
    BOOL success = [self.xmlParser parse];
    
    if (!success){
        
        NSLog(@"self xml parser failure");
        
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
    
    //get url string from user defaults
    NSString* urlRootString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"url"] objectForKey:@"url"];

    //declare the input string
    NSString* inputString;
    //declare the parameter string
    NSMutableString* paraString = [NSMutableString stringWithString:@""];
    
    //add a cache killer!!!
    //a combination of timestamp and a random number
    NSDate* ckDate = [NSDate date];
    NSString* thisFormattedDate= [NSDateFormatter localizedStringFromDate:ckDate dateStyle:NSDateFormatterNoStyle
                                                                timeStyle:NSDateFormatterLongStyle ];
    float ckFloat = arc4random() % 100000;
    NSString* ck = [NSString stringWithFormat:@"ck=%5.0f%@", ckFloat, thisFormattedDate];
    
    //test if any parameters exist
    if ([para count] > 0){
        
        NSLog(@"this is the number of parameters: %lu", (unsigned long)[para count]);
        
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
    
    
    NSLog(@"this is the inputstring: %@", newUrlString);
    
    
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
    
    //build an array of equipment items
    if ([elementName isEqualToString:@"entries"]){
        
        if (!self.muteArray){
            
            self.muteArray = [[NSMutableArray alloc] initWithCapacity:1];
        }
        
        return;
    }
    
    //this equip object
    if ([elementName isEqualToString:@"entry"]){

        //a variable property
        self.currentThing = [[NSClassFromString(self.variableClassString)  alloc] init];
        
        return;
    }
    
    
    
    //_______*******  list of equip properties
    if ([elementName isEqualToString:@"key_id"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    //Properties for EquipTitle Item
    if ([elementName isEqualToString:@"name"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"short_name"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"subcategory"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"category"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"schedule_grouping"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    
    //Properties for EquipUniqueItem
    if ([elementName isEqualToString:@"equipTitleItem_foreignKey"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"distinquishing_id"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"status_level"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    //Properties for Contact Item
    if ([elementName isEqualToString:@"first_and_last"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"phone"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"email"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    
    //Properties for Class Section Item
    if ([elementName isEqualToString:@"section_name"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"term"]){

        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"catalog_foreign_key"]){

        self.currentProperty = elementName;
        return;
    }
    
    //Properties for Class Registration Item
    if ([elementName isEqualToString:@"contact_foreignKey"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    //Properties for ClassCatalog_EquipTitleItem_Join Item
    if ([elementName isEqualToString:@"EquipTitleItem_foreignKey"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    
    //Properties for ScheduleTracking_EquipUniqueItem_Join
    if ([elementName isEqualToString:@"equipUniqueItem_foreignKey"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"scheduleTracking_foreignKey"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"contact_name"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"renter_type"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"request_date_begin"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"request_date_end"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    //Properties for ScheduleTracking
    
    if ([elementName isEqualToString:@"classSection_foreignKey"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"classTitle_foreignKey"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    if ([elementName isEqualToString:@"time_of_request"]){
        
        self.currentProperty = elementName;
        return;
    }
    
    
    
    
}


-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    if (!self.currentValue){
        
        self.currentValue = [[NSMutableString alloc] initWithCapacity:50];
    }
    
    //_____remove non alpha numerica characters at the start of the value
    NSString* newString = [self testForValidChar:string];
        
    [self.currentValue appendString:newString];
    
}



-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"entry"]){
        
//        NSLog(@"this is the current thing class: %@", [self.currentThing class]);
        
        //add item to ivar array
        [self.muteArray addObject:self.currentThing];
        
        self.currentThing = nil;
    }
    
    
    NSString* prop = self.currentProperty;
    
    //______probably should create a template Item class that has key_id as a property that other classes inherit from
//    if ([prop isEqualToString:@"key_id"]){
//        
//        if ([self.currentThing respondsToSelector:@selector(key_id)]){
//            
//            [(EQREquipItem*)self.currentThing setKey_id: [self.currentValue substringFromIndex:1]];
//            
//            self.currentValue = nil;
//        }
//    }
    
    //_______********* START
    
    //Properties for EquipTitle
    if ([prop isEqualToString:@"name"]){
        
        //_______********  adds a return at the very start of the value?? Use substring to remove it
        if ([self.currentThing respondsToSelector:@selector(name)]){
            
            [(EQREquipItem*)self.currentThing setName: self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"short_name"]){
        
        if ([self.currentThing respondsToSelector:@selector(shortname)]){
            
            [(EQREquipItem*)self.currentThing setShortname: self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"subcategory"]){
        
        if ([self.currentThing respondsToSelector:@selector(subcategory)]){
            
            [(EQREquipItem*)self.currentThing setSubcategory: self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"category"]){
        
        if ([self.currentThing respondsToSelector:@selector(category)]){
            
            [(EQREquipItem*)self.currentThing setCategory: self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"schedule_grouping"]){
        
        if ([self.currentThing respondsToSelector:@selector(schedule_grouping)]){
            
            [(EQREquipItem*)self.currentThing setSchedule_grouping: self.currentValue];
            
            self.currentValue = nil;
        }
    }
    
    
    //Properties for EquipUniqueItem
    if ([prop isEqualToString:@"equipTitleItem_foreignKey"]){
        
        if ([self.currentThing respondsToSelector:@selector(equipTitleItem_foreignKey)]){
            
            [(EQREquipUniqueItem*)self.currentThing setEquipTitleItem_foreignKey: self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"status_level"]){
        
        if ([self.currentThing respondsToSelector:@selector(status_level)]){
            
            [(EQREquipUniqueItem*)self.currentThing setStatus_level: self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"distinquishing_id"]){
        
        if ([self.currentThing respondsToSelector:@selector(distinquishing_id)]){
            
            [(EQREquipUniqueItem*)self.currentThing setDistinquishing_id: self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    
    //Properties for Contact
    if ([prop isEqualToString:@"first_and_last"]){
        
        if ([self.currentThing respondsToSelector:@selector(first_and_last)]){
            
            [(EQRContactNameItem*)self.currentThing setFirst_and_last:self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"phone"]){
        
        if ([self.currentThing respondsToSelector:@selector(phone)]){
            
            [(EQRContactNameItem*)self.currentThing setPhone:self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"email"]){
        
        if ([self.currentThing respondsToSelector:@selector(email)]){
            
            [(EQRContactNameItem*)self.currentThing setEmail:self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    
    //Properties for Class Section
    if ([prop isEqualToString:@"section_name"]){
        
        if ([self.currentThing respondsToSelector:@selector(section_name)]){
            
            [(EQRClassItem*)self.currentThing setSection_name:self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"key_id"]){
        
        if ([self.currentThing respondsToSelector:@selector(key_id)]){
            
            [(EQRClassItem*)self.currentThing setKey_id:self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"term"]){
        
        if ([self.currentThing respondsToSelector:@selector(term)]){
            
            [(EQRClassItem*)self.currentThing setTerm:self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"catalog_foreign_key"]){
        
        if ([self.currentThing respondsToSelector:@selector(catalog_foreign_key)]){
            
            [(EQRClassItem*)self.currentThing setCatalog_foreign_key:self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    //Properties for Class Registration
    if ([prop isEqualToString:@"contact_foreignKey"]){
        
        if ([self.currentThing respondsToSelector:@selector(contact_foreignKey)]){
            
            [(EQRClassRegistrationItem*)self.currentThing setContact_foreignKey:self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    //Properties for ClassCatalog_EquipTitleItem_Join Item
    if ([prop isEqualToString:@"EquipTitleItem_foreignKey"]){
        
        if ([self.currentThing respondsToSelector:@selector(equipTitleItem_foreignKey)]){
            
            [(EQRClassCatalog_EquipTitleItem_Join*)self.currentThing setEquipTitleItem_foreignKey:self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    
    //Properties for ScheduleTracking_EquipUniqueItem_Join
    if ([prop isEqualToString:@"equipUniqueItem_foreignKey"]){
        
        if ([self.currentThing respondsToSelector:@selector(equipUniqueItem_foreignKey)]){
            
            [(EQRScheduleTracking_EquipmentUnique_Join*)self.currentThing setEquipUniqueItem_foreignKey:self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"scheduleTracking_foreignKey"]){
        
        if ([self.currentThing respondsToSelector:@selector(scheduleTracking_foreignKey)]){
            
            [(EQRScheduleTracking_EquipmentUnique_Join*)self.currentThing setScheduleTracking_foreignKey:self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"contact_name"]){
        
        if ([self.currentThing respondsToSelector:@selector(contact_name)]){
            
            [(EQRScheduleTracking_EquipmentUnique_Join*)self.currentThing setContact_name:self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"renter_type"]){
        
        if ([self.currentThing respondsToSelector:@selector(renter_type)]){
            
            [(EQRScheduleTracking_EquipmentUnique_Join*)self.currentThing setRenter_type:self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    
    //need to convert date string into dates
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    // HH:mm:ss
    
    if ([prop isEqualToString:@"request_date_begin"]){
        
        if ([self.currentThing respondsToSelector:@selector(request_date_begin)]){
            
            [(EQRScheduleTracking_EquipmentUnique_Join*)self.currentThing setRequest_date_begin:[dateFormatter dateFromString:self.currentValue]];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"request_date_end"]){
        
        if ([self.currentThing respondsToSelector:@selector(request_date_end)]){
            
            [(EQRScheduleTracking_EquipmentUnique_Join*)self.currentThing setRequest_date_end:[dateFormatter dateFromString:self.currentValue]];
            
            self.currentValue = nil;
        }
            return;
    }

    
    //Properties for ScheduleRequestItem

//    if ([prop isEqualToString:@"request_date_begin"]){
//        
//        if ([self.currentThing respondsToSelector:@selector(request_date_begin)]){
//            
//            [(EQRScheduleRequestItem*)self.currentThing setRequest_date_begin:[dateFormatter dateFromString:self.currentValue]];
//            
//            self.currentValue = nil;
//        }
//        return;
//    }
//    
//    if ([prop isEqualToString:@"request_date_end"]){
//        
//        if ([self.currentThing respondsToSelector:@selector(request_date_end)]){
//            
//            [(EQRScheduleRequestItem*)self.currentThing setRequest_date_end:[dateFormatter dateFromString:self.currentValue]];
//            
//            self.currentValue = nil;
//        }
//        return;
//    }
    
    if ([prop isEqualToString:@"classSection_foreignKey"]){
        
        if ([self.currentThing respondsToSelector:@selector(classSection_foreignKey)]){
            
            [(EQRScheduleRequestItem*)self.currentThing setClassSection_foreignKey:self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    
    if ([prop isEqualToString:@"classTitle_foreignKey"]){
        
        if ([self.currentThing respondsToSelector:@selector(classTitle_foreignKey)]){
            
            [(EQRScheduleRequestItem*)self.currentThing setClassTitle_foreignKey:self.currentValue];
            
            self.currentValue = nil;
        }
        return;
    }
    

    
    if ([prop isEqualToString:@"time_of_request"]){
        
        if ([self.currentThing respondsToSelector:@selector(time_of_request)]){
            
            [(EQRScheduleRequestItem*)self.currentThing setTime_of_request:[dateFormatter dateFromString:self.currentValue]];
            
            self.currentValue = nil;
        }
        return;
    }
    
    
    
    //_________************ END
}


-(NSString*)testForValidChar:(NSString*)myChar{
    
//    NSLog(@"this here myChar: %@", myChar);
    
    //is it a return?
    if ([[myChar substringToIndex:1] isEqualToString: @"\n"]) {
        
        return @"";
        
    }else{
        
        return myChar;
    }
    
    
//    //test if ivar array exists
//    if (!self.alphaNumericaArray){
//     
//        //load up a an array with the alphabet and numbers
//        self.alphaNumericaArray = [NSArray arrayWithObjects:@"1",@"2", @"3", @"4,", @"5", @"6", @"7", @"8", @"9", @"0",
//                                   @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n",
//                                   @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z",
//                                   @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N",
//                                   @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z",
//                                   @"-", @":", @"'", @"\"", @"–", @"<", @">", @"&",
//                                   nil];
//    }
//    
//    
//    NSInteger myLength = [myChar length];
//    
//    int n;
//    for (n=0 ; n < myLength ; n++){
//        
//        for (NSString* alphaNum in self.alphaNumericaArray){
//            
//            if ([[NSString stringWithFormat:@"%c", [myChar characterAtIndex:n] ] isEqualToString:alphaNum]){
//                
//                return [myChar substringFromIndex:n];
//            }
//        }
//    }
//    
//    return @"";
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    
    NSLog(@"parse error occured: %@", parseError);
}


//_________*********  i have no idea what this is or if it's doing anything...
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
    
}






@end
