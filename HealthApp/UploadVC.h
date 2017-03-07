//
//  UploadVC.h
//  Neediator
//
//  Created by adverto on 10/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NTextField.h"
#import "AddressesViewController.h"

@interface UploadVC : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate, MWPhotoBrowserDelegate, UICollectionViewDataSource, UICollectionViewDelegate, AddressDelegate>
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

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) ALAssetsLibrary *ALAssetsLibrary;


@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *deliveryTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *deliveryTypeButton;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;

@property (weak, nonatomic) IBOutlet UILabel *dataTimeLabel;
@property (weak, nonatomic) IBOutlet NTextField *dateTimeField;


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;



@end
