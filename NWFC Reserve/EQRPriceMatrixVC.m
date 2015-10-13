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
//#import "EQRLineItem.h"
#import "EQRPriceMatrixCllctnViewContentVC.h"
#import "EQRPriceMatrixCllctnVwCll.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQREquipItem.h"
#import "EQREquipUniqueItem.h"
#import "EQRGenericNumberEditor.h"
#import "EQRTransaction.h"
#import "EQRRenterPricingTypeTableVC.h"


@interface EQRPriceMatrixVC () <EQRWebDataDelegate, UICollectionViewDataSource, UICollectionViewDelegate, EQRGenericNumberEditorDelegate, EQRPriceMatrixContentDelegate, UIAlertViewDelegate, EQRRenterPricingDelegate>

@property (strong, nonatomic) EQRScheduleRequestItem *myRequestItem;

@property (strong, nonatomic) IBOutlet UICollectionView *lineItemsCollection;

@property (strong, nonatomic) NSMutableArray *arrayOfEquipJoins;
@property (strong, nonatomic) NSMutableArray *arrayOfMiscJoins;
@property (strong, nonatomic) NSMutableArray *arrayOfLineItems;
@property (strong, nonatomic) NSMutableArray *arrayOfPriceEquipTitles;

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
@property (strong, nonatomic) IBOutlet UILabel *depositPaid;
@property (strong, nonatomic) IBOutlet UILabel *depositDue;
@property (strong, nonatomic) IBOutlet UILabel *markAsPaidStaffAndTimestamp;

@property (strong, nonatomic) EQRRenterPricingTypeTableVC *renterPricingTableVC;

@property float subtotalAsFloat;
@property float discountTotalAsFloat;
@property float totalAsFloat;
@property float totalPaidAsFloat;
@property float totalDueAsFloat;
@property float depositDueAsFloat;
@property float depositPaidAsFloat;


@property BOOL finishedLoadingEquipJoins;
@property BOOL finishedLoadingMiscJoins;
@property (strong, nonatomic) NSIndexPath *tempIndexPath;
@property BOOL tempIndexPathIsEquipJoin;
@property (strong, nonatomic) NSMutableArray *tempArrayOfEquipUniquesWithInfo;

@property (strong, nonatomic) EQRTransaction *myTransaction;

@property BOOL IAmANewRequest;
@property BOOL IAmANewTransaction;
@property BOOL needsNewPriceCalculation;

@end

@implementation EQRPriceMatrixVC 


#pragma mark - View methods

- (void)viewDidLoad {
    
    [self.lineItemsCollection registerClass:[EQRPriceMatrixCllctnVwCll class] forCellWithReuseIdentifier:@"Cell"];

    

    
    
    [super viewDidLoad];
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
}

-(void)viewDidLayoutSubviews{
    
    //add targets for tapping in text fields
    UITapGestureRecognizer* tapDaysPrice = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pricingDaysFieldTapped:)];
    [self.daysForPrice addGestureRecognizer:tapDaysPrice];
    
    [super viewDidLayoutSubviews];
}




#pragma mark - Setup Methods

-(void)sharedInitialSetup{
    
    //__fill scheduleReqeust info: name and dates
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"EEE, MMM d"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [timeFormatter setDateFormat:@"h:mm a"];
    
    NSString *pickUpDate = [NSString stringWithFormat:@"%@, %@", [dateFormatter stringFromDate:self.myRequestItem.request_date_begin], [timeFormatter stringFromDate:self.myRequestItem.request_time_begin]];
    
    NSString *returnDate = [NSString stringWithFormat:@"%@, %@", [dateFormatter stringFromDate:self.myRequestItem.request_date_end], [timeFormatter stringFromDate:self.myRequestItem.request_time_end]];
    
    self.datesAndTimes.text = [NSString stringWithFormat:@"%@ — %@", pickUpDate, returnDate];
    
    self.renterName.text = self.myRequestItem.contact_name;
    
    //__calculate default days for pricing
    NSDate *beginDateJustDay = [EQRDataStructure dateByStrippingOffTime:self.myRequestItem.request_date_begin];
    NSDate *endDateJustDay = [EQRDataStructure dateByStrippingOffTime:self.myRequestItem.request_date_end];
    float timeDifference = [endDateJustDay timeIntervalSinceDate:beginDateJustDay];
    // 86400 seconds in a day
    NSInteger daysDifference = timeDifference / 86400;
    if (daysDifference < 1){
        daysDifference = 1;
    }
    self.daysForPrice.text = [NSString stringWithFormat:@"%ld", (long)daysDifference];
    
}

-(void)startNewTransaction:(EQRScheduleRequestItem *)request{
    
    self.IAmANewRequest = YES;
    
    [self createANewTransaction:request];
}


