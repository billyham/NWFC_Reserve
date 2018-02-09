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
#import "EQRGenericNumberEditor.h"
#import "EQRGenericEditor.h"
#import "EQRGenericPickerVC.h"
#import "EQREquipCategory.h"
#import "EQREquipSubcategory.h"
#import "EQREquipScheduleGrouping.h"

@interface EQREquipTitleDetailVC () <EQRGenericEditorDelegate, EQREquipTitleInfoDelegate, EQREquipTitlePricesDelegate>

@property (strong, nonatomic) NSString *equipTitleKeyId;
@property (strong, nonatomic) EQREquipItem *equipTitle;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionShortLabel;
@property (weak, nonatomic) IBOutlet UIView *descriptionShortBG;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLongLabel;
@property (weak, nonatomic) IBOutlet UIView *descriptionLongBG;
@property (weak, nonatomic) IBOutlet UILabel *depositLabel;
@property (weak, nonatomic) IBOutlet UIView *depositBG;
@property (weak, nonatomic) IBOutlet UISwitch *hideFromPublicSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *hideFromStudentsSwitch;

@property (weak, nonatomic) EQREquipTitleInfoTVC *equipTitleInfo;
@property (weak, nonatomic) EQREquipTitlePricesTVC *equipTitlePrices;

@property (strong, nonatomic) EQRGenericEditor *genericEditor;

@end

@implementation EQREquipTitleDetailVC
@synthesize delegate;

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
    
    UITapGestureRecognizer *tapShortDesc = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editDescriptionShort:)];
    tapShortDesc.cancelsTouchesInView = NO;
    [self.descriptionShortBG addGestureRecognizer:tapShortDesc];
    
    UITapGestureRecognizer *tapLongDesc = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editDescriptionLong:)];
    tapLongDesc.cancelsTouchesInView = NO;
    [self.descriptionLongBG addGestureRecognizer:tapLongDesc];
    
    UITapGestureRecognizer *tapDeposit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editDeposit:)];
    tapDeposit.cancelsTouchesInView = NO;
    [self.depositBG addGestureRecognizer:tapDeposit];
    
    // Right buttons
    UIBarButtonItem *twentySpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    twentySpace.width = 20;
    UIBarButtonItem *thirtySpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    thirtySpace.width = 30;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteItem:)];
    
    NSArray *rightButtons = @[addButton];
    
    [self.navigationItem setRightBarButtonItems:rightButtons];

    [self.navigationItem setHidesBackButton:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.equipTitle) {
        [self renderInfo:self.equipTitle];
    }
}


#pragma mark - render
- (void)renderInfo:(EQREquipItem *)equipItem {
    self.nameLabel.text = equipItem.name;
    self.shortNameLabel.text = equipItem.short_name;

    if (self.equipTitle.description_long == nil) self.equipTitle.description_long = @" ";
    if (self.equipTitle.description_short == nil) self.equipTitle.description_short = @" ";
    
    self.descriptionLongLabel.text = equipItem.description_long;
    self.descriptionShortLabel.text = equipItem.description_short;
    
    // Send data to container TableVCs
    if (self.equipTitle.name == nil) self.equipTitle.name = @"";
    if (self.equipTitle.short_name == nil) self.equipTitle.short_name = @"";
    if (self.equipTitle.category == nil) self.equipTitle.category = @"";
    if (self.equipTitle.subcategory == nil) self.equipTitle.subcategory = @"";
    if (self.equipTitle.schedule_grouping == nil) self.equipTitle.schedule_grouping = @"";
    
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
    if (self.equipTitle.price_deposit == nil) self.equipTitle.price_deposit = @"0";
    
    [self.equipTitlePrices setText:@{
                                     @"commercial": self.equipTitle.price_commercial,
                                     @"artist": self.equipTitle.price_artist,
                                     @"student": self.equipTitle.price_student,
                                     @"staff": self.equipTitle.price_staff,
                                     @"faculty": self.equipTitle.price_nonprofit
                                     }];
    
    self.depositLabel.text = equipItem.price_deposit;
    
    if (self.equipTitle.decommissioned == nil) self.equipTitle.decommissioned = @"0";
    
    if ([self.equipTitle.hide_from_public isEqualToString:@"1"]) {
        [self.hideFromPublicSwitch setOn:YES];
    }
    
    if ([self.equipTitle.hide_from_student isEqualToString:@"1"]) {
        [self.hideFromStudentsSwitch setOn:YES];
    }
}

