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
-(void)hideButtonsSeenAfter7Days:(BOOL)hide;
-(void)hideButtonsAndViewSeenBefore7Days:(BOOL)hide;
- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;



@property (weak, nonatomic) IBOutlet UILabel *StoreName;
@property (weak, nonatomic) IBOutlet UILabel *StoreArea;
@property (weak, nonatomic) IBOutlet UILabel *n_orderNumber;
@property (weak, nonatomic) IBOutlet UILabel *n_orderAmount;
@property (weak, nonatomic) IBOutlet UILabel *n_orderStatus;
@property (weak, nonatomic) IBOutlet HorizontalCollectionView *n_collectionView;


@property (weak, nonatomic) IBOutlet UIButton *returnButton;
@property (weak, nonatomic) IBOutlet UIButton *replaceButton;
@property (weak, nonatomic) IBOutlet UIButton *trackButton;

@property (weak, nonatomic) IBOutlet UIButton *infoBtn;

@property (weak, nonatomic) IBOutlet UIButton *ProductInfoButton;


@property (weak, nonatomic) IBOutlet UIView *ReturnReplace_View;
@property (weak, nonatomic) IBOutlet UIButton *ReturnBtn;
@property (weak, nonatomic) IBOutlet UIButton *ReplaceBtn;


@property (weak, nonatomic) IBOutlet UIView   *beforeCompleteOptionView;
@property (weak, nonatomic) IBOutlet UIButton *cancelOrderButton;
@property (weak, nonatomic) IBOutlet UIButton *beforeCompleteTrackOrderButton;

@property (weak, nonatomic) IBOutlet UIButton *pendingCancelOrderBtn;

@property (nonatomic, strong) NSString *storeImage;
@property (weak, nonatomic) IBOutlet UIImageView *storeImageView;



@property (weak, nonatomic) IBOutlet UILabel *stlbl;


@end
