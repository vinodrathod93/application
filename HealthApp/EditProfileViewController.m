//
//  EditProfileViewController.m
//  Neediator
//
//  Created by adverto on 12/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "EditProfileViewController.h"

@interface EditProfileViewController ()

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) ALAssetsLibrary *ALAssetsLibrary;
@property (nonatomic, strong) NSArray *selectedImagesArray;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation EditProfileViewController {
    MWPhotoBrowser *browser;
    BOOL _cameraCaptured;
    UIImage *_cameraImage;
    NSMutableArray *_selections;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Edit Profile";
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    saveButton.titleLabel.font = [NeediatorUtitity mediumFontWithSize:16.f];
    [saveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    
    self.imageBackgroundView.layer.cornerRadius = self.imageBackgroundView.frame.size.width/2;
    self.imageBackgroundView.layer.masksToBounds = YES;
    
    
    
    User *savedUser = [User savedUser];
    
    if (savedUser) {
        [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:savedUser.profilePic] placeholderImage:[UIImage imageNamed:@"profile_placeholder"] options:SDWebImageRefreshCached];
        self.firstnameTF.text = savedUser.firstName;
        self.lastnameTF.text = savedUser.lastName;
    }
    
    
    self.firstnameTF.delegate = self;
    self.lastnameTF.delegate = self;
    
    
    [self.editProfileButton addTarget:self action:@selector(editPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self loadAssets];
    
    
}


-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat lastViewHeight = CGRectGetHeight(((UIView *)[self.contentView.subviews lastObject]).frame);
    int lastViewY = CGRectGetMaxY(((UIView *)[self.contentView.subviews lastObject]).frame);
    
    CGFloat height = lastViewHeight + lastViewY;
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), height);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)saveButtonPressed:(id)sender {
    
    NSString *convertedImage = @"";
    
    if (self.selectedImagesArray.count != 0) {
        convertedImage = [self selectedImagesBase64][0];
    }
    
    
    
    [self showHUD];
    self.hud.mode = MBProgressHUDModeDeterminateHorizontalBar;

    
    NSDictionary *data = @{
                           @"firstname" : self.firstnameTF.text,
                           @"lastname"  : self.lastnameTF.text,
                           @"imageprofile" : convertedImage
                           };
    
    
    [[NAPIManager sharedManager] updateUserProfile:data withHUD:self.hud success:^(BOOL success, NSDictionary *responseData) {
        // get data and pop
        
        if (success) {
            
            NSLog(@"%@", responseData);
            
            
            [self hideHUD];
            [self showHideCompletedHUD];
            
            NSDictionary *response = responseData[@"update_profile"][0];
            
            User *savedUser = [User savedUser];
            
            savedUser.firstName = response[@"FirstName"] == [NSNull null] ? @"" : response[@"FirstName"];
            savedUser.lastName  = response[@"LastName"] == [NSNull null] ? @"" : response[@"LastName"];
            savedUser.profilePic    = response[@"imageurl"] == [NSNull null] ? @"" : response[@"imageurl"];
            savedUser.email         = response[@"Email"] == [NSNull null] ? @"" : response[@"Email"];
            
            [savedUser save];
            
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        
    } failure:^(NSError *error) {
        
        [self.hud hide:YES];
        [NeediatorUtitity alertWithTitle:@"Error" andMessage:error.localizedDescription onController:self];
    }];
}


-(void)editPressed:(UIButton *)sender {
    
//    [self hideAllElements];
    
    [self showUploadImageOptions:sender];
    
}


-(void)showUploadImageOptions:(UIButton *)sender {
    
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Choose new Photo" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self takePhoto];
    }];
    
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectPhotos];
    }];
    
    [controller addAction:camera];
    [controller addAction:library];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:cancel];
    
    controller.popoverPresentationController.sourceView = sender;
    controller.popoverPresentationController.sourceRect = sender.bounds;
    [self presentViewController:controller animated:YES completion:nil];
}



-(void)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


