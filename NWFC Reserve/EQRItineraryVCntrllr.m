//
//  EQRItineraryVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/14/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRItineraryVCntrllr.h"
#import "EQRItineraryRowCell.h"
#import "EQRGlobals.h"
#import "EQRColors.h"

@interface EQRItineraryVCntrllr ()

@property (strong, nonatomic) IBOutlet UICollectionView* myMasterItineraryCollection;
@property (strong ,nonatomic) IBOutlet UICollectionView* myNavBarCollectionView;

@property (strong, nonatomic) NSDate* dateForShow;

@property EQRItineraryFilter currentFilterBitmask;
@property (strong, nonatomic) IBOutlet UIButton* buttonAll;
@property (strong, nonatomic) IBOutlet UIButton* buttonGoingShelf;
@property (strong, nonatomic) IBOutlet UIButton* buttonGoingPrepped;
@property (strong, nonatomic) IBOutlet UIButton* buttonGoingPickedUp;
@property (strong, nonatomic) IBOutlet UIButton* buttonReturningOut;
@property (strong, nonatomic) IBOutlet UIButton* buttonReturningReturned;
@property (strong, nonatomic) IBOutlet UIButton* buttonReturningShelved;

-(IBAction)moveToNextDay:(id)sender;
-(IBAction)moveToPreviousDay:(id)sender;

@end

@implementation EQRItineraryVCntrllr

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
    [self.myMasterItineraryCollection registerClass:[EQRItineraryRowCell class] forCellWithReuseIdentifier:@"Cell"];
    
    //set initial filter bitmask to 'all'
    self.currentFilterBitmask = EQRFilterAll;
    
    //set all button to filter on color
    EQRColors* sharedColors = [EQRColors sharedInstance];
    [self.buttonAll setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
    
    
    //initial day is the current day
    self.dateForShow = [NSDate date];
    
    //update day label
    NSDateFormatter* dayNameFormatter = [[NSDateFormatter alloc] init];
    dayNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dayNameFormatter.dateFormat =@"EEEE, MMM d, yyyy";
    
    //assign month to nav bar title
    self.navigationItem.title = [dayNameFormatter stringFromDate:self.dateForShow];

}


-(void)viewWillAppear:(BOOL)animated{
    
    
    
}


-(void)refreshTheView{
    
    //get scheduleTrackingItems for the day
    
    //add items to a local ivar array
    
    
    
    
    
    
}


#pragma mark - day movement

-(IBAction)moveToNextDay:(id)sender{
    
    
}



-(IBAction)moveToPreviousDay:(id)sender{
    
    
    
}



#pragma mark - filter methods


-(IBAction)dismissFilters:(id)sender{
    
    self.currentFilterBitmask = EQRFilterAll;
    
    
    
}




-(IBAction)applyFilter:(id)sender{
    
    //get the color dic
    EQRColors* sharedColors = [EQRColors sharedInstance];
    
    
    if (self.currentFilterBitmask == EQRFilterAll){
        
        self.currentFilterBitmask = EQRFilterNone;
        
    }
    
    
    if ([sender tag] > 0){
        
        //if any filter button is tapped, make sure all button is set to white
        [self.buttonAll setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    //add to the bitmask based on the tag of the sender button
    switch ([sender tag]) {
        case 0:
            self.currentFilterBitmask = EQRFilterAll;
            [self.buttonAll setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
            
            //set all other buttons to white (off color)
            [self.buttonGoingShelf setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.buttonGoingPrepped setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.buttonGoingPickedUp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.buttonReturningOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.buttonReturningReturned setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.buttonReturningShelved setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            break;
            
        case 1:
            if (self.currentFilterBitmask & EQRGoingShelf){
                
                //if it already contains this bit, then remove it
                self.currentFilterBitmask = self.currentFilterBitmask & ~EQRGoingShelf;
                [self.buttonGoingShelf setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

                
            } else {
                
                //if it doesn't contain this bit, then add it
                self.currentFilterBitmask = self.currentFilterBitmask | EQRGoingShelf;
                [self.buttonGoingShelf setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];

            }
            
            break;
            
        case 2:
            if (self.currentFilterBitmask & EQRGoingPrepped){
                
                self.currentFilterBitmask = self.currentFilterBitmask & ~EQRGoingPrepped;
                [self.buttonGoingPrepped setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
            } else {
                
                self.currentFilterBitmask = self.currentFilterBitmask | EQRGoingPrepped;
                [self.buttonGoingPrepped setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];

            }
            break;
            
        case 3:
            if (self.currentFilterBitmask & EQRGoingPickedUp){
                
                self.currentFilterBitmask = self.currentFilterBitmask & ~EQRGoingPickedUp;
                [self.buttonGoingPickedUp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
            } else {
                
                self.currentFilterBitmask = self.currentFilterBitmask | EQRGoingPickedUp;
                [self.buttonGoingPickedUp setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];

            }
            break;
            
        case 4:
            if (self.currentFilterBitmask & EQRReturningOut){
                
                self.currentFilterBitmask = self.currentFilterBitmask & ~EQRReturningOut;
                [self.buttonReturningOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
            } else {
                
                self.currentFilterBitmask = self.currentFilterBitmask | EQRReturningOut;
                [self.buttonReturningOut setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];

            }
            break;
            
        case 5:
            if (self.currentFilterBitmask & EQRReturningReturned){
                
                self.currentFilterBitmask = self.currentFilterBitmask & ~EQRReturningReturned;
                [self.buttonReturningReturned setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
            } else {
                
                self.currentFilterBitmask = self.currentFilterBitmask | EQRReturningReturned;
                [self.buttonReturningReturned setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];

            }
            break;
            
        case 6:
            if (self.currentFilterBitmask & EQRReturningShelved){
                
                self.currentFilterBitmask = self.currentFilterBitmask & ~EQRReturningShelved;
                [self.buttonReturningShelved setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
            } else {
                
                self.currentFilterBitmask = self.currentFilterBitmask | EQRReturningShelved;
                [self.buttonReturningShelved setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];

            }
            break;
            
        default:
            break;
    }
    
    //if all filters removed, switch all on
    if (self.currentFilterBitmask == EQRFilterNone) {
        
        self.currentFilterBitmask = EQRFilterAll;
     
        [self.buttonAll setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
        
    }
    
    
    
    
    NSLog(@"this is the bitmask: %u", self.currentFilterBitmask);
}



#pragma mark - request box methods

-(IBAction)requestBoxOpen:(id)sender{
    
    
    
}



#pragma mark - collection view data source methods


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return 15;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"Cell";
    
    
    EQRItineraryRowCell* cell = [self.myMasterItineraryCollection dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //remove subviews
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    //and reset the cell's background color...
    cell.backgroundColor = [UIColor whiteColor];
    
    
    
    [cell initialSetupWithTitle:@"title"];
    
    
    
    
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
