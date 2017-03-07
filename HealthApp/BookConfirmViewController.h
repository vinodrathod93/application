//
//  BookConfirmViewController.h
//  Neediator
//
//  Created by adverto on 25/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookConfirmViewController : UIViewController

@property (nonatomic, strong) NSString *timeSlot_id;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *entity_id;
@property (nonatomic, strong) NSString *entity_name;
@property (nonatomic, strong) NSString *image_url;
@property (nonatomic, strong) NSString *entity_meta_string;

@property (nonatomic, strong) NSString *cat_id;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *metaLabel;
@property (weak, nonatomic) IBOutlet UILabel *appointmentDateTimeLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UIButton *bookButton;
@end