-(void)createANewTransaction:(EQRScheduleRequestItem *)request{
    
    self.IAmANewTransaction = YES;
    
    //Is called from Request. Use info in reqeustManager.request.
    //Create a transaction
    //populate collection view with Join objects
    
    //get an array of dictionaries of alternate costs for all equipTitles included in this request
    //assign cost to each join (based on request's renter_pricing_class)
    
    //get array of available discounts
    //get array of available items for purchase (add-ons)
    
    NSLog(@"this is the scheduleRequest key_id: %@  this is the count of equips: %lu  and of misc items: %lu", request.key_id, (unsigned long)[request.arrayOfEquipmentJoins count], (unsigned long)[request.arrayOfMiscJoins count]);

    if ([request.arrayOfEquipmentJoins count] > 0){
        EQRScheduleTracking_EquipmentUnique_Join *join = [request.arrayOfEquipmentJoins objectAtIndex:0];
        NSLog(@"this is join.key_id: %@  join.titleKey: %@  join.name: %@  join.dist_id: %@", join.key_id, join.equipTitleItem_foreignKey, join.name, join.distinquishing_id);
    }
    //yes, array is good
    
    self.myRequestItem = request;
    
    [self sharedInitialSetup];
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    NSArray *firstArray = @[@"scheduleTracking_foreignKey", self.myRequestItem.key_id];
    NSArray *topArray = @[firstArray];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
       
        [webData queryForStringwithAsync:@"EQSetNewTransaction.php" parameters:topArray completion:^(NSString *object) {
           
            //string of key_id
            if (object){
                
                EQRTransaction *newTransaction = [[EQRTransaction alloc] init];
                newTransaction.key_id = object;
                newTransaction.scheduleTracking_foreignKey = self.myRequestItem.key_id;
                self.myTransaction = newTransaction;
                
                if (self.IAmANewRequest == NO){
                    [self editExistingStage2];
                }else{
                    [self startNewStage2];
                }
                
            }else{
                //error handling
            }
        }];
    });
}


-(void)startNewStage2{  //populate arrays with info from myRequest.array...
    
    if (!self.arrayOfEquipJoins){
        self.arrayOfEquipJoins = [NSMutableArray arrayWithCapacity:1];
    }
    [self.arrayOfEquipJoins removeAllObjects];
    self.arrayOfEquipJoins = [NSMutableArray arrayWithArray:self.myRequestItem.arrayOfEquipmentJoins];
    
    if (!self.arrayOfMiscJoins){
        self.arrayOfMiscJoins = [NSMutableArray arrayWithCapacity:1];
    }
    [self.arrayOfMiscJoins removeAllObjects];
    self.arrayOfMiscJoins = [NSMutableArray arrayWithArray:self.myRequestItem.arrayOfMiscJoins];
    
    
    //____get the the name and dist_id information
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    
    SEL thisSelector = @selector(addToTempArrayOfEquipJoinsWithInfo:);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryWithAsync:@"EQGetEquipUniqueItemsAll.php" parameters:nil class:@"EQREquipUniqueItem" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
            
            [self startNewStage3];
        }];
    });
}


-(void)startNewStage3{      //populate local array of joins with correct names, dist_ids
    
    for (EQRScheduleTracking_EquipmentUnique_Join *join in self.arrayOfEquipJoins){
        for (EQREquipUniqueItem *uniqueItem in self.tempArrayOfEquipUniquesWithInfo){
            if ([join.equipTitleItem_foreignKey isEqualToString:uniqueItem.equipTitleItem_foreignKey]){
                join.name = uniqueItem.name;
                join.distinquishing_id = @"N/A";
                break;
            }
        }
    }
    
    
    //combine equipJoins and miscJoins into LineItem array
    [self startNewStage4];

}

-(void)startNewStage4{  //get ALL equipTitles
    
    NSLog(@"this is the count of equipJoins: %lu", (long)[self.arrayOfEquipJoins count]);
    
    if (!self.arrayOfLineItems){
        self.arrayOfLineItems = [NSMutableArray arrayWithCapacity:1];
    }
    [self.arrayOfLineItems removeAllObjects];
    
    if (self.arrayOfEquipJoins){
        [self.arrayOfLineItems addObjectsFromArray:self.arrayOfEquipJoins];
    }
    
    if (self.arrayOfMiscJoins){
        [self.arrayOfLineItems addObjectsFromArray:self.arrayOfMiscJoins];
    }
    
    [self.lineItemsCollection reloadData];
    
    NSLog(@"this is the count of the collection view: %lu", (long)[self.lineItemsCollection numberOfItemsInSection:0]);
    
    
    //get list of all equip prices
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    
    SEL thisSelector = @selector(addToArrayOfPriceEquipTitles:);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryWithAsync:@"EQGetAllEquipTitleCosts.php" parameters:nil class:@"EQREquipItem" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
            
            [self editExistingStage4];
        }];
    });
    
}



-(void)editExistingTransaction:(EQRScheduleRequestItem *)request{
    
    self.IAmANewRequest = NO;
    self.IAmANewTransaction = NO;
    
    //Is called from requestEditor or inbox
    //DB call to get existing transaction using scheduleTracking_foreignKey
    //DB call to get existing equipJoins and miscJoins using scheduleTracking_foreignKey
    //...however, the transaction may not exist. If the reqeust changed from a non-public type to a public type in the editor.
    //error handle when no transaction returns to create a new one... call above method – startNewTransaction
    
    //populate collection view with Join objects
    
    //get an array of dictionaries of alternate costs for all equipTitles included in this request
    //assign cost to each join (based on request's renter_pricing_class) and any existing discount
    
    //get array of available discounts
    //get array of available items for purchase (add-ons)
    
//    NSLog(@"this is the scheduleRequest key_id: %@  this is the count of equips: %lu  and of misc items: %lu", request.key_id, (unsigned long)[request.arrayOfEquipmentJoins count], (unsigned long)[request.arrayOfMiscJoins count]);
    
    //no, array is bad
    
    self.myRequestItem = request;
    
    [self sharedInitialSetup];
    
    //test that a transaction exists and continue with transaction properties
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    NSArray *firstArray = @[@"scheduleTracking_foreignKey", self.myRequestItem.key_id];
    NSArray *topArray = @[firstArray];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryForStringwithAsync:@"EQGetTransactionWithScheduleRequestKey.php" parameters:topArray completion:^(EQRTransaction *transaction) {
            
            if (transaction){
                
                NSLog(@"this is the transaction's key_id: %@", transaction.key_id);
                
                self.myTransaction = transaction;
                
                //found a matching transaction for this schedule Request, go on...
                [self editExistingStage2];

            }else{
                
                //no matching transaction, create a fresh one.
                [self createANewTransaction:self.myRequestItem];
                NSLog(@"creating a new transaction because it didn't find an existing one");
            }
        }];
    });
    
}

