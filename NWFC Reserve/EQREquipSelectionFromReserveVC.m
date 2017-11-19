//
//  EQREquipSelectionFromReserveVC.m
//  Gear
//
//  Created by Ray Smith on 11/18/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import "EQREquipSelectionFromReserveVC.h"

@interface EQREquipSelectionFromReserveVC ()

@end

@implementation EQREquipSelectionFromReserveVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //add the cancel button
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTheThing:)];
    
    //add button to the current navigation item
    [self.navigationItem setRightBarButtonItem:cancelButton];
}





@end
