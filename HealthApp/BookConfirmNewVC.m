//
//  BookConfirmNewVC.m
//  Neediator
//
//  Created by adverto on 30/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "BookConfirmNewVC.h"
#import "OrderCompleteViewController.h"

@interface BookConfirmNewVC ()

@end

@implementation BookConfirmNewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.Booking_Date.text=self.Date;
    self.Patient_ID_OptionalTF.text=self.PatientID;
    self.Time_From.text=self.Time_Slot_From;
    self.Time_To.text=self.Time_Slot_To;
    self.Patient_ID_OptionalTF.text=self.PatientID;
    self.Reffered_By_Optional_TF.text=self.refferdby;
    self.Patient_Communication_Date.text=self.Commn_Date;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.Scroll_View.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), 600);
}


- (IBAction)Apply_Action:(id)sender
{
    
}

- (IBAction)CheckBoxAction:(UIButton *)sender
{
    
    
}

#pragma mark - Submit Action.
- (IBAction)Submit_Action:(id)sender
{
    User *saved_user = [User savedUser];
    
    NSLog(@"Submit Action Clicked......");
    NSString *parameterString = [NSString stringWithFormat:@"SectionId=%@&StoreId=%@&purposeType=%@&date=%@&timeslotfrom=%@&timeslotto=%@&isConsultingFirstTime=%@&LastCommunicationDate=%@&RefferedBy=%@&userid=%@&bookingstatus=%@&addresstype=%@",[NeediatorUtitity savedDataForKey:kSAVE_CAT_ID],[NeediatorUtitity savedDataForKey:kSAVE_STORE_ID],self.Purpose_Type_ID,self.Date,self.Time_Slot_From,self.Time_Slot_To,self.ConsultingString,self.Commn_Date,self.refferdby,saved_user.userID,@"13",@""];
    
     NSString *url = [NSString stringWithFormat:@"http://192.168.1.199/NeediatorWebservice/NeediatorWS.asmx/addBook2"];
    NSLog(@"URL is --> %@", url);
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.168.1.199/NeediatorWebservice/NeediatorWS.asmx/addBook2"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody   = [NSData dataWithBytes:[parameterString UTF8String] length:[parameterString length]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",response);
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        }
        else
        {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSMutableArray *ResponsrArray=json[@"details"];
                NSDictionary *responseData=[ResponsrArray firstObject];
                
                
                OrderCompleteViewController *orderCompleteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderCompleteVC"];
                orderCompleteVC.order_id    = responseData[@"BookingNo"];
                orderCompleteVC.message     = @"Your order Request  has been successfully Submitted";
                //                    orderCompleteVC.additonalInfo = [NSString stringWithFormat:@"Payment Type is %@\n Delivery Date is %@", order[@"PaymentType"], order[@"preferred_time"]];
                [self.navigationController pushViewController:orderCompleteVC animated:YES];
                
                NSLog(@"%@",json);
                
            });
        }
    }];
    [task resume];
}
@end
