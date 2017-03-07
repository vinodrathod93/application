//
//  UploadReportsVC.h
//  Neediator
//
//  Created by adverto on 31/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NTextField.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface UploadReportsVC : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate, MWPhotoBrowserDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray *_selections;
}

- (IBAction)takePhotoPressed:(id)sender;
- (IBAction)selectPhotoPressed:(id)sender;
- (IBAction)uploadPhotoPressed:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *selectPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UILabel *selectPhotoLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIView *Patient_Detail_View;
@property (weak, nonatomic) IBOutlet UIView *Communication_Date_View;

@property (weak, nonatomic) IBOutlet UITextField *Patient_ID_TF;
@property (weak, nonatomic) IBOutlet UITextField *Communication_Date_TF;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) ALAssetsLibrary *ALAssetsLibrary;

@end
