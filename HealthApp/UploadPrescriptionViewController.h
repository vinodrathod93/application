//
//  UploadPrescriptionViewController.h
//  HealthApp
//
//  Created by adverto on 06/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadPrescriptionViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)takePhotoPressed:(id)sender;
- (IBAction)selectPhotoPressed:(id)sender;
- (IBAction)uploadPhotoPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *selectPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIImageView *takePhotoImage;
@property (weak, nonatomic) IBOutlet UIImageView *selectPhotoImage;
@property (weak, nonatomic) IBOutlet UILabel *selectPhotoLabel;

@end
