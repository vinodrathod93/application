//
//  UploadReportsPreviewController.m
//  Neediator
//
//  Created by adverto on 31/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "UploadReportsPreviewController.h"
#import "OrderCompleteViewController.h"

@interface UploadReportsPreviewController ()
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation UploadReportsPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Review Order";
    
    
    self.patientIDTf.text=self.PatientIDString;
    self.patientCommunicationdate.text=self.PatientCommunicationDate;
    
    self.collectionview.backgroundColor = [UIColor clearColor];
    self.collectionview.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.collectionview.layer.borderWidth = 1.5f;
    self.collectionview.layer.cornerRadius = 5.f;
    self.collectionview.layer.masksToBounds = YES;
    
    
    self.uploadButton.layer.cornerRadius = 6.f;
    self.uploadButton.layer.masksToBounds = YES;
    [self.uploadButton addTarget:self action:@selector(uploadPrescriptions) forControlEvents:UIControlEventTouchUpInside];
    
    //    if (![self.shippingTypeID isEqual:@1])
    //    {
    //        self.shippingTimeHeader.hidden = YES;
    //        self.deliveryTimeLabel.hidden = YES;
    //    }
    
}

#pragma mark - Collection View Methods.
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



#pragma mark - Upload Prescription Web Upload
-(void)uploadPrescriptions {
    User *saved_user = [User savedUser];
    
    
    if (saved_user != nil) {
        
        [self showHUD];
        self.hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
        
        
        NSDictionary *data = @{
                               @"images"                         : self.base64Images,
                               @"lastcommunicationdate"          : @"01/01/2017"
                               };
        
        NSLog(@"%@",data);
        [[NAPIManager sharedManager] uploadReportsWithData:data withHUD:self.hud success:^(BOOL success, NSDictionary *responseData) {
            if (success) {
                
                NSLog(@"Success");
                
                [self hideHUD];
                [self showHideCompletedHUD];
                
                
                
                OrderCompleteViewController *orderCompleteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderCompleteVC"];
                orderCompleteVC.order_id    = responseData[@"ReportNo"];
                orderCompleteVC.message     = @"Your order Request has been successfully Submitted";
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



@end
