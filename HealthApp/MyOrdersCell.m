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
    
    self.n_collectionView.backgroundColor = [UIColor clearColor];
    
    [self.n_collectionView registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:@"MyOrderCollectionViewCellIdentifier"];
    self.n_collectionView.showsHorizontalScrollIndicator = NO;
    
    
    self.returnButton.layer.cornerRadius        = 5.f;
    self.replaceButton.layer.cornerRadius       = 5.f;
    self.trackButton.layer.cornerRadius         = 5.f;
    self.cancelOrderButton.layer.cornerRadius   = 5.f;
    self.beforeCompleteTrackOrderButton.layer.cornerRadius = 5.f;
    
    
    
    self.returnButton.layer.masksToBounds       = YES;
    self.replaceButton.layer.masksToBounds      = YES;
    self.trackButton.layer.masksToBounds        = YES;
    self.cancelOrderButton.layer.masksToBounds  = YES;
    self.beforeCompleteTrackOrderButton.layer.masksToBounds = YES;
    
    

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


-(void)hideButtonsSeenAfter7Days:(BOOL)hide {
    if (hide) {
        self.returnButton.hidden    = hide;
        self.replaceButton.hidden   = hide;
        self.trackButton.hidden     = hide;
    }
    else {
        self.returnButton.hidden = !hide;
        self.replaceButton.hidden = !hide;
        self.trackButton.hidden = !hide;
    }
}

-(void)hideButtonsAndViewSeenBefore7Days:(BOOL)hide {
    if (hide) {
        self.cancelOrderButton.hidden               = hide;
        self.beforeCompleteTrackOrderButton.hidden  = hide;
        self.beforeCompleteOptionView.hidden        = hide;
    }
    else {
        self.cancelOrderButton.hidden               = !hide;
        self.beforeCompleteTrackOrderButton.hidden  = !hide;
        self.beforeCompleteOptionView.hidden        = !hide;
    }
}

-(void)setStoreImage:(NSString *)storeImage {
    
//    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.n_collectionView.frame];
//    [backgroundImage sd_setImageWithURL:[NSURL URLWithString:storeImage]];
//    [backgroundImage setAlpha:0.2];
    
    
    
    
    
    
    
    
    [self.storeImageView sd_setImageWithURL:[NSURL URLWithString:storeImage]];
    
    UIView *view = [[UIView alloc] initWithFrame:self.storeImageView.frame];
    view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    
    [self.storeImageView addSubview:view];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//        
//        blurEffectView.frame = self.storeImageView.frame;
//        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        
////        
////        
////        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
////        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
////        [vibrancyEffectView setFrame:self.storeImageView.frame];
//        
////        [blurEffectView.contentView addSubview:vibrancyEffectView];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.storeImageView addSubview:blurEffectView];
//        });
//    });
    
    
    
    
    
}

@end
