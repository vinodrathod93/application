//
//  RatingViewController.m
//  Neediator
//
//  Created by adverto on 09/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "RatingViewController.h"
#import "WriteReviewController.h"
#import "AllReviewTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface RatingViewController ()

@end

@implementation RatingViewController

#pragma mark - View Did Load...
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ReviewListTableView.delegate=self;
    self.ReviewListTableView.dataSource=self;
    [self callWebService];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handle_data) name:@"reload_data" object:nil];
    
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:_storeImageUrl] placeholderImage:[UIImage imageNamed:@"profile_placeholder"] options:SDWebImageRefreshCached];
    self.NameLabel.text=self.storeName;
    self.LocationLabel.text=self.Area;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.ReviewListTableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];}


#pragma mark - Handle Data...
-(void)handle_data {
    
    [self callWebService];
    [self.ReviewListTableView reloadData];
}

-(void)callWebService
{
    NSString *parameterString = [NSString stringWithFormat:@"Section_id=%@&store_id=%@",self.sectionID,self.storeID];
    NSString *url = [NSString stringWithFormat:@"http://192.168.1.199/NeediatorWebservice/NeediatorWS.asmx/showRatingReviews"];
    NSLog(@"URL is --> %@", url);
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.168.1.199/NeediatorWebservice/NeediatorWS.asmx/showRatingReviews"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody   = [NSData dataWithBytes:[parameterString UTF8String] length:[parameterString length]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //  NSLog(@"%@",response);
        
        
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        }
        else
        {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                _ReviewArray=[json objectForKey:@"ratingreviews"];
                
                
                NSLog(@"review array is %@",_ReviewArray);
                [self.ReviewListTableView reloadData];
                
            });
        }
    }];
    [task resume];
    
}


#pragma mark - TableView Data Source Methods.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    return _ReviewArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AllReviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reviewListingCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSDictionary *t=[_ReviewArray objectAtIndex:indexPath.row];
    cell.ReviewUserNamelbl.text=t[@"name"];
    cell.reviewlbl.text=t[@"reviews"];
    cell.partnerRply.text=t[@"PartnerReply"];
    return cell;
}



#pragma mark - Write Review....
- (IBAction)WriteReview:(id)sender {
    //
    //    WriteReviewController *rvc = [self.storyboard instantiateViewControllerWithIdentifier:@"WriteReviewController"];
    //    rvc.storeId=self.storeID;
    //    rvc.sectionid=self.sectionID;
    //    [self.navigationController pushViewController:rvc animated:YES];
    
    
    WriteReviewController *logSignVC = (WriteReviewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"WriteReviewController"];
    logSignVC.storeId=self.storeID;
    logSignVC.sectionid=self.sectionID;
    
    UINavigationController *logSignNav = [[UINavigationController alloc]initWithRootViewController:logSignVC];
    logSignVC.title=@"Reviews";
    logSignNav.navigationBar.tintColor = self.ReviewListTableView.tintColor;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        logSignNav.modalPresentationStyle    = UIModalPresentationFormSheet;
    }
    [self presentViewController:logSignNav animated:YES completion:nil];
}
@end
