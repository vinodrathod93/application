//
//  PaymentVC.m
//  Neediator
//
//  Created by adverto on 13/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "PaymentVC.h"
#import "CashOnDeliveryCell.h"
#import "CreditCardCell.h"
#import "DebitCardCell.h"
#import "User.h"
#import "OrderCompleteViewController.h"
#import "Order.h"

@interface PaymentVC ()
{
    BOOL CashOnDeliveryFlag;
    BOOL CreditCardFlag;
    BOOL DebitCardFlag;
    
}


@end

@implementation PaymentVC

#pragma mark - View Did Load.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    self.amountLbl.text=[NSString stringWithFormat:@"₹ %@",self.amountPayable];
   
    self.storeNamelbl.text=self.StoreName;
    self.CartItemsCount.text=[NSString stringWithFormat:@"(%@ Items)",self.NoOfItems];

    
    
    CashOnDeliveryFlag=1;
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - Table View Delegate & DataSource.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(CashOnDeliveryFlag==1)
    {
        CashOnDeliveryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CODcell" forIndexPath:indexPath];
        cell.CashOnDeliveryLbl.text=[NSString stringWithFormat:@"You Agree To Pay ₹%@ By Cash On Delivery",self.amountPayable];
        return cell;
    }
    if(CreditCardFlag==1)
    {
        CreditCardCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"CreditCell" forIndexPath:indexPath];
        return cell1;
    }
    
    if(DebitCardFlag==1)
    {
        DebitCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DebitCell" forIndexPath:indexPath];
        return cell;
        
        
        
        //      CompletedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CompletedCell" forIndexPath:indexPath];
        //      return cell;
        
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if(DebitCardFlag==1)
    //    {
    //        return 400;
    //
    //    }
    
    return 69;
}


#pragma mark - Button Actions.
- (IBAction)CashOnDeliveryAction:(id)sender
{
    CashOnDeliveryFlag=1;
    CreditCardFlag=0;
    DebitCardFlag=0;
    _PaymentID=@"1";
    [self.tableView reloadData];
}

- (IBAction)CreditCardAction:(id)sender
{
    CashOnDeliveryFlag=0;
    CreditCardFlag=1;
    DebitCardFlag=0;
    [self.tableView reloadData];
}

- (IBAction)DebitCardAction:(id)sender
{
    CashOnDeliveryFlag=0;
    CreditCardFlag=0;
    DebitCardFlag=1;
    [self.tableView reloadData];
}

- (IBAction)SendOrder:(id)sender {
    
    User *saved_user = [User savedUser];
    
    NSLog(@"Submit Action Clicked......");
    
    NSString *parameterString = [NSString stringWithFormat:@"user_id=%@&payment_id=%@&address_id=%@&store_id=%@&Section_id=%@&delivery_type=%@&preffered_time=%@",saved_user.userID,@"1",_addressID,[NeediatorUtitity savedDataForKey:CheckOutStoreId],[NeediatorUtitity savedDataForKey:kSAVE_SEC_ID],_deliveryType,_prefeeredTime];
    
    NSLog(@"Send Order Parameters Are %@",parameterString);
    
    
    NSString *url = [NSString stringWithFormat:@"http://neediator.net/NeediatorWebservice/NeediatorWS.asmx/addOrder"];
    NSLog(@"URL is --> %@", url);
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://neediator.net/NeediatorWebservice/NeediatorWS.asmx/addOrder"]];
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
                OrderCompleteViewController *orderCompleteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderCompleteVC"];
                orderCompleteVC.order_id    = json[@"orderno"];
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
