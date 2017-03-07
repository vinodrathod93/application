//
//  UploadPrescriptionViewController.m
//  HealthApp
//
//  Created by adverto on 06/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "UploadPrescriptionViewController.h"
#import "OrderCompleteViewController.h"
#import "ImageModalViewController.h"
#import "UploadPrsCollectionViewCell.h"
#import "UploadPreviewController.h"
#import "NeediatorPhotoBrowser.h"



@interface UploadPrescriptionViewController ()<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

{
    long long expectedLength;
    long long currentLength;
    NeediatorPhotoBrowser *browser;
    UIImage *_cameraImage;
    UIDatePicker *_dateTimePicker;
    
    NSNumber *_selectedDeliveryID;
    NSNumber *_selectedAddressTypeID;
    NSNumber *_selectedAddressID;
    NSString *_shippingAddress;
    
    UIImageView *_selectedImageView;
    NSMutableArray *_allThumbnails;
    
    CGFloat previousTopConstant, previousBottomConstant;
    CGFloat previousAddressLabelHeight, previousAddressButtonHeight;
}

@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSMutableArray *cameraCapturedArray;
@property (nonatomic, strong) NSMutableArray *selectedImagesArray;
@property (nonatomic, strong) NSMutableArray *finalDisplayArray;

@property (nonatomic, strong) NSMutableArray *cameraThumbnails;
@property (nonatomic, strong) NSMutableArray *galleryThumbnails;

@property (nonatomic) CGFloat previousTopConstant, previousBottomConstant, previousAddressLabelHeight, previousAddressButtonHeight;
@end

@implementation UploadPrescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Send Prescription";
    self.selectedImagesArray = [[NSMutableArray alloc] init];
    self.finalDisplayArray = [[NSMutableArray alloc] init];
    self.cameraCapturedArray = [[NSMutableArray alloc] init];
    self.cameraThumbnails = [[NSMutableArray alloc] init];
    self.galleryThumbnails = [[NSMutableArray alloc] init];
    _allThumbnails = [[NSMutableArray alloc] init];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissVC:)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    self.View1.hidden=YES;
    self.view2.hidden=YES;
    self.view3.hidden=YES;
    self.AcountCodeTF.hidden=YES;
    self.AccountCodelabel.hidden=YES;
    
    [self.View1 setBackgroundColor:[UIColor clearColor]];
    [self.view2 setBackgroundColor:[UIColor clearColor]];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
    
    
    [self disableHideUploadButton];
    
    self.closeButton.layer.cornerRadius = self.closeButton.frame.size.height/2;
    self.closeButton.layer.masksToBounds = YES;
    
    [self loadAssets];
    
    
    
    self.imagesCollectionView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.imagesCollectionView.layer.borderWidth = 1.5f;
    self.imagesCollectionView.layer.cornerRadius = 5.f;
    self.imagesCollectionView.layer.masksToBounds = YES;
    
    
    
    [self hideCollectionView];
    
    
    [self.deliveryTypeButton addTarget:self action:@selector(showShippingTypeSheet:) forControlEvents:UIControlEventTouchUpInside];
    [self.addressTypeButton addTarget:self action:@selector(showAddressTypeSheet:) forControlEvents:UIControlEventTouchUpInside];
    [self.addNewAddressButton addTarget:self action:@selector(showAddresses:) forControlEvents:UIControlEventTouchUpInside];
    
    [self decorateButtons];
    [self showDateTimePicker];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.View1 setBackgroundColor:[UIColor clearColor]];
    [self.view2 setBackgroundColor:[UIColor clearColor]];
    //    self.View1.hidden=YES;
    //    self.view2.hidden=YES;
    //    self.AcountCodeTF.hidden=YES;
    //    self.AccountCodelabel.hidden=YES;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Send-Prescription Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


-(void)disableHideUploadButton
{
    [self.uploadButton setTintColor:[UIColor lightGrayColor]];
    [self.uploadButton setUserInteractionEnabled:NO];
    self.uploadButton.hidden = YES;
}


-(void)dismissVC:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark - IBActions

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
        for (int i = 0; i < photos.count; i++) {
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
        
        UploadPreviewController *uploadPreviewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"uploadPreviewVC"];
        
        NSArray *readyImages = [self readyImages];
        
        uploadPreviewVC.base64Images = [self base64Images:readyImages];
        uploadPreviewVC.selectedImages = readyImages;
        uploadPreviewVC.shippingTypeID = _selectedDeliveryID;
        uploadPreviewVC.shippingAddressID = _selectedAddressID;
        uploadPreviewVC.shippingAddressTypeID=_selectedAddressTypeID;
        
        uploadPreviewVC.deliveryTime = self.dateTimeField.text;
        
        
        
        NSArray *names = [self deliveryTypes];
        uploadPreviewVC.shippingType = names[_selectedDeliveryID.integerValue-1];
        uploadPreviewVC.shippingAddress = _shippingAddress;
        uploadPreviewVC.timeslotFrom=self.timeSlotFromTF.text;
        uploadPreviewVC.timeslotTo=self.timeSlotToTF.text;
        uploadPreviewVC.AccountCode=self.accountCodeTF.text;
        
        
        
        [self.navigationController pushViewController:uploadPreviewVC animated:YES];
        
    }
    
}


