//
//  ProductImageViewCell.h
//  Chemist Plus
//
//  Created by adverto on 17/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductImageViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIScrollView *productImageScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end
