//
//  StoresViewCell.h
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoresViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *localityAddress;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@end
