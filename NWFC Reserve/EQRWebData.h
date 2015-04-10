//
//  EQRWebData.h
//  NWFC Reserve
//
//  Created by Ray Smith on 11/12/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Completion block definitions
typedef void (^CompletionBlock) ();
typedef void (^CompletionBlockWithArray) (NSMutableArray* muteArray);
typedef void (^CompletionBlockWithNestedArray) (NSMutableArray* nestedMuteArray);
typedef void (^CompletionBlockWithBool) (BOOL isLoadingFlagUp);

@protocol EQRWebDataDelegate;


@interface EQRWebData : NSObject <NSXMLParserDelegate>{
    
    __weak id <EQRWebDataDelegate> delegateDataFeed;
}

@property (nonatomic, weak) id <EQRWebDataDelegate> delegateDataFeed;

//block as property
@property (copy) CompletionBlockWithBool delayedCompletionBlock;

//@property BOOL cancelTheScheduleDownloadFlag;
//@property (strong, nonatomic) NSMutableArray* totalEquip;
//@property (strong, nonatomic) NSMutableArray* muteArray;
//@property (strong, nonatomic) NSXMLParser* xmlParser;


+(EQRWebData*)sharedInstance;

//- (void)hardCodedUrlTest;
- (void) queryWithLink:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithArray)completeBlock;
-(NSString*)queryForStringWithLink:(NSString*)link parameters:(NSArray*)para;

//asynchronous methods, used in conjunction with WebData delegate
-(void)queryWithAsync:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString selector:(SEL)action completion:(CompletionBlockWithBool)completeBlock;

//stop parsing
-(void)stopXMLParsing;

@end

//delegateDataFeed methods
@protocol EQRWebDataDelegate <NSObject>

-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action;

@end
