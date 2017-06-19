//
//  TypeSendTableViewCell.h
//  Neediator
//
//  Created by Vinod Rathod on 20/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TypeSendTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *productNameTF;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *productDescription;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *featureDescription;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *quantityTF;

@end
