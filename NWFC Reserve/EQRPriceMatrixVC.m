//
//  EQRPriceMatrixVC.m
//  Gear
//
//  Created by Dave Hanagan on 9/14/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRPriceMatrixVC.h"
#import "EQREquipSummaryGenericVCntrllr.h"
#import "EQRModeManager.h"
#import "EQRStaffUserManager.h"
#import "EQRGlobals.h"
#import "EQRColors.h"
#import "EQRScheduleRequestManager.h"
#import "EQRWebData.h"
#import "EQRDataStructure.h"
#import "EQRLineItem.h"
#import "EQRPriceMatrixCllctnViewContentVC.h"


@interface EQRPriceMatrixVC () <EQRWebDataDelegate, UICollectionViewDataSource, UICollectionViewDelegate>


@property (strong, nonatomic) EQRScheduleRequestItem *myRequestItem;

@property (strong, nonatomic) IBOutlet UICollectionView *lineItemsCollection;
@property (strong, nonatomic) NSMutableArray *arrayOfLineItems;

@property (strong, nonatomic) IBOutlet UIView *mainSubView;
@property (strong, nonatomic) IBOutlet UILabel *datesAndTimes;
@property (strong, nonatomic) IBOutlet UILabel *renterName;
@property (strong, nonatomic) IBOutlet UITextField *daysForPrice;
@property (strong, nonatomic) IBOutlet UIButton *renterPricingType;
@property (strong, nonatomic) IBOutlet UIButton *addDiscount;
@property (strong, nonatomic) IBOutlet UIButton *removeDiscount;
@property (strong, nonatomic) IBOutlet UIButton *markAsPaid;
@property (strong, nonatomic) IBOutlet UIButton *removeAsPaid;
@property (strong, nonatomic) IBOutlet UITextView *notesView;
@property (strong, nonatomic) IBOutlet UILabel *subtotal;
@property (strong, nonatomic) IBOutlet UILabel *discountTotal;
@property (strong, nonatomic) IBOutlet UILabel *total;
@property (strong, nonatomic) IBOutlet UILabel *totalPaid;
@property (strong, nonatomic) IBOutlet UILabel *totalDue;



@end

@implementation EQRPriceMatrixVC

#pragma mark - methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    

}


-(void)viewWillAppear:(BOOL)animated{
    
    
    [super viewWillAppear:animated];
}



#pragma mark - public methods

-(void)startNewTransaction:(EQRScheduleRequestItem *)request{
    
    //Is called from Request. Use info in reqeustManager.request.
    //Create a transaction
    //Create line items for each equipUnique
    
    NSLog(@"this is the scheduleRequest key_id: %@  this is the count of equips: %lu  and of misc items: %lu", request.key_id, (unsigned long)[request.arrayOfEquipmentJoins count], (unsigned long)[request.arrayOfMiscJoins count]);

    //yes, array is good
    
    self.myRequestItem = request;
    
    //fill scheduleReqeust info: name and dates
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"EEE, MMM d"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [timeFormatter setDateFormat:@"h:mm a"];
    
    NSString *pickUpDate = [NSString stringWithFormat:@"%@, %@", [dateFormatter stringFromDate:self.myRequestItem.request_date_begin], [timeFormatter stringFromDate:self.myRequestItem.request_time_begin]];
    
    NSString *returnDate = [NSString stringWithFormat:@"%@, %@", [dateFormatter stringFromDate:self.myRequestItem.request_date_end], [timeFormatter stringFromDate:self.myRequestItem.request_time_end]];
    
    self.datesAndTimes.text = [NSString stringWithFormat:@"%@ — %@", pickUpDate, returnDate];
    
    self.renterName.text = request.contact_name;
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    NSArray *firstArray = @[@"scheduleTracking_foreignKey", self.myRequestItem.key_id];
    NSArray *topArray = @[firstArray];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
       
        [webData queryForStringwithAsync:@"EQSetNewTransaction.php" parameters:topArray completion:^(NSString *object) {
           
            //string of key_id
            if (object){
                [self startNewStage2];
            }else{
                //error handling
            }
        }];
    });
}

