//
//  UploadReportsVC.m
//  Neediator
//
//  Created by adverto on 31/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "UploadReportsVC.h"
#import "ImageModalViewController.h"
#import "UploadPrsCollectionViewCell.h"
#import "UploadPreviewController.h"
#import "NeediatorPhotoBrowser.h"
#import "UploadReportsPreviewController.h"

@interface UploadReportsVC ()<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>
{
    NeediatorPhotoBrowser *browser;
    UIImage *_cameraImage;
    UIImageView *_selectedImageView;
    NSMutableArray *_allThumbnails;
}

@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSMutableArray *cameraCapturedArray;
@property (nonatomic, strong) NSMutableArray *selectedImagesArray;
@property (nonatomic, strong) NSMutableArray *finalDisplayArray;

@property (nonatomic, strong) NSMutableArray *cameraThumbnails;
@property (nonatomic, strong) NSMutableArray *galleryThumbnails;

@property(nonatomic,retain)NSString *t1,*t2;


@end

@implementation UploadReportsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Send Reports";
    
    
    User *saved_user = [User savedUser];
    
    NSString *parameterString = [NSString stringWithFormat:@"isConsultingFirstTime=%@&userid=%@&storeid=%@&Sectionid=%@",@"No",saved_user.userID,[NeediatorUtitity savedDataForKey:kSAVE_STORE_ID],[NeediatorUtitity savedDataForKey:kSAVE_CAT_ID]];
    NSLog(@"Consultation Parameter is --> %@", parameterString);
    
    NSString *url = [NSString stringWithFormat:@"http://192.168.1.199/NeediatorWebservice/NeediatorWS.asmx/ConsultationDetails"];
    NSLog(@"URL is --> %@", url);
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.168.1.199/NeediatorWebservice/NeediatorWS.asmx/ConsultationDetails"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody   = [NSData dataWithBytes:[parameterString UTF8String] length:[parameterString length]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      NSLog(@"%@",response);
                                      if (error) {
                                          NSLog(@"%@",error.localizedDescription);
                                      }
                                      else
                                      {
                                          NSError *jsonError;
                                          NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              
                                              NSMutableArray *ResponsrArray=json[@"lastdetails"];
                                              NSDictionary *dict=[ResponsrArray firstObject];
                                              
                                              self.t1=[NSString stringWithFormat:@"%@",dict[@"userid"]];
                                              self.t2=dict[@"lastcommunicationdate"];
                                              
                                              self.Patient_ID_TF.text=_t1;
                                              self.Communication_Date_TF.text=_t2;
                                              
                                              
                                              
                                              NSLog(@"%@",json);
                                          });
                                      }
                                  }];
    [task resume];
    
    
    self.Patient_Detail_View.hidden=YES;
    self.Communication_Date_View.hidden=YES;
    self.uploadButton.hidden=YES;
    self.imagesCollectionView.hidden=YES;
    
    
    self.selectedImagesArray = [[NSMutableArray alloc] init];
    self.finalDisplayArray = [[NSMutableArray alloc] init];
    self.cameraCapturedArray = [[NSMutableArray alloc] init];
    self.cameraThumbnails = [[NSMutableArray alloc] init];
    self.galleryThumbnails = [[NSMutableArray alloc] init];
    _allThumbnails = [[NSMutableArray alloc] init];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissVC:)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
    
    
    [self disableHideUploadButton];
    
    
    [self loadAssets];
    
    
    
    self.imagesCollectionView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.imagesCollectionView.layer.borderWidth = 1.5f;
    self.imagesCollectionView.layer.cornerRadius = 5.f;
    self.imagesCollectionView.layer.masksToBounds = YES;
    
    [self hideCollectionView];
}