#pragma mark - button actions

- (IBAction)deleteItem:(id)keyId {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Item" message:@"Permanently delete this equipment item from your catalog" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        self.equipTitle.decommissioned = @"1";
        [self updateEquipTitle:^{
            [self.navigationController popViewControllerAnimated:NO];
            [self.delegate reloadList];
        }];
    }];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) { }];
    
    [alert addAction:alertOk];
    [alert addAction:alertCancel];
    [self presentViewController:alert animated:YES completion:^{
    }];
}

#pragma mark - switch actions
- (IBAction)togglePublic:(id)sender {
    if (self.hideFromPublicSwitch.on) {
        self.equipTitle.hide_from_public = @"1";
    } else {
        self.equipTitle.hide_from_public = @"0";
    }
    
    [self updateEquipTitle:^{}];
}

- (IBAction)toggleStudent:(id)sender {
    if (self.hideFromStudentsSwitch.on) {
        self.equipTitle.hide_from_student = @"1";
    } else {
        self.equipTitle.hide_from_student = @"0";
    }
    
    [self updateEquipTitle:^{}];
}

#pragma mark - Initiate editing
- (void)editDescriptionShort:(UITapGestureRecognizer *)sender {
    [self editDescription:@"updateDescriptionShort:" property:self.equipTitle.description_short];
}

- (void)editDescriptionLong:(UITapGestureRecognizer *)sender {
    [self editDescription:@"updateDescriptionLong:" property:self.equipTitle.description_long];
}

- (void)editDescription:(NSString *)returnMethod property:(NSString *)property {
    self.genericEditor = [[EQRGenericBlockOfTextEditor alloc] initWithNibName:@"EQRGenericBlockOfTextEditor" bundle:nil];
    self.genericEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    self.genericEditor.delegate = self;
    [self.genericEditor initalSetupWithTitle:@"none" subTitle:@"none" currentText:property keyboard:nil returnMethod:returnMethod];
    [self presentViewController:self.genericEditor animated:YES
                     completion:^{
                         
                     }];
}

- (void)editDeposit:(UITapGestureRecognizer *)sender {
    self.genericEditor = [[EQRGenericNumberEditor alloc] initWithNibName:@"EQRGenericNumberEditor" bundle:nil];
    self.genericEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    self.genericEditor.delegate = self;
    [self.genericEditor initalSetupWithTitle:@"none"
                                          subTitle:@"none"
                                       currentText:self.equipTitle.price_deposit
                                          keyboard:nil
                                      returnMethod:@"updateDeposit:"];
    [self presentViewController:self.genericEditor animated:YES completion:^{
        
    }];
}

#pragma mark - load data methods
- (void)loadCategoriesWithCallback:(void(^)(NSArray *array))cb {
    __block NSArray *arrayOfCategories = @[];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"allCategories";
    queue.maxConcurrentOperationCount = 1;
    
    NSBlockOperation *getEquipCategories = [NSBlockOperation blockOperationWithBlock:^{
    
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetEquipCategoriesAll.php" parameters:nil class:@"EQREquipCategory" completion:^(NSMutableArray *arrayOfEquipCategories) {
            NSMutableArray *muteArray = [NSMutableArray arrayWithCapacity:1];
            for (EQREquipCategory *cat in arrayOfEquipCategories) {
                [muteArray addObject:cat.category];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                arrayOfCategories = [NSArray arrayWithArray:muteArray];
                cb(arrayOfCategories);
            });
        }];
    }];
    
    [queue addOperation:getEquipCategories];
}

- (void)loadSubcategoriesWithCallback:(void(^)(NSArray *array))cb {
    __block NSArray *arrayOfSubcategories = @[];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"allSubcategories";
    queue.maxConcurrentOperationCount = 1;
    
    NSBlockOperation *getEquipSubcategories = [NSBlockOperation blockOperationWithBlock:^{
        
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetEquipSubcategoriesAll.php" parameters:nil class:@"EQREquipSubcategory" completion:^(NSMutableArray *arrayOfEquipSubcategories) {
            NSMutableArray *muteArray = [NSMutableArray arrayWithCapacity:1];
            for (EQREquipSubcategory *cat in arrayOfEquipSubcategories) {
                [muteArray addObject:cat.subcategory];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                arrayOfSubcategories = [NSArray arrayWithArray:muteArray];
                cb(arrayOfSubcategories);
            });
        }];
    }];
    
    [queue addOperation:getEquipSubcategories];
}

