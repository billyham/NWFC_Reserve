//
//  EQRDataProxy.m
//  Gear
//
//  Created by Ray Smith on 3/11/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRDataProxy.h"

@interface EQRDataProxy ()



@end

@implementation EQRDataProxy

@synthesize delegate;

+(EQRDataProxy*)sharedInstance{
    
    EQRDataProxy *myInstance = [[EQRDataProxy alloc] init];
    return myInstance;
}

#pragma mark - dataProxySource protocol methods

-(void) queryWithLink:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithArray)completeBlock{
    
}


-(NSString*)queryForStringWithLink:(NSString*)link parameters:(NSArray*)para{
    
    
    
    return @"nonsense";
}



-(void)queryWithAsync:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithBool)completeBlock{
    
    
}

-(void)stopXMLParsing{
    
}


@end
