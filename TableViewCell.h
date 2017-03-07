//
//  TableViewCell.h
//  Neediator
//
//  Created by adverto on 19/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPrescriptionViewCell.h"



@interface HorizontalCollectionView1 : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;

@end






@interface TableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *StoreName;
@property (weak, nonatomic) IBOutlet UILabel *AreaName;


@property (weak, nonatomic) IBOutlet UIButton *PendingCancelOrdrBtn;










@property (weak, nonatomic) IBOutlet UILabel *orderNumber;
@property (weak, nonatomic) IBOutlet UIImageView *PrescriptionView;

@property (weak, nonatomic) IBOutlet UIScrollView *offersScrollView;


@property (weak, nonatomic) IBOutlet UIButton *returnButton;
@property (weak, nonatomic) IBOutlet UIButton *replaceButton;
@property (weak, nonatomic) IBOutlet UIButton *trackButton;


@property (weak, nonatomic) IBOutlet UIView *beforeCompleteOptionView;
@property (weak, nonatomic) IBOutlet UIButton *cancelOrderButton;
@property (weak, nonatomic) IBOutlet UIButton *beforeCompleteTrackOrderButton;


@property (weak, nonatomic) IBOutlet HorizontalCollectionView1 *p_colection;



@property (strong, nonatomic)  HorizontalCollectionView1 *collectionView;
- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;

@property (weak, nonatomic) IBOutlet UIImageView *storeImageView;


@end
