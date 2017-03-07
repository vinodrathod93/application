//
//  OrderReviewCell.h
//  Chemist Plus
//
//  Created by adverto on 05/10/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderReviewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *product_imageview;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *quantity;
@property (weak, nonatomic) IBOutlet UILabel *variant;
@property (weak, nonatomic) IBOutlet UILabel *total_price;

@end
