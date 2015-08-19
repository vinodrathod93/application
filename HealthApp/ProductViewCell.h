//
//  ProductViewCell.h
//  Chemist Plus
//
//  Created by adverto on 14/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *productImageView;
@property (nonatomic, weak) IBOutlet UILabel * productLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;

@end
