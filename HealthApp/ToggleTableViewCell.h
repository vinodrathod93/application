//
//  ToggleTableViewCell.h
//  Neediator
//
//  Created by Vinod Rathod on 04/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToggleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *toggleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;

@end
