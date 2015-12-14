//
//  MoreViewController.m
//  Neediator
//
//  Created by adverto on 14/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "MoreViewController.h"
#import "WebViewController.h"
#import <MessageUI/MessageUI.h>

@interface MoreViewController ()<MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *moreData;
@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _moreData = [[NSArray alloc] initWithObjects:@"Rate us", @"Share us", @"Privacy Policy", @"About us", nil];
    
    _moreData   = @[
                    @[@"Rate us", @"Share us"],
                    @[@"Privacy Policy", @"Terms & Conditions"],
                    @"Contact us",
                    @"About us"
                    ];
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
        
        cell.textLabel.text = array[indexPath.row];
    }
    else {
        cell.textLabel.text = _moreData[indexPath.section];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([_moreData indexOfObject:_moreData.lastObject] == section) {
        return 100.f;
    }
    else
        return 0.f;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if ([_moreData indexOfObject:_moreData.lastObject] == section) {
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 80.f)];
        
        UIImageView *appIcon    = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - 25, 10, 50, 50)];
        appIcon.image           = [UIImage imageNamed:@"icon"];
        
        
        [footerView addSubview:appIcon];
        
        UILabel *appVersion = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, CGRectGetWidth(self.view.frame), 15)];
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
    if (indexPath.section == 2) {
        [self prepareMail];
    }
    else if (indexPath.section == 1) {
        
        
        
        if (indexPath.row == 0) {
            WebViewController *privacyWebViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewVC"];
            privacyWebViewVC.urlString = [NSString stringWithFormat:@"http://www.elnuur.com/privacy_policy"];
            [self.navigationController pushViewController:privacyWebViewVC animated:YES];
            
        }
        else if (indexPath.row == 1) {
            WebViewController *termsConditionWebViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewVC"];
            termsConditionWebViewVC.urlString = [NSString stringWithFormat:@"http://www.elnuur.com/terms_conditions"];
            [self.navigationController pushViewController:termsConditionWebViewVC animated:YES];
            
        }
    }
    else if (indexPath.section == 3) {
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"about_us" ofType:@"txt"];
        NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
        
        WebViewController *aboutUsWebViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewVC"];
        
        aboutUsWebViewVC.htmlString = htmlString;
        
        [self.navigationController pushViewController:aboutUsWebViewVC animated:YES];
    }
}


-(void)prepareMail {
    // Email Subject
    NSString *emailTitle = @"";
    // Email Content
    NSString *messageBody = @""; // Change the message body to HTML
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"care@neediator.com"];
    
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


-(void)aboutUs {
    
//    [webView loadHTMLString:htmlString baseURL:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end