-(void)editExistingStage2{  //get EquipJoins and MiscJoins
    
    self.finishedLoadingEquipJoins = NO;
    self.finishedLoadingMiscJoins = NO;
    
    //if the transaction object has a value for days_for_pricing, then override the calculated value...
    if (self.myTransaction.rental_days_for_pricing){
        
        //and make sure it isn't a blank value
        if (![self.myTransaction.rental_days_for_pricing isEqualToString:@""]){
            self.daysForPrice.text = self.myTransaction.rental_days_for_pricing;
        }
    }
    
    NSLog(@"EQRPriceMatrix > editExistingStage2");
    
    //________!!!!!!!! The arrays already attached to the Reqeust are meaningless  !!!!!______
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    NSArray *firstArray = @[@"scheduleTracking_foreignKey", self.myRequestItem.key_id];
    NSArray *topArray = @[firstArray];
    
    SEL thisSelector = @selector(addEquipJoinToArray:);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryWithAsync:@"EQGetScheduleEquipJoinsForPriceMatrix.php" parameters:topArray class:@"EQRScheduleTracking_EquipmentUnique_Join" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
            
            self.finishedLoadingEquipJoins = YES;
            if (self.finishedLoadingMiscJoins == YES){
                [self editExistingStage3];
            }
        }];
    });
    
    SEL thatSelector = @selector(addMiscJoinToArray:);
    
    EQRWebData *webData2 = [EQRWebData sharedInstance];
    webData2.delegateDataFeed = self;
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue2, ^{
        
        [webData2 queryWithAsync:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:topArray class:@"EQRMiscJoin" selector:thatSelector completion:^(BOOL isLoadingFlagUp) {
            
            self.finishedLoadingMiscJoins = YES;
            if (self.finishedLoadingEquipJoins == YES){
                [self editExistingStage3];
            }
        }];
    });
}

-(void)editExistingStage3{  //get prices for equip titles
    
    NSLog(@"this is the count of equipJoins: %lu", (long)[self.arrayOfEquipJoins count]);
    
    for (EQRScheduleTracking_EquipmentUnique_Join *join in self.arrayOfEquipJoins){
        if (join.cost){
            if (![join.cost isEqualToString:@""]){
                join.hasAStoredCostValue = YES;
            }
        }
    }
    
    if (!self.arrayOfLineItems){
        self.arrayOfLineItems = [NSMutableArray arrayWithCapacity:1];
    }
    [self.arrayOfLineItems removeAllObjects];
    
    if (self.arrayOfEquipJoins){
        [self.arrayOfLineItems addObjectsFromArray:self.arrayOfEquipJoins];
    }
    
    if (self.arrayOfMiscJoins){
        [self.arrayOfLineItems addObjectsFromArray:self.arrayOfMiscJoins];
    }
    
    [self.lineItemsCollection reloadData];
    
    NSLog(@"this is the count of the collection view: %lu", (long)[self.lineItemsCollection numberOfItemsInSection:0]);
    
    
    //get list of all equip prices
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    NSArray *firstArray = @[@"scheduleTracking_foreignKey", self.myRequestItem.key_id];
    NSArray *topArray = @[firstArray];
    
    SEL thisSelector = @selector(addToArrayOfPriceEquipTitles:);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryWithAsync:@"EQGetEquipTitleCostsWithScheduleRequest.php" parameters:topArray class:@"EQREquipItem" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
            
            [self editExistingStage4];
        }];
    });
    
   
}

