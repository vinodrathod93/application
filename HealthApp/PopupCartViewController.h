//
//  PopupCartViewController.h
//  Neediator
//
//  Created by adverto on 27/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupCartViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *warningMessageLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *emptyCartButton;
@property (weak, nonatomic) IBOutlet UIButton *goToCartButton;
@property (weak, nonatomic) IBOutlet UILabel *importantLabel;
- (IBAction)emptyCart:(id)sender;
- (IBAction)goToCart:(id)sender;
@end
