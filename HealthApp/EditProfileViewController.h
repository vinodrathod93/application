//
//  EditProfileViewController.h
//  Neediator
//
//  Created by adverto on 12/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface EditProfileViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, MWPhotoBrowserDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *firstnameTF;
@property (weak, nonatomic) IBOutlet UITextField *lastnameTF;
@property (weak, nonatomic) IBOutlet UIView *imageBackgroundView;

@property (nonatomic, copy) UIImage *image;
@property (nonatomic, copy) NSString *firstname;
@property (nonatomic, copy) NSString *lastname;

@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *dateOfBirthTF;
@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *mobileVerificationButton;
@property (weak, nonatomic) IBOutlet UIButton *emailVerificationButton;
@end
