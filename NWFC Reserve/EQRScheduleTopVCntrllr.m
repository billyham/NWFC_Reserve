//
//  EQRScheduleTopVCntrllr.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/7/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleTopVCntrllr.h"
#import "EQRGlobals.h"
#import "EQRCellTemplate.h"
#import "EQRScheduleCellContentVCntrllr.h"
#import "EQRScheduleRowCell.h"

@interface EQRScheduleTopVCntrllr ()

@property (strong, nonatomic) IBOutlet UICollectionView* myMasterScheduleCollectionView;

@end

@implementation EQRScheduleTopVCntrllr

#pragma mark - methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //register collection view cell
    [self.myMasterScheduleCollectionView registerClass:[EQRScheduleRowCell class] forCellWithReuseIdentifier:@"Cell"];
    
    
}



#pragma mark - collection view data source methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return 3;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"Cell";
    EQRScheduleRowCell* cell = [self.myMasterScheduleCollectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    [cell initialSetupWithTitle:@"gest"];
    
    //add content view from xib
    EQRScheduleCellContentVCntrllr* myContentViewController = [[EQRScheduleCellContentVCntrllr alloc] initWithNibName:@"EQRScheduleCellContentVCntrllr" bundle:nil];
    
    //add subview
    [cell.contentView addSubview:myContentViewController.view];
    
    
    //change label AFTER adding it to the view else defaults to XIB file
    myContentViewController.myRowLabel.text = @"Big C Stand.";

    
    
    
    return cell;
}


#pragma mark - collection view delegate methods







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
