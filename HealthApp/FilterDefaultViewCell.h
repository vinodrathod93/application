//
//  FilterDefaultViewCell.h
//  Neediator
//
//  Created by Vinod Rathod on 11/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterDefaultViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *defaultLabel;
@property (weak, nonatomic) IBOutlet UILabel *defaultValue;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingDefaultLabelConstraint;
@end
