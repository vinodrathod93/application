//
//  PaymentDetailViewCell.h
//  Neediator
//
//  Created by adverto on 24/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentDetailViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *subTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTotalValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryValueLabel;
@end
