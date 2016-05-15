//
//  FollowUsTableViewCell.h
//  Neediator
//
//  Created by Vinod Rathod on 12/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FollowUsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UILabel *followLabel;
@property (weak, nonatomic) IBOutlet UIImageView *followImageView;
@end
