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


@interface EQRPriceMatrixVC () <EQRWebDataDelegate>


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
    
    NSLog(@"this is the scheduleRequest key_id: %@  this is the count of equips: %u  and of misc items: %u", request.key_id, [request.arrayOfEquipmentJoins count], [request.arrayOfMiscJoins count]);

    //yes, array is good
    
    self.myRequestItem = request;
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    NSArray *firstArray = @[@"scheduleTracking_foreignKey", self.myRequestItem.key_id];
    NSArray *topArray = @[firstArray];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
       
        [webData queryForStringwithAsync:@"EQSetNewTransaction.php" parameters:topArray completion:^(id object) {
           
            //string of key_id
            
            
        }];
        
    });
    
}


-(void)editExistingTransaction:(EQRScheduleRequestItem *)request{
    
    //Is called from requestEditor or inbox
    //DB call to get existing transaction using scheduleTracking_foreignKey
    //DB call to get existing lineItems using transaction_foreignKey
    //...however, the transaction may not exist. If the reqeust changed from a non-public type to a public type in the editor.
    //error handle when no transaction returns to create a new one... call above method – startNewTransaction
    
    NSLog(@"this is the scheduleRequest key_id: %@  this is the count of equips: %u  and of misc items: %u", request.key_id, [request.arrayOfEquipmentJoins count], [request.arrayOfMiscJoins count]);
    
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
