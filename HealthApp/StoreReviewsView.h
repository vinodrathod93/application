//
//  StoreReviewsView.h
//  Pods
//
//  Created by adverto on 14/03/16.
//
//

#import <UIKit/UIKit.h>
#import "RatingView.h"

@interface StoreReviewsView : UIView

@property (weak, nonatomic) IBOutlet RatingView *ratingView;
@property (weak, nonatomic) IBOutlet UIButton *reviewsLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *viewsButton;


@property (assign, nonatomic) BOOL likedStore;
//@property (assign, nonatomic) BOOL dislikedStore;
@end
