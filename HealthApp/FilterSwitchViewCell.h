//
//  FilterSwitchViewCell.h
//  Neediator
//
//  Created by Vinod Rathod on 11/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterSwitchViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *filterName;
@property (weak, nonatomic) IBOutlet UISwitch *filterSwitch;
@end
