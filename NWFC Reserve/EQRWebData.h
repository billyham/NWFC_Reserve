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

@property BOOL cancelTheScheduleDownloadFlag;

//@property (strong, nonatomic) NSMutableArray* totalEquip;
@property (strong, nonatomic) NSMutableArray* muteArray;
@property (strong, nonatomic) NSXMLParser* xmlParser;


+(EQRWebData*)sharedInstance;

//- (void)hardCodedUrlTest;
- (void) queryWithLink:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithArray)completeBlock;
-(NSString*)queryForStringWithLink:(NSString*)link parameters:(NSArray*)para;

//asynchronous methods, used in conjunction with WebData delegate
-(void)queryWithAsync:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithBool)completeBlock;

@end


@protocol EQRWebDataDelegate <NSObject>

-(void)addScheduleTrackingItem:(id)currentThing;

//______something else to think about (this is used in scheduleDisplayTopVC)
// [self.myWebData.xmlParser abortParsing]

@end
