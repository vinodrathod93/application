//
//  MoreViewController.m
//  Neediator
//
//  Created by adverto on 14/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "MoreViewController.h"
#import "WebViewController.h"
#import "CallBackViewController.h"
#import <MessageUI/MessageUI.h>


enum SECTIONS {
    SharingSection = 0,
    PolicySection,
    ContactUs,
    AboutUs
};

@interface MoreViewController ()<MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *moreData;
@property (nonatomic, strong) NSArray *moreDataIcons;
@end


@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _moreData = [[NSArray alloc] initWithObjects:@"Rate us", @"Share us", @"Privacy Policy", @"About us", nil];
    
    _moreData   = @[
                    @[@"Rate us", @"Share us"],
                    @[ @"Privacy Policy", @"Return Policy",@"Terms of Use"],
                    @"Contact us",
                    @"About us"
                    ];
    
    _moreDataIcons = @[
                       @[@"rate", @"share"],
                       @[ @"privacy",@"return_policy", @"terms_condition"],
                       @"contact_us",
                       @"about_us"
                       ];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"More Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _moreData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_moreData[section] isKindOfClass:[NSArray class]]) {
        NSArray *array = _moreData[section];
        
        return array.count;
    }
    else
        return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCellIdentifier" forIndexPath:indexPath];
    
    if ([_moreData[indexPath.section] isKindOfClass:[NSArray class]]) {
        
        NSArray *array = _moreData[indexPath.section];
        NSArray *icons = _moreDataIcons[indexPath.section];
        
        cell.textLabel.text = array[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", icons[indexPath.row]]];
    }
    else {
        cell.textLabel.text = _moreData[indexPath.section];
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", _moreDataIcons[indexPath.section]]];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([_moreData indexOfObject:_moreData.lastObject] == section) {
        return 120.f;
    }
    else
        return 0.f;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if ([_moreData indexOfObject:_moreData.lastObject] == section) {
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 80.f)];
        
        UIImageView *appIcon    = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - 25, 20, 50, 50)];
        appIcon.image           = [UIImage imageNamed:@"icon"];
        
        
        [footerView addSubview:appIcon];
        
        UILabel *appVersion = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, CGRectGetWidth(self.view.frame), 15)];
        appVersion.textAlignment = NSTextAlignmentCenter;
        appVersion.textColor     = [UIColor darkGrayColor];
        appVersion.font          = [UIFont fontWithName:@"AvenirNext-Regular" size:15.f];
        appVersion.text     = @"Version 1.0 - Beta";
        
        [footerView addSubview:appVersion];
        
        return footerView;
        
    }
    else
        return nil;
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == SharingSection) {
        
        if (indexPath.row == 0) {
            // Rate us
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: kAPP_URL_STRING]];
            
        }
        else if (indexPath.row == 1) {
            // Share us
            
            UITableViewCell *selected_cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            [self shareUsFromCell:selected_cell];
            
            
        }
        
    }
    else if (indexPath.section == ContactUs) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self contactUsOptions:cell];
        
    }
    else if (indexPath.section == PolicySection) {
        
        if (indexPath.row == 0) {
            WebViewController *privacyWebViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewVC"];
            privacyWebViewVC.urlString = [NSString stringWithFormat:@"http://neediator.in/privacy_policy.html"];
            privacyWebViewVC.hidesBottomBarWhenPushed = YES;
            privacyWebViewVC.title = @"Privacy Policy";
            
            [self.navigationController pushViewController:privacyWebViewVC animated:YES];
            
        }
        else if (indexPath.row == 1) {
            WebViewController *returnPolicyWebViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewVC"];
#warning change the url to return policy
            returnPolicyWebViewVC.urlString = [NSString stringWithFormat:@"http://neediator.in/return_policy.html"];
            returnPolicyWebViewVC.hidesBottomBarWhenPushed = YES;
            returnPolicyWebViewVC.title = @"Return Policy";
            
            [self.navigationController pushViewController:returnPolicyWebViewVC animated:YES];
        }
        else if (indexPath.row == 2) {
            WebViewController *termsConditionWebViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewVC"];
            termsConditionWebViewVC.urlString = [NSString stringWithFormat:@"http://neediator.in/terms_of_usage.html"];
            termsConditionWebViewVC.hidesBottomBarWhenPushed = YES;
            termsConditionWebViewVC.title = @"Terms & Conditions";
            
            [self.navigationController pushViewController:termsConditionWebViewVC animated:YES];
            
        }
        
        
    }
    else if (indexPath.section == AboutUs) {
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"about_us" ofType:@"txt"];
        NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
        
        WebViewController *aboutUsWebViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewVC"];
        aboutUsWebViewVC.hidesBottomBarWhenPushed = YES;
        aboutUsWebViewVC.title = @"About us";
        
        aboutUsWebViewVC.htmlString = htmlString;
        
        [self.navigationController pushViewController:aboutUsWebViewVC animated:YES];
    }
}


-(void)prepareMail {
    // Email Subject
    NSString *emailTitle = @"Assistance Required";
    // Email Content
    NSString *messageBody = @"Hi Neediator Team, I'm inquiring about: \n"; // Change the message body to HTML
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"care@neediator.in"];
    
    MFMailComposeViewController *mailComposerVC = [[MFMailComposeViewController alloc] init];
    
    if ([MFMailComposeViewController canSendMail]) {
        mailComposerVC.mailComposeDelegate = self;
        [mailComposerVC setSubject:emailTitle];
        [mailComposerVC setMessageBody:messageBody isHTML:YES];
        [mailComposerVC setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mailComposerVC animated:YES completion:NULL];
    }
    
}


-(void)callbackVC {
    CallBackViewController *callbackVC = [self.storyboard instantiateViewControllerWithIdentifier:@"callbackVC"];
    [self.navigationController pushViewController:callbackVC animated:YES];
}

-(void)contactUsOptions:(UITableViewCell *)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Select Contact Option" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *callBackAction = [UIAlertAction actionWithTitle:@"Call Me Back" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self callbackVC];
    }];
    
    UIAlertAction *mail = [UIAlertAction actionWithTitle:@"Give Feedback" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self prepareMail];
    }];
    
    UIAlertAction *meetus = [UIAlertAction actionWithTitle:@"Meet Us" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [controller addAction:callBackAction];
    [controller addAction:mail];
    [controller addAction:meetus];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:cancel];
    
    controller.popoverPresentationController.sourceView = sender;
    controller.popoverPresentationController.sourceRect = sender.bounds;
    [self presentViewController:controller animated:YES completion:nil];
}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


-(void)shareUsFromCell:(UITableViewCell *)cell {
    
    NSString *texttoshare = @"Hey! I Found this Awesome HyperLocal App for Shopping or Searching for your Daily needs around your location.\nDownload it Today and Enjoy Shopping \n\nAndroid: https://play.google.com/store/apps/details?id=info.adverto.neediator\n\niOS: https://itunes.apple.com/in/app/neediator/id1073622324?mt=8";
    
    NSArray *activityItems = @[texttoshare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeCopyToPasteboard];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityVC animated:TRUE completion:nil];
    }
    else {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        [popup presentPopoverFromRect:cell.bounds inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}


@end
