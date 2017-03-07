//
//  HomeRequestConfirmVC.m
//  Neediator
//
//  Created by adverto on 11/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "HomeRequestConfirmVC.h"
#import "OrderCompleteViewController.h"

@interface HomeRequestConfirmVC ()

@end

@implementation HomeRequestConfirmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.Date_lbl.text=self.Date;
    self.timeFrom_lbl.text=self.Time_Slot_From;
    self.timeTo_lbl.text=self.Time_Slot_To;
    self.PurposeType_lbl.text=self.purposeName;
    self.refferedBy_TF.text=self.refferdby;
    self.PatientAddress.text=self.AddressString;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Submit Action.
- (IBAction)SubmitAction:(id)sender {
    
    User *saved_user = [User savedUser];
    
    NSLog(@"Submit Action Clicked......");
    NSString *parameterString = [NSString stringWithFormat:@"SectionId=%@&StoreId=%@&purposeType=%@&date=%@&timeslotfrom=%@&timeslotto=%@&isConsultingFirstTime=%@&LastCommunicationDate=%@&RefferedBy=%@&userid=%@&bookingstatus=%@&addresstype=%@",
                                
                                 [NeediatorUtitity savedDataForKey:kSAVE_CAT_ID],
                                 [NeediatorUtitity savedDataForKey:kSAVE_STORE_ID],
                                 self.Purpose_Type_ID,
                                 self.Date,
                                 self.Time_Slot_From,
                                 self.Time_Slot_To,
                                 @"",
                                 @"",
                                 self.refferdby,
                                 saved_user.userID,
                                 @"13",
                                 _Address_Type_ID];
    
    NSLog(@"Parameters Are %@",parameterString);
    
    
    
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
