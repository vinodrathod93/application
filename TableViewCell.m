//
//  TableViewCell.m
//  Neediator
//
//  Created by adverto on 19/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "TableViewCell.h"


@implementation HorizontalCollectionView1


@end



@implementation TableViewCell

- (void)awakeFromNib {
    
    self.p_colection.backgroundColor = [UIColor clearColor];
    
    [self.p_colection registerClass:[CustomPrescriptionViewCell class] forCellWithReuseIdentifier:@"MyPrescriptionCollectionCellIdentifier"];
    self.p_colection.showsHorizontalScrollIndicator = NO;
    
    
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
    
    //    self.orderState = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, CGRectGetWidth(self.bounds)/2 - 8, 22.f)];
    //    self.orderState.font = [UIFont fontWithName:@"AvenirNext-Bold" size:16.f];
    //    self.orderState.textColor = [UIColor blackColor];
    //    [self.contentView addSubview:self.orderState];
    
    
    self.orderNumber = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)/2, 8, CGRectGetWidth(self.bounds)/2 - 8, 22.f)];
    self.orderNumber.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.f];
    self.orderNumber.textColor = [UIColor darkGrayColor];
    [self.orderNumber setTextAlignment:NSTextAlignmentRight];
    [self.contentView addSubview:self.orderNumber];
    
    
    //    self.orderDate = [[UILabel alloc] initWithFrame:CGRectMake(8, 38, CGRectGetWidth(self.bounds) - 8, 38)];
    //    self.orderDate.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13.f];
    //    self.orderDate.textColor = [UIColor darkGrayColor];
    //    self.orderDate.numberOfLines = 0;
    //    [self.contentView addSubview:self.orderDate];
    
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(2, 2, 0, 2);
    layout.itemSize = CGSizeMake(75, 90);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[HorizontalCollectionView1 alloc] initWithFrame:CGRectMake(8, 84, CGRectGetWidth(self.bounds) - (2 * 8), 100) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[CustomPrescriptionViewCell class] forCellWithReuseIdentifier:@"MyPrescriptionCollectionCellIdentifier"];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.collectionView];
    
    
    return self;
}


- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    self.p_colection.dataSource = dataSourceDelegate;
    self.p_colection.delegate = dataSourceDelegate;
    self.p_colection.indexPath = indexPath;
    [self.p_colection reloadData];
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
    if (hide)
    {
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

-(void)setStoreImage:(NSString *)storeImage
{
    [self.storeImageView sd_setImageWithURL:[NSURL URLWithString:storeImage]];
    UIView *view = [[UIView alloc] initWithFrame:self.storeImageView.frame];
    view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    [self.storeImageView addSubview:view];
}


@end
