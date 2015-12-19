//
//  MyOrdersCell.h
//  Neediator
//
//  Created by adverto on 16/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCollectionViewCell.h"


@interface HorizontalCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;
@end


@interface MyOrdersCell : UITableViewCell

@property (strong, nonatomic)  UILabel *orderState;
@property (strong, nonatomic)  UILabel *orderNumber;
@property (strong, nonatomic)  UILabel *orderDate;

@property (strong, nonatomic)  HorizontalCollectionView *collectionView;

@property (nonatomic, strong) NSArray *images;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;

@end
