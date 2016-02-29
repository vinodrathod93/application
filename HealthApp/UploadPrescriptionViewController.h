//
//  UploadPrescriptionViewController.h
//  HealthApp
//
//  Created by adverto on 06/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface UploadPrescriptionViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate, MWPhotoBrowserDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray *_selections;
}


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
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
@end
