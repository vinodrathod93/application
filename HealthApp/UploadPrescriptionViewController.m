//
//  UploadPrescriptionViewController.m
//  HealthApp
//
//  Created by adverto on 06/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "UploadPrescriptionViewController.h"


@interface UploadPrescriptionViewController ()
{
    long long expectedLength;
    long long currentLength;
    MWPhotoBrowser *browser;
}

@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation UploadPrescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
    
    [self.uploadButton setTintColor:[UIColor lightGrayColor]];
    [self.uploadButton setUserInteractionEnabled:NO];
    
    
    self.closeButton.layer.cornerRadius = self.closeButton.frame.size.height/2;
    self.closeButton.layer.masksToBounds = YES;
    
    [self loadAssets];
    
    
    
    self.imagesCollectionView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.imagesCollectionView.layer.borderWidth = 1.5f;
    self.imagesCollectionView.layer.cornerRadius = 5.f;
    self.imagesCollectionView.layer.masksToBounds = YES;
    
    
    self.imagesCollectionView.hidden = YES;
    
}


-(IBAction)takePhotoPressed:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


-(IBAction)selectPhotoPressed:(id)sender {
    
    
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.allowsEditing = YES;
//    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    
//    [self presentViewController:picker animated:YES completion:NULL];
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
    
    
    if (browser.displaySelectionButtons) {
        _selections = [NSMutableArray new];
        for (int i = 0; i < photos.count; i++) {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
    
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
        self.imagesCollectionView.hidden = NO;
        
        self.selectPhotoButton.hidden = YES;
        self.takePhotoButton.hidden = YES;
        self.selectPhotoLabel.hidden = YES;
        
        [self.uploadButton setTintColor:self.view.tintColor];
        [self.uploadButton setUserInteractionEnabled:YES];
        
        [self.view bringSubviewToFront:self.imagesCollectionView];
        [self.imagesCollectionView reloadData];
    }];
    
    
    
    
    
    
}


#pragma mark - ImagePicker Delegates

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.selectPhotoButton.hidden = YES;
    self.takePhotoButton.hidden = YES;
    
    self.selectPhotoLabel.hidden = YES;
    
    
    [self.uploadButton setTintColor:self.view.tintColor];
    [self.uploadButton setUserInteractionEnabled:YES];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)uploadPhotoPressed:(id)sender {
    
    NSArray *selectedImages = [self selectedImages];
    
    if (selectedImages.count <= 0) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Cannot Upload"
                                                              message:@"First Select Images"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    } else {
        [self uploadImages];
    }
    
}

-(void)pushToPlaceOrderVC {
    
    if (self.dictionary != nil) {
        [self hideHUD];
        
//        PlaceOrderViewController *placeOrderVC = [self.storyboard instantiateViewControllerWithIdentifier:@"placeOrderVC"];
//        placeOrderVC.dataDictionary = self.dictionary;
//        [self.navigationController pushViewController:placeOrderVC animated:YES];
        
        // navigate to show place order 
    }
}





-(void)uploadImages {
    
    NSArray *array = [self selectedImagesBase64];
    
    
    
    User *saved_user = [User savedUser];
    if (saved_user != nil) {
        
        [self showHUD];
        self.hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
        
        [[NAPIManager sharedManager] uploadImages:array withHUD:self.hud success:^(BOOL success) {
            if (success) {
                NSLog(@"Success");
                
                [self hideHUD];
                [self showHideCompletedHUD];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
                
            }
            else
                NSLog(@"Failed");
            
            
        } failure:^(NSError *error) {
            NSLog(@"Error %@",error.localizedDescription);
            
            [self.hud hide:YES];
        }];
        
    }
    else {
        
        LogSignViewController *logSignVC = [self.storyboard instantiateViewControllerWithIdentifier:@"logSignNVC"];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            logSignVC.modalPresentationStyle    = UIModalPresentationFormSheet;
        }
        
        [self presentViewController:logSignVC animated:YES completion:nil];
        
    }
    
    
}



