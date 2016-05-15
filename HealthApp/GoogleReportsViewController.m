//
//  GoogleReportsViewController.m
//  Neediator
//
//  Created by Vinod Rathod on 08/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "GoogleReportsViewController.h"

@interface GoogleReportsViewController ()

@end


static NSString *const kKeychainItemName = @"Reports API";

@implementation GoogleReportsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Create a UITextView to display output.
    self.output = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.output.editable = false;
    self.output.contentInset = UIEdgeInsetsMake(20.0, 0.0, 20.0, 0.0);
    self.output.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.output];
    
    // Initialize the Reports API service & load existing credentials from the keychain if available.
    self.service = [[GTLService alloc] init];
    self.service.authorizer =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kGoogleReportingAPIClientID
                                                      clientSecret:nil];
}

// When the view appears, ensure that the Reports API service is authorized, and perform API calls.
- (void)viewDidAppear:(BOOL)animated {
    if (!self.service.authorizer.canAuthorize) {
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        [self presentViewController:[self createAuthController] animated:YES completion:nil];
        
    } else {
        [self fetchLoginEvents];
    }
}


// Construct a query to get the last 10 login events in the domain via the Admin SDK Reports API.
- (void)fetchLoginEvents {
    self.output.text = @"Getting last 10 login events...";
    NSString *baseUrl =
    @"https://www.googleapis.com/admin/reports/v1/activity/users/all/applications/login";
    NSDictionary *params = @{ @"maxResults": @"10" };
    NSURL *url = [GTLUtilities URLWithString:baseUrl queryParameters:params];
    [self.service fetchObjectWithURL:url
                         objectClass:[GTLObject class]
                            delegate:self
                   didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
}

// Process the response and display output.
- (void)displayResultWithTicket:(GTLServiceTicket *)ticket
             finishedWithObject:(GTLObject *)object
                          error:(NSError *)error {
    if (error == nil) {
        NSMutableString *output = [[NSMutableString alloc] init];
        NSArray *activities = [object.JSON objectForKey:@"items"];
        if (activities.count > 0) {
            [output appendString:@"Logins:\n"];
            for (NSDictionary *activity in activities) {
                [output appendFormat:@"%@: %@ (%@)\n", [[activity objectForKey:@"id"] objectForKey:@"time"],
                 [[activity objectForKey:@"actor"] objectForKey:@"email"],
                 [[activity objectForKey:@"events"][0] objectForKey:@"name"]];
            }
        } else {
            [output appendString:@"No logins found."];
        }
        self.output.text = output;
    } else {
        NSMutableString *message = [[NSMutableString alloc] init];
        [message appendFormat:@"Error getting login events: %@\n", error.localizedDescription];
        [self showAlert:@"Error" message:message];
    }
}


// Creates the auth controller for authorizing access to Reports API.
- (GTMOAuth2ViewControllerTouch *)createAuthController {
    GTMOAuth2ViewControllerTouch *authController;
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    NSArray *scopes = [NSArray arrayWithObjects:@"https://www.googleapis.com/auth/admin.reports.audit.readonly", nil];
    authController = [[GTMOAuth2ViewControllerTouch alloc]
                      initWithScope:[scopes componentsJoinedByString:@" "]
                      clientID:kGoogleReportingAPIClientID
                      clientSecret:nil
                      keychainItemName:kKeychainItemName
                      delegate:self
                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}


// Handle completion of the authorization process, and update the Reports API
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    if (error != nil) {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    }
    else {
        self.service.authorizer = authResult;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:message
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
    [alert show];
}



@end
