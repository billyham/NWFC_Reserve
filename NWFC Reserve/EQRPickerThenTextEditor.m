//
//  EQRPickerThenTextEditor.m
//  Gear
//
//  Created by Ray Smith on 1/28/18.
//  Copyright © 2018 Ham Again LLC. All rights reserved.
//

#import "EQRPickerThenTextEditor.h"

@interface EQRPickerThenTextEditor () <UINavigationControllerDelegate>

@property (strong, nonatomic) EQRGenericPickerVC *picker;
@property (strong, nonatomic) EQRGenericEditor *textEditor;
@property (copy) void(^onDone)(NSArray *values);
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) NSMutableArray<NSString *> *arrayOfReturnValues;
@property (weak, nonatomic) UIViewController *launchVC;

@end

@implementation EQRPickerThenTextEditor

- (void)initialSetupWithPicker:(EQRGenericPickerVC *)picker
                      callback:(void(^)(NSArray *values))cb {
    
    picker.edgesForExtendedLayout = UIRectEdgeNone;
    NSUInteger index = 0;
    
    [picker setEnterButtonBlock:^(NSString *value) {
        if (!value || [value isEqualToString:@""]) {
            return;
        }
        [self.arrayOfReturnValues insertObject:value atIndex:index];
        [self.navController pushViewController:self.textEditor animated:YES];
    }];
    
    self.picker = picker;
    self.onDone = cb;
}

- (void)addTextEditor:(EQRGenericEditor *)genericEditor {
    NSUInteger index = 1;
    
    if (!self.arrayOfReturnValues) {
        self.arrayOfReturnValues = [NSMutableArray arrayWithCapacity:1];
    }
    genericEditor.edgesForExtendedLayout = UIRectEdgeNone;
    [genericEditor setEnterButtonBlock:^(NSString *value) {
        if ([value isEqualToString:@""]) {
            return;
        }
        [self.arrayOfReturnValues insertObject:value atIndex:index];
        self.onDone(self.arrayOfReturnValues);
        [self.launchVC dismissViewControllerAnimated:YES completion:^{ }];
    }];
    
    self.textEditor = genericEditor;
}



- (void)presentEditor:(UIViewController *)vc {
    self.launchVC = vc;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.picker];
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    self.navController = navController;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    [self.picker.navigationItem setLeftBarButtonItem:leftButton];
    
    [vc presentViewController:self.navController animated:YES completion:^{  }];
}

- (void)cancelAction {
    [self.launchVC dismissViewControllerAnimated:YES completion:^{ }];
}

@end
