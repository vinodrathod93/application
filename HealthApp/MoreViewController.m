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
#import "GoogleReportsViewController.h"
#import "FollowUsTableViewCell.h"
#import <MessageUI/MessageUI.h>


enum SECTIONS {
    FAQSection = 0,
    PolicySection,
    SharingSection,
    ContactUs,
    SyncGoogleSection
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
                    @"FAQ",
                    @[ @"Privacy Policy", @"Return Policy",@"Terms of Use"],
                    @[@"About Us", @"Rate Us", @"Share Us"],
                    @"Contact Us",
                    @"Follow Us"
                    ];
    
    _moreDataIcons = @[
                       @"about_us",
                       @[ @"privacy",@"return_policy", @"terms_condition"],
                       @[@"about_us", @"rate", @"share"],
                       @"contact_us",
                       @"circle"
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
    
    
    
    
    if ([_moreData[indexPath.section] isEqual:[_moreData lastObject]]) {
        FollowUsTableViewCell *followUsCell = [tableView dequeueReusableCellWithIdentifier:@"followUsMoreCellIdentifier" forIndexPath:indexPath];
        followUsCell.backgroundColor = [UIColor clearColor];
//        followUsCell.
        [followUsCell.facebookButton addTarget:self action:@selector(facebookButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [followUsCell.twitterButton addTarget:self action:@selector(twitterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        return followUsCell;
    }
    else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCellIdentifier" forIndexPath:indexPath];
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        
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
        
        return cell;
    }
    
}


//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == _moreData.count-1) {
//        NSArray *subViews = cell.subviews;
//        
//        if (subViews.count >= 3) {
//            for (UIView *subview in subViews) {
//                if (subview != cell.contentView) {
//                    [subview removeFromSuperview];
//                    break;
//                }
//            }
//        }
//    }
//}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == _moreData.count-1) {
        return @"Follow Us";
    }
    else
        return @"";
}

-(void)facebookButtonTapped:(id)sender {
    
    
    NSURL *fbURL = [[NSURL alloc] initWithString:@"fb://profile/IamSRK"];
    // check if app is installed
    if ( ! [[UIApplication sharedApplication] canOpenURL:fbURL] ) {
        // if we get here, we can't open the FB app.
        fbURL = [NSURL URLWithString:@"https://www.facebook.com/IamSRK"];
    }
    
    [[UIApplication sharedApplication] openURL:fbURL];
    
}

-(void)twitterButtonTapped:(id)sender {
    // open the Twitter App
    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=iamsrk"]]) {
        
        // opening the app didn't work - let's open Safari
        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/iamsrk"]]) {
            
            // nothing works - perhaps we're not onlye
            NSLog(@"Nothing works. Punt.");
        }
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([_moreData indexOfObject:_moreData.lastObject] == section) {
        return 120.f;
    }
    else
        return 0.f;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == _moreData.count-1) {
        return 50.f;
    }
    else
        return 44.f;
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
            NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"about_us" ofType:@"txt"];
            NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
            
            WebViewController *aboutUsWebViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewVC"];
            aboutUsWebViewVC.hidesBottomBarWhenPushed = YES;
            aboutUsWebViewVC.title = @"About us";
            
            aboutUsWebViewVC.htmlString = htmlString;
            
            [self.navigationController pushViewController:aboutUsWebViewVC animated:YES];
        }
        else if (indexPath.row == 1) {
            // Rate us
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: kAPP_URL_STRING]];
            
        }
        else if (indexPath.row == 2) {
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
    else {
//        GoogleReportsViewController *reportVC = [[GoogleReportsViewController alloc] init];
//        reportVC.title = @"Reports";
//        
//        [self.navigationController pushViewController:reportVC animated:YES];
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



-(void)prepareFeedbackMail {
    // Email Subject
    NSString *emailTitle = @"Feedback";
    // Email Content
    NSString *messageBody = @"Hi Neediator Team, \n"; // Change the message body to HTML
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
    
    UIAlertAction *feedback = [UIAlertAction actionWithTitle:@"Give Feedback" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self prepareFeedbackMail];
    }];
    
    UIAlertAction *emailUs = [UIAlertAction actionWithTitle:@"Email Us" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self prepareMail];
    }];
    
    UIAlertAction *callUs = [UIAlertAction actionWithTitle:@"Call Us" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
        
            
        NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",@"+91-XXX-XXX-XXXX"]];
        
        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
            [[UIApplication sharedApplication] openURL:phoneUrl];
        } else
        {
            UIAlertView *callAlertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [callAlertView show];
        }
        
    }];
    
    
    
    [controller addAction:callBackAction];
    [controller addAction:emailUs];
    [controller addAction:callUs];
    [controller addAction:feedback];
    
    
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
    UIImage *neediatorQR = [UIImage imageNamed:@"NeediatorQR - AppStore.png"];
    
    NSArray *activityItems = @[texttoshare, neediatorQR];
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