#pragma mark - Gallery..
-(IBAction)takePhotoPressed:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}
-(IBAction)selectPhotoPressed:(id)sender {
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    
    @synchronized(_assets)
    {
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
            for (ALAsset *asset in copy)
            {
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
    
    browser = [[NeediatorPhotoBrowser alloc] initWithDelegate:self];
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
    
    
    if (_selections != nil)
    {
        NSLog(@"Already Selected");
    }
    else if (browser.displaySelectionButtons) {
        _selections = [NSMutableArray new];
        for (int i = 0; i < photos.count; i++)
        {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
    
}


- (IBAction)uploadPhotoPressed:(id)sender {
    
    
    if (self.finalDisplayArray.count <= 0)
    {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Cannot Proceed"
                                                              message:@"First Select Images"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    } else
        
    {
        
        UploadReportsPreviewController *uploadPreviewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UploadReportsPreviewController"];
        
        NSArray *readyImages = [self readyImages];
        
        
        uploadPreviewVC.base64Images = [self base64Images:readyImages];
        uploadPreviewVC.selectedImages = readyImages;
        uploadPreviewVC.PatientIDString=self.Patient_ID_TF.text;
        uploadPreviewVC.PatientCommunicationDate=self.Communication_Date_TF.text;
        
        
        [self.navigationController pushViewController:uploadPreviewVC animated:YES];
        
    }
    
}



- (IBAction)closeButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
            
            [self.selectedImagesArray removeAllObjects];
            [self.galleryThumbnails removeAllObjects];
            
            [self.selectedImagesArray addObjectsFromArray:[self largeSelectedImages]];
            [self.galleryThumbnails addObjectsFromArray:[self thumbnailSelectedImages]];
            
            
            if (self.finalDisplayArray.count > 0) {
                [self.finalDisplayArray removeAllObjects];
                [_allThumbnails removeAllObjects];
            }
            
            [self.finalDisplayArray addObjectsFromArray:self.cameraCapturedArray];
            [self.finalDisplayArray addObjectsFromArray:self.selectedImagesArray];
            [self.finalDisplayArray addObject:[UIImage imageNamed:@"addPlus"]];
            
            [_allThumbnails addObjectsFromArray:self.cameraThumbnails];
            [_allThumbnails addObjectsFromArray:self.galleryThumbnails];
            [_allThumbnails addObject:[UIImage imageNamed:@"addPlus"]];
            
            [self showCollectionImages];
            
            [self enableUploadButton];
        }
    }];
}


#pragma mark - ImagePicker Delegates

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSLog(@"%@", info);
    _cameraImage = info[UIImagePickerControllerOriginalImage];
    
    [self.cameraCapturedArray addObject:_cameraImage];
    [self.cameraThumbnails addObject:[self imageWithImage:_cameraImage scaledToSize:CGSizeMake(100, 150)]];
    
    if (self.finalDisplayArray.count > 0) {
        [self.finalDisplayArray removeAllObjects];
        [_allThumbnails removeAllObjects];
    }
    
    
    
    [self.finalDisplayArray addObjectsFromArray:self.selectedImagesArray];
    [self.finalDisplayArray addObjectsFromArray:self.cameraCapturedArray];
    [self.finalDisplayArray addObject:[UIImage imageNamed:@"addPlus"]];
    
    [_allThumbnails addObjectsFromArray:self.galleryThumbnails];
    [_allThumbnails addObjectsFromArray:self.cameraThumbnails];
    [_allThumbnails addObject:[UIImage imageNamed:@"addPlus"]];
    
    // Show Image in collection view
    [self showCollectionImages];
    
    
    //enable upload button
    [self enableUploadButton];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}





#pragma mark - Helper Methods


-(void)showCollectionImages {
    
    [self.view bringSubviewToFront:self.imagesCollectionView];
    [self.imagesCollectionView reloadData];
    [self hideNewUploadView];
    self.imagesCollectionView.hidden = NO;
    self.Patient_Detail_View.hidden=NO;
    self.Communication_Date_View.hidden=NO;
    self.uploadButton.hidden=NO;
}


-(void)hideCollectionView
{
    self.imagesCollectionView.hidden = YES;
}



-(void)hideNewUploadView
{
    self.selectPhotoButton.hidden = YES;
    self.takePhotoButton.hidden = YES;
    self.selectPhotoLabel.hidden = YES;
}

-(void)showNewUploadView {
    self.selectPhotoButton.hidden = NO;
    self.takePhotoButton.hidden = NO;
    self.selectPhotoLabel.hidden = NO;
}

