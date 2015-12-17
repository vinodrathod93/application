//
//  MyOrdersCell.m
//  Neediator
//
//  Created by adverto on 16/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "MyOrdersCell.h"

@implementation HorizontalCollectionView


@end


@implementation MyOrdersCell

- (void)awakeFromNib {
    // Initialization code
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MyOrderCollectionViewCellIdentifier"];
    self.collectionView.showsHorizontalScrollIndicator = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
//    
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MyOrderCollectionViewCellIdentifier"];
//    self.collectionView.showsHorizontalScrollIndicator = NO;
//    
//    return self;
//}


- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.indexPath = indexPath;
    
    [self.collectionView reloadData];
}


@end
