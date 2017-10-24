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
#import "EQRGenericBlockOfTextEditor.h"
#import "EQRGenericTextEditor.h"

@interface EQREquipTitleDetailVC () <EQRGenericBlockOfTextTextEditorDelegate, EQRGenericTextEditorDelegate, EQREquipTitleInfoDelegate, EQREquipTitlePricesDelegate>

@property (strong, nonatomic) NSString *equipTitleKeyId;
@property (strong, nonatomic) EQREquipItem *equipTitle;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLongLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionShortLabel;
@property (weak, nonatomic) IBOutlet UIView *descriptionShortBG;
@property (weak, nonatomic) IBOutlet UIView *descriptionLongBG;

@property (weak, nonatomic) EQREquipTitleInfoTVC *equipTitleInfo;
@property (weak, nonatomic) EQREquipTitlePricesTVC *equipTitlePrices;
//@property (weak, nonatomic) IBOutlet UITableView *itemsUniqueTable;

@property (strong, nonatomic) EQRGenericBlockOfTextEditor *genericTextEditor;
@property (strong, nonatomic) EQRGenericTextEditor *genericSingleLineTextEditor;

@end

@implementation EQREquipTitleDetailVC

#pragma mark - launch with title key
- (void)launchWithKey:(NSString *)keyId {
    self.equipTitleKeyId = keyId;
    
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
    
//    [self.itemsUniqueTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    UITapGestureRecognizer *tapShortDesc = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editDescriptionShort:)];
    tapShortDesc.cancelsTouchesInView = NO;
    [self.descriptionShortBG addGestureRecognizer:tapShortDesc];
    
    UITapGestureRecognizer *tapLongDesc = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editDescriptionLong:)];
    tapLongDesc.cancelsTouchesInView = NO;
    [self.descriptionLongBG addGestureRecognizer:tapLongDesc];
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

    if (self.equipTitle.description_long == nil) self.equipTitle.description_long = @" ";
    if (self.equipTitle.description_short == nil) self.equipTitle.description_short = @" ";
    
    self.descriptionLongLabel.text = equipItem.description_long;
    self.descriptionShortLabel.text = equipItem.description_short;
    
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


#pragma mark - Initiate editing

- (void)editDescriptionShort:(UITapGestureRecognizer *)sender {
    [self editDescription:@"updateDescriptionShort:" property:self.equipTitle.description_short];
}

- (void)editDescriptionLong:(UITapGestureRecognizer *)sender {
    [self editDescription:@"updateDescriptionLong:" property:self.equipTitle.description_long];
}

- (void)editDescription:(NSString *)returnMethod property:(NSString *)property {
    self.genericTextEditor = [[EQRGenericBlockOfTextEditor alloc] initWithNibName:@"EQRGenericBlockOfTextEditor" bundle:nil];
    self.genericTextEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    self.genericTextEditor.delegate = self;
    [self.genericTextEditor initalSetupWithTitle:@"none" subTitle:@"none" currentText:property keyboard:nil returnMethod:returnMethod];
    [self presentViewController:self.genericTextEditor animated:YES
                     completion:^{
                         
                     }];
}

#pragma mark - EquipTitleDetailDelegate method

- (void)propertySelection:(NSString *)property value:(NSString *)value {
    
    NSString *updateMethod;
    if ([property isEqualToString:@"name"]) {
        updateMethod = @"updateName:";
    }else if([property isEqualToString:@"short_name"]) {
        updateMethod = @"updateShortName:";
    }else if([property isEqualToString:@"category"]) {
        updateMethod = @"updateCategory:";
    }else if([property isEqualToString:@"subcategory"]) {
        updateMethod = @"updateSubcategory:";
    }else if([property isEqualToString:@"schedule_grouping"]) {
        updateMethod = @"updateScheduleGrouping:";
    }else if([property isEqualToString:@"price_commercial"]) {
        updateMethod = @"updatePriceCommercial:";
    }else if([property isEqualToString:@"price_artist"]) {
        updateMethod = @"updatePriceArtist:";
    }else if([property isEqualToString:@"price_student"]) {
        updateMethod = @"updatePriceStudent:";
    }else if([property isEqualToString:@"price_staff"]) {
        updateMethod = @"updatePriceStaff:";
    }else if([property isEqualToString:@"price_nonprofit"]) {
        updateMethod = @"updatePriceNonprofit:";
    }else{
        NSLog(@"EQREquipTitleDetailVC > propertySelection failed to match the property: %@", property);
        return;
    }
    
    self.genericSingleLineTextEditor = [[EQRGenericTextEditor alloc] initWithNibName:@"EQRGenericTextEditor" bundle:nil];
    self.genericSingleLineTextEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    self.genericSingleLineTextEditor.delegate = self;
    [self.genericSingleLineTextEditor initalSetupWithTitle:@"none" subTitle:@"none" currentText:value keyboard:nil returnMethod:updateMethod];
    [self presentViewController:self.genericSingleLineTextEditor animated:YES completion:^{
        
    }];
    
}

#pragma mark - Complete editing

