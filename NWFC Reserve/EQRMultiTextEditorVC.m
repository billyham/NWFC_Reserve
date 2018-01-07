//
//  EQRMultiTextEditorVC.m
//  Gear
//
//  Created by Ray Smith on 12/23/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import "EQRMultiTextEditorVC.h"

@interface EQRMultiTextEditorVC () <UINavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray<EQRGenericEditor *> *arrayOfEditors;
@property (strong, nonatomic) NSMutableArray<NSString *> *arrayOfReturnValues;
@property (copy) void (^onDone)(NSArray *values);
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) EQRGenericEditor *genericEditor;
@property (weak, nonatomic) UIViewController *launchedVC;

@end

@implementation EQRMultiTextEditorVC
@synthesize delegate;

#pragma mark - public methods
- (void)initialSetupWithReturnCallback:(void(^)(NSArray *values))cb {
    self.onDone = cb;
}

- (void)pushNewTextEditor:(EQRGenericEditor *)genericEditor {
    if (!self.arrayOfEditors) {
        self.arrayOfEditors = [NSMutableArray arrayWithCapacity:1];
    }
    if (!self.arrayOfReturnValues) {
        self.arrayOfReturnValues = [NSMutableArray arrayWithCapacity:1];
    }
    genericEditor.edgesForExtendedLayout = UIRectEdgeNone;
    NSUInteger index = self.arrayOfEditors.count;
    [self.arrayOfEditors addObject:genericEditor];
    
    [genericEditor setEnterButtonBlock:^(NSString *value){
        if ([value isEqualToString:@""]) {
            return;
        };
        [self.arrayOfReturnValues insertObject:value atIndex:index];
        self.onDone(self.arrayOfReturnValues);
        [self.launchedVC dismissViewControllerAnimated:YES completion:^{ }];
    }];
    
    if (self.arrayOfEditors.count > 1) {
        [self.arrayOfEditors[index - 1] setEnterButtonBlock:^(NSString *value){
            if ([value isEqualToString:@""]) {
                return;
            };
            [self.arrayOfReturnValues insertObject:value atIndex:index - 1];
            [self.navController pushViewController:self.arrayOfEditors[index]  animated:YES];
        }];
    }
}

- (void)presentEditor:(UIViewController *)vc {
    self.launchedVC = vc;
    EQRGenericEditor *genericEditor = self.arrayOfEditors[0];
    self.genericEditor = genericEditor;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.genericEditor];
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    self.navController = navController;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    [self.genericEditor.navigationItem setLeftBarButtonItem:leftButton];
    
    [vc presentViewController:self.navController animated:YES completion:^{ }];
}


- (void)cancelAction {
    [self.launchedVC dismissViewControllerAnimated:YES completion:^{ }];
}

//- (void)pushNewView:(NSString *)item {
//    [self.navController pushViewController:[self.arrayOfEditors objectAtIndex:1]  animated:YES];
//}

#pragma mark - navigation controller delegate
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//}
//
//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//}





@end
