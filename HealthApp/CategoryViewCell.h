//
//  CategoryViewCell.h
//  Chemist Plus
//
//  Created by adverto on 13/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

- (void)downloadImageFromURL:(NSURL *)imageUrl;
@end

