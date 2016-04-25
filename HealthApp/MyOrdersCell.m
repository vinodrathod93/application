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
    
    
//    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//    layout.sectionInset = UIEdgeInsetsMake(2, 2, 0, 2);
//    layout.itemSize = CGSizeMake(75, 90);
//    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    self.n_collectionView = [[HorizontalCollectionView alloc] initWithFrame:CGRectMake(8, 84, CGRectGetWidth(self.bounds) - (2 * 8), 100) collectionViewLayout:layout];
    
    self.n_collectionView.backgroundColor = [UIColor whiteColor];
    [self.n_collectionView registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:@"MyOrderCollectionViewCellIdentifier"];
    self.n_collectionView.showsHorizontalScrollIndicator = NO;
    
    
    self.returnButton.layer.cornerRadius = 5.f;
    self.replaceButton.layer.cornerRadius = 5.f;
    self.trackButton.layer.cornerRadius = 5.f;
    
    self.returnButton.layer.masksToBounds = YES;
    self.replaceButton.layer.masksToBounds = YES;
    self.trackButton.layer.masksToBounds = YES;
    
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    self.orderState = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, CGRectGetWidth(self.bounds)/2 - 8, 22.f)];
    self.orderState.font = [UIFont fontWithName:@"AvenirNext-Bold" size:16.f];
    self.orderState.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.orderState];
    
    
    self.orderNumber = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)/2, 8, CGRectGetWidth(self.bounds)/2 - 8, 22.f)];
    self.orderNumber.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.f];
    self.orderNumber.textColor = [UIColor darkGrayColor];
    [self.orderNumber setTextAlignment:NSTextAlignmentRight];
    [self.contentView addSubview:self.orderNumber];
    

    self.orderDate = [[UILabel alloc] initWithFrame:CGRectMake(8, 38, CGRectGetWidth(self.bounds) - 8, 38)];
    self.orderDate.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13.f];
    self.orderDate.textColor = [UIColor darkGrayColor];
    self.orderDate.numberOfLines = 0;
    [self.contentView addSubview:self.orderDate];
    
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(2, 2, 0, 2);
    layout.itemSize = CGSizeMake(75, 90);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[HorizontalCollectionView alloc] initWithFrame:CGRectMake(8, 84, CGRectGetWidth(self.bounds) - (2 * 8), 100) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:@"MyOrderCollectionViewCellIdentifier"];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.collectionView];
    
    
    
    
    
    
    
    
    
    return self;
}


- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    self.n_collectionView.dataSource = dataSourceDelegate;
    self.n_collectionView.delegate = dataSourceDelegate;
    self.n_collectionView.indexPath = indexPath;
    
    [self.n_collectionView reloadData];
}


@end
