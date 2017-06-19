//
//  NotificationTableViewCell.h
//  Neediator
//
//  Created by Vinod Rathod on 27/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *notifDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *notifTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@end