- (void)loadScheduleGroupingWithCallback:(void(^)(NSArray *array))cb {
    __block NSArray *arrayOfScheduleGroupings = @[];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"allScheduleGrouping";
    queue.maxConcurrentOperationCount = 1;
    
    NSBlockOperation *getEquipScheduleGrouping = [NSBlockOperation blockOperationWithBlock:^{
       
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetEquipScheduleGroupingAll.php" parameters:nil class:@"EQREquipScheduleGrouping" completion:^(NSMutableArray *arrayOfEquipScheduleGroupings) {
            NSMutableArray *muteArray = [NSMutableArray arrayWithCapacity:1];
            for (EQREquipScheduleGrouping *cat in arrayOfEquipScheduleGroupings) {
                [muteArray addObject:cat.schedule_grouping];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                arrayOfScheduleGroupings = [NSArray arrayWithArray:muteArray];
                cb(arrayOfScheduleGroupings);
            });
        }];
    }];
    
    [queue addOperation:getEquipScheduleGrouping];
}

#pragma mark - Info and Prices table delegate method
- (void)propertySelection:(NSString *)property value:(NSString *)value {
    
    NSString *updateMethod;
    if ([property isEqualToString:@"name"]) {
        self.genericEditor = [[EQRGenericTextEditor alloc] initWithNibName:@"EQRGenericTextEditor" bundle:nil];
        updateMethod = @"updateName:";
    }else if([property isEqualToString:@"short_name"]) {
        self.genericEditor = [[EQRGenericTextEditor alloc] initWithNibName:@"EQRGenericTextEditor" bundle:nil];
        updateMethod = @"updateShortName:";
    }else if([property isEqualToString:@"category"]) {
        [self loadCategoriesWithCallback:^(NSArray *array) {
            EQRGenericPickerVC *genericPicker = [[EQRGenericPickerVC alloc] initWithNibName:@"EQRGenericPickerVC" bundle:nil];
            genericPicker.modalPresentationStyle = UIModalPresentationFormSheet;
            [genericPicker initialSetupWithTitle:@"Existing Category" subTitle:@"Select one or create a new one" array:array selectedValue:nil allowManualEntry:YES callback:^(NSString *value) {
                self.equipTitle.category = value;
                [self updateEquipTitle:^{
                    [self dismissViewControllerAnimated:YES completion:^{ }];
                }];
            }
             ];
            [self presentViewController:genericPicker animated:YES completion:^{ }];
        }];
        return;
    }else if([property isEqualToString:@"subcategory"]) {
        [self loadSubcategoriesWithCallback:^(NSArray *array) {
            EQRGenericPickerVC *genericPicker = [[EQRGenericPickerVC alloc] initWithNibName:@"EQRGenericPickerVC" bundle:nil];
            genericPicker.modalPresentationStyle = UIModalPresentationFormSheet;
            [genericPicker initialSetupWithTitle:@"Existing Subcategory" subTitle:@"Select one or create a new one" array:array selectedValue:nil allowManualEntry:YES callback:^(NSString *value) {
                self.equipTitle.subcategory = value;
                [self updateEquipTitle:^{
                    [self dismissViewControllerAnimated:YES completion:^{ }];
                }];
            }
             ];
            [self presentViewController:genericPicker animated:YES completion:^{ }];
        }];
        return;
    }else if([property isEqualToString:@"schedule_grouping"]) {
        [self loadScheduleGroupingWithCallback:^(NSArray *array) {
            EQRGenericPickerVC *genericPicker = [[EQRGenericPickerVC alloc] initWithNibName:@"EQRGenericPickerVC" bundle:nil];
            genericPicker.modalPresentationStyle = UIModalPresentationFormSheet;
            [genericPicker initialSetupWithTitle:@"Existing Schedule Grouping" subTitle:@"Select one or create a new one" array:array selectedValue:nil allowManualEntry:YES callback:^(NSString *value) {
                self.equipTitle.schedule_grouping = value;
                [self updateEquipTitle:^{
                    [self dismissViewControllerAnimated:YES completion:^{ }];
                }];
            }];
            [self presentViewController:genericPicker animated:YES completion:^{ }];
        }];
        return;
    }else if([property isEqualToString:@"price_commercial"]) {
        self.genericEditor = [[EQRGenericNumberEditor alloc] initWithNibName:@"EQRGenericNumberEditor" bundle:nil];
        updateMethod = @"updatePriceCommercial:";
    }else if([property isEqualToString:@"price_artist"]) {
        self.genericEditor = [[EQRGenericNumberEditor alloc] initWithNibName:@"EQRGenericNumberEditor" bundle:nil];
        updateMethod = @"updatePriceArtist:";
    }else if([property isEqualToString:@"price_student"]) {
        self.genericEditor = [[EQRGenericNumberEditor alloc] initWithNibName:@"EQRGenericNumberEditor" bundle:nil];
        updateMethod = @"updatePriceStudent:";
    }else if([property isEqualToString:@"price_staff"]) {
        self.genericEditor = [[EQRGenericNumberEditor alloc] initWithNibName:@"EQRGenericNumberEditor" bundle:nil];
        updateMethod = @"updatePriceStaff:";
    }else if([property isEqualToString:@"price_nonprofit"]) {
        self.genericEditor = [[EQRGenericNumberEditor alloc] initWithNibName:@"EQRGenericNumberEditor" bundle:nil];
        updateMethod = @"updatePriceNonprofit:";
    }else{
        NSLog(@"EQREquipTitleDetailVC > propertySelection failed to match the property: %@", property);
        return;
    }
    
    self.genericEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    self.genericEditor.delegate = self;
    [self.genericEditor initalSetupWithTitle:@"none" subTitle:@"none" currentText:value keyboard:nil returnMethod:updateMethod];
    [self presentViewController:self.genericEditor animated:YES completion:^{  }];
}

