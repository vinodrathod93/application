//
//  CartViewCell.h
//  Chemist Plus
//
//  Created by adverto on 23/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CartViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *c_imageView;
@property (nonatomic, weak) IBOutlet UILabel *c_name;
@property (weak, nonatomic) IBOutlet UILabel *singlePrice;
@property (weak, nonatomic) IBOutlet UILabel *quantityPrice;

@property (weak, nonatomic) IBOutlet UILabel *variant;
@property (weak, nonatomic) IBOutlet UIButton *quantity;

@property (weak, nonatomic) IBOutlet UILabel *currencySymbolLabel;

@end
