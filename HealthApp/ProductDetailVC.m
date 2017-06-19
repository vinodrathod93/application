//
//  ProductDetailVC.m
//  Neediator
//
//  Created by adverto on 11/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "ProductDetailVC.h"
#import "SpecificationTableViewCell.h"
#import "DescriptionsTableViewCell.h"
#import "Order.h"
#import "LineItems.h"
#import "User.h"

@interface ProductDetailVC ()
{
    NSDictionary *received;
    NSArray *productsArray;
    NSArray *descriptionArray;
    BOOL flag;
    BOOL HeightFlag;
    NSString *VendorPid;
}
@property (nonatomic, strong) LineItems *lineItemsModel;
@property (nonatomic, strong) NSFetchedResultsController *pd_orderFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *pd_lineItemFetchedResultsController;
@property (nonatomic, strong) UIButton *cartButton;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ProductDetailVC

#pragma mark - View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ProductNameLabel.text=_AdminProductName;
    self.ProductPrice.text=_AdminProductPrice;
    
    
    UIBarButtonItem *cartItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"cart"] style:UIBarButtonItemStylePlain target:self action:@selector(showCartView)];
    self.navigationItem.rightBarButtonItem = cartItem;
    
    
    flag=0;
    productsArray=[NSArray array];
    descriptionArray=[NSArray array];
    
    NSString *parameterString = [NSString stringWithFormat:@"AdminProductId=%@",_AdminProductID];
    NSLog(@"My Details %@",parameterString);
    NSString *url = [NSString stringWithFormat:@"http://neediator.net/NeediatorWebservice/NeediatorWS.asmx/getProductSpecification"];
    NSLog(@"URL is --> %@", url);
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://neediator.net/NeediatorWebservice/NeediatorWS.asmx/getProductSpecification"]];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@" Product Response Is %@",received);
                NSError *jsonError;
                received = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                NSLog(@" Product Response Is %@",received);
                productsArray=received[@"specifications"];
                [self.TableView reloadData];
            });
        }
    }];
    [task resume];
    
    
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,20, self.view.frame.size.width/1, 150)];
    scrollView.contentSize = CGSizeMake(320, 465);
    scrollView.backgroundColor=[UIColor clearColor];
    
    //    [scrollView setScrollEnabled:YES];
    
    [scrollView setPagingEnabled:YES];
    [scrollView setAlwaysBounceVertical:NO];
    [self.view addSubview:scrollView];
    
    [self.ImagesArray enumerateObjectsUsingBlock:^(NSDictionary *imageURL, NSUInteger idx, BOOL *stop) {
        CGFloat xOrigin = idx * scrollView.frame.size.width;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
        imageView.tag   = idx;
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageURL[@"ImagePath"]] placeholderImage:[UIImage imageNamed:@"placeholder_neediator"]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [scrollView addSubview:imageView];
    }];
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width * [_ImagesArray count], scrollView.frame.size.height)];
    
    
    self.SpecificationOutlet.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.SpecificationOutlet.layer.borderWidth = 1.f;
    self.SpecificationOutlet.layer.masksToBounds = YES;
    
    self.DescriptionOutlet.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.DescriptionOutlet.layer.borderWidth = 1.f;
    self.DescriptionOutlet.layer.masksToBounds = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View delegates.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    _heightConstraints.constant=productsArray.count*35;
    
    if(flag==1)
    {
        return descriptionArray.count;
    }
    
    //    _heightConstraints.constant=productsArray.count*35;
    return productsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(flag==1)
    {
        HeightFlag=0;
        DescriptionsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"descriptioncell" forIndexPath:indexPath];
        NSDictionary *abc=[descriptionArray objectAtIndex:indexPath.row];
        
        cell.KeyName.text=abc[@"description"];
        
        
//        cell.KeyName.numberOfLines=0;
//        cell.KeyName.adjustsFontSizeToFitWidth=YES;

        return cell;
    }
    else
    {
        HeightFlag=1;
        SpecificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"specificationcell" forIndexPath:indexPath];
        NSDictionary *t=[productsArray objectAtIndex:indexPath.row];
        cell.KeyName.text=t[@"Specification"];
        cell.ValueName.text=t[@"SpecificationValue"];
        
        
                return cell;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(HeightFlag==1)
    {
         return 19;
    }
    return 250;
}


