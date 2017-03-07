//
//  SubCategoryHeaderView.h
//  Neediator
//
//  Created by adverto on 30/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubCategoryHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *blurView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end
