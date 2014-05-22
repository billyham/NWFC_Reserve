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
#import "EQRScheduleRequestItem.h"
#import "EQRScheduleRequestManager.h"
#import "EQRWebData.h"

@interface EQRItineraryVCntrllr ()

@property (strong, nonatomic) IBOutlet UICollectionView* myMasterItineraryCollection;
@property (strong ,nonatomic) IBOutlet UICollectionView* myNavBarCollectionView;

@property (strong, nonatomic) NSDate* dateForShow;

@property (strong, nonatomic) EQRScheduleRequestManager* privateRequestManager;

@property (strong, nonatomic) NSArray* arrayOfScheduleRequests;

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

    //register for notifications
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    //refresh the view when a change is made
    [nc addObserver:self selector:@selector(refreshTheView) name:EQRAChangeWasMadeToTheSchedule object:nil];
    
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
    
    //assign date to nav bar title
    self.navigationItem.title = [dayNameFormatter stringFromDate:self.dateForShow];
    
    //assign custom view / buttons to nav bar
    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    testView.backgroundColor = [UIColor yellowColor];
    [self.navigationController.navigationBar addSubview:testView];
    
    
    //instantiate private request manager
//    if (!self.privateRequestManager){
//        
//        self.privateRequestManager = [[EQRScheduleRequestManager alloc] init];
//    }
//    
//    //two important methods that initiate requestManager ivar arrays
//    [self.privateRequestManager resetEquipListAndAvailableQuantites];
//    [self.privateRequestManager retrieveAllEquipUniqueItems];
    
    
    //this will load the ivar array of scheduleReqeust items based on the dateForShow ivar
    [self refreshTheView];
   
    


}


-(void)viewWillAppear:(BOOL)animated{
    
    
    
}


-(void)refreshTheView{
    
    //get scheduleTrackingItems for the day
    
    //tricky cuz each tracking item actually needs to appear twice, once for pick up and once for return
    //maybe populate two sub arrays with trackingItem objects: going and returning.
    
    //add items to a local ivar array
    
    
    
    //________________________
    
    //get some schedule request items
    
    //empty out the exiting array
    if (self.arrayOfScheduleRequests){
        
        self.arrayOfScheduleRequests = nil;
    }
    
    //put the date in timestamp format
    //format the nsdates to a mysql compatible string
    NSDateFormatter* dateFormatForDate = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatForDate setLocale:usLocale];
    [dateFormatForDate setDateFormat:@"yyyy-MM-dd"];
    NSString* dateBeginString = [NSString stringWithFormat:@"%@ 00:00:00", [dateFormatForDate stringFromDate:self.dateForShow]];
    NSString* dateEndString = [NSString stringWithFormat:@"%@ 23:59:59", [dateFormatForDate stringFromDate:self.dateForShow]];

    //go get an array
    NSArray* firstArray = [NSArray arrayWithObjects:@"request_date_begin", dateBeginString, nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"request_date_end", dateEndString, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, nil];
    
    NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
    
    //First, add the 'going' schedule items
    EQRWebData* webData = [EQRWebData sharedInstance];
    [webData queryWithLink:@"EQGetScheduleItemsWithBeginDate.php" parameters:topArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
     
        for (id object in muteArray){
            
            //adjust the begin date by adding 9 hours... or 8 hours
            float secondsForOffset = 28800;    //this is 9 hours = 32400;
            NSDate* newTimeBegin = [[(EQRScheduleRequestItem*)object request_time_begin] dateByAddingTimeInterval:secondsForOffset];
            [(EQRScheduleRequestItem*)object setRequest_time_begin:newTimeBegin];
            
            [tempMuteArray addObject:object];
        }
        
    }];
    
    //Second, add the 'returning' items to the same array
    [webData queryWithLink:@"EQGetScheduleItemsWithEndDate.php" parameters:topArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        for (id object in muteArray){
            
            //adjust the date by adding 9 hours... or 8 hours
            float secondsForOffset = 28800;    //this is 9 hours = 32400;
            NSDate* newTimeEnd = [[(EQRScheduleRequestItem*)object request_time_end] dateByAddingTimeInterval:secondsForOffset];
            [(EQRScheduleRequestItem*)object setRequest_time_end:newTimeEnd];
            
            //mark the request item as a return object
            [(EQRScheduleRequestItem*) object setMarkedForReturn:YES];
            
            [tempMuteArray addObject:object];
        }
    }];
    
    
    
    
    //sort by request date begin (...and end)
    
    NSArray* tempMuteArrayAlpha = [tempMuteArray sortedArrayUsingComparator:^NSComparisonResult(EQRScheduleRequestItem* obj1, EQRScheduleRequestItem* obj2) {
        
        //use either time begin or time end depending on whether this item is going or returning
        
        NSDate* date1;
        if (!obj1.markedForReturn){
            date1 = [obj1 request_time_begin];
        } else{
            date1 = [obj1 request_time_end];
        }
        
        NSDate* date2;
        if (!obj2.markedForReturn){
            date2 = [obj2 request_time_begin];
        } else{
            date2 = [obj2 request_time_end];
        }
        
        return [date1 compare:date2];
    }];
    
    //assign to ivar
    self.arrayOfScheduleRequests = tempMuteArrayAlpha;
    
    //reload the view
    [self.myMasterItineraryCollection reloadData];
    
}


#pragma mark - day movement

-(IBAction)moveToNextDay:(id)sender{
    
    //seconds in a day 86400
    
    self.dateForShow = [self.dateForShow dateByAddingTimeInterval:86400];
    
    //update day label
    NSDateFormatter* dayNameFormatter = [[NSDateFormatter alloc] init];
    dayNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dayNameFormatter.dateFormat =@"EEEE, MMM d, yyyy";
    
    //assign day to nav bar title
    self.navigationItem.title = [dayNameFormatter stringFromDate:self.dateForShow];
    
    [self refreshTheView];
    
}



-(IBAction)moveToPreviousDay:(id)sender{
    
    self.dateForShow = [self.dateForShow dateByAddingTimeInterval:-86400];
    
    //update day label
    NSDateFormatter* dayNameFormatter = [[NSDateFormatter alloc] init];
    dayNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dayNameFormatter.dateFormat =@"EEEE, MMM d, yyyy";
    
    //assign day to nav bar title
    self.navigationItem.title = [dayNameFormatter stringFromDate:self.dateForShow];
    
    [self refreshTheView];
    
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
    
    //if all filters are added, switch 'all' on
    if ((self.currentFilterBitmask == EQRFilterAll) && ([sender tag] != 0)){
        
        [self.buttonAll setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
        
        //set all other buttons to white (off color)
        [self.buttonGoingShelf setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.buttonGoingPrepped setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.buttonGoingPickedUp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.buttonReturningOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.buttonReturningReturned setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.buttonReturningShelved setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    
    
    NSLog(@"this is the bitmask: %u", (int)self.currentFilterBitmask);
}



#pragma mark - request box methods

-(IBAction)requestBoxOpen:(id)sender{
    
    
    
}



#pragma mark - collection view data source methods


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [self.arrayOfScheduleRequests count];
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
    
    
    
    [cell initialSetupWithRequestItem:[self.arrayOfScheduleRequests objectAtIndex:indexPath.row]];
    
    
    
    
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
