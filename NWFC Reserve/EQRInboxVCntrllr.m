//
//  EQRInboxVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 7/19/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRInboxVCntrllr.h"
#import "EQRInboxRowCell.h"

@interface EQRInboxVCntrllr ()

@property (strong, nonatomic) IBOutlet UICollectionView* inboxCollection;

@end

@implementation EQRInboxVCntrllr

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
    [self.inboxCollection registerClass:[EQRInboxRowCell class] forCellWithReuseIdentifier:@"Cell"];
    
    
    
}


#pragma mark - collection view protocols

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
};


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return 1;
};


-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"Cell";
    
    EQRInboxRowCell* cell = [self.inboxCollection dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //remove subviews
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
//    NSLog(@"inside collection view methods for inbox");
    
    [cell initialSetupWithTitle:@"puddin"];
    
    //and reset the cell's background color...
    cell.backgroundColor = [UIColor whiteColor];
    
    
    
    
    return cell;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