//this is implemented by both
-(void)editExistingStage4{ //populate collection view objects with available prices
    
    NSLog(@"inside editExistingStage 4, count of arrayOfPriceEquipTitles: %lu", (unsigned long)[self.arrayOfPriceEquipTitles count]);
    
    SEL priceSelector;
    
    //default to the artist rate
    priceSelector = @selector(price_artist);
    
    //test if a renter Pricing exists yet, if not bring up tableVC
    if (!self.myTransaction.renter_pricing_class || [self.myTransaction.renter_pricing_class isEqualToString:@""]){
        
        [self selectRenterPricingType:nil];
        
    } else {
        
        [self.renterPricingType setTitle:[NSString stringWithFormat:@"Renter Pricing Type: %@", self.myTransaction.renter_pricing_class] forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
        
        if ([self.myTransaction.renter_pricing_class isEqualToString:EQRPriceCommerial]){
            priceSelector = @selector(price_commercial);
        }else if ([self.myTransaction.renter_pricing_class isEqualToString:EQRPriceArtist]){
            priceSelector = @selector(price_artist);
        }else if ([self.myTransaction.renter_pricing_class isEqualToString:EQRPriceStudent]){
            priceSelector = @selector(price_student);
        }else if ([self.myTransaction.renter_pricing_class isEqualToString:EQRPriceFaculty]){
            priceSelector = @selector(price_nonprofit);
        }else if ([self.myTransaction.renter_pricing_class isEqualToString:EQRPriceStaff]){
            priceSelector = @selector(price_staff);
        }
    }
    
    for (EQRScheduleTracking_EquipmentUnique_Join *join in self.arrayOfEquipJoins){
        
        NSLog(@"this is the join's cost value: %@", join.cost);
        
        //only continue if join.cost has no value yet or if rental pricing type has changed
        if (([join.cost isEqualToString:@""]) || !join.cost || self.needsNewPriceCalculation){
            
//            //don't continue if the join has a stored value
//            if (join.hasAStoredCostValue == NO){
            
                for (EQREquipItem *titleItem in self.arrayOfPriceEquipTitles){
                    
                    if ([join.equipTitleItem_foreignKey isEqualToString:titleItem.key_id]){
                        //found an equipTitle match
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        join.cost = [titleItem performSelector:priceSelector];
#pragma clang diagnostic pop
                        break;
                    }
                }
//            }
        }
        
        //only continue if join.deposit has no value yet
        if (([join.deposit isEqualToString:@""]) || !join.deposit){
            
            for (EQREquipItem *titleItem in self.arrayOfPriceEquipTitles){
                
                if ([join.equipTitleItem_foreignKey isEqualToString:titleItem.key_id]){
                    //found an equipTitle match
                    join.deposit = titleItem.price_deposit;
                    break;
                }
            }
        }
        
    }
    
    //do the same for line items array????
    for (EQRScheduleTracking_EquipmentUnique_Join *join2 in self.arrayOfLineItems){
        
        //only continue if the lineItem is an EquipJoin
        if ([join2 respondsToSelector:@selector(equipTitleItem_foreignKey)]){
            
            //only continue if join.cost has no value yet, or if rental pricing type has changed
            if (([join2.cost isEqualToString:@""]) || !join2.cost || self.needsNewPriceCalculation){
                
//                //don't continue if the join has a stored value
//                if (join2.hasAStoredCostValue == NO){
                
                    for (EQREquipItem *titleItem in self.arrayOfPriceEquipTitles){
                        
                        if ([join2.equipTitleItem_foreignKey isEqualToString:titleItem.key_id]){
                            //found an equipTitle match
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                            join2.cost = [titleItem performSelector:priceSelector];
#pragma clang diagnostic pop
                            break;
                        }
                    }
//                }
            }
        }
        
        //only continue if the lineItem is an EquipJoin
        if ([join2 respondsToSelector:@selector(equipTitleItem_foreignKey)]){
            
            //only continue if join.cost has no value yet
            if (([join2.deposit isEqualToString:@""]) || !join2.deposit){
                
                for (EQREquipItem *titleItem in self.arrayOfPriceEquipTitles){
                    
                    if ([join2.equipTitleItem_foreignKey isEqualToString:titleItem.key_id]){
                        //found an equipTitle match
                        join2.deposit = titleItem.price_deposit;
                        break;
                    }
                }
            }
        }
    }
    
    //reload the collection view to display cost data
    [self.lineItemsCollection reloadData];
    
    //set prices
    //FORK!!
    //_1_ If reading an existing transaction, enter the stored values
    //_2- If just created a new trasaction or after having changed the rental pricing type, then calculate values
    
    if (self.IAmANewTransaction || self.needsNewPriceCalculation){
        
        self.needsNewPriceCalculation = NO;
        
        [self calculatePriceStage1];
        
    }else{
     
        self.subtotalAsFloat = [self.myTransaction.subtotal floatValue];
        self.subtotal.text = [NSString stringWithFormat:@"Subtotal: %5.2f", self.subtotalAsFloat];

        self.discountTotalAsFloat = [self.myTransaction.discount_total floatValue];
        self.discountTotal.text = [NSString stringWithFormat:@"Discount Total: %5.2f", self.discountTotalAsFloat];
        
        self.totalAsFloat = [self.myTransaction.total_due floatValue];
        self.total.text = [NSString stringWithFormat:@"Total: %5.2f", self.totalAsFloat];

        self.totalPaidAsFloat = [self.myTransaction.total_paid floatValue];
        self.totalPaid.text = [NSString stringWithFormat:@"Total Paid: %5.2f", self.totalPaidAsFloat];
        
        self.totalDueAsFloat = self.totalAsFloat - self.totalPaidAsFloat;
        self.totalDue.text = [NSString stringWithFormat:@"Total Due: %5.2f", self.totalDueAsFloat];
        
        self.depositDueAsFloat = [self.myTransaction.deposit_due floatValue];
        self.depositDue.text = [NSString stringWithFormat:@"Deposit Due: %5.2f", self.depositDueAsFloat];
        
        self.depositPaidAsFloat = [self.myTransaction.deposit_paid floatValue];
        self.depositPaid.text = [NSString stringWithFormat:@"Deposit Paid: %5.2f", self.depositPaidAsFloat];
        
        if (self.myTransaction.payment_staff_foreignKey){
            if (![self.myTransaction.payment_staff_foreignKey isEqualToString:@""]){
                if (self.myTransaction.payment_timestamp){
                    
                    self.markAsPaid.hidden = YES;
                    self.removeAsPaid.hidden = NO;
                    
                    //is a valid marked as paid value
                    EQRStaffUserManager *staffManager = [EQRStaffUserManager sharedInstance];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                    dateFormatter.dateFormat = @"MMM dd, yyyy";
                    self.markAsPaidStaffAndTimestamp.text = [NSString stringWithFormat:@"%@ - %@", staffManager.currentStaffUser.first_name, [dateFormatter stringFromDate:self.myTransaction.payment_timestamp]];
                    
                }
            }
        }
    }
}


-(void)calculatePriceStage1{
    
    //go through lineItem array and add all cost properties
    //multiply by days for pricing
    //enter into subtotal
    
    float sumOfCosts = 0;
    float sumOfDeposits = 0;
    for (EQRScheduleTracking_EquipmentUnique_Join *join in self.arrayOfLineItems){
        float costAsFloat = [join.cost floatValue];
        float depositAsFloat = [join.deposit floatValue];
        sumOfCosts = sumOfCosts + costAsFloat;
        sumOfDeposits = sumOfDeposits + depositAsFloat;
    }
    
    //limit deposit amount to $1,000
    if (sumOfDeposits > 1000){
        sumOfDeposits = 1000;
    }
    
    float daysForPricingAsFloat = [self.daysForPrice.text floatValue];
    
    float subTotal = daysForPricingAsFloat * sumOfCosts;
    
    //subtotal
    self.subtotalAsFloat = subTotal;
    self.subtotal.text = [NSString stringWithFormat:@"Subtotal: %5.2f", subTotal];
    
    //discount total
    self.discountTotalAsFloat = 0;
    self.discountTotal.text = [NSString stringWithFormat:@"Discount Total: %5.2f", self.discountTotalAsFloat];
    
    self.totalAsFloat = self.subtotalAsFloat - self.discountTotalAsFloat;
    self.total.text = [NSString stringWithFormat:@"Total: %5.2f", self.totalAsFloat];
    
    self.totalPaidAsFloat = 0;
    self.totalPaid.text = [NSString stringWithFormat:@"Total Paid: %5.2f", self.totalPaidAsFloat];
    
    self.totalDueAsFloat = self.totalAsFloat - self.totalPaidAsFloat;
    self.totalDue.text = [NSString stringWithFormat:@"Total Due: %5.2f", self.totalDueAsFloat];
    
    //--
    self.depositDueAsFloat = sumOfDeposits;
    self.depositDue.text = [NSString stringWithFormat:@"Deposit Due: %5.2f", self.depositDueAsFloat];
    
    self.depositPaidAsFloat = 0;
    self.depositPaid.text = [NSString stringWithFormat:@"Deposit Paid: %5.2f", self.depositPaidAsFloat];
    //--
    
    //____and save these values to Transaction...
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    NSArray *firstArray = @[@"subtotal", [NSString stringWithFormat:@"%5.2f", self.subtotalAsFloat]];
    NSArray *secondArray = @[@"total_due", [NSString stringWithFormat:@"%5.2f", self.totalAsFloat]];
    NSArray *thirdArray = @[@"discount_total", [NSString stringWithFormat:@"%5.2f", self.discountTotalAsFloat]];
    NSArray *fourthArray = @[@"total_paid", [NSString stringWithFormat:@"%5.2f", self.totalPaidAsFloat]];
    NSArray *fifthArray = @[@"deposit_due", [NSString stringWithFormat:@"%5.2f", self.depositDueAsFloat]];
    NSArray *sixthArray = @[@"deposit_paid", [NSString stringWithFormat:@"%5.2f", self.depositPaidAsFloat]];
    NSArray *seventhArray = @[@"key_id", self.myTransaction.key_id];
    NSArray *topArray = @[firstArray, secondArray, thirdArray, fourthArray, fifthArray, sixthArray, seventhArray];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryForStringwithAsync:@"EQAlterTransactionTotals.php" parameters:topArray completion:^(NSString *returnKey) {
            
            if ([returnKey isEqualToString:self.myTransaction.key_id]){
                
                //everthign is cool
                
            }else{
                
                //error handling
                NSLog(@"failed to successfully alter transaction prices");
            }
        }];
    });
    
}

