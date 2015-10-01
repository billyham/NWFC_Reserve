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
#import "EQRGenericNumberEditor.h"
#import "EQRTransaction.h"


@interface EQRPriceMatrixVC () <EQRWebDataDelegate, UICollectionViewDataSource, UICollectionViewDelegate, EQRGenericNumberEditorDelegate, EQRPriceMatrixContentDelegate>

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

@property BOOL finishedLoadingEquipJoins;
@property BOOL finishedLoadingMiscJoins;
@property (strong, nonatomic) NSIndexPath *tempIndexPath;
@property BOOL tempIndexPathIsEquipJoin;

@property (strong, nonatomic) EQRTransaction *myTransaction;

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
    
    //Is called from Request. Use info in reqeustManager.request.
    //Create a transaction
    //populate collection view with Join objects
    
    //get an array of dictionaries of alternate costs for all equipTitles included in this request
    //assign cost to each join (based on request's renter_pricing_class)
    
    //get array of available discounts
    //get array of available items for purchase (add-ons)
    
//    NSLog(@"this is the scheduleRequest key_id: %@  this is the count of equips: %lu  and of misc items: %lu", request.key_id, (unsigned long)[request.arrayOfEquipmentJoins count], (unsigned long)[request.arrayOfMiscJoins count]);

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
                
                //__________!!!!!!!!  Just testing this... remove  !!!!!________
                [self editExistingStage2];
                
//                [self startNewStage2];
                
            }else{
                //error handling
            }
        }];
    });
}


-(void)startNewStage2{
    

}


-(void)startNewStage3{
    

    
}



-(void)editExistingTransaction:(EQRScheduleRequestItem *)request{
    
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
                [self startNewTransaction:self.myRequestItem];
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

-(void)editExistingStage4{ //populate collection view objects with available prices
    
    NSLog(@"inside editExistingStage 4, count of arrayOfPriceEquipTitles: %lu", (unsigned long)[self.arrayOfPriceEquipTitles count]);
    
    for (EQRScheduleTracking_EquipmentUnique_Join *join in self.arrayOfEquipJoins){
        
        //only continue if join.cost has no value yet
        if ([join.cost isEqualToString:@""]){
            
            for (EQREquipItem *titleItem in self.arrayOfPriceEquipTitles){
                
                if ([join.equipTitleItem_foreignKey isEqualToString:titleItem.key_id]){
                    //found an equipTitle match
                    join.cost = titleItem.price_artist;
                    break;
                }
            }
        }
    }
    
    
    //do the same for line items array????
    for (EQRScheduleTracking_EquipmentUnique_Join *join2 in self.arrayOfLineItems){
        
        //only continue if the lineItem is an EquipJoin
        if ([join2 respondsToSelector:@selector(equipTitleItem_foreignKey)]){
            
            //only continue if join.cost has no value yet
            if ([join2.cost isEqualToString:@""]){
                
                for (EQREquipItem *titleItem in self.arrayOfPriceEquipTitles){
                    
                    NSLog(@"this is titleItem.key_id: %@  and join.equipTitleItem_foreignKey: %@", titleItem.key_id, join2.equipTitleItem_foreignKey);
                    
                    if ([join2.equipTitleItem_foreignKey isEqualToString:titleItem.key_id]){
                        NSLog(@"found a match");
                        //found an equipTitle match
                        join2.cost = titleItem.price_artist;
                        break;
                    }
                }
            }
        }
    }
    
    //reload the collection view to display cost data
    [self.lineItemsCollection reloadData];
    
    //set price
    [self calculatePriceStage1];
    
}


-(void)calculatePriceStage1{
    
    //go through lineItem array and add all cost properties
    //multiply by days for pricing
    //enter into subtotal
    
    NSInteger sumOfCosts = 0;
    for (EQRScheduleTracking_EquipmentUnique_Join *join in self.arrayOfLineItems){
        NSInteger costAsInt = [join.cost integerValue];
        sumOfCosts = sumOfCosts + costAsInt;
    }
    
    NSInteger daysForPricingAsInt = [self.daysForPrice.text integerValue];
    
    NSInteger subTotal = daysForPricingAsInt * sumOfCosts;
    
    self.subtotal.text = [NSString stringWithFormat:@"Subtotal: %u", subTotal];
    
}

#pragma mark - Having tapped on things


-(IBAction)pricingDaysFieldTapped:(id)sender{
    
    EQRGenericNumberEditor *numberEditor = [[EQRGenericNumberEditor alloc] initWithNibName:@"EQRGenericNumberEditor" bundle:nil];
    numberEditor.delegate = self;
    numberEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:numberEditor animated:YES completion:^{
       
        [numberEditor initalSetupWithTitle:@"Enter Number of Days for Pricing" subTitle:[NSString stringWithFormat:@"For rental happening %@", self.daysForPrice.text] currentText:@"6" returnMethod:@"updateDaysForPrice:"];
        
    }];
}

//Price Matrix Content VC delegate method
-(void)launchCostEditorWithJoinKeyID:(NSString *)joinKeyID isEquipJoin:(BOOL)isEquipJoin cost:(NSString *)cost{
    
    __block NSIndexPath *savedIndexPath;
    [self.arrayOfLineItems enumerateObjectsUsingBlock:^(EQRScheduleTracking_EquipmentUnique_Join *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //continue only if there is agreement that both joins are an equipJoin or not
        if (isEquipJoin == [obj respondsToSelector:@selector(distinquishing_id)]){
            
            if ([obj.key_id isEqualToString:joinKeyID]){
                //found a match
                savedIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                self.tempIndexPath = savedIndexPath;
                self.tempIndexPathIsEquipJoin = isEquipJoin;
            }
        }
    }];
    
    if (!savedIndexPath){
        //error handling...
        return;
        NSLog(@"EQRPriceMatrix > launchCostEditorWithJoinKeyID says no match from contentVC to lineItems array");
    }
    
    EQRGenericNumberEditor *numberEditor = [[EQRGenericNumberEditor alloc] initWithNibName:@"EQRGenericNumberEditor" bundle:nil];
    numberEditor.delegate = self;
    numberEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:numberEditor animated:YES completion:^{
        
        [numberEditor initalSetupWithTitle:@"Enter New Daily Cost" subTitle:nil currentText:cost returnMethod:@"updateJoinRowWithNewCost:"];
        
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
    
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    
    //______is it an EquipJoin or a MiscJoin?
    if (self.tempIndexPathIsEquipJoin){
        
        EQRScheduleTracking_EquipmentUnique_Join *join = [self.arrayOfLineItems objectAtIndex:self.tempIndexPath.row];
        join.cost = returnText;
        
        [self.lineItemsCollection reloadData];
        
        //udpate database
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
    pmcontent.delegate = self;
    
    cell.myContentVC = pmcontent;
    
    if ([[self.arrayOfLineItems objectAtIndex:indexPath.row] respondsToSelector:@selector(distinquishing_id)]){
        //must be equipJoin
        
        EQRScheduleTracking_EquipmentUnique_Join *join = [self.arrayOfLineItems objectAtIndex:indexPath.row];
        [cell.myContentVC initialSetupWithName:join.name distID:join.distinquishing_id cost:join.cost joinKeyID:join.key_id];
        
        NSLog(@"name: %@  distID: %@  cost: %@", join.name, join.distinquishing_id, join.cost);
        
    }else{
        //must be miscJoin
        
        EQRMiscJoin *join = [self.arrayOfLineItems objectAtIndex:indexPath.row];
        [cell.myContentVC initialSetupWithName:join.name distID:nil cost:join.cost joinKeyID:join.key_id];
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
