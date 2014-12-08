//
//  EQREditorRenterVCntrllrViewController.m
//  NWFC Reserve
//
//  Created by Ray Smith on 4/17/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREditorRenterVCntrllr.h"
#import "EQRGlobals.h"


@interface EQREditorRenterVCntrllr ()

@property (nonatomic, strong) NSString* renter_type;
@property NSInteger selectedIndexRow;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSArray* arrayOfRenterTypes;

@end

@implementation EQREditorRenterVCntrllr

@synthesize delegate;

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
    // Do any additional setup after loading the view from its nib.
    
    //register table cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    NSArray* thisArray = [NSArray arrayWithObjects:
                          EQRRenterStudent,
                         EQRRenterStaff,
                          EQRRenterFaculty,
                         EQRRenterPublic,
                         EQRRenterYouth,
                          EQRRenterInClass,
                         nil];
    
    self.arrayOfRenterTypes = thisArray;

}

-(void)initialSetupWithRenterTypeString:(NSString*)presetRenter{
    
    //select an existing renter type

    if ([presetRenter isEqualToString:EQRRenterStudent]){
        
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        
    }else if([presetRenter isEqualToString:EQRRenterStaff]){
        
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        
    }else if([presetRenter isEqualToString:EQRRenterFaculty]){
        
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        
    }else if([presetRenter isEqualToString:EQRRenterPublic]){
        
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        
    }else if([presetRenter isEqualToString:EQRRenterYouth]){
        
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        
    }else if ([presetRenter isEqualToString:EQRRenterInClass]){
        
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
}


-(id)retrieveRenterType{
    
//    return self.renter_type;
    return [self.arrayOfRenterTypes objectAtIndex:self.selectedIndexRow];
    
}


#pragma mark - table view data source methods


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.arrayOfRenterTypes count];
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self.arrayOfRenterTypes objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    return cell;
}


#pragma mark - table view delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.renter_type = [self.arrayOfRenterTypes objectAtIndex:indexPath.row];
    
    self.selectedIndexRow = indexPath.row;
    
    NSLog(@"this is the selected indexpath row: %lu", (long)self.selectedIndexRow);

    [self.delegate initiateRetrieveRenterItem];
}





#pragma mark - picker view datasource methods

//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
//    
//    return 1;
//}
//
//
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
//    
//    return 5;
//}
//
//
//
//
//#pragma mark - picker view delegate methods
//
//- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    
//    NSDictionary* arrayAttA = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:8] forKey:NSFontAttributeName];
//    
//    if (row == 0){
//        
//        return [[NSAttributedString alloc] initWithString:EQRRenterStudent attributes:arrayAttA];
//        
//    } else if(row == 1){
//        
//        return [[NSAttributedString alloc] initWithString:EQRRenterPublic attributes:arrayAttA];
//        
//    }else if(row == 2){
//        
//        return [[NSAttributedString alloc] initWithString:EQRRenterFaculty attributes:arrayAttA];
//        
//    }else if (row == 3){
//        
//        return [[NSAttributedString alloc] initWithString:EQRRenterStaff attributes:arrayAttA];
//        
//    }else if (row == 4){
//        
//        return [[NSAttributedString alloc] initWithString:EQRRenterYouth attributes:arrayAttA];
//        
//    }else{
//        
//        return [[NSAttributedString alloc] initWithString:@"NA" attributes:arrayAttA];
//    }
//}
//
//
//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
//    
//    return 25.f;  //30.f
//}
//
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
//    
//    return 200.f;  //210.f
//}
//
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//    
//    switch (row) {
//        case 0:
//            self.renter_type = EQRRenterStudent;
//            break;
//            
//        case 1:
//            self.renter_type = EQRRenterPublic;
//            break;
//            
//        case 2:
//            self.renter_type = EQRRenterFaculty;
//            break;
//            
//        case 3:
//            self.renter_type = EQRRenterStaff;
//            break;
//            
//        case 4:
//            self.renter_type = EQRRenterYouth;
//            break;
//            
//        default:
//            self.renter_type = @"";
//            break;
//    }
//}


#pragma mark - memory warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
