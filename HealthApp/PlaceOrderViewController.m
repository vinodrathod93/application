//
//  PlaceOrderViewController.m
//  Chemist Plus
//
//  Created by adverto on 07/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "PlaceOrderViewController.h"
#import "OrderConfirmationViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface PlaceOrderViewController ()

@property (nonatomic, strong) NSMutableArray *citiesArray;
@property (nonatomic, strong) NSMutableArray *citiesIDArray;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) NSString *selectedCityID;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation PlaceOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pincode.delegate = self;
    
    self.citiesArray = [NSMutableArray array];
    self.citiesIDArray = [NSMutableArray array];
    
    NSArray *array = [self.dataDictionary valueForKey:@"cities"];
    NSLog(@"%@",array);
    
    NSArray *allCities = [array valueForKey:@"city_name"];
    
    NSArray *allCityID = [array valueForKey:@"city_id"];
    for (NSString *city in allCities) {
        [self.citiesArray addObject:city];
    }
    
    for (NSString *cityID in allCityID) {
        [self.citiesIDArray addObject:cityID];
    }
    
    self.imagePath = [self.dataDictionary valueForKey:@"url"];
    // Do any additional setup after loading the view.
}

- (IBAction)placeOrderPressed:(id)sender {
    
    BOOL flag = [self isValidPinCode:self.pincode.text];
    NSLog(flag ? @"Valid": @"Not Valid");
    
    NSString *postString = [NSString stringWithFormat:@"name=%@&phone=%@&image_url=%@&pincode=%@&city_id=%@&address=%@",self.nameTextField.text, self.mobileTextField.text, self.imagePath, self.pincode.text, self.selectedCityID, self.address.text];
    NSURL *url = [NSURL URLWithString:@"http://chemistplus.in/submit_prescription.php"];
    NSData *data = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"Order output %@",dataString);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self pushToOrderConfirmationPage:dataString];
        });
        
    }];
    
    [task resume];
    [self showHUD];
}

-(void)pushToOrderConfirmationPage:(NSString *)dataString {
    [self showCustomHUD];
    [self hideHUD];
    
    OrderConfirmationViewController *orderConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderConfirmationVC"];
    orderConfirmationVC.orderIDString = dataString;
    [self.navigationController pushViewController:orderConfirmationVC animated:YES];
}


-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = self.view.tintColor;
}

-(void)showCustomHUD {
    self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    self.hud.mode = MBProgressHUDModeCustomView;
}

-(void)hideHUD {
    [self.hud hide:YES afterDelay:2];
}

- (IBAction)cityPressed:(id)sender {
    NSLog(@"city presed");
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    [actionSheet setTitle:@"Select City"];
    [actionSheet setDelegate:self];
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:@"Cancel"]];
    
    
    for (NSString *cityString in self.citiesArray) {
        NSLog(@"%@",cityString);
        [actionSheet addButtonWithTitle:cityString];
    }
    
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex) {
        NSLog(@"%ld",(long)buttonIndex);
        self.city.text = [self.citiesArray objectAtIndex:buttonIndex-1];
        self.selectedCityID = [self.citiesIDArray objectAtIndex:buttonIndex-1];
        
    }
}

-(BOOL)isValidPinCode:(NSString*)pincode    {
    NSString *pinRegex = @"^[0-9]{6}$";
    NSPredicate *pinTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pinRegex];
    
    BOOL pinValidates = [pinTest evaluateWithObject:pincode];
    return pinValidates;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    int limit = 5;
    return !([textField.text length]>limit && [string length] > range.length);
}
@end