#pragma mark - Having tapped on things

#pragma mark Select Rental Pricing Type

-(IBAction)selectRenterPricingType:(id)sender{
    
    UIStoryboard *captureStoryboard = [UIStoryboard storyboardWithName:@"Pricing" bundle:nil];
    EQRRenterPricingTypeTableVC *pricingTableVC = [captureStoryboard instantiateViewControllerWithIdentifier:@"RenterPricingTableVC"];
    
    self.renterPricingTableVC = pricingTableVC;
    self.renterPricingTableVC.delegate = self;
    self.renterPricingTableVC.modalPresentationStyle = UIModalPresentationFormSheet;
    
    if (self.myTransaction.renter_pricing_class){
        if (![self.myTransaction.renter_pricing_class isEqualToString:@""]){
            [self.renterPricingTableVC shouldSelect:self.myTransaction.renter_pricing_class];
        }
        
    }
    
    [self presentViewController:self.renterPricingTableVC animated:YES completion:^{
        
        
    }];
}


// EQRRentalPricingTypeTableDelegate method
-(void)didSelectRenterPricingType:(NSString *)renterPricingType{
    
    if (renterPricingType){
        
        //update view
//        [self.renterPricingType setTitle:[NSString stringWithFormat:@"Renter Pricing Type: %@", renterPricingType] forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
        
        //update schedule object
        self.myTransaction.renter_pricing_class = renterPricingType;
        
        //this will update the view
        self.needsNewPriceCalculation = YES;
        [self editExistingStage4];
        
        
        
        //update database
        EQRWebData *webData = [EQRWebData sharedInstance];
        NSArray *firstArray = @[@"key_id", self.myTransaction.key_id];
        NSArray *secondArray = @[@"renter_pricing_class", self.myTransaction.renter_pricing_class];
        NSArray *topArray = @[firstArray, secondArray];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
           
            [webData queryForStringwithAsync:@"EQAlterTransactiontRenterPricing.php" parameters:topArray completion:^(NSString *returnString) {
               
                if ([returnString isEqualToString:self.myTransaction.key_id]){
                    
                    //it's cool
                    
                }else{
                    
                    //error handling
                    NSLog(@"failed to successfully alter scheduleTracking renterPricing");
                }
                
            }];
            
        });
    }
}



#pragma mark Mark As Paid or Unpaid

