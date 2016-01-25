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


@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UIButton *viewButton;

- (IBAction)viewOrderPressed:(id)sender;
@end