- (void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod {
    
    self.genericTextEditor.delegate = nil;
    self.genericSingleLineTextEditor.delegate = nil;
    
    [self dismissViewControllerAnimated:YES completion:^{
#   pragma clang diagnostic push
#   pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:NSSelectorFromString(returnMethod) withObject:returnText];
#   pragma clang diagnostic pop
        
        self.genericTextEditor = nil;
        self.genericSingleLineTextEditor = nil;
    }];
}

- (void)cancelByDismissingVC {
    self.genericTextEditor.delegate = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    self.genericTextEditor = nil;
}

- (void)updateName:(NSString *)currentText {
    self.equipTitle.name = currentText;
    [self updateEquipTitle];
}

- (void)updateShortName:(NSString *)currentText {
    self.equipTitle.short_name = currentText;
    [self updateEquipTitle];
}

- (void)updateCategory:(NSString *)currentText {
    self.equipTitle.category = currentText;
    [self updateEquipTitle];
}

- (void)updateSubcategory:(NSString *)currentText {
    self.equipTitle.subcategory = currentText;
    [self updateEquipTitle];
}

- (void)updateScheduleGrouping:(NSString *)currentText {
    self.equipTitle.schedule_grouping = currentText;
    [self updateEquipTitle];
}

- (void)updatePriceCommercial:(NSString *)currentText {
    self.equipTitle.price_commercial = currentText;
    [self updateEquipTitle];
}

- (void)updatePriceArtist:(NSString *)currentText {
    self.equipTitle.price_artist = currentText;
    [self updateEquipTitle];
}

- (void)updatePriceStudent:(NSString *)currentText {
    self.equipTitle.price_student = currentText;
    [self updateEquipTitle];
}

- (void)updatePriceStaff:(NSString *)currentText {
    self.equipTitle.price_staff = currentText;
    [self updateEquipTitle];
}

- (void)updatePriceNonprofit:(NSString *)currentText {
    self.equipTitle.price_nonprofit = currentText;
    [self updateEquipTitle];
}

- (void)updateDescriptionShort:(NSString *)currentText {
    self.equipTitle.description_short = currentText;
    [self updateEquipTitle];
}

- (void)updateDescriptionLong:(NSString *)currentText {
    self.equipTitle.description_long = currentText;
    [self updateEquipTitle];
}

- (void)updateEquipTitle {
    // Render to screen
    [self renderInfo:self.equipTitle];
    
    // Update Database
    NSArray *topArray = @[
                          @[@"key_id", self.equipTitle.key_id],
                          @[@"name", self.equipTitle.name],
                          @[@"short_name", self.equipTitle.short_name],
                          @[@"description_long", self.equipTitle.description_long],
                          @[@"description_short", self.equipTitle.description_short],
                          @[@"category", self.equipTitle.category],
                          @[@"subcategory", self.equipTitle.subcategory],
                          @[@"schedule_grouping", self.equipTitle.schedule_grouping],
                          @[@"price_commercial", self.equipTitle.price_commercial],
                          @[@"price_artist", self.equipTitle.price_artist],
                          @[@"price_student", self.equipTitle.price_student],
                          @[@"price_staff", self.equipTitle.price_staff],
                          @[@"price_nonprofit", self.equipTitle.price_nonprofit],
                          @[@"price_deposit", self.equipTitle.price_deposit],
                          @[@"hide_from_public", self.equipTitle.hide_from_public],
                          @[@"hide_from_student", self.equipTitle.hide_from_student]
                          ];
    
    EQRWebData *webData = [EQRWebData sharedInstance];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    __block NSString *returnValue;
    NSString *originalKey = self.equipTitle.key_id;
    NSBlockOperation *alterItem = [NSBlockOperation blockOperationWithBlock:^{
        returnValue = [webData queryForStringWithLink:@"EQAlterEquipTitle.php" parameters:topArray];
    }];
    
    NSBlockOperation *receiveData = [NSBlockOperation blockOperationWithBlock:^{
        if (![originalKey isEqualToString:returnValue]) {
            NSLog(@"EQREquipTitleDetailVC > updateEquipTitle Failed to alter DB: %@", returnValue);
            // TODO: revert display to previous value if database call fails
        }
    }];
    [receiveData addDependency:alterItem];
    
    [queue addOperation:alterItem];
    [queue addOperation:receiveData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"EquipTitleInfo"]) {
        // Prepare for Segue gets called before the contained view is loaded.
        // Save a reference to the destination VC for later
        EQREquipTitleInfoTVC *infoTVC = [segue destinationViewController];
        infoTVC.delegate = self;
        self.equipTitleInfo = infoTVC;
    }
    
    if ([segue.identifier isEqualToString:@"EquipTitlePrices"]) {
        EQREquipTitlePricesTVC *pricesTVC = [segue destinationViewController];
        pricesTVC.delegate = self;
        self.equipTitlePrices = pricesTVC;
    }
}

#pragma mark - tableview datasource

//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 3;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
//
//    cell.textLabel.text = @"The country bumpkins";
//    return cell;
//}

#pragma mark - EQREquipTitleItemInfo delegate methods



#pragma mark - memory warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