-(IBAction)markAsPaid:(id)sender{
    
    //MUST CHECK THAT THE USER HAS LOGGED IN FIRST:
    EQRStaffUserManager* staffManager = [EQRStaffUserManager sharedInstance];
    if (!staffManager.currentStaffUser){
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Current User" message:@"Please log in as a user before marking an item complete or incomplete" delegate:[self presentingViewController] cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            [alert show];
        }];
        
        return;
    }
    
    NSString *userName = staffManager.currentStaffUser.first_and_last;

    UIAlertView *alertConfirmation = [[UIAlertView alloc] initWithTitle:@"Mark as PAID" message:[NSString stringWithFormat:@"PAID and stamped with staff signature: %@", userName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    [alertConfirmation show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if ([alertView.title isEqualToString:@"Mark as PAID"]){
        
        if (buttonIndex != 1){
            return;
        }
        
        //update display
        //update transaction property with staff key_id and timestamp
        //date Transaction DB with staff key_id and timestamp
        
        EQRStaffUserManager *staffManager = [EQRStaffUserManager sharedInstance];
        
        self.markAsPaid.hidden = YES;
        self.removeAsPaid.hidden = NO;
        
        //formatted string for display
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        dateFormatter.dateFormat = @"MMM dd, yyyy";
        self.markAsPaidStaffAndTimestamp.text = [NSString stringWithFormat:@"%@ - %@", staffManager.currentStaffUser.first_name, [dateFormatter stringFromDate:[NSDate date]]];
        self.totalPaidAsFloat = self.totalAsFloat;
        self.totalDueAsFloat = 0;
        self.totalPaid.text = [NSString stringWithFormat:@"Total Paid %5.2f", self.totalPaidAsFloat];
        self.totalDue.text = @"Total Due: 0";
        self.depositPaidAsFloat = self.depositDueAsFloat;
        self.depositPaid.text = [NSString stringWithFormat:@"Deposit Paid: %5.2f", self.depositPaidAsFloat];
        
        self.myTransaction.payment_timestamp = [NSDate date];
        self.myTransaction.payment_staff_foreignKey = staffManager.currentStaffUser.key_id;
        self.myTransaction.total_paid = [NSString stringWithFormat:@"%5.2f", self.totalPaidAsFloat];
        self.myTransaction.total_due = @"0";
        self.myTransaction.deposit_paid = [NSString stringWithFormat:@"%5.2f", self.depositPaidAsFloat];
        
        
        //formatted string for MYSQL
        NSString *stringForDate = [EQRDataStructure dateAsString:[NSDate date]];
        EQRWebData *webData = [EQRWebData sharedInstance];
        NSArray *firstArray = @[@"key_id", self.myTransaction.key_id];
        NSArray *secondArray = @[@"payment_timestamp", stringForDate];
        NSArray *thirdarray = @[@"payment_staff_foreignKey", staffManager.currentStaffUser.key_id];
        NSArray *fourthArray = @[@"payment_type", @""];
        NSArray *fifthArray = @[@"total_paid", self.myTransaction.total_paid];
        NSArray *sixthArray = @[@"deposit_paid", self.myTransaction.deposit_paid];
        NSArray *topArray = @[firstArray, secondArray, thirdarray, fourthArray, fifthArray, sixthArray];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            
            [webData queryForStringwithAsync:@"EQAlterTransactionMarkAsPaid.php" parameters:topArray completion:^(NSString *returnKey) {
                
                if ([returnKey isEqualToString:self.myTransaction.key_id]){
                    
                    //everthign is cool
                    
                }else{
                    
                    //error handling
                    NSLog(@"failed to successfully alter transaction mark as paid");
                }
            }];
        });
    }
}

-(IBAction)markAsNotPaid:(id)sender{
    
    //update display
    //update transaction property with staff key_id and timestamp
    //date Transaction DB with staff key_id and timestamp
    
    self.markAsPaid.hidden = NO;
    self.removeAsPaid.hidden = YES;
    
    self.markAsPaidStaffAndTimestamp.text = @"";
    self.totalPaidAsFloat = 0;
    self.totalDueAsFloat = self.totalAsFloat;
    self.totalPaid.text = @"Total Paid: 0";
    self.totalDue.text = [NSString stringWithFormat:@"Total Due: %5.2f", self.totalDueAsFloat];
    self.depositPaidAsFloat = 0;
    self.depositPaid.text = @"Deposit Paid: 0";
    
    self.myTransaction.payment_timestamp = nil;
    self.myTransaction.payment_staff_foreignKey = @"";
    self.myTransaction.total_paid = @"0";
    self.myTransaction.total_due = [NSString stringWithFormat:@"%5.2f", self.totalDueAsFloat];
    self.myTransaction.deposit_paid = @"0";
    
    
    //formatted string for MYSQL
    EQRWebData *webData = [EQRWebData sharedInstance];
    NSArray *firstArray = @[@"key_id", self.myTransaction.key_id];
    NSArray *secondArray = @[@"payment_timestamp", @""];
    NSArray *thirdarray = @[@"payment_staff_foreignKey", @""];
    NSArray *fourthArray = @[@"payment_type", @""];
    NSArray *fifthArray = @[@"total_paid", self.myTransaction.total_paid];
    NSArray *sixthArray = @[@"deposit_paid", self.myTransaction.deposit_paid];
    NSArray *topArray = @[firstArray, secondArray, thirdarray, fourthArray, fifthArray, sixthArray];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryForStringwithAsync:@"EQAlterTransactionMarkAsPaid.php" parameters:topArray completion:^(NSString *returnKey) {
            
            if ([returnKey isEqualToString:self.myTransaction.key_id]){
                
                //everthign is cool
                
            }else{
                
                //error handling
                NSLog(@"failed to successfully alter transaction mark as unpaid");
            }
        }];
    });
    
}

