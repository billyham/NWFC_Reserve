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
@property (strong, nonatomic) UIView *currentDayHighlight;

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
        
    //register for notifications
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(changeInOrientation:) name:EQRRefreshViewWhenOrientationRotates object:nil];
    
    float widthOfColumns = EQRScheduleItemWidthForDay;
    
    //make opacity of navBarDates less if in portrait orientation
    UIInterfaceOrientation orientationOnLunch = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientationOnLunch)) {
        
        self.navBarDates.alpha = 0.5;
        self.navBarWeeks.alpha = 0.5;
        
        widthOfColumns = EQRScheduleItemWidthForDayNarrow;
    }

    //indicate the current day
    if (self.dateForShowIsCurrentMonth){
        NSInteger dayAsNumber = [self getCurrentDayAsInt];
        float originForX = (dayAsNumber - 1) * widthOfColumns + self.navBarDates.frame.origin.x;
        CGRect rectForDay = CGRectMake(originForX, 0, widthOfColumns, EQRScheduleItemHeightForDay);
        
        //create a view over the day
        self.currentDayHighlight = [[UIView alloc] initWithFrame:rectForDay];
        self.currentDayHighlight.backgroundColor = [UIColor yellowColor];
        self.currentDayHighlight.alpha = 0.15;
        
        [self.view addSubview:self.currentDayHighlight];
    }
    
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

-(NSInteger)getCurrentDayAsInt{
    
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"d"];
    NSString *dayAsString = [dateFormatter stringFromDate:todayDate];
    NSInteger dayAsNumber = [dayAsString integerValue];
    return dayAsNumber;
}


#pragma mark - notifications

-(void)changeInOrientation:(NSNotification*)note{
    
    NSNumber* orientationNumber = [[note userInfo] objectForKey:@"orientation"];
    int orientationInt = (int)[orientationNumber integerValue];
    
    if ((orientationInt == UIInterfaceOrientationPortrait) || (orientationInt == UIInterfaceOrientationPortraitUpsideDown)){
        
        self.navBarDates.isNarrowFlag = YES;
        self.navBarWeeks.isNarrowFlag = YES;
        
        self.navBarDates.alpha = 0.5;
        self.navBarWeeks.alpha = 0.5;
        
        self.weeksLeadingConstraint.constant = EQRScheduleLengthOfEquipUniqueLabel+(EQRScheduleItemWidthForDayNarrow * self.weekIndicatorOffset);
        
        [self.navBarDates setNeedsDisplay];
        [self.navBarWeeks setNeedsDisplay];
        
        //dayhighlight
        if (self.dateForShowIsCurrentMonth){
            NSInteger dayAsNumber = [self getCurrentDayAsInt];
            float originForX = (dayAsNumber - 1) * EQRScheduleItemWidthForDayNarrow + self.navBarDates.frame.origin.x;
            CGRect rectForDay = CGRectMake(originForX, 0, EQRScheduleItemWidthForDayNarrow, EQRScheduleItemHeightForDay);
            
            [UIView animateWithDuration:0.25 animations:^{
                
                self.currentDayHighlight.frame = rectForDay;
            }];
        }
        
    }else{
        
        self.navBarDates.isNarrowFlag = NO;
        self.navBarWeeks.isNarrowFlag = NO;
        
        self.navBarDates.alpha = 1.0;
        self.navBarWeeks.alpha = 1.0;
        
        self.weeksLeadingConstraint.constant = EQRScheduleLengthOfEquipUniqueLabel + (EQRScheduleItemWidthForDay * self.weekIndicatorOffset);
        
        [self.navBarDates setNeedsDisplay];
        [self.navBarWeeks setNeedsDisplay];
        
        //dayhighlight
        if (self.dateForShowIsCurrentMonth){
            NSInteger dayAsNumber = [self getCurrentDayAsInt];
            float originForX = (dayAsNumber - 1) * EQRScheduleItemWidthForDay + self.navBarDates.frame.origin.x;
            CGRect rectForDay = CGRectMake(originForX, 0, EQRScheduleItemWidthForDay, EQRScheduleItemHeightForDay);
            
            [UIView animateWithDuration:0.25 animations:^{
                
                self.currentDayHighlight.frame = rectForDay;
            }];
        }
    }
    
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


#pragma mark - view disappear methods

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
