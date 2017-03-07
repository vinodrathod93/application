//
//  WriteReviewController.h
//  Neediator
//
//  Created by adverto on 09/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"


@interface WriteReviewController : UIViewController<RateViewDelegate,UIActionSheetDelegate>


@property (weak, nonatomic) IBOutlet RatingView *ratingView;
@property (weak, nonatomic) IBOutlet UITextView *reviewTextView;
- (IBAction)postReview:(id)sender;





@property(nonatomic,retain)NSString *userId;
@property(nonatomic,retain)NSString *sectionid;
@property(nonatomic,retain)NSString *storeId;
@property(nonatomic,retain)NSString *OverallRating;



@end
