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


@interface EQRPriceMatrixVC () <EQRWebDataDelegate, UICollectionViewDataSource, UICollectionViewDelegate, EQRGenericNumberEditorDelegate>

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



@end

@implementation EQRPriceMatrixVC

#pragma mark - methods

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


#pragma mark - public methods

-(void)startNewTransaction:(EQRScheduleRequestItem *)request{
    
    //Is called from Request. Use info in reqeustManager.request.
    //Create a transaction
    //populate collection view with Join objects
    
    //get an array of dictionaries of alternate costs for all equipTitles included in this request
    //assign cost to each join (based on request's renter_pricing_class)
    
    //get array of available discounts
    //get array of available items for purchase (add-ons)
    
    
    
    NSLog(@"this is the scheduleRequest key_id: %@  this is the count of equips: %lu  and of misc items: %lu", request.key_id, (unsigned long)[request.arrayOfEquipmentJoins count], (unsigned long)[request.arrayOfMiscJoins count]);

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
                
                [self startNewStage2];
                
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
    
    NSLog(@"this is the scheduleRequest key_id: %@  this is the count of equips: %lu  and of misc items: %lu", request.key_id, (unsigned long)[request.arrayOfEquipmentJoins count], (unsigned long)[request.arrayOfMiscJoins count]);
    
    //no, array is bad
    
    self.myRequestItem = request;
    
    [self sharedInitialSetup];
    
    [self editExistingStage2];
    
}

-(void)editExistingStage2{  //get EquipJoins and MiscJoins
    
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
            
            [self editExistingStage3];
        }];
    });
    
}

-(void)editExistingStage3{  //get prices for equip titles
    
    if (!self.arrayOfLineItems){
        self.arrayOfLineItems = [NSMutableArray arrayWithCapacity:1];
    }
    
    self.arrayOfLineItems = self.arrayOfEquipJoins;
    
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
        for (EQREquipItem *titleItem in self.arrayOfPriceEquipTitles){
            
            if ([join.equipTitleItem_foreignKey isEqualToString:titleItem.key_id]){
                //found an equipTitle match
                join.cost = titleItem.price_artist;
                break;
            }
        }
    }
    
    
    //do the same for line items array????
    for (EQRScheduleTracking_EquipmentUnique_Join *join2 in self.arrayOfLineItems){
        
        //only continue if the lineItem is an EquipJoin
        if ([join2 respondsToSelector:@selector(equipTitleItem_foreignKey)]){
            
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
    
    //reload the collection view to display cost data
    [self.lineItemsCollection reloadData];
    
    
    
}


-(IBAction)pricingDaysFieldTapped:(id)sender{
    
    EQRGenericNumberEditor *numberEditor = [[EQRGenericNumberEditor alloc] initWithNibName:@"EQRGenericNumberEditor" bundle:nil];
    numberEditor.delegate = self;
    numberEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:numberEditor animated:YES completion:^{
       
        
        [numberEditor initalSetupWithTitle:@"Enter Number of Days for Pricing" subTitle:[NSString stringWithFormat:@"For rental happening %@", self.daysForPrice.text] currentText:@"6" returnMethod:@"updateDaysForPrice:"];
        
    }];
    
    

}


#pragma mark - Generic Number Editor protocol method

-(void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod{
    
    SEL returnMethodForReal = NSSelectorFromString(returnMethod);

    [self performSelector:returnMethodForReal withObject:returnText afterDelay:0];
    
}

-(void)updateDaysForPrice:(NSString *)returnText{
    
    self.daysForPrice.text = returnText;
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        
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
    
    [self.arrayOfMiscJoins addObject:currentThing];
}


-(void)addEquipJoinToArray:(id)currentThing{
    
    if (!currentThing){
        return;
    }
    
    if (!self.arrayOfEquipJoins){
        self.arrayOfEquipJoins = [NSMutableArray arrayWithCapacity:1];
    }
    
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
    
    EQRPriceMatrixCllctnVwCll *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    for (UIView *subview in cell.contentView.subviews){
        [subview removeFromSuperview];
    }
    
    EQRPriceMatrixCllctnViewContentVC *pmcontent = [[EQRPriceMatrixCllctnViewContentVC alloc] initWithNibName:@"EQRPriceMatrixCllctnViewContentVC" bundle:nil];
    cell.myContentVC = pmcontent;
    
    EQRScheduleTracking_EquipmentUnique_Join *join = [self.arrayOfLineItems objectAtIndex:indexPath.row];
    
    NSLog(@"name: %@  distID: %@  cost: %@", join.name, join.distinquishing_id, join.cost);
    
    [cell.myContentVC initialSetupWithName:join.name distID:join.distinquishing_id cost:join.cost];
    
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
