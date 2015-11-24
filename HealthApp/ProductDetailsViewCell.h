//
//  ProductDetailsViewCell.h
//  Neediator
//
//  Created by adverto on 24/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailsViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *productLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end