-(void)enableUploadButton {
    [self.uploadButton setTintColor:self.view.tintColor];
    [self.uploadButton setUserInteractionEnabled:YES];
    self.uploadButton.hidden = NO;
    self.uploadButton.clipsToBounds = YES;
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

-(void)removeImageSelectionAtIndex:(int)itemIndex {
    
    
    NSArray *positions = [self positionArray];
    
    if (positions.count == 0) {
        ;
    }
    else {
        NSNumber *index = positions[itemIndex];
        NSLog(@"Index, %d", index.intValue);
        
        
        [_selections replaceObjectAtIndex:index.intValue withObject:@0];
        
        NSLog(@"%@", _selections);
    }
}


-(NSArray *)commonSelectedImagesWithSize:(CGSize)size {
    NSMutableArray *selectedImagesArray = [[NSMutableArray alloc] init];
    NSArray *positions = [self positionArray];
    
    
    [positions enumerateObjectsUsingBlock:^(NSNumber  *_Nonnull index, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHAsset *photo = _assets[index.intValue];
        UIImage *image = [self getAssetThumbnail:photo withTargetSize:size];
        
        
        [selectedImagesArray addObject:image];
        
    }];
    
    
    
    return selectedImagesArray;
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


-(NSArray *)thumbnailSelectedImages {
    
    NSMutableArray *thumbnails = [NSMutableArray array];
    
    thumbnails = (NSMutableArray *)[self commonSelectedImagesWithSize:CGSizeMake(100, 150)];
    
    
    return thumbnails;
}


-(NSArray *)largeSelectedImages {
    
    return [self commonSelectedImagesWithSize:self.view.frame.size];
}


-(NSArray *)readyImages {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (_allThumbnails.count > 0) {
        
        
        array = _allThumbnails;
        
        //sb      [array removeLastObject];
        
        
    }
    
    return array;
}


-(NSArray *)base64Images:(NSArray *)images {
    
    
    NSMutableArray *base64Images = [[NSMutableArray alloc] init];
    
    [images enumerateObjectsUsingBlock:^(UIImage  *_Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx == images.count-1)
        {
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




#pragma mark - UICollectionView Methods.

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    
    NSArray *thumbnailImages = self.finalDisplayArray;
    
    if (thumbnailImages.count != 0) {
        return [thumbnailImages count];
    }
    else
        return 0;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"selectedImagesCellIdentifier";
    
    UploadPrsCollectionViewCell *uploadPrsCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [uploadPrsCell.deleteButton addTarget:self action:@selector(removeImage:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    if ([_allThumbnails count] >= 1) {
        NSLog(@"Entered the loop");
        
        
        uploadPrsCell.pImageView.image = (UIImage *)_allThumbnails[indexPath.item];
        
        
        if (indexPath.item == [_allThumbnails count] -1) {
            NSLog(@"Removed Delete Button");
            
            uploadPrsCell.pImageView.frame = CGRectMake(uploadPrsCell.frame.size.width/2 - (25/2), uploadPrsCell.frame.size.height/2 - (25/2), 25, 25);
            [uploadPrsCell hideDeleteButton];
        }
        else
        {
            uploadPrsCell.pImageView.frame = CGRectMake(0, 0, 90, 110);
            [uploadPrsCell showDeleteButton];
        }
        
    }
    
    return uploadPrsCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.item == [self.finalDisplayArray indexOfObject:self.finalDisplayArray.lastObject]) {
        // New Image
        
        
        UploadPrsCollectionViewCell *cell = (UploadPrsCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        [self showNewActionSheet:cell];
        
    }
    else {
        
        NSArray *images = self.finalDisplayArray;
        
        ImageModalViewController *imageModalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"imageModalVC"];
        imageModalVC.image  = images[indexPath.item];
        
        imageModalVC.transitioningDelegate = self;
        imageModalVC.modalPresentationStyle = UIModalPresentationCustom;
        
        [self presentViewController:imageModalVC animated:YES completion:nil];
    }
    
}




#pragma mark - Remove Image.
-(void)removeImage:(UIButton *)sender {
    
    UploadPrsCollectionViewCell *cell = (UploadPrsCollectionViewCell *)[[[sender superview] superview] superview];
    
    UIImage *tappedImage = [cell.pImageView image];
    
    
    if ([self.cameraThumbnails containsObject:tappedImage]) {
        
        int index = [self.cameraThumbnails indexOfObject:tappedImage];
        [self.cameraThumbnails removeObject:tappedImage];
        
        
        [self.cameraCapturedArray removeObjectAtIndex:index];
        
    }
    else if ([self.galleryThumbnails containsObject:tappedImage]) {
        
        int index = [self.galleryThumbnails indexOfObject:tappedImage];
        [self removeImageSelectionAtIndex:index];
    }
    
    
    self.selectedImagesArray = (NSMutableArray *)[self largeSelectedImages];
    self.galleryThumbnails = (NSMutableArray *)[self thumbnailSelectedImages];
    
    if (self.finalDisplayArray.count > 0)
    {
        [self.finalDisplayArray removeAllObjects];
        [_allThumbnails removeAllObjects];
    }
    
    [self.finalDisplayArray addObjectsFromArray:self.selectedImagesArray];
    [self.finalDisplayArray addObjectsFromArray:self.cameraCapturedArray];
    [self.finalDisplayArray addObject:[UIImage imageNamed:@"addPlus"]];
    
    [_allThumbnails addObjectsFromArray:self.galleryThumbnails];
    [_allThumbnails addObjectsFromArray:self.cameraThumbnails];
    [_allThumbnails addObject:[UIImage imageNamed:@"addPlus"]];
    
    [self.imagesCollectionView reloadData];
    
}






-(void)showNewActionSheet:(UploadPrsCollectionViewCell *)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Send Prescription" message:@"Select Mode to Add Images" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhotoPressed:nil];
    }];
    
    UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectPhotoPressed:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    
    [controller addAction:cameraAction];
    [controller addAction:galleryAction];
    [controller addAction:cancelAction];
    
    controller.popoverPresentationController.sourceView = sender;
    controller.popoverPresentationController.sourceRect = sender.bounds;
    
    [self presentViewController:controller animated:YES completion:nil];
}


#pragma mark - UIViewControllerTransitioningDelegate

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}


#pragma mark - UIViewControllerAnimatedTransitioning

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    
    UIView *container       = transitionContext.containerView;
    
    UIViewController *fromVC    = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ImageModalViewController *toVC      = (ImageModalViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView            = fromVC.view;
    UIView *toView              = toVC.view;
    
    
    CGRect beginFrame;
    CGRect endFrame             = toView.frame;
    
    
    beginFrame = [container convertRect:_selectedImageView.frame fromView:_selectedImageView.superview];
    
    NSLog(@"%@",toView.subviews);
    
    UIView *move                = nil;
    
    if (toVC.isBeingPresented) {
        toView.frame            = endFrame;
        move                    = [toView snapshotViewAfterScreenUpdates:YES];
        move.frame              = beginFrame;
        
        
        _selectedImageView.hidden = YES;
        
        
    } else {
        
        ImageModalViewController *modalVC       = (ImageModalViewController *)fromVC;
        modalVC.imageContentView.backgroundColor = [UIColor clearColor];
        
        move        = [fromView snapshotViewAfterScreenUpdates:NO];
        move.frame  = fromView.frame;
        
        [fromView removeFromSuperview];
        
    }
    
    [container addSubview:move];
    
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:500 initialSpringVelocity:15 options:0 animations:^{
        move.frame = toVC.isBeingPresented ? endFrame : beginFrame;
        
    } completion:^(BOOL finished) {
        if (toVC.isBeingPresented) {
            
            [move removeFromSuperview];
            toView.frame    = endFrame;
            [container addSubview:toView];
            
        } else {
            
            
            _selectedImageView.hidden = NO;
            
        }
        
        [transitionContext completeTransition:YES];
    }];
    
}

#pragma mark - HUD

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

-(void)dismissVC:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)disableHideUploadButton
{
    [self.uploadButton setTintColor:[UIColor lightGrayColor]];
    [self.uploadButton setUserInteractionEnabled:NO];
    self.uploadButton.hidden = YES;
}




@end
