//
//  AddressCell.h
//  Chemist Plus
//
//  Created by adverto on 01/10/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *full_name;
@property (weak, nonatomic) IBOutlet UILabel *completeAddress;


@property (weak, nonatomic) IBOutlet UILabel *AddressTYpe;
@property (weak, nonatomic) IBOutlet UIButton *DefaultAddressBtn;
@property (weak, nonatomic) IBOutlet UILabel *ContactNumber;


@end
