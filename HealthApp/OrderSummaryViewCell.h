//
//  OrderSummaryViewCell.h
//  Chemist Plus
//
//  Created by adverto on 21/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderSummaryViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *itemsLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@end