#pragma mark - Specification of Product API.
- (IBAction)SpecificationPressed:(id)sender
{
    flag=0;
    
    self.DescriptionOutlet.backgroundColor=[UIColor clearColor];
    self.DescriptionOutlet.titleLabel.textColor=[UIColor blackColor];
    self.SpecificationOutlet.backgroundColor=[UIColor blackColor];
    
    NSString *parameterString = [NSString stringWithFormat:@"AdminProductId=%@",_AdminProductID];
    NSLog(@"My Details %@",parameterString);
    NSString *url = [NSString stringWithFormat:@"http://neediator.net/NeediatorWebservice/NeediatorWS.asmx/getProductSpecification"];
    NSLog(@"URL is --> %@", url);
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://neediator.net/NeediatorWebservice/NeediatorWS.asmx/getProductSpecification"]];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@" Product Response Is %@",received);
                NSError *jsonError;
                received = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                NSLog(@" product Response Is %@",received);
                productsArray=received[@"specifications"];
                [self.TableView reloadData];
            });
        }
    }];
    [task resume];
    
}


#pragma mark - Description Of Product API
- (IBAction)DescriptionPressed:(id)sender
{
    flag=1;
    self.SpecificationOutlet.backgroundColor=[UIColor clearColor];
    self.SpecificationOutlet.titleLabel.textColor=[UIColor blackColor];
    self.DescriptionOutlet.backgroundColor=[UIColor blackColor];
    
    
    NSString *parameterString = [NSString stringWithFormat:@"VendorProductid=%@",_VendorProductID];
    NSLog(@"My Details %@",parameterString);
    NSString *url = [NSString stringWithFormat:@"http://neediator.net/NeediatorWebservice/NeediatorWS.asmx/getProductDescription"];
    NSLog(@"URL is --> %@", url);
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://neediator.net/NeediatorWebservice/NeediatorWS.asmx/getProductDescription"]];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@" Product Response Is %@",received);
                NSError *jsonError;
                received = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                NSLog(@" Description Response Is %@",received);
                descriptionArray=received[@"Descriptions"];
                [self.TableView reloadData];
            });
        }
    }];
    [task resume];
 }





#pragma mark - Add To Cart API.
- (IBAction)AddToCartPressed:(id)sender
{
    User *user = [User savedUser];
    //   [self checkOrders];
    
    
    NSString *url = [NSString stringWithFormat:@"http://neediator.net/NeediatorWebservice/neediatorWs.asmx/addToCartNew"];
    
    
    
    NSLog(@"URL is --> %@", url);
    
    NSString *parameter  = [NSString stringWithFormat:@"VendorProductId=%@&qty=%@&user_id=%@&store_id=%@&Section_id=%@", _VendorProductID, _ProductQuantity, user.userID,[NeediatorUtitity savedDataForKey:kSAVE_STORE_ID],[NeediatorUtitity savedDataForKey:kSAVE_SEC_ID]];
    NSLog(@"Add To Cart Parameters%@",parameter);
    
    NSData *parameterData = [NSData dataWithBytes:[parameter UTF8String] length:[parameter length]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = parameterData;
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)parameterData.length] forHTTPHeaderField:@"Content-Length"];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@",response);
                NSError *jsonError;
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                NSLog(@"Add To Cart Product Details %@", json);
                
                [self.hud hide:YES];
                if (jsonError) {
                    NSLog(@"Error %@",[jsonError localizedDescription]);
                } else {
                    
                    
                    if (_pd_orderFetchedResultsController.fetchedObjects.count != 0) {
                        
                        Order *orderModel = [_pd_orderFetchedResultsController.fetchedObjects lastObject];
                        [orderModel addCartLineItemsObject:_lineItemsModel];
                        
                    }
                    
                    //                    [self.managedObjectContext save:nil];
                    //
                    //                    [self addedLabelButton];
                    //                    [self vibratePhone];
                    //
                }
                
            });
        }
        else {
            [self displayConnectionFailed];
        }
        
        
    }];
    
    [task resume];
    
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    self.hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    self.hud.dimBackground = YES;
    self.hud.labelText = @"Adding To Cart...";
    self.hud.color = self.view.tintColor;
    
}




#pragma mark - Navigation..

-(void)showCartView
{
    UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
    [tabBarController setSelectedIndex:3];
}

- (IBAction)BuyNowPressed:(id)sender
{
    NSLog(@"Buy Now Pressed..");
    UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
    [tabBarController setSelectedIndex:3];
}


//-(void)checkOrders {
//    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
//
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
//    [fetchRequest setSortDescriptors:@[sortDescriptor]];
//
//    self.pd_orderFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
//    NSError *error;
//    if(![self.pd_orderFetchedResultsController performFetch:&error])
//    {
//
//        NSLog(@"Order Model Fetch Failure: %@",error);
//    }
//}



#pragma mark - Helper Methods.
-(void)displayConnectionFailed {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hud hide:YES];
        
        UIAlertView *failed_alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [failed_alert show];
    });
    
}


@end