-(void)selectPhotos {
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    
    @synchronized(_assets) {
        NSMutableArray *copy = [_assets copy];
        if (NSClassFromString(@"PHAsset")) {
            // Photos library
            UIScreen *screen = [UIScreen mainScreen];
            CGFloat scale = screen.scale;
            // Sizing is very rough... more thought required in a real implementation
            CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
            CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
            CGSize thumbTargetSize = CGSizeMake(imageSize / 3.0 * scale, imageSize / 3.0 * scale);
            for (PHAsset *asset in copy) {
                [photos addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
                [thumbs addObject:[MWPhoto photoWithAsset:asset targetSize:thumbTargetSize]];
            }
        } else {
            // Assets library
            for (ALAsset *asset in copy) {
                MWPhoto *photo = [MWPhoto photoWithURL:asset.defaultRepresentation.url];
                [photos addObject:photo];
                MWPhoto *thumb = [MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]];
                [thumbs addObject:thumb];
                if ([asset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo) {
                    photo.videoURL = asset.defaultRepresentation.url;
                    thumb.isVideo = true;
                }
            }
        }
        
    }
    
    self.photos = photos;
    self.thumbs = thumbs;
    
    browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = NO;
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = YES;
    browser.alwaysShowControls = YES;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = NO;
    browser.startOnGrid = YES;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = NO;
    [browser setCurrentPhotoIndex:0];
    
    
    if (_selections != nil) {
        NSLog(@"Already Selected");
    }
    else if (browser.displaySelectionButtons) {
        _selections = [NSMutableArray new];
        for (int i = 0; i < photos.count; i++) {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
}




#pragma mark - ImagePicker Delegates

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    
    NSLog(@"%@", info);
    _cameraImage = info[UIImagePickerControllerOriginalImage];
    
    
    _cameraCaptured = YES;
    
    
    
    self.selectedImagesArray  = [self thumbnailSelectedImages];
    [self updateProfileImageView];
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}



-(void)updateProfileImageView {
    
    if (self.selectedImagesArray.count != 0) {
        self.profileImageView.image = self.selectedImagesArray[0];
    }
    else
        NSLog(@"Could not update");
    
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}


- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    NSLog(@"Selections %@", _selections);
    [self dismissViewControllerAnimated:YES completion:^{
        
        if ([_selections containsObject:[NSNumber numberWithBool:YES]]) {
            
            
            self.selectedImagesArray = [self thumbnailSelectedImages];
            [self updateProfileImageView];
        }
        
        
        
    }];
    
    
    
    
    
    
}




-(NSArray *)thumbnailSelectedImages {
    
    NSMutableArray *thumbnails = [NSMutableArray array];
    
    thumbnails = (NSMutableArray *)[self commonSelectedImagesWithSize:CGSizeMake(100, 150)];
    
    
    [thumbnails addObject:[UIImage imageNamed:@"addPlus"]];
    
    return thumbnails;
}


-(NSArray *)largeSelectedImages {
    
    return [self commonSelectedImagesWithSize:self.view.frame.size];
}


-(NSArray *)selectedImagesBase64 {
    
    NSArray *images = self.selectedImagesArray;
    
    NSMutableArray *base64Images = [[NSMutableArray alloc] init];
    
    [images enumerateObjectsUsingBlock:^(UIImage  *_Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx == images.count-1) {
            ;
        }
        else {
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            NSData *base64data = [data base64EncodedDataWithOptions:0];
            
            NSString *imageBase64String = [[NSString alloc] initWithData:base64data encoding:NSUTF8StringEncoding];
            
            [base64Images addObject:imageBase64String];
        }
        
    }];
    
    
    return base64Images;
}


-(NSArray *)commonSelectedImagesWithSize:(CGSize)size {
    NSMutableArray *selectedImagesArray = [[NSMutableArray alloc] init];
    NSArray *positions = [self positionArray];
    
    if (_cameraCaptured) {
        
        
        UIImage *scaledImage = [self imageWithImage:_cameraImage scaledToSize:size];
        [selectedImagesArray addObject:scaledImage];
    }
    else {
        
        [positions enumerateObjectsUsingBlock:^(NSNumber  *_Nonnull index, NSUInteger idx, BOOL * _Nonnull stop) {
            
            PHAsset *photo = _assets[index.intValue];
            UIImage *image = [self getAssetThumbnail:photo withTargetSize:size];
            
            
            [selectedImagesArray addObject:image];
            
        }];
        
    }
    
    
    
    return selectedImagesArray;
}

