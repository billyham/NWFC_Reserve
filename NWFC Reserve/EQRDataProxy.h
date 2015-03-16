//
//  EQRDataProxy.h
//  Gear
//
//  Created by Ray Smith on 3/11/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Completion block definitions
typedef void (^CompletionBlockWithArray) (NSMutableArray* muteArray);
typedef void (^CompletionBlockWithBool) (BOOL isLoadingFlagUp);

@protocol EQRDataProxySource;
@protocol EQRDataProxyDelegate;

@interface EQRDataProxy : NSObject{
    __weak id <EQRDataProxyDelegate> delegate;
}

@property (weak, nonatomic) id <EQRDataProxyDelegate> delegate;

+(EQRDataProxy*)sharedInstance;

-(void) queryWithLink:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithArray)completeBlock;
-(NSString*)queryForStringWithLink:(NSString*)link parameters:(NSArray*)para;
-(void)queryWithAsync:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithBool)completeBlock;


@end


@protocol EQRDataProxySource <NSObject>

-(void) queryWithLink:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithArray)completeBlock;
-(NSString*)queryForStringWithLink:(NSString*)link parameters:(NSArray*)para;
-(void)queryWithAsync:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithBool)completeBlock;
-(void)stopXMLParsing;

@end

@protocol EQRDataProxyDelegate <NSObject>

-(void)addASyncDataItem:(id)currentThing;

@end