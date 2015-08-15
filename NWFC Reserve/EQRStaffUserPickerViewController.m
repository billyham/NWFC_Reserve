//
//  EQRStaffUserPickerViewController.m
//  NWFC Reserve
//
//  Created by Ray Smith on 8/4/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRStaffUserPickerViewController.h"
#import "EQRWebData.h"
#import "EQRContactNameItem.h"

@interface EQRStaffUserPickerViewController () <EQRWebDataDelegate>



@end

@implementation EQRStaffUserPickerViewController 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        webData.delegateDataFeed = self;
        
        SEL thisSelector = NSSelectorFromString(@"addToArrayOfContactObjects:");
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            [webData queryWithAsync:@"EQGetEQRoomStaffAndInterns.php" parameters:nil class:@"EQRContactNameItem" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
                
                //sort the array...
                
                //reload the pickerview
                [self.myPicker reloadAllComponents];
            }];
        });
        
        
        
//        NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
//        
//        //get array of staff and interns
//        [webData queryWithLink:@"EQGetEQRoomStaffAndInterns.php" parameters:nil class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
//            
//            for (id object in muteArray){
//                
//                [tempMuteArray addObject:object];
//            }
//        }];
//        
//        _arrayOfContactObjects = [NSArray arrayWithArray:tempMuteArray];
        
        
    }
    
    return self;
}


- (void)viewDidLoad{
    
    [super viewDidLoad];
}


-(void)initStage2{
    
    
}


#pragma mark - webData dataFeedDelegate methods

-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    
    //abort if selector is unrecognized, otherwise crash
    if (![self respondsToSelector:action]){
        NSLog(@"cannot perform selector: %@", NSStringFromSelector(action));
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:action withObject:currentThing];
#pragma clang diagnostic pop
    
}


-(void)addToArrayOfContactObjects:(id)currentThing{

    NSMutableArray *tempMuteArray = [NSMutableArray arrayWithCapacity:1];
    
    if (currentThing){
        
        tempMuteArray = [NSMutableArray arrayWithArray:self.arrayOfContactObjects];
        [tempMuteArray addObject:currentThing];
    }
    
    self.arrayOfContactObjects = [NSArray arrayWithArray:tempMuteArray];
}




#pragma mark - uipicker delegate methods (provides content)

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    
    return [(EQRContactNameItem*)[self.arrayOfContactObjects objectAtIndex:row] first_and_last];
}


#pragma mark - uipicker datasource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    
    
    return [self.arrayOfContactObjects count];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