-(NSArray *)positionArray {
    
    NSMutableArray *positions = [[NSMutableArray alloc] init];
    
    
    [_selections enumerateObjectsUsingBlock:^(NSNumber *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.intValue == 1) {
            [positions addObject:@(idx)];
        }
    }];
    
    return positions;
    
}


-(UIImage *)getAssetThumbnail:(PHAsset *)asset withTargetSize:(CGSize)size {
    PHImageManager *manager = [PHImageManager defaultManager];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    
    __block UIImage *thumbnail = [[UIImage alloc] init];
    options.synchronous = TRUE;
    
    [manager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        thumbnail = result;
    }];
    
    return thumbnail;
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - Assests


- (void)loadAssets {
    if (NSClassFromString(@"PHAsset")) {
        
        // Check library permissions
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self performLoadAssets];
                }
            }];
        } else if (status == PHAuthorizationStatusAuthorized) {
            [self performLoadAssets];
        }
        
    } else {
        
        // Assets library
        [self performLoadAssets];
        
    }
}


- (void)performLoadAssets {
    
    // Initialise
    _assets = [NSMutableArray new];
    
    // Load
    if (NSClassFromString(@"PHAsset")) {
        
        // Photos library iOS >= 8
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PHFetchOptions *options = [PHFetchOptions new];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHFetchResult *fetchResults = [PHAsset fetchAssetsWithOptions:options];
            [fetchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [_assets addObject:obj];
            }];
            if (fetchResults.count > 0) {
                //                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                
                
                NSLog(@"Gallery Photos fetched");
            }
        });
        
    } else {
        
        // Assets Library iOS < 8
        _ALAssetsLibrary = [[ALAssetsLibrary alloc] init];
        
        // Run in the background as it takes a while to get all assets from the library
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
            NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
            
            // Process assets
            void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    NSString *assetType = [result valueForProperty:ALAssetPropertyType];
                    if ([assetType isEqualToString:ALAssetTypePhoto] || [assetType isEqualToString:ALAssetTypeVideo]) {
                        [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                        NSURL *url = result.defaultRepresentation.url;
                        [_ALAssetsLibrary assetForURL:url
                                          resultBlock:^(ALAsset *asset) {
                                              if (asset) {
                                                  @synchronized(_assets) {
                                                      [_assets addObject:asset];
                                                      if (_assets.count == 1) {
                                                          // Added first asset so reload data
                                                          //                                                          [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                                          
                                                          NSLog(@"First Gallery Photos fetched");
                                                      }
                                                  }
                                              }
                                          }
                                         failureBlock:^(NSError *error){
                                             NSLog(@"operation was not successfull!");
                                         }];
                        
                    }
                }
            };
            
            // Process groups
            void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
                if (group != nil) {
                    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                    [assetGroups addObject:group];
                }
            };
            
            // Process!
            [_ALAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                            usingBlock:assetGroupEnumerator
                                          failureBlock:^(NSError *error) {
                                              NSLog(@"There is an error");
                                          }];
            
        });
        
    }
    
}


-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = self.view.tintColor;
    self.hud.labelText = @"Updating...";
}

-(void)hideHUD {
    
    [self.hud hide:YES];
    [self.hud removeFromSuperview];
}


-(void)showHideCompletedHUD {
    MBProgressHUD *completed_hud = [[MBProgressHUD alloc] initWithView:self.view];
    completed_hud.color = [UIColor clearColor];
    [self.view addSubview:completed_hud];
    
    completed_hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ok Filled"]];
    completed_hud.mode = MBProgressHUDModeCustomView;
    
    [completed_hud show:YES];
    [completed_hud hide:YES afterDelay:2.0];
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.firstnameTF]) {
        [self.lastnameTF becomeFirstResponder];
    }
    else if ([textField isEqual:self.lastnameTF]) {
        [self.lastnameTF resignFirstResponder];
    }
    
    
    return YES;
}






@end
