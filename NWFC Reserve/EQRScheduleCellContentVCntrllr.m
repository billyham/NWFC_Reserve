//
//  EQRScheduleCellContentVCntrllr.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/20/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleCellContentVCntrllr.h"
#import "EQRCellTemplate.h"
#import "EQRGlobals.h"

@interface EQRScheduleCellContentVCntrllr ()

@property (strong, nonatomic) IBOutlet UICollectionView* myUniqueItemCollectionView;


@end

@implementation EQRScheduleCellContentVCntrllr

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
    
//    //register collection view cell
//    [self.myUniqueItemCollectionView registerClass:[EQRCellTemplate class] forCellWithReuseIdentifier:@"Cell"];
//    
//    //create a uicollectionview object programatically
//    UICollectionViewFlowLayout* thisFlowLayout = [[UICollectionViewFlowLayout alloc] init];
//    CGRect thisRect = CGRectMake(0, 0, 10, 10);
//    UICollectionView* thisCollectionView = [[UICollectionView alloc] initWithFrame:thisRect collectionViewLayout:thisFlowLayout];
//    self.myUniqueItemCollectionView = thisCollectionView;
//    
//    [self.myUniqueItemCollectionView setDataSource:self];
//    [self.myUniqueItemCollectionView setDelegate:self];
////
//    [self.view addSubview:self.myUniqueItemCollectionView];
    
}
//
//#pragma mark - collection view data source methods
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
// 
//    return 0;
//}
//
//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    
//    return 1;
//}
//
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    static NSString* CellIdentifier = @"Cell";
//    EQRCellTemplate* cell = [self.myUniqueItemCollectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    for (UIView* view in cell.contentView.subviews){
//        
//        [view removeFromSuperview];
//    }
//    
//    [cell initialSetupWithTitle:@"Monkey Butt"];
//    
//    
//    
//    return cell;
//}
//
//
//#pragma mark - collection view delegate methods







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
