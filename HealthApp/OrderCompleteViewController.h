//
//  OrderCompleteViewController.h
//  Chemist Plus
//
//  Created by adverto on 05/10/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderCompleteViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *order_number;

@property (nonatomic, strong) NSString *order_id;


@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewButton;
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *heading;
@property (strong, nonatomic) NSString *booking_id;


- (IBAction)viewOrderPressed:(id)sender;
@end
