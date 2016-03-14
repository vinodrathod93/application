//
//  StoreReviewsView.m
//  Pods
//
//  Created by adverto on 14/03/16.
//
//

#import "StoreReviewsView.h"

@implementation StoreReviewsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib {
    [super awakeFromNib];
    
    
    /* Ratings View */
    self.ratingView.backgroundColor     = [UIColor clearColor];
    self.ratingView.notSelectedImage    = [UIImage imageNamed:@"Star"];
    self.ratingView.halfSelectedImage   = [UIImage imageNamed:@"Star Half Empty"];
    self.ratingView.fullSelectedImage   = [UIImage imageNamed:@"Star Filled"];
    
    
    self.ratingView.editable            = NO;
    self.ratingView.maxRating           = 5;
    self.ratingView.minImageSize        = CGSizeMake(10.f, 10.f);
    self.ratingView.midMargin           = 0.f;
    self.ratingView.leftMargin          = 0.f;
}

@end