#pragma mark Days for Pricing Field

-(IBAction)pricingDaysFieldTapped:(id)sender{
    
    EQRGenericNumberEditor *numberEditor = [[EQRGenericNumberEditor alloc] initWithNibName:@"EQRGenericNumberEditor" bundle:nil];
    numberEditor.delegate = self;
    numberEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:numberEditor animated:YES completion:^{
       
        [numberEditor initalSetupWithTitle:@"Enter Number of Days for Pricing" subTitle:[NSString stringWithFormat:@"For rental happening %@", self.daysForPrice.text] currentText:@"6" returnMethod:@"updateDaysForPrice:"];
        
    }];
}

//Price Matrix Content VC delegate method
-(void)launchCostEditorWithJoinKeyID:(NSString *)joinKeyID isEquipJoin:(BOOL)isEquipJoin cost:(NSString *)cost indexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"PriceMatrix > launchCostEditorWithJoinKeyID this is the joinKeyID: %@", joinKeyID);
    
    self.tempIndexPath = indexPath;
    self.tempIndexPathIsEquipJoin = isEquipJoin;
    
    EQRGenericNumberEditor *numberEditor = [[EQRGenericNumberEditor alloc] initWithNibName:@"EQRGenericNumberEditor" bundle:nil];
    numberEditor.delegate = self;
    numberEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:numberEditor animated:YES completion:^{
        
        [numberEditor initalSetupWithTitle:@"Enter New Daily Cost" subTitle:nil currentText:cost returnMethod:@"updateJoinRowWithNewCost:"];
        
    }];
}

-(void)launchDepositEditorWithJoinKeyID:(NSString *)joinKeyID isEquipJoin:(BOOL)isEquipJoin deposit:(NSString *)deposit indexPath:(NSIndexPath *)indexPath{
    
    self.tempIndexPath = indexPath;
    self.tempIndexPathIsEquipJoin = isEquipJoin;
    
    EQRGenericNumberEditor *numberEditor = [[EQRGenericNumberEditor alloc] initWithNibName:@"EQRGenericNumberEditor" bundle:nil];
    numberEditor.delegate = self;
    numberEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:numberEditor animated:YES completion:^{
        
        [numberEditor initalSetupWithTitle:@"Enter New Deposit Amount" subTitle:nil currentText:deposit returnMethod:@"updateJoinRowWithNewDeposit:"];
        
    }];
    
}




#pragma mark - Generic Number Editor delegate method

-(void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod{
    
    SEL returnMethodForReal = NSSelectorFromString(returnMethod);

    [self performSelector:returnMethodForReal withObject:returnText afterDelay:0];
    
}

-(void)updateDaysForPrice:(NSString *)returnText{
    
    self.daysForPrice.text = returnText;
    
    NSLog(@"this is the transaction key_id: %@", self.myTransaction.key_id);
    
    //udpate database
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    NSArray *firstArray = @[@"key_id", self.myTransaction.key_id];
    NSArray *secondArray = @[@"rental_days_for_pricing", returnText];
    NSArray *topArray = @[firstArray, secondArray];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryForStringwithAsync:@"EQAlterTransactionDaysForPrice.php" parameters:topArray completion:^(NSString *returnKey) {
            
            if ([returnKey isEqualToString:self.myTransaction.key_id]){
                
                //everthign is cool
                
            }else{
                
                //error handling
                NSLog(@"failed to successfully alter transaction days for pricing");
            }
        }];
    });
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self calculatePriceStage1];
    }];
}


-(void)updateJoinRowWithNewCost:(NSString *)returnText{
    
    NSLog(@"inside updateJoinRowWithNewCost");
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    
    //______is it an EquipJoin or a MiscJoin?
    if (self.tempIndexPathIsEquipJoin){
        
        EQRScheduleTracking_EquipmentUnique_Join *join = [self.arrayOfLineItems objectAtIndex:self.tempIndexPath.row];
        join.cost = returnText;
        join.hasAStoredCostValue = YES;
        
        [self.lineItemsCollection reloadData];
        
        //udpate database
        //only if join has a key_id, it won't if it's a new request
        if (join.key_id){
            NSArray *firstArray = @[@"key_id", join.key_id];
            NSArray *secondArray = @[@"cost", returnText];
            NSArray *topArray = @[firstArray, secondArray];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                
                [webData queryForStringwithAsync:@"EQAlterCostOfScheduleEquipJoin.php" parameters:topArray completion:^(NSString *returnKey) {
                    
                    if ([returnKey isEqualToString:join.key_id]){
                        
                        //everthign is cool
                        
                    }else{
                        
                        //error handling
                        NSLog(@"failed to successfully alter transaction equipJoin price");
                    }
                }];
            });
        }
        
    }else{     // Must be a MiscJoin
        
        EQRMiscJoin *join = [self.arrayOfLineItems objectAtIndex:self.tempIndexPath.row];
        join.cost = returnText;
        
        [self.lineItemsCollection reloadData];
        
        //udpate database
        NSArray *firstArray = @[@"key_id", join.key_id];
        NSArray *secondArray = @[@"cost", returnText];
        NSArray *topArray = @[firstArray, secondArray];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            
            [webData queryForStringwithAsync:@"EQAlterCostOfMiscJoin.php" parameters:topArray completion:^(NSString *returnKey) {
                
                if ([returnKey isEqualToString:join.key_id]){
                    
                    //everthign is cool
                    
                }else{
                    
                    //error handling
                    NSLog(@"failed to successfully alter transaction miscJoin price");
                }
            }];
        });
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self calculatePriceStage1];
    }];
}

