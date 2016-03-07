//
//  EQRCoreData.h
//  Gear
//
//  Created by Ray Smith on 3/7/16.
//  Copyright © 2016 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EQRWebData.h"

#pragma mark - Completion block definitions
typedef void (^CompletionBlockWithArray) (NSMutableArray* muteArray);
typedef void (^CompletionBlockWithBool) (BOOL isLoadingFlagUp);


@protocol EQRCoreDataDelegate;

@interface EQRCoreData : EQRWebData{
    //    __weak id <EQRCoreDataDelegate> delegateDataFeed;
}

//@property (weak, nonatomic) id <EQRCoreDataDelegate> delegateDataFeed;

+(EQRCoreData*)sharedInstance;

//-(void) queryWithLink:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithArray)completeBlock;
//-(NSString*)queryForStringWithLink:(NSString*)link parameters:(NSArray*)para;
//-(void)queryWithAsync:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString selector:(SEL)action completion:(CompletionBlockWithBool)completeBlock;


@end



@protocol EQRCoreDataDelegate <NSObject>

//-(void)addASyncDataItem:(id)currentThing;

@end
