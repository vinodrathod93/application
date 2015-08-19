//
//  UploadPrescriptionViewController.m
//  HealthApp
//
//  Created by adverto on 06/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "UploadPrescriptionViewController.h"
#import "PlaceOrderViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface UploadPrescriptionViewController ()
{
    long long expectedLength;
    long long currentLength;
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
}


-(IBAction)takePhotoPressed:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


-(IBAction)selectPhotoPressed:(id)sender {
    
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
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
    
    
    if (!self.imageView.image) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Upload your prescription"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    } else if(self.imageView.image) {
        [self uploadImageAndGetPath];
    }
    
}

-(void)pushToPlaceOrderVC {
    
    if (self.dictionary != nil) {
        [self hideHUD];
        
        PlaceOrderViewController *placeOrderVC = [self.storyboard instantiateViewControllerWithIdentifier:@"placeOrderVC"];
        placeOrderVC.dataDictionary = self.dictionary;
        [self.navigationController pushViewController:placeOrderVC animated:YES];
    }
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


-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = self.view.tintColor;
}

-(void)hideHUD {
    self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    self.hud.mode = MBProgressHUDModeCustomView;
    [self.hud hide:YES afterDelay:2];
}

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

- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
