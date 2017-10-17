//
//  EQRXMLParserHelper.h
//  Gear
//
//  Created by Ray Smith on 10/14/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRXMLParserHelper : NSObject

+ (NSSet *)generateStandardElements;
+ (NSSet *)generateValidElementsFromSets:(NSArray *)arrayOfSets;
+ (BOOL)isValidElement:(NSString *)element inSet:(NSSet *)set;
+ (BOOL)assignCurrentValue:(NSString *)currentValue toCurrentThing:(id)currentThing forProp:(NSString *)prop forStandardSet:(NSSet *)set;

@end
