//
//  OffersPopViewController.m
//  Pods
//
//  Created by adverto on 30/03/16.
//
//

#import "OffersPopViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>


@interface OffersPopViewController ()

@end

@implementation OffersPopViewController

#pragma mark - View Did Load.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.offerContentView.layer.cornerRadius = 5.f;
    self.offerContentView.layer.masksToBounds = YES;
    //    self.closeButton.layer.cornerRadius = self.closeButton.frame.size.width/2;
    self.closeButton.layer.borderWidth  = 1.f;
    self.closeButton.layer.borderColor  = [UIColor redColor].CGColor;
    self.closeButton.layer.masksToBounds = YES;
    [self.closeButton addTarget:self action:@selector(closeTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.offerDescriptionlbl.text=_DescriptionString;
   // self.promoCodeLbl.text=self.PromoCodeString;
    self.promoCodeTF.text=self.PromoCodeString;
    
    self.termsAndConditiontxt.text=self.termsAndCondition;
    [self.offerImageView sd_setImageWithURL:[NSURL URLWithString:self.imageurlString]];
    
    self.ValidityLbl.font = [UIFont fontWithName:@"AvenirNext-Medium" size:12.f];
    
    self.ValidityLbl.text=[NSString stringWithFormat:@"This Offer Valid Till %@",_validityString];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Dismiss ViewController.
-(void)closeTapped:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- Copy Promo Code.

- (IBAction)CopyPromoCodeAction:(id)sender
{
    
    NSString *message = @"Copied...";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    int duration = 1; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
    
    NSString *abc=self.promoCodeLbl.text;
    
    [[NSUserDefaults standardUserDefaults] setObject:abc forKey:@"promocode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"abc is %@",abc);
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"promocode"];
    NSLog(@"Userdefault %@",savedValue);
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"PromoCodeNotification" object:abc];
    
}
@end