- (IBAction)closeButton:(id)sender {
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
-(void)showShippingTypeSheet:(UIButton *)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Select Order Type" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *names = [self deliveryTypes];
    NSArray *ids   = [self deliveryIDs];
    
    [names enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [sender setTitle:action.title forState:UIControlStateNormal];
            _selectedDeliveryID = ids[idx];
            
            
            
            if ([_selectedDeliveryID isEqual:@1])
            {
                self.view2.hidden=NO;
                self.View1.hidden=NO;
                self.view3.hidden=YES;
                
                
                self.AccountCodelabel.hidden=NO;
                self.AcountCodeTF.hidden=NO;
                self.addressButton.hidden=NO;
            }
            else
            {
                
                self.View1.hidden=NO;
                self.view2.hidden=YES;
                self.view3.hidden=NO;
            }
        }];
        
        [controller addAction:action];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:cancel];
    
    controller.popoverPresentationController.sourceView = sender;
    controller.popoverPresentationController.sourceRect = sender.bounds;
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)showAddressTypeSheet:(UIButton *)sender
{
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Select Address Type" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *namess = [self addressTypes];
    NSArray *idss   = [self addressIDs];
    
    [namess enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [sender setTitle:action.title forState:UIControlStateNormal];
            _selectedAddressTypeID = idss[idx];
            
        }];
        
        [controller addAction:action];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:cancel];
    
    controller.popoverPresentationController.sourceView = sender;
    controller.popoverPresentationController.sourceRect = sender.bounds;
    [self presentViewController:controller animated:YES completion:nil];
}




-(NSArray *)deliveryTypes
{
    
    NSArray *delivery_types = [NeediatorUtitity savedDataForKey:kSAVE_DELIVERY_TYPES];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    [delivery_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [names addObject:[type valueForKey:@"type"]];
    }];
    
    return names;
}

-(NSArray *)deliveryIDs {
    NSArray *delivery_types = [NeediatorUtitity savedDataForKey:kSAVE_DELIVERY_TYPES];
    
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    
    [delivery_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [ids addObject:[type valueForKey:@"id"]];
    }];
    
    return ids;
}

-(NSArray *)addressTypes
{
    
    NSArray *address_types = [NeediatorUtitity savedDataForKey:kSAVE_Address_Types];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    [address_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [names addObject:[type valueForKey:@"AddressType"]];
    }];
    return names;
}


-(NSArray *)addressIDs {
    NSArray *address_types = [NeediatorUtitity savedDataForKey:kSAVE_Address_Types];
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    
    [address_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [ids addObject:[type valueForKey:@"id"]];
    }];
    
    return ids;
}







-(void)showDateTimePicker
{
    _dateTimePicker = [[UIDatePicker alloc]initWithFrame:CGRectZero];
    _dateTimePicker.datePickerMode = UIDatePickerModeDate;
    
    NSDate *currentDate = [NSDate date];
    NSDate *nextDate = [currentDate dateByAddingTimeInterval:60*60*24*7];
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    
    
    
    NSLog(@"Current Date = %@", [dateFormat stringFromDate:currentDate]);
    NSLog(@"Next Date = %@", [dateFormat stringFromDate:nextDate]);
    
    [_dateTimePicker setMinimumDate:currentDate];
    [_dateTimePicker setMaximumDate:nextDate];
    
    self.dateTimeField.inputView = _dateTimePicker;
    self.dateTimeField.inputAccessoryView = [self pickupDateTimePickerToolBar];
    
    [_dateTimePicker addTarget:self action:@selector(setSelectedDateTime:) forControlEvents:UIControlEventValueChanged];
    
    
}


-(UIToolbar *)pickupDateTimePickerToolBar {
    UIToolbar *toolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,44)];
    toolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 150, 21.f)];
    message.font = [NeediatorUtitity mediumFontWithSize:15.f];
    message.textAlignment = NSTextAlignmentCenter;
    message.backgroundColor = [UIColor clearColor];
    message.textColor = [UIColor darkGrayColor];
    message.text = @"Select Date and Time";
    
    
    
    UIBarButtonItem *flexibleSpaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *titleButton = [[UIBarButtonItem alloc] initWithCustomView:message];
    
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissDateTimePickerView)];
    
    [toolbar setItems:@[flexibleSpaceLeft, titleButton, flexibleSpaceRight, doneButton] animated:YES];
    
    return toolbar;
}


