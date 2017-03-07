//
//  WriteReviewController.m
//  Neediator
//
//  Created by adverto on 09/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "WriteReviewController.h"
#import "RatingView.h"
#import "User.h"



@interface WriteReviewController ()
{
    
}

@end

@implementation WriteReviewController

#pragma mark - View Did Load..
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissVC:)];
    
    self.ratingView.backgroundColor     = [UIColor clearColor];
    self.ratingView.notSelectedImage    = [UIImage imageNamed:@"star-1"];
    self.ratingView.halfSelectedImage   = [UIImage imageNamed:@"Star Half Empty"];
    self.ratingView.fullSelectedImage   = [UIImage imageNamed:@"Star Filled"];
    self.ratingView.editable            = YES;
    self.ratingView.maxRating           = 5;
    self.ratingView.minImageSize        = CGSizeMake(10.f, 10.f);
    self.ratingView.midMargin           = 0.f;
    self.ratingView.leftMargin          = 0.f;
    self.ratingView.rating = 0;
    self.ratingView.delegate = self;
}


#pragma mark - Rating View Delegate Implementation.
- (void)rateView:(RatingView *)rateView ratingDidChange:(float)rating {
    
    NSLog(@"Rating is %f",rating);
    _OverallRating=[NSString stringWithFormat:@"%f",rating];
    
}


#pragma mark - Post Review..

- (IBAction)postReview:(id)sender
{
    
    if([_OverallRating isEqualToString:@"0.000000"])
    {
        NSLog(@"You Cannot Proceed Without Giving Rating");
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Warning" message:@"Cant procees Without Rating" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else
    {
        User *user = [User savedUser];
        NSString *parameterString = [NSString stringWithFormat:@"rating=%@&user_id=%@&reviews=%@&Section_id=%@&store_id=%@",self.OverallRating,user.userID,self.reviewTextView.text,self.sectionid,self.storeId];
        
        NSLog(@"Paratmeter String is %@",parameterString);
        
        
        NSString *url = [NSString stringWithFormat:@"http://192.168.1.199/NeediatorWebservice/NeediatorWS.asmx/addRatingReviews"];
        NSLog(@"URL is --> %@", url);
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.168.1.199/NeediatorWebservice/NeediatorWS.asmx/addRatingReviews"]];
        request.HTTPMethod = @"POST";
        request.HTTPBody   = [NSData dataWithBytes:[parameterString UTF8String] length:[parameterString length]];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSLog(@"%@",response);
            
            if (error) {
                NSLog(@"%@",error.localizedDescription);
            }
            else
            {
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@" Rating json   %@",json);
                });
            }
        }];
        [task resume];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Dismiss View Controller.

-(void)dismissVC:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
