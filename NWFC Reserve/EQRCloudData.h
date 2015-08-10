//
//  EQRDataProxy.h
//  Gear
//
//  Created by Ray Smith on 3/11/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EQRWebData.h"

#pragma mark - Completion block definitions
typedef void (^CompletionBlockWithArray) (NSMutableArray* muteArray);
typedef void (^CompletionBlockWithBool) (BOOL isLoadingFlagUp);


@protocol EQRCloudDataDelegate;

@interface EQRCloudData : EQRWebData{
//    __weak id <EQRCloudDataDelegate> delegateDataFeed;
}

//@property (weak, nonatomic) id <EQRCloudDataDelegate> delegateDataFeed;

+(EQRCloudData*)sharedInstance;

//-(void) queryWithLink:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithArray)completeBlock;
//-(NSString*)queryForStringWithLink:(NSString*)link parameters:(NSArray*)para;
//-(void)queryWithAsync:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString selector:(SEL)action completion:(CompletionBlockWithBool)completeBlock;


@end



@protocol EQRCloudDataDelegate <NSObject>

//-(void)addASyncDataItem:(id)currentThing;

@end