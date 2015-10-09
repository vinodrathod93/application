//
//  OrderReviewFooterView.h
//  Chemist Plus
//
//  Created by adverto on 05/10/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderReviewFooterView : UIView

@property (weak, nonatomic) IBOutlet UILabel *purchase_price_label;
@property (weak, nonatomic) IBOutlet UILabel *tax_label;
@property (weak, nonatomic) IBOutlet UILabel *total_price_label;
@end
