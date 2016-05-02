//
//  DoctorOptionsViewCell.h
//  Neediator
//
//  Created by adverto on 02/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoctorOptionsViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *appointmentView;
@property (weak, nonatomic) IBOutlet UIView *sendReportsView;
@property (weak, nonatomic) IBOutlet UIView *homeRequestView;
@property (weak, nonatomic) IBOutlet UIButton *appointmentButton;
@property (weak, nonatomic) IBOutlet UIButton *sendReportButton;
@property (weak, nonatomic) IBOutlet UIButton *homeRequestButton;
@end
