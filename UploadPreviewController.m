//
//  UploadPreviewController.m
//  Neediator
//
//  Created by adverto on 11/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "UploadPreviewController.h"
#import "OrderCompleteViewController.h"

@interface UploadPreviewController () <UIAlertViewDelegate>

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation UploadPreviewController
{
    UIAlertView *_uPromoAlertView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Review Order";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingNotification:) name:@"PromoCodeNotification" object:self];

    
    //  UIBarButtonItem *uPromoButton = [[UIBarButtonItem alloc] initWithTitle:@"Promo Code" style:UIBarButtonItemStylePlain target:self action:@selector(uPromoAlertView)];
    //    self.navigationItem.rightBarButtonItem = uPromoButton;
    
    self.collectionview.backgroundColor = [UIColor clearColor];
    self.collectionview.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.collectionview.layer.borderWidth = 1.5f;
    self.collectionview.layer.cornerRadius = 5.f;
    self.collectionview.layer.masksToBounds = YES;
    
    
    self.uploadButton.layer.cornerRadius = 6.f;
    self.uploadButton.layer.masksToBounds = YES;
    [self.uploadButton addTarget:self action:@selector(uploadPrescriptions) forControlEvents:UIControlEventTouchUpInside];
    
    if (![self.shippingTypeID isEqual:@1])
    {
        self.shippingTimeHeader.hidden = YES;
        self.deliveryTimeLabel.hidden = YES;
    }
    
    self.deliveryTypeLabel.text = self.shippingType;
    self.deliveryAddressLabel.text = self.shippingAddress;
    self.deliveryTimeLabel.text = self.deliveryTime;
    self.timeSlotToLabel.text=self.timeslotFrom;
    self.timeSlotFromLabel.text=self.timeslotFrom;
}

- (void)incomingNotification:(NSNotification *)notification{
    NSString *theString = [notification object];
    NSLog(@"the string %@",theString);
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = @"heelo";
    
    NSLog(@"PAsteboardString Is %@",pasteboard.string);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //    CGFloat lastViewHeight = CGRectGetHeight(((UIView *)[self.contentView.subviews lastObject]).frame);
    //    int lastViewY = CGRectGetMaxY(((UIView *)[self.contentView.subviews lastObject]).frame);
    //
    //    CGFloat height = lastViewHeight + lastViewY;
    //
    //    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), height);
}


#pragma mark - UICollectionView Methods.

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([self.selectedImages count] != 0) {
        return [self.selectedImages count];
    }
    else
        return 0;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"previewImagesCellIdentifier";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [NeediatorUtitity defaultColor];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.cornerRadius = 6.f;
    imageView.layer.masksToBounds = YES;
    
    if ([self.selectedImages count] > 0) {
        NSLog(@"Entered the loop");
        
        
        imageView.image = (UIImage *)self.selectedImages[indexPath.item];
        
        NSLog(@"Index %ld",(long)indexPath.item);
        
        
        imageView.frame = CGRectMake(0, 0, 90, 110);
        
    }
    
    [cell.contentView addSubview:imageView];
    
    return cell;
}


#pragma mark - Upload Prescription.
-(void)uploadPrescriptions {
    User *saved_user = [User savedUser];
    
    
    if (saved_user != nil) {
        
        [self showHUD];
        self.hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
        
        
        if([_shippingTypeID isEqual:@1])
        {
            NSDictionary *data = @{
                                   @"images"                :self.base64Images,
                                   @"deliveryID"            : self.shippingTypeID.stringValue,
                                   @"addressID"             : self.shippingAddressID.stringValue,
                                   @"dateTime"              : self.deliveryTime,
                                   @"timeslotfrom"          : self.timeslotFrom,
                                   @"timeslotto"            : self.timeslotTo,
                                   @"accountcode"           :self.AccountCode,
                                   @"comments"              :self.CommentTF.text,
                                   @"addresstype"           :self.shippingAddressTypeID
                                   };
            
            NSLog(@"%@",data);
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
        
        else{
            
            NSDictionary *data = @{
                                   @"images"                :self.base64Images,
                                   @"deliveryID"            : self.shippingTypeID.stringValue,
                                   @"addressID"             : @"0",
                                   @"dateTime"              : self.deliveryTime,
                                   @"timeslotfrom"          : self.timeslotFrom,
                                   @"timeslotto"            : self.timeslotTo,
                                   @"accountcode"           :self.AccountCode,
                                   @"comments"              :self.CommentTF.text,
                                   @"addresstype"           :@"0"
                                   };
            NSLog(@"%@",data);
            
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
        
    }
    else {
        
        LogSignViewController *logSignVC = [self.storyboard instantiateViewControllerWithIdentifier:@"logSignNVC"];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            logSignVC.modalPresentationStyle    = UIModalPresentationFormSheet;
        }
        [self presentViewController:logSignVC animated:YES completion:nil];
    }
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
    
    [NSThread sleepForTimeInterval:1.0];
    
    [completed_hud hide:YES];
}


#pragma mark - Alert View...
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView isEqual:_uPromoAlertView]) {
        if (buttonIndex == 0) {
            NSLog(@"Promo Applied");
            NSString *reasonString = [[alertView textFieldAtIndex:0] text];
            NSLog(@"%@",reasonString);
            
            // send the promo code.
        }
        else
            NSLog(@"Not send");
    }
}


#pragma mark - Promo Code..
- (IBAction)PromoCodeAction:(id)sender
{
//    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
//                            stringForKey:@"promocode"];
//    NSLog(@"Userdefault %@",savedValue);
    
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    self.PromoCodeTF.text = [pb string];
    
    
    
   // self.PromoCodeTF.text=savedValue;
}




//-(void)uPromoAlertView
//{
//    _uPromoAlertView = [[UIAlertView alloc]initWithTitle:@"Enter Promo Code" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
//    [_uPromoAlertView setDelegate:self];
//    [_uPromoAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
//    [_uPromoAlertView addButtonWithTitle:@"Apply"];
//    [_uPromoAlertView addButtonWithTitle:@"Dismiss"];
//    [_uPromoAlertView show];
//}
@end
