//
//  EQRPageHeaderNWDoc.h
//  Gear
//
//  Created by Ray Smith on 12/10/16.
//  Copyright © 2016 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRPageHeaderNWDoc : NSObject

+ (void)drawHeaderWithName:(NSString *)name
                     Phone:(NSString *)phone
                     Email:(NSString *)email
                RenterType:(NSString *)renterType
                     Class:(NSString *)classTitle;

@end
