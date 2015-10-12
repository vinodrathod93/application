//
//  SearchResultsProductViewCell.h
//  Chemist Plus
//
//  Created by adverto on 12/10/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsProductViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *product_imageView;
@property (weak, nonatomic) IBOutlet UILabel *product_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *product_priceLabel;
@end
