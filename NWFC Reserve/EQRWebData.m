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

@interface EQRWebData ()

@property (strong, nonatomic) NSString* currentProperty;
@property (strong, nonatomic) NSMutableString* currentValue;

@property (strong, nonatomic) NSString* variableClassString;
@property (strong, nonatomic) NSObject* currentThing;
@property (strong, nonatomic) EQREquipItem* currentEquip;
@property (strong, nonatomic) EQRContactNameItem* currentContactName;
@property (strong, nonatomic) EQRClassRegistrationItem* currentClassRegistration;

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
    }
    
    //this equip object
    if ([elementName isEqualToString:@"entry"]){

        //a variable property
        self.currentThing = [[NSClassFromString(self.variableClassString)  alloc] init];
    }
    
    
    
    //_______*******  list of equip properties
    if ([elementName isEqualToString:@"key_id"]){
        
        self.currentProperty = elementName;
    }
    
    //Properties for EquipTitle Item
    if ([elementName isEqualToString:@"name"]){
        
        self.currentProperty = elementName;
    }
    
    if ([elementName isEqualToString:@"short_name"]){
        
        self.currentProperty = elementName;
    }
    
    if ([elementName isEqualToString:@"category"]){
        
        self.currentProperty = elementName;
    }
    
    
    //Properties for Contact Item
    if ([elementName isEqualToString:@"first_and_last"]){
        
        self.currentProperty = elementName;
    }
    
    if ([elementName isEqualToString:@"phone"]){
        
        self.currentProperty = elementName;
    }
    
    if ([elementName isEqualToString:@"email"]){
        
        self.currentProperty = elementName;
    }
    
    
    //Properties for Class Section Item
    if ([elementName isEqualToString:@"section_name"]){
        
        self.currentProperty = elementName;
    }
    
    if ([elementName isEqualToString:@"term"]){

        self.currentProperty = elementName;
    }
    
    if ([elementName isEqualToString:@"catalog_foreign_key"]){

        self.currentProperty = elementName;
    }
    
    //Properties for Class Registration Item
    if ([elementName isEqualToString:@"contact_foreignKey"]){
        
        self.currentProperty = elementName;
    }
    
    //Properties for ClassCatalog_EquipTitleItem_Join Item
    if ([elementName isEqualToString:@"EquipTitleItem_foreignKey"]){
        
        self.currentProperty = elementName;
    }
    
    
    //Properties for ScheduleTracking_EquipUniqueItem_Join
    
}


-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    if (!self.currentValue){
        
        self.currentValue = [[NSMutableString alloc] initWithCapacity:50];
    }
    
    //_____****** test that value is a real character, otherwise don't append the string
    if ([self testForValidChar:self.currentValue]){
        
        [self.currentValue appendString:string];
    }
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
            
            [(EQREquipItem*)self.currentThing setName: [self.currentValue substringFromIndex:1]];
            
            self.currentValue = nil;
        }
    }
    
    if ([prop isEqualToString:@"short_name"]){
        
        if ([self.currentThing respondsToSelector:@selector(shortname)]){
            
            [(EQREquipItem*)self.currentThing setShortname: [self.currentValue substringFromIndex:1]];
            
            self.currentValue = nil;
        }
    }
    
    if ([prop isEqualToString:@"category"]){
        
        if ([self.currentThing respondsToSelector:@selector(category)]){
            
            [(EQREquipItem*)self.currentThing setCategory: [self.currentValue substringFromIndex:1]];
            
            self.currentValue = nil;
        }
    }
    
    
    //Properties for Contact
    if ([prop isEqualToString:@"first_and_last"]){
        
        if ([self.currentThing respondsToSelector:@selector(first_and_last)]){
            
            [(EQRContactNameItem*)self.currentThing setFirst_and_last:[self.currentValue substringFromIndex:1]];
            
            self.currentValue = nil;
        }
    }
    
    if ([prop isEqualToString:@"phone"]){
        
        if ([self.currentThing respondsToSelector:@selector(phone)]){
            
            [(EQRContactNameItem*)self.currentThing setPhone:[self.currentValue substringFromIndex:1]];
            
            self.currentValue = nil;
        }
    }
    
    if ([prop isEqualToString:@"email"]){
        
        if ([self.currentThing respondsToSelector:@selector(email)]){
            
            [(EQRContactNameItem*)self.currentThing setEmail:[self.currentValue substringFromIndex:1]];
            
            self.currentValue = nil;
        }
    }
    
    
    //Properties for Class Section
    if ([prop isEqualToString:@"section_name"]){
        
        if ([self.currentThing respondsToSelector:@selector(section_name)]){
            
            [(EQRClassItem*)self.currentThing setSection_name:[self.currentValue substringFromIndex:1]];
            
            self.currentValue = nil;
        }
    }
    
    if ([prop isEqualToString:@"key_id"]){
        
        if ([self.currentThing respondsToSelector:@selector(key_id)]){
            
            [(EQRClassItem*)self.currentThing setKey_id:[self.currentValue substringFromIndex:1]];
            
            self.currentValue = nil;
        }
    }
    
    if ([prop isEqualToString:@"term"]){
        
        if ([self.currentThing respondsToSelector:@selector(term)]){
            
            [(EQRClassItem*)self.currentThing setTerm:[self.currentValue substringFromIndex:1]];
            
            self.currentValue = nil;
        }
    }
    
    if ([prop isEqualToString:@"catalog_foreign_key"]){
        
        if ([self.currentThing respondsToSelector:@selector(catalog_foreign_key)]){
            
            [(EQRClassItem*)self.currentThing setCatalog_foreign_key:[self.currentValue substringFromIndex:1]];
            
            self.currentValue = nil;
        }
    }
    
    //Properties for Class Registration
    if ([prop isEqualToString:@"contact_foreignKey"]){
        
        if ([self.currentThing respondsToSelector:@selector(contact_foreignKey)]){
            
            [(EQRClassRegistrationItem*)self.currentThing setContact_foreignKey:[self.currentValue substringFromIndex:8]];
            
            self.currentValue = nil;
        }
    }
    
    //Properties for ClassCatalog_EquipTitleItem_Join Item
    if ([prop isEqualToString:@"EquipTitleItem_foreignKey"]){
        
        if ([self.currentThing respondsToSelector:@selector(equipTitleItem_foreignKey)]){
            
            [(EQRClassCatalog_EquipTitleItem_Join*)self.currentThing setEquipTitleItem_foreignKey:[self.currentValue substringFromIndex:1]];
            
            self.currentValue = nil;
        }
    }
    
    //_________************ END
}


-(BOOL)testForValidChar:(NSString*)myChar{
    
    //load up a an array with the alphabet and numbers
    NSArray* alphanumericArray = [NSArray arrayWithObjects:@"1",@"2", @"3", @"4,", @"5", @"6", @"7", @"8", @"9", @"0",
                                  @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n",
                                  @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z",
                                  @"-", @":", @"'", @"\"", @"–", @"<", @">", @"&",
                                  nil];
    
    for (NSString* alphaNum in alphanumericArray){
        
        if ([myChar isEqualToString:alphaNum]){
            
            return YES;
        }
    }
    
    return NO;
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    
    NSLog(@"parse error occured: %@", parseError);
}





- (void)parserDidEndDocument:(NSXMLParser *)parser{
    
}






@end