-(void)startNewStage2{
    
    
    //create line items for each equipment join
    
    
}



-(void)editExistingTransaction:(EQRScheduleRequestItem *)request{
    
    //Is called from requestEditor or inbox
    //DB call to get existing transaction using scheduleTracking_foreignKey
    //DB call to get existing lineItems using transaction_foreignKey
    //...however, the transaction may not exist. If the reqeust changed from a non-public type to a public type in the editor.
    //error handle when no transaction returns to create a new one... call above method – startNewTransaction
    
    NSLog(@"this is the scheduleRequest key_id: %@  this is the count of equips: %lu  and of misc items: %lu", request.key_id, (unsigned long)[request.arrayOfEquipmentJoins count], (unsigned long)[request.arrayOfMiscJoins count]);
    
    //no, array is bad
    
    self.myRequestItem = request;
    
}






#pragma mark - webData delegate


-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    
    //abort if selector is unrecognized, otherwise crash
    if (![self respondsToSelector:action]){
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    [self performSelector:action withObject:currentThing];
    
#pragma clang diagnostic pop
    
}



//-(void)addEquipJoinToArray:(id)currentThing{
//    
//    float delayTime = 0.0;
//    
//    [self performSelector:@selector(addEquipJoinToArrayAfterDelay:) withObject:currentThing afterDelay:delayTime];
//    
//}
//
//
//
//-(void)addMiscJoinToArray:(id)currentThing{
//    
//    if (!currentThing){
//        return;
//    }
//    
//    [self.arrayOfMiscJoins addObject:currentThing];
//    [self genericAddItemToArray:currentThing];
//}
//
//-(void)addEquipJoinToArrayAfterDelay:(id)currentThing{
//    
//    
//    if (!currentThing){
//        return;
//    }
//    
//    [self.arrayOfEquipJoins addObject:currentThing];
//    [self genericAddItemToArray:currentThing];
//    
//}
//
//
//-(void)genericAddItemToArray:(id)currentThing{
//    
//    if (!currentThing){
//        return;
//    }
//    
//    NSMutableArray *newSubArray = [NSMutableArray arrayWithCapacity:1];
//    
//    if (self.arrayOfEquipJoinsWithStructure){
//        if ([self.arrayOfEquipJoinsWithStructure count] > 0){
//            [newSubArray addObjectsFromArray:[self.arrayOfEquipJoinsWithStructure objectAtIndex:0]];
//            [newSubArray addObject:currentThing];
//            self.arrayOfEquipJoinsWithStructure = [NSArray arrayWithObject:newSubArray];
//        }else{  //if no sub array exists yet
//            [newSubArray addObject:currentThing];
//            self.arrayOfEquipJoinsWithStructure = [NSArray arrayWithObject:newSubArray];
//        }
//    }else{  //if the main array doesn't exist yet
//        [newSubArray addObject:currentThing];
//        self.arrayOfEquipJoinsWithStructure = [NSArray arrayWithObject:newSubArray];
//    }
//    
//    [self.myEquipCollection reloadData];
//}


#pragma mark - collection view data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [self.arrayOfLineItems count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    for (UIView *subview in cell.subviews){
        [subview removeFromSuperview];
    }
    
    EQRPriceMatrixCllctnViewContentVC *pmcontent = [[EQRPriceMatrixCllctnViewContentVC alloc] initWithNibName:@"EQRPriceMatrixCllctnViewContentVC" bundle:nil];
    
    [cell.contentView addSubview:pmcontent.view];
    
    EQRLineItem *lineItem = [self.arrayOfLineItems objectAtIndex:indexPath.row];
    pmcontent.equipNameLabel.text = lineItem.equipName;
    pmcontent.distIdLabel.text = lineItem.equipDist_id;
    pmcontent.costField.text = lineItem.cost;
    
    
    return cell;
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
