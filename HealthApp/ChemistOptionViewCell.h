//
//  ChemistOptionViewCell.h
//  Neediator
//
//  Created by adverto on 02/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChemistOptionViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *sendPrescriptionView;
@property (weak, nonatomic) IBOutlet UIView *quickOrderView;
@property (weak, nonatomic) IBOutlet UIButton *sendPresButton;
@property (weak, nonatomic) IBOutlet UIButton *quickOrderButton;
@end
