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


@interface EQRWebData : NSObject <NSXMLParserDelegate>

//@property (strong, nonatomic) NSMutableArray* totalEquip;
@property (strong, nonatomic) NSMutableArray* muteArray;
@property (strong, nonatomic) NSXMLParser* xmlParser;


+(EQRWebData*)sharedInstance;

//- (void)hardCodedUrlTest;
- (void) queryWithLink:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithArray)completeBlock;
-(NSString*)queryForStringWithLink:(NSString*)link parameters:(NSArray*)para;


@end