-(void)dismissDateTimePickerView {
    
    [self.dateTimeField resignFirstResponder];
    
    
}




-(void)setSelectedDateTime:(UIDatePicker *)picker {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    
    self.dateTimeField.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:picker.date]];
    
    
}

-(void)dismissPicker:(UITapGestureRecognizer *)recognizer {
    
    [self.dateTimeField resignFirstResponder];
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


-(void)showCollectionImages {
    
    [self.view bringSubviewToFront:self.imagesCollectionView];
    [self.imagesCollectionView reloadData];
    
    [self hideNewUploadView];
    
    self.imagesCollectionView.hidden = NO;
    self.deliveryTypeLabel.hidden = NO;
    self.deliveryTypeButton.hidden = NO;
    self.addressLabel.hidden = NO;
    self.addressButton.hidden = NO;
    
    self.dataTimeLabel.hidden = NO;
    self.dateTimeField.hidden = NO;
    
    
    self.View1.hidden=YES;
    self.view2.hidden=YES;
    self.AcountCodeTF.hidden=YES;
    self.AccountCodelabel.hidden=YES;
}


-(void)hideCollectionView {
    self.imagesCollectionView.hidden = YES;
    
    self.deliveryTypeLabel.hidden = YES;
    self.deliveryTypeButton.hidden = YES;
    self.addressLabel.hidden = YES;
    self.addressButton.hidden = NO;
    
    self.dataTimeLabel.hidden = YES;
    self.dateTimeField.hidden = YES;
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

-(void)decorateButtons {
    
    //   [self.deliveryTypeButton setTitle:@"" forState:UIControlStateNormal];
    self.deliveryTypeButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.deliveryTypeButton.layer.borderWidth = 1.f;
    self.deliveryTypeButton.layer.masksToBounds = YES;
    
    //   [self.addressButton setTitle:@"" forState:UIControlStateNormal];
    self.addressButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.addressButton.layer.borderWidth = 1.f;
    self.addressButton.layer.masksToBounds = YES;
    
    //   [self.addressTypeButton setTitle:@"" forState:UIControlStateNormal];
    self.addressTypeButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.addressTypeButton.layer.borderWidth = 1.f;
    self.addressTypeButton.layer.masksToBounds = YES;
    
    //    [self.addNewAddressButton setTitle:@"" forState:UIControlStateNormal];
    self.addNewAddressButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.addNewAddressButton.layer.borderWidth = 1.f;
    self.addNewAddressButton.layer.masksToBounds = YES;
    
    self.dateTimeField.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.dateTimeField.layer.borderWidth = 1.f;
    self.dateTimeField.layer.masksToBounds = YES;
    
    self.timeSlotToTF.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.timeSlotToTF.layer.borderWidth = 1.f;
    self.timeSlotToTF.layer.masksToBounds = YES;
    
    self.timeSlotFromTF.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.timeSlotFromTF.layer.borderWidth = 1.f;
    self.timeSlotFromTF.layer.masksToBounds = YES;
    
    self.accountCodeTF.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.accountCodeTF.layer.borderWidth = 1.f;
    self.accountCodeTF.layer.masksToBounds = YES;
    
    
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
        
       [array removeLastObject];
        
        
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



-(void)showAddresses:(UIButton *)button {
    
    User *user = [User savedUser];
    if (user)
    {
        
        AddressesViewController *addressesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressesVC"];
        addressesVC.isGettingOrder = YES;
        addressesVC.addressesArray = user.addresses;
        addressesVC.title = @"Addresses";
        addressesVC.delegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addressesVC];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    else
        [NeediatorUtitity showLoginOnController:self isPlacingOrder:NO];
    
}





#pragma mark - Address Delegate

-(void)deliverableAddressDidSelect:(NSDictionary *)address {
    
    _selectedAddressID = address[@"id"];
    
    NSString *address1 = [[address valueForKey:@"address"] capitalizedString];
    
    if (![address1 isEqual:[NSNull null]])
        address1       = [address1 capitalizedString];
    else
        address1       = @"";
    
    NSString *zipcode  = [address valueForKey:@"pincode"];
    
    NSString *complete_address = [NSString stringWithFormat:@"%@, - %@",address1,zipcode];
    
    _shippingAddress = complete_address;
    
    
    [self.addressButton setTitle:complete_address forState:UIControlStateNormal];
    
}



#pragma mark - Network


-(NSString *)validateInputs {
    
    NSString *errorMessage;
    
    if (_selectedAddressID == nil) {
        errorMessage = @"Please Select an Delivery Address";
    }
    else if (_dateTimeField.text == nil) {
        errorMessage = @"Please select an Delivery Date & Time";
    }
    
    return errorMessage;
}



/*
 -(void)sendImagesToUpload {

 NSString *error = [self validateInputs];
 
 if (error == nil) {
 [self uploadImages];
 }
 else
 [NeediatorUtitity alertWithTitle:@"Error" andMessage:error onController:self];
 }
 
 
 -(void)uploadImages {
 
 NSArray *array = [self selectedImagesBase64];
 User *saved_user = [User savedUser];
 
 
 if (saved_user != nil) {
 
 [self showHUD];
 self.hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
 
 
 NSDictionary *data = @{
 @"images": array,
 @"deliveryID": _selectedDeliveryID,
 @"addressID" : _selectedAddressID,
 @"dateTime"  : self.dateTimeField.text
 };
 
 [[NAPIManager sharedManager] uploadImagesWithData:data withHUD:self.hud success:^(BOOL success, NSDictionary *responseData) {
 if (success) {
 
 NSLog(@"Success");
 
 [self hideHUD];
 [self showHideCompletedHUD];
 
 
 NSDictionary *order = responseData[@"details"][0];
 
 
 OrderCompleteViewController *orderCompleteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderCompleteVC"];
 orderCompleteVC.order_id    = order[@"OrderNo"];
 orderCompleteVC.message     = [NSString stringWithFormat:@"Your Prescription has been successfully send to %@", [order[@"storename"] capitalizedString]];
 orderCompleteVC.additonalInfo = [NSString stringWithFormat:@"Payment Type is %@\n Delivery Date is %@", order[@"PaymentType"], order[@"preferred_time"]];
 [self.navigationController pushViewController:orderCompleteVC animated:YES];
 
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
 */

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
    
    [self.imagesCollectionView reloadData];
    
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

/*
 -(void)collectionViewTapGestureSelectAtIndex:(NSIndexPath *)indexPath {
 
 
 UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
 
 if (indexPath.item == [[self selectedImages] count]) {
 
 
 UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Capture" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
 [self takePhotoPressed:nil];
 }];
 
 UIAlertAction *library = [UIAlertAction actionWithTitle:@"Select from Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
 [self selectPhotoPressed:nil];
 }];
 
 UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
 [controller dismissViewControllerAnimated:YES completion:nil];
 }];
 
 [controller addAction:camera];
 [controller addAction:library];
 [controller addAction:cancel];
 
 
 }
 else {
 
 UICollectionViewCell *cell = [self.imagesCollectionView cellForItemAtIndexPath:indexPath];
 
 for (id item in cell.subviews) {
 if ([item isKindOfClass:[UIImageView class]]) {
 _selectedImageView = (UIImageView *)item;
 }
 }
 
 UIAlertAction *viewImage = [UIAlertAction actionWithTitle:@"View Image" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
 // View Image
 
 
 NSArray *images = [self selectedImages];
 
 ImageModalViewController *imageModalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"imageModalVC"];
 imageModalVC.image  = images[indexPath.item];
 
 imageModalVC.transitioningDelegate = self;
 imageModalVC.modalPresentationStyle = UIModalPresentationCustom;
 
 [self presentViewController:imageModalVC animated:YES completion:nil];
 
 }];
 
 UIAlertAction *deleteImage = [UIAlertAction actionWithTitle:@"Delete Image" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
 // Remvoe from selected Image
 
 [self removeImageAtIndex:indexPath];
 [self.imagesCollectionView reloadData];
 
 
 }];
 
 UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
 [controller dismissViewControllerAnimated:YES completion:nil];
 }];
 
 [controller addAction:viewImage];
 [controller addAction:deleteImage];
 [controller addAction:cancel];
 }
 
 [self presentViewController:controller animated:YES completion:nil];
 }
 */





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


#pragma mark - Not Needed

/*
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
 
 */


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //
    //    CGFloat lastViewHeight = CGRectGetHeight(((UIView *)[self.contentView.subviews lastObject]).frame);
    //    int lastViewY = CGRectGetMaxY(((UIView *)[self.contentView.subviews lastObject]).frame);
    //
    //    CGFloat height = lastViewHeight + lastViewY;
    //
    //    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), height);
    //
    //    NSLog(@"%@", NSStringFromCGRect(self.contentView.frame));
    //    NSLog(@"Scrollview %@", NSStringFromCGRect(self.scrollView.frame));
    //
    //    NSLog(@"%@", self.uploadButton.superview);
    //    NSLog(@"%@", NSStringFromCGRect(self.uploadButton.frame));
}

@end
