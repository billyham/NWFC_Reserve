//
//  EQREquipTitleDetailVC.m
//  Gear
//
//  Created by Ray Smith on 10/18/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import "EQREquipTitleDetailVC.h"
#import "EQRWebData.h"
#import "EQREquipItem.h"
#import "EQREquipTitleInfoTVC.h"
#import "EQREquipTitlePricesTVC.h"

@interface EQREquipTitleDetailVC () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSString *equipTitleKeyId;
@property (strong, nonatomic) EQREquipItem *equipTitle;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *subcategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *scheduleGroupingLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceCommercialLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceStudentLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceStaffLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceNonprofitLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceArtistLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceDepositLabel;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLongLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionShortLabel;

@property (weak, nonatomic) IBOutlet UISwitch *hideFromPublic;
@property (weak, nonatomic) IBOutlet UISwitch *hideFromStudent;

@property (weak, nonatomic) EQREquipTitleInfoTVC *equipTitleInfo;
@property (weak, nonatomic) EQREquipTitlePricesTVC *equipTitlePrices;
@property (weak, nonatomic) IBOutlet UITableView *itemsUniqueTable;

@end

@implementation EQREquipTitleDetailVC

#pragma mark - launch with title key
- (void)launchWithKey:(NSString *)keyId {
    self.equipTitleKeyId = keyId;
    self.countLabel.text = keyId;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"equipDetail";
    queue.maxConcurrentOperationCount = 1;
    
    __block EQREquipItem *currentItem;
    NSBlockOperation *getEquipTitle = [NSBlockOperation blockOperationWithBlock:^{
        EQRWebData *webData = [EQRWebData sharedInstance];
        NSArray *topArray = @[ @[@"key_id", self.equipTitleKeyId] ];
        [webData queryWithLink:@"EQGetEquipTitleWithKey.php" parameters:topArray class:@"EQREquipItem" completion:^(NSMutableArray *muteArray) {
            
            if ([muteArray count] < 1) {
                NSLog(@"EQREquipTitleDetailTableVC > launch, failed to retrieve equipTitleItem");
                return;
            }
            
            currentItem = [muteArray objectAtIndex:0];
        }];
        
    }];
    
    NSBlockOperation *showEquipItem = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.equipTitle = currentItem;
            [self renderInfo:self.equipTitle];
        });
    }];
    [showEquipItem addDependency:getEquipTitle];
    
    [queue addOperation:getEquipTitle];
    [queue addOperation:showEquipItem];
}


#pragma mark - view methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.itemsUniqueTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.equipTitle) {
        [self renderInfo:self.equipTitle];
    }
}

- (void)renderInfo:(EQREquipItem *)equipItem {
    self.nameLabel.text = equipItem.name;
    self.shortNameLabel.text = equipItem.short_name;
    self.categoryLabel.text = equipItem.category;
    self.subcategoryLabel.text = equipItem.subcategory;
    self.scheduleGroupingLabel.text = equipItem.schedule_grouping;
    
    self.priceCommercialLabel.text = equipItem.price_commercial;
    self.priceArtistLabel.text = equipItem.price_artist;
    self.priceStudentLabel.text = equipItem.price_student;
    self.priceStaffLabel.text = equipItem.price_staff;
    self.priceNonprofitLabel.text = equipItem.price_nonprofit;
    self.priceDepositLabel.text = equipItem.price_deposit;
    
    self.descriptionLongLabel.text = equipItem.description_long;
    self.descriptionShortLabel.text = equipItem.description_short;
    
    BOOL hideFromPublic = [equipItem.hide_from_public boolValue];
    [self.hideFromPublic setOn:hideFromPublic animated:NO];
    
    BOOL hideFromStudent = [equipItem.hide_from_student boolValue];
    [self.hideFromStudent setOn:hideFromStudent animated:NO];
    
    // Send data to container TableVCs
    [self.equipTitleInfo setText:@{
                                   @"name": self.equipTitle.name,
                                   @"shortName": self.equipTitle.short_name,
                                   @"category": self.equipTitle.category,
                                   @"subcategory": self.equipTitle.subcategory,
                                   @"scheduleGrouping": self.equipTitle.schedule_grouping
                                   }];
    
    if (self.equipTitle.price_commercial == nil) self.equipTitle.price_commercial = @"0";
    if (self.equipTitle.price_artist == nil) self.equipTitle.price_artist = @"0";
    if (self.equipTitle.price_student == nil) self.equipTitle.price_student = @"0";
    if (self.equipTitle.price_staff == nil) self.equipTitle.price_staff = @"0";
    if (self.equipTitle.price_nonprofit == nil) self.equipTitle.price_nonprofit = @"0";
    
    [self.equipTitlePrices setText:@{
                                     @"commercial": self.equipTitle.price_commercial,
                                     @"artist": self.equipTitle.price_artist,
                                     @"student": self.equipTitle.price_student,
                                     @"staff": self.equipTitle.price_staff,
                                     @"faculty": self.equipTitle.price_nonprofit
                                     }];
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"EquipTitleInfo"]) {
        // Prepare for Segue gets called before the contained view is loaded.
        // Save a reference to the destination VC for later
        EQREquipTitleInfoTVC *infoTVC = [segue destinationViewController];
        self.equipTitleInfo = infoTVC;
    }
    
    if ([segue.identifier isEqualToString:@"EquipTitlePrices"]) {
        EQREquipTitlePricesTVC *pricesTVC = [segue destinationViewController];
        self.equipTitlePrices = pricesTVC;
    }
}

#pragma mark - tableview datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = @"The country bumpkins";
    return cell;
}

#pragma mark - EQREquipTitleItemInfo delegate methods



#pragma mark - memory warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
