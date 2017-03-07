//
//  PaymentVC.h
//  Neediator
//
//  Created by adverto on 13/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentVC : UIViewController<UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)CashOnDeliveryAction:(id)sender;
- (IBAction)CreditCardAction:(id)sender;
- (IBAction)DebitCardAction:(id)sender;
- (IBAction)SendOrder:(id)sender;



@property (weak, nonatomic) IBOutlet UILabel *amountLbl;
@property (weak, nonatomic) IBOutlet UILabel *storeNamelbl;
@property (weak, nonatomic) IBOutlet UILabel *CartItemsCount;











@property(nonatomic,retain)NSString *prefeeredTime;
@property(nonatomic,retain)NSString *deliveryType;
@property(nonatomic,retain)NSString *addressID;
@property(nonatomic,retain)NSString *PaymentID;

@property(nonatomic,retain)NSString *amountPayable;
@property(nonatomic,retain)NSString *amountInRS;
@property(nonatomic,retain)NSString *StoreName;
@property(nonatomic,retain)NSString *NoOfItems;

@end