-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = self.view.tintColor;
    self.hud.labelText = @"Uploading...";
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



- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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




#pragma mark - UICollectionView 

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    return [[self positionArray] count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"selectedImagesCellIdentifier";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    NSArray *images = [self selectedImages];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    imageView.contentMode   = UIViewContentModeScaleAspectFit;
    imageView.image = (UIImage *)images[indexPath.item];

    
    UIView *background = [[UIView alloc] initWithFrame:cell.frame];
    background.backgroundColor = [UIColor whiteColor];
    background.layer.cornerRadius = 5.f;
    background.layer.masksToBounds = YES;
    [background addSubview:imageView];
    
    cell.backgroundView = background;
    
    return cell;
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


-(UIImage *)getAssetThumbnail:(PHAsset *)asset {
    PHImageManager *manager = [PHImageManager defaultManager];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    
    __block UIImage *thumbnail = [[UIImage alloc] init];
    options.synchronous = TRUE;
    
    [manager requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        thumbnail = result;
    }];
    
    return thumbnail;
}

-(NSArray *)selectedImages {
    
    NSMutableArray *selectedImages = [[NSMutableArray alloc] init];
    NSArray *positions = [self positionArray];
    
    [positions enumerateObjectsUsingBlock:^(NSNumber  *_Nonnull index, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHAsset *photo = _assets[index.intValue];
        UIImage *image = [self getAssetThumbnail:photo];
        
        
        [selectedImages addObject:image];
        
    }];
    
    return selectedImages;
}


-(NSArray *)selectedImagesBase64 {
    
    NSArray *images = [self selectedImages];
    
    NSMutableArray *base64Images = [[NSMutableArray alloc] init];
    
    [images enumerateObjectsUsingBlock:^(UIImage  *_Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        NSData *base64data = [data base64EncodedDataWithOptions:0];
        
        NSString *imageBase64String = [[NSString alloc] initWithData:base64data encoding:NSUTF8StringEncoding];
        
        [base64Images addObject:imageBase64String];
        
    }];
    
    
    return base64Images;
}
































#pragma mark - Not Needed 

-(NSData *)createBodyWithParameters:(NSDictionary *)param andFilePathKey:(NSString *)filePathKey withImageDataKey:(NSData *)imageDataKey andBoundary:(NSString *)boundary {
    NSMutableData *body = [NSMutableData data];
    NSString *filename = @"prescription";
    NSString *mimetype = @"image/jpg";
    
    if (param != nil) {
        
        [param enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            NSLog(@"%@ : %@",key,obj);
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",obj] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
        }];
        
        
    }
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", filePathKey,filename] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[NSData dataWithData:imageDataKey]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return body;
}

-(NSString *)generateBoundaryString {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    NSString *boundaryString = [NSString stringWithFormat:@"Boundary-%@",uuid];
    return boundaryString;
}

-(void)getJSONData:(NSData *)data {
    NSError *error;
    self.dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
}


-(void)uploadImageAndGetPath {
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"http://chemistplus.in/uploader.php"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = [self generateBoundaryString];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 1.0);
    
    
    request.HTTPBody = [self createBodyWithParameters:nil andFilePathKey:@"file" withImageDataKey:imageData andBoundary:boundary];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"str: %@", str);
        
        if (response) {
            expectedLength = MAX([response expectedContentLength], 1);
            currentLength = 0;
            self.hud.mode = MBProgressHUDModeDeterminate;
        }
        
        if (data) {
            currentLength += [data length];
            self.hud.progress = currentLength / (float)expectedLength;
        }
        
        
        // Push to orderVC when the URL path gets as a response.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getJSONData:data];
            [self pushToPlaceOrderVC];
        });
        
        
        if (error != nil) {
            NSLog(@"%@",error);
        }
    }];
    
    [task resume];
    [self showHUD];
}

@end