#pragma mark - generic editor delegate methods
- (void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod {
    
    self.genericEditor.delegate = nil;
    
    [self dismissViewControllerAnimated:YES completion:^{
#   pragma clang diagnostic push
#   pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:NSSelectorFromString(returnMethod) withObject:returnText];
#   pragma clang diagnostic pop
        self.genericEditor = nil;
    }];
}

- (void)cancelByDismissingVC {
    self.genericEditor.delegate = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        self.genericEditor = nil;
    }];
}

#pragma mark - complete edits
- (void)updateName:(NSString *)currentText {
    self.equipTitle.name = currentText;
    [self updateEquipTitle:^{}];
}

- (void)updateShortName:(NSString *)currentText {
    self.equipTitle.short_name = currentText;
    [self updateEquipTitle:^{    }];
}

- (void)updateCategory:(NSString *)currentText {
    self.equipTitle.category = currentText;
    [self updateEquipTitle:^{    }];
}

- (void)updateSubcategory:(NSString *)currentText {
    self.equipTitle.subcategory = currentText;
    [self updateEquipTitle:^{    }];
}

- (void)updateScheduleGrouping:(NSString *)currentText {
    self.equipTitle.schedule_grouping = currentText;
    [self updateEquipTitle:^{    }];
}

- (void)updatePriceCommercial:(NSString *)currentText {
    self.equipTitle.price_commercial = currentText;
    [self updateEquipTitle:^{    }];
}

- (void)updatePriceArtist:(NSString *)currentText {
    self.equipTitle.price_artist = currentText;
    [self updateEquipTitle:^{    }];
}

- (void)updatePriceStudent:(NSString *)currentText {
    self.equipTitle.price_student = currentText;
    [self updateEquipTitle:^{    }];
}

- (void)updatePriceStaff:(NSString *)currentText {
    self.equipTitle.price_staff = currentText;
    [self updateEquipTitle:^{    }];
}

- (void)updatePriceNonprofit:(NSString *)currentText {
    self.equipTitle.price_nonprofit = currentText;
    [self updateEquipTitle:^{    }];
}

- (void)updateDescriptionShort:(NSString *)currentText {
    self.equipTitle.description_short = currentText;
    [self updateEquipTitle:^{    }];
}

- (void)updateDescriptionLong:(NSString *)currentText {
    self.equipTitle.description_long = currentText;
    [self updateEquipTitle:^{    }];
}

- (void)updateDeposit:(NSString *)currentText {
    self.equipTitle.price_deposit = currentText;
    [self updateEquipTitle:^{    }];
}

#pragma mark - render equiptitle changes and update database
- (void)updateEquipTitle:(void (^)(void))onDone {
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
                          @[@"hide_from_student", self.equipTitle.hide_from_student],
                          @[@"decommissioned", self.equipTitle.decommissioned]
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
        } else {
            // Otherwise invoke the onDone method
            dispatch_async(dispatch_get_main_queue(), ^{
                onDone();
            });
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

//#pragma mark - tableview datasource
//
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


#pragma mark - memory warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
