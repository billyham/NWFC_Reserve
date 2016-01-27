//
//  EQRPageHeader.h
//  Gear
//
//  Created by Ray Smith on 12/27/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRPageHeader : NSObject

+ (void)drawHeaderWithName:(NSString *)name
                     Phone:(NSString *)phone
                     Email:(NSString *)email
                RenterType:(NSString *)renterType
                     Class:(NSString *)classTitle;

@end