-(void)updateJoinRowWithNewDeposit:(NSString *)returnText{
    
    NSLog(@"inside updateJoinRowWithNewDeposit");

    
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    
    //______is it an EquipJoin or a MiscJoin?
    if (self.tempIndexPathIsEquipJoin){
        
        EQRScheduleTracking_EquipmentUnique_Join *join = [self.arrayOfLineItems objectAtIndex:self.tempIndexPath.row];
        join.deposit = returnText;
        
        NSLog(@"this is the Join.key_id: %@  this is returnText: %@", join.key_id, returnText);
        
        [self.lineItemsCollection reloadData];
        
        //udpate database
        //only if join has a key_id, it won't if it's a new request
        if (join.key_id){
            NSArray *firstArray = @[@"key_id", join.key_id];
            NSArray *secondArray = @[@"deposit", returnText];
            NSArray *topArray = @[firstArray, secondArray];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                
                [webData queryForStringwithAsync:@"EQAlterDepositOfScheduleEquipJoin.php" parameters:topArray completion:^(NSString *returnKey) {
                    
                    if ([returnKey isEqualToString:join.key_id]){
                        
                        //everthign is cool
                        
                    }else{
                        
                        //error handling
                        NSLog(@"failed to successfully alter transaction equipJoin deposit");
                    }
                }];
            });
        }
        
    }else{     // Must be a MiscJoin
        
        EQRMiscJoin *join = [self.arrayOfLineItems objectAtIndex:self.tempIndexPath.row];
        join.deposit = returnText;
        
        [self.lineItemsCollection reloadData];
        
        //udpate database
        NSArray *firstArray = @[@"key_id", join.key_id];
        NSArray *secondArray = @[@"deposit", returnText];
        NSArray *topArray = @[firstArray, secondArray];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            
            [webData queryForStringwithAsync:@"EQAlterDepositOfMiscJoin.php" parameters:topArray completion:^(NSString *returnKey) {
                
                if ([returnKey isEqualToString:join.key_id]){
                    
                    //everthign is cool
                    
                }else{
                    
                    //error handling
                    NSLog(@"failed to successfully alter transaction miscJoin deposit");
                }
            }];
        });
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self calculatePriceStage1];
    }];
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

-(void)addMiscJoinToArray:(id)currentThing{
    
    if (!currentThing){
        return;
    }
    
    if (!self.arrayOfMiscJoins){
        self.arrayOfMiscJoins = [NSMutableArray arrayWithCapacity:1];
    }
    
    [self.arrayOfMiscJoins addObject:currentThing];
}

-(void)addEquipJoinToArray:(id)currentThing{
    
    if (!currentThing){
        return;
    }
    
    if (!self.arrayOfEquipJoins){
        self.arrayOfEquipJoins = [NSMutableArray arrayWithCapacity:1];
    }
    
    NSLog(@"adding equipJoin to array");
    [self.arrayOfEquipJoins addObject:currentThing];
}

-(void)addToArrayOfPriceEquipTitles:(id)currentThing{

    if (!currentThing){
        return;
    }
    
    if (!self.arrayOfPriceEquipTitles){
        self.arrayOfPriceEquipTitles = [NSMutableArray arrayWithCapacity:1];
    }
    
    [self.arrayOfPriceEquipTitles addObject:currentThing];
}

-(void)addToTempArrayOfEquipJoinsWithInfo:(id)currentThing{
    
    if (!currentThing){
        return;
    }
    
    if (!self.tempArrayOfEquipUniquesWithInfo){
        self.tempArrayOfEquipUniquesWithInfo = [NSMutableArray arrayWithCapacity:1];
    }
    
    [self.tempArrayOfEquipUniquesWithInfo addObject:currentThing];
}


#pragma mark - collection view data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [self.arrayOfLineItems count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    EQRPriceMatrixCllctnVwCll *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    for (UIView *subview in cell.contentView.subviews){
        [subview removeFromSuperview];
    }
    
    EQRPriceMatrixCllctnViewContentVC *pmcontent = [[EQRPriceMatrixCllctnViewContentVC alloc] initWithNibName:@"EQRPriceMatrixCllctnViewContentVC" bundle:nil];
    
    cell.myContentVC = pmcontent;
    cell.myContentVC.delegate = self;
    
    if ([[self.arrayOfLineItems objectAtIndex:indexPath.row] respondsToSelector:@selector(distinquishing_id)]){
        //must be equipJoin
        
        EQRScheduleTracking_EquipmentUnique_Join *join = [self.arrayOfLineItems objectAtIndex:indexPath.row];
        [cell.myContentVC initialSetupWithName:join.name
                                        distID:join.distinquishing_id
                                          cost:join.cost
                                       deposit:join.deposit
                                     joinKeyID:join.key_id
                                     indexPath:indexPath
                                   isEquipJoin:YES
                           hasAStoredCostValue:join.hasAStoredCostValue];
        
        NSLog(@"name: %@  distID: %@  cost: %@  deposit: %@", join.name, join.distinquishing_id, join.cost, join.deposit);
        
    }else{
        //must be miscJoin
        
        EQRMiscJoin *join = [self.arrayOfLineItems objectAtIndex:indexPath.row];
        [cell.myContentVC initialSetupWithName:join.name
                                        distID:nil
                                          cost:join.cost
                                       deposit:join.deposit
                                     joinKeyID:join.key_id
                                     indexPath:indexPath
                                   isEquipJoin:NO
                           hasAStoredCostValue:NO];
    }

    [cell.contentView addSubview:cell.myContentVC.view];
    
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
