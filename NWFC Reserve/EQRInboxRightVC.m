//
//  EQRInboxRightVC.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 8/27/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRInboxRightVC.h"
#import "EQRInboxLeftTableVC.h"

@interface EQRInboxRightVC ()

@property (strong, nonatomic) EQRScheduleRequestItem* myScheduleRequest;

@property (strong, nonatomic) IBOutlet UITableView* myTable;
@property (strong, nonatomic) IBOutlet UIView* rightView;
@property (strong, nonatomic) IBOutlet UIView* leftView;

@property (strong, nonatomic) IBOutlet UILabel* timeOfRequestValue;
@property (strong, nonatomic) IBOutlet UILabel* firstLastNameValue;
@property (strong, nonatomic) IBOutlet UILabel* typeValue;
@property (strong, nonatomic) IBOutlet UILabel* classValue;
@property (strong, nonatomic) IBOutlet UILabel* pickUpTimeValue;
@property (strong, nonatomic) IBOutlet UILabel* returnTimeValue;

@property (strong, nonatomic) NSArray* arrayOfJoins;

@end

@implementation EQRInboxRightVC

@synthesize delegateForRightSide;


#pragma mark - methods

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
    
    //add right side buttons in nav item
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(sendEmail)]];
    
    //register cells
    [self.myTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.myTable registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"SuppCell"];
    
    
    //initially hide everything
    [self.leftView setHidden:YES];
    [self.rightView setHidden:YES];
    
    
}

-(void)awakeFromNib{
    
    [super awakeFromNib];
    [self.splitViewController setDelegate:self];
    
}


-(void)renewTheViewWithRequest:(EQRScheduleRequestItem*)request{
    
    //set reqeustItem (error handling if nil)
    self.myScheduleRequest = request;

    //set label values
    self.firstLastNameValue.text = self.myScheduleRequest.contact_name;
    self.typeValue.text = self.myScheduleRequest.renter_type;
    self.classValue.text = self.myScheduleRequest.classTitle_foreignKey;
    
    //date formats
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"EEEE, MMM d";
    
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    timeFormatter.dateFormat = @"h:mm aaa";
    
    NSDateFormatter* submitFormatter = [[NSDateFormatter alloc] init];
    submitFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    submitFormatter.dateFormat = @"EEEE, MMM d, h:mm aaa";
    
    NSString* pickUpDateString = [dateFormatter stringFromDate:self.myScheduleRequest.request_date_begin];
    NSString* pickUpTimeString = [timeFormatter stringFromDate:self.myScheduleRequest.request_time_begin];
    NSString* returnDateString = [dateFormatter stringFromDate:self.myScheduleRequest.request_date_end];
    NSString* returnTimeString = [timeFormatter stringFromDate:self.myScheduleRequest.request_time_end];
    NSString* timeOfRequest = [submitFormatter stringFromDate:self.myScheduleRequest.time_of_request];
    
    self.timeOfRequestValue.text = timeOfRequest;
    self.pickUpTimeValue.text = [NSString stringWithFormat:@"%@ - %@", pickUpDateString, pickUpTimeString];
    self.returnTimeValue.text = [NSString stringWithFormat:@"%@ - %@", returnDateString, returnTimeString];
    
    //make subview visible
    [self.rightView setHidden:NO];
    [self.leftView setHidden:NO];
    
    NSLog(@"a small inconsequential change");
}





#pragma mark - button methods

-(void)sendEmail{
    
    
    NSString* messageTitle = @"subject title";
    NSString* messageBody = @"body";
    NSArray* messageRecipients = [NSArray arrayWithObjects: @"dave@nwfilm.org", nil];
    
    MFMailComposeViewController* mfVC = [[MFMailComposeViewController alloc] init];
    mfVC.mailComposeDelegate = self;
    
    [mfVC setSubject:messageTitle];
    [mfVC setMessageBody:messageBody isHTML:NO];
    [mfVC setToRecipients:messageRecipients];
    
    [self presentViewController:mfVC animated:YES completion:^{
        
        
    }];
    
    
    
    
}


#pragma mark - mail compose delegate methods

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    switch (result) {
            
        case MFMailComposeResultCancelled:
            
            
            break;
            
        case MFMailComposeResultFailed:
            
            break;
            
        case MFMailComposeResultSaved:
            
            break;
            
        case MFMailComposeResultSent:
            
            break;
            
        default:
            break;
    }
    
    //dismiss email compose
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
}


#pragma mark - split view delegate methods

-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc{
    
    NSLog(@"inside willHide split view delegate method");
    
    barButtonItem.title = @"Filters";
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    self.popover = pc;
    
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
    
    [self.navigationItem setLeftBarButtonItem:nil];
    
    self.popover = nil;
}



#pragma mark - table datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    

    cell.textLabel.text = @"Cell Text";
    
    return cell;
}


#pragma mark - table delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
}


#pragma mark - memory warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
