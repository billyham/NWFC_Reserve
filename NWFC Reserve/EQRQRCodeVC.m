//
//  EQRQRCodeVC.m
//  Gear
//
//  Created by Dave Hanagan on 4/26/16.
//  Copyright © 2016 Ham Again LLC. All rights reserved.
//

#import "EQRQRCodeVC.h"

@interface EQRQRCodeVC ()

@property (nonatomic, strong) IBOutlet UILabel *itemName;
@property (nonatomic, strong) IBOutlet UILabel *itemNumber;
@property (nonatomic, strong) IBOutlet UIImageView *qrCodeImageView;

@property (nonatomic, strong) NSString *myQRCode;

@end

@implementation EQRQRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    
}

-(void)initialSetupWithCode:(NSString *)code Name:(NSString *)name Number:(NSString *)number{
    
    self.myQRCode = code;
    self.itemName.text = name ? name:  @"";
    self.itemNumber.text = number ? number: @"";
    
    NSData *textData = [self.myQRCode dataUsingEncoding:NSISOLatin1StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:textData forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *ciImage = filter.outputImage;
    UIImage *qrCodeImg = [self createNonInterpolatedUIImageFromCIImage:ciImage withScale:2*[[UIScreen mainScreen] scale]];

    
    if (ciImage){
        self.qrCodeImageView.image = qrCodeImg;
        
        [self printContent];
        
    }else{
        NSLog(@"ciImage is nil");
    }
}


// From https://github.com/ShinobiControls/iOS7-day-by-day/blob/master/15-core-image-filters/15-core-image-filters.md
- (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image withScale:(CGFloat)scale
{
    // Render the CIImage into a CGImage
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
    
    // Now we'll rescale using CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake(image.extent.size.width * scale, image.extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    // We don't want to interpolate (since we've got a pixel-correct image)
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    // Get the image out
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // Tidy up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    return scaledImage;
}


- (void)printContent {
    
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    
    pic.delegate = self;
        
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = @"job name";
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    pic.printInfo = printInfo;
    pic.showsPageRange = YES;
    
    NSData *nameData = [self.itemName.text dataUsingEncoding:NSISOLatin1StringEncoding];
    NSData *numberData = [self.itemNumber.text dataUsingEncoding:NSISOLatin1StringEncoding];
    
    pic.printingItems =  @[self.qrCodeImageView.image, nameData, numberData];
    
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            
        }];
        
        if (!completed && error)
            NSLog(@"FAILED! due to error in domain %@ with error code %u",
                  error.domain, error.code);
    };

    [pic presentAnimated:YES completionHandler:completionHandler];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
