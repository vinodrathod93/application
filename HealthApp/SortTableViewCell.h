//
//  SortTableViewCell.h
//  Neediator
//
//  Created by Vinod Rathod on 20/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SortTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *sortLabel;
@property (weak, nonatomic) IBOutlet UIButton *ascending;
@property (weak, nonatomic) IBOutlet UIButton *descending;
@end
