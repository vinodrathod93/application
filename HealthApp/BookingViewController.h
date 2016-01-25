//
//  BookingViewController.h
//  Pods
//
//  Created by adverto on 25/01/16.
//
//

#import <UIKit/UIKit.h>
#import <DIDatepicker/DIDatepicker.h>

@interface BookingViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *metaInfo;
@property (weak, nonatomic) IBOutlet DIDatepicker *calendar;

@property (weak, nonatomic) IBOutlet UILabel *selected_dateLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSString *entity_id;
@property (nonatomic, strong) NSString *category_id;
@property (nonatomic, strong) NSString *entity_name;
@property (nonatomic, strong) NSString *entity_meta_info;

@end
