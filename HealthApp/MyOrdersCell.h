//
//  MyOrdersCell.h
//  Neediator
//
//  Created by adverto on 16/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HorizontalCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;
@end


@interface MyOrdersCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *orderState;
@property (weak, nonatomic) IBOutlet UILabel *orderNumber;
@property (weak, nonatomic) IBOutlet UILabel *orderDate;

@property (weak, nonatomic) IBOutlet HorizontalCollectionView *collectionView;

@property (nonatomic, copy) NSArray *images;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;
@end
