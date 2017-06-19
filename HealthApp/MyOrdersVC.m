//
//  MyOrdersVC.m
//  Neediator
//
//  Created by adverto on 17/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "MyOrdersVC.h"
#import "MyOrdersCell.h"
#import "APIManager.h"
#import "MyOrdersModel.h"
#import "LineItemsModel.h"
#import "CustomCollectionViewCell.h"
#import "TrackPipelineView.h"
#import "CancelOrderView.h"
#import "CancelOrderNewView.h"
#import "MyOrderByStatus.h"
#import "ShowMyPrescriptionVC.h"

@interface MyOrdersVC ()

@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic, strong) NeediatorHUD *hud;



@end

@implementation MyOrdersVC
{
    NSMutableArray *_itemsImages;
    NSArray *_orders;
    NSArray *_statusArray;
    NSArray *_prescriptionArray;
    NSArray *_pendingorderreasonArray;
    NSArray *_processingorderreason;
    
    NSMutableDictionary *storeDetailsdict;
    
    BOOL _isTrackTapped;
    BOOL _isCancelTapped;
    BOOL _iscancelTappedFromPending;
    UIScrollView *scroll;
    
    ShowMyPrescriptionVC *smpc;
    
    NSString *selectedSegmentID;
    
    BOOL CancelFlag;
    NSNumber     *_selectedReasonTypeID;

    
    
    
}

#pragma mark - View Did Load...
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    storeDetailsdict=[NSMutableDictionary dictionary];
    self.PrescriptionContainerView.hidden=YES;
    
    self.title = @"My Orders";
    [self showHUD];
    [self HandleSegment];
    _itemsImages = [NSMutableArray array];
    
    [[NAPIManager sharedManager] getMyOrdersListingWithSuccess:^(MyOrdersResponseModel *myOrdersModel) {
        
        [self hideHUD];
        
        NSLog(@"%@", myOrdersModel.orders);
        
        _orders = myOrdersModel.orders;
        
        [NeediatorUtitity save:myOrdersModel.pendingorderreason forKey:kSAVE_Pending_Reason_Types];
        [NeediatorUtitity save:myOrdersModel.processingorderreason forKey:kSAVE_Processing_Reason_Types];

        
        [self getImagesForAll];
        selectedSegmentID=@"0";
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self hideHUD];
        UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertError show];
    }];
}


#pragma mark - Handle Segment.
-(void)HandleSegment
{
    NSArray *itemArray = [NSArray arrayWithObjects: @"Pending", @"In process", @"Completed",@"Cancelled", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray]; //provide array of segment names
    segmentedControl.tintColor=[UIColor blackColor];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                              NSForegroundColorAttributeName :[UIColor darkGrayColor]
                                                              } forState:UIControlStateNormal];
    
    segmentedControl.apportionsSegmentWidthsByContent=YES;
    segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
    segmentedControl.selectedSegmentIndex = 0; //by default selected index
    selectedSegmentID=[NSString stringWithFormat:@"%ld",segmentedControl.selectedSegmentIndex];
    
    UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [segmentedControl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // The device is an iPad running iOS 3.2 or later.
        scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,36, self.view.frame.size.width, 60)];
        segmentedControl.frame = CGRectMake(3,0, scroll.frame.size.width, 50); //change accordingly
    }
    
    else
    {
        scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,36, self.view.frame.size.width, 60)];
        segmentedControl.frame = CGRectMake(3,0, self.view.frame.size.width, 50);//change accordingly
    }
    
    scroll.showsHorizontalScrollIndicator = NO; //disable horizontal scroll
    scroll.showsVerticalScrollIndicator = NO; //disable vertical scroll
    scroll.bounces=NO;
    [segmentedControl addTarget:self action:@selector(SegmentChanged:) forControlEvents:UIControlEventValueChanged];
    [scroll addSubview:segmentedControl]; // add segment
    scroll.contentSize = CGSizeMake(segmentedControl.frame.size.width, segmentedControl.frame.size.height); //change accordingly
    [self.view addSubview:scroll]; //add scroll view
    
}


#pragma mark - Segment Changed....
-(void)SegmentChanged:(UISegmentedControl *)sender
{
    NSLog(@"Segment Selected");
    selectedSegmentID=[NSString stringWithFormat:@"%ld",(long)sender.selectedSegmentIndex];
    NSLog(@"Seleced Segment ID Is %@",selectedSegmentID);
    if (sender.selectedSegmentIndex == 0)
    {
        CancelFlag=0;
        [[NAPIManager sharedManager] getMyOrdersListingWithSuccess:^(MyOrdersResponseModel *myOrdersModel) {
            
            [self hideHUD];
            
            NSLog(@"%@", myOrdersModel.orders);
            
            _orders = myOrdersModel.orders;
            _statusArray=myOrdersModel.statusArray;
            _prescriptionArray=myOrdersModel.Prescriptions;
            
            
            [self getImagesForAll];
            
            [self.tableView reloadData];
            
        } failure:^(NSError *error) {
            
            [self hideHUD];
            UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertError show];
        }];
    }
    
    if (sender.selectedSegmentIndex == 1)
    {
        CancelFlag=0;
        
        selectedSegmentID=[NSString stringWithFormat:@"%ld",(long)sender.selectedSegmentIndex];
        NSLog(@"Seleced Segment ID Is %@",selectedSegmentID);
        
        User *user  = [User savedUser];
        MyOrderByStatus *requestModel = [MyOrderByStatus new];
        requestModel.userid=user.userID;
        requestModel.status=@"2";
        
        [[NAPIManager sharedManager] getMyOrdersListingByStatus:requestModel success:^(MyOrdersResponseModel *response)
         {
             
             NSLog(@" Index 2 Is Selected %@", response.orders);
             
             _orders = response.orders;
             _statusArray=response.statusArray;
             _prescriptionArray=response.Prescriptions;
             
             [self getImagesForAll];
             
             [self hideHUD];
             
             [self.tableView reloadData];
             
         } failure:^(NSError *error)
         {
             [self hideHUD];
             NSLog(@"Error: %@", error.localizedDescription);
         }];
        
    }
    
    if (sender.selectedSegmentIndex == 2)
    {
        CancelFlag=0;
        
        selectedSegmentID=[NSString stringWithFormat:@"%ld",(long)sender.selectedSegmentIndex];
        NSLog(@"Seleced Segment ID Is %@",selectedSegmentID);
        
        MyOrderByStatus *requestModel = [MyOrderByStatus new];
        User *user  = [User savedUser];
        
        requestModel.userid=user.userID;
        requestModel.status=@"5";
        
        [[NAPIManager sharedManager] getMyOrdersListingByStatus:requestModel success:^(MyOrdersResponseModel *response)
         {
             
             NSLog(@" Index 2 Is Selected %@", response.orders);
             
             _orders = response.orders;
             _statusArray=response.statusArray;
             _prescriptionArray=response.Prescriptions;
             
             [self getImagesForAll];
             
             [self hideHUD];
             [self.tableView reloadData];
             
         } failure:^(NSError *error)
         {
             [self hideHUD];
             NSLog(@"Error: %@", error.localizedDescription);
         }];
    }
    
    if (sender.selectedSegmentIndex == 3)
    {
        CancelFlag=1;
        selectedSegmentID=[NSString stringWithFormat:@"%ld",(long)sender.selectedSegmentIndex];
        NSLog(@"Seleced Segment ID Is %@",selectedSegmentID);
        
        User *user  = [User savedUser];
        MyOrderByStatus *requestModel = [MyOrderByStatus new];
        requestModel.userid=user.userID;
        requestModel.status=@"6";
        
        [[NAPIManager sharedManager] getMyOrdersListingByStatus:requestModel success:^(MyOrdersResponseModel *response)
         {
             NSLog(@" Index 2 Is Selected %@", response.orders);
             
             _orders = response.orders;
             _statusArray=response.statusArray;
             _prescriptionArray=response.Prescriptions;
             
             [self getImagesForAll];
             [self hideHUD];
             [self.tableView reloadData];
             
         } failure:^(NSError *error)
         {
             [self hideHUD];
             NSLog(@"Error: %@", error.localizedDescription);
         }];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideHUD];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _orders.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyOrdersCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"myOrdersCell" forIndexPath:indexPath];
    MyOrdersModel *model = _orders[indexPath.section];
    
    if (!cell) {
        cell = [[MyOrdersCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myOrdersCell"];
    }
    
    cell.beforeCompleteOptionView.hidden=YES;
    
    cell.StoreName.text=model.storeName;
    cell.StoreArea.text=model.area;
    cell.n_orderAmount.text = [NSString stringWithFormat:@"₹%@",model.orderTotal];
    cell.n_orderNumber.text = model.orderNumber;
    cell.n_orderStatus.text = model.orderState;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell hideButtonsSeenAfter7Days:YES];
    
   
    if([selectedSegmentID isEqualToString:@"0"])
    {
        cell.beforeCompleteOptionView.hidden=YES;
        cell.ReturnReplace_View.hidden=YES;
        cell.infoBtn.hidden=YES;
        cell.stlbl.hidden=YES;
        cell.n_orderStatus.hidden=YES;
        
        
    }
    if([selectedSegmentID isEqualToString:@"1"])
    {
        cell.beforeCompleteOptionView.hidden=NO;
        cell.ReturnReplace_View.hidden=YES;
        cell.infoBtn.hidden=YES;
        cell.stlbl.hidden=NO;
        cell.n_orderStatus.hidden=NO;
    }
    
    if([selectedSegmentID isEqualToString:@"2"])
    {
        cell.beforeCompleteOptionView.hidden=YES;
        cell.ReturnReplace_View.hidden=NO;
        cell.infoBtn.hidden=NO;
        cell.stlbl.hidden=YES;
        cell.n_orderStatus.hidden=YES;
        [cell.contentView bringSubviewToFront:cell.ReturnReplace_View];
    }
    
    if([selectedSegmentID isEqualToString:@"3"])
    {
        cell.beforeCompleteOptionView.hidden=YES;
        cell.ReturnReplace_View.hidden=NO;
        cell.infoBtn.hidden=YES;
        cell.stlbl.hidden=YES;
        cell.n_orderStatus.hidden=YES;
    }
    
    
    //    else
    //    {
    //        cell.beforeCompleteOptionView.hidden=YES;
    //        cell.beforeCompleteOptionView.hidden=YES;
    //    }
    
    [cell.trackButton addTarget:self action:@selector(showTrackView:) forControlEvents:UIControlEventTouchUpInside];
    [cell.beforeCompleteTrackOrderButton addTarget:self action:@selector(showTrackView:) forControlEvents:UIControlEventTouchUpInside];
    [cell.pendingCancelOrderBtn addTarget:self action:@selector(showCancelViewPending:) forControlEvents:UIControlEventTouchUpInside];
    [cell.cancelOrderButton addTarget:self action:@selector(showCancelViewProcessing:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}




-(void)showCancelViewPending:(UIButton *)sender
{
    MyOrdersCell *cell = (MyOrdersCell *)[[sender superview] superview];
    
    if (![cell isKindOfClass:[MyOrdersCell class]]) {
        cell = (MyOrdersCell *)[[[sender superview] superview] superview];
    }
    
        _iscancelTappedFromPending=!_iscancelTappedFromPending;
    
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSLog(@"IndexPath Section Is%ld",(long)indexPath.section);
        
        MyOrdersModel *model = _orders[indexPath.section];
        
        NSLog(@"My order 007 %@",model);
        model.isCancelExpanded = _iscancelTappedFromPending;
        
        CancelOrderNewView *cancelView = [[[NSBundle mainBundle] loadNibNamed:@"CancelOrderNewView" owner:self options:nil]firstObject];
        [cell.contentView addSubview:cancelView];
        
        cancelView.frame = CGRectMake(0, 230, self.view.frame.size.width, 101);
        [cancelView.selectReasonBtn addTarget:self action:@selector(showPendingReasonTypeSheet:) forControlEvents:UIControlEventTouchUpInside];

        [cancelView.SubmitBtn addTarget:self action:@selector(CancelOrderFromPending) forControlEvents:UIControlEventTouchUpInside];
        
        [self.tableView reloadData];
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
   // }
}

-(void)showCancelViewProcessing:(UIButton *)sender
{
    
    MyOrdersCell *cell = (MyOrdersCell *)[[sender superview] superview];
    
    if (![cell isKindOfClass:[MyOrdersCell class]])
    {
        cell = (MyOrdersCell *)[[[sender superview] superview] superview];
    }
    
    if (!_isTrackTapped) {
        _isCancelTapped = !_isCancelTapped;
        
        
        cell.beforeCompleteTrackOrderButton.alpha = 0.5;
        cell.cancelOrderButton.alpha = 1.0;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSLog(@"IndexPath Section Is%ld",(long)indexPath.section);
        
        
        MyOrdersModel *model = _orders[indexPath.section];
        
        NSLog(@"My order 007 %@",model);
        model.isCancelExpanded = _isCancelTapped;
        
        CancelOrderView *cancelView = [[[NSBundle mainBundle] loadNibNamed:@"CancelOrderView" owner:self options:nil] firstObject];
        [cell.contentView addSubview:cancelView];
        
        cancelView.frame = CGRectMake(0, 230, self.view.frame.size.width, 134);
        
        [cancelView.SelectReasonBtn addTarget:self action:@selector(showProcessingReasonTypeSheet:) forControlEvents:UIControlEventTouchUpInside];
        [cancelView.submitButton addTarget:self action:@selector(CancelOrderFromPending) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView reloadData];
        
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}


-(void)showTrackView:(UIButton *)sender {
    
    MyOrdersCell *cell = (MyOrdersCell *)[[sender superview] superview];
    
    if (![cell isKindOfClass:[MyOrdersCell class]]) {
        cell = (MyOrdersCell *)[[[sender superview] superview] superview];
    }
    
    if (!_isCancelTapped) {
        
        cell.cancelOrderButton.alpha = 0.5;
        cell.beforeCompleteTrackOrderButton.alpha = 1.0;
        _isTrackTapped = !_isTrackTapped;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        MyOrdersModel *model = _orders[indexPath.section];
        model.isExpanded = _isTrackTapped;
        
        TrackPipelineView *trackView = [[[NSBundle mainBundle] loadNibNamed:@"TrackPipelineView" owner:self options:nil] firstObject];
        [trackView drawCurrentOrderState:model.orderState orderDateTime:model.completed_date withCode:model.statusCode.intValue];
        [cell.contentView addSubview:trackView];
        
        trackView.frame = CGRectMake(0, 230, self.view.frame.size.width, 186);
        
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}




-(void)tableView:(UITableView *)tableView willDisplayCell:(MyOrdersCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyOrdersModel *model = _orders[indexPath.section];
    
    if(CancelFlag==1)
    {
        return 155;
    }
    if (model.isExpanded)
    {
        return 196+235;
    }
    else if (model.isCancelExpanded) {
        return 134+235;
    }
    else
    {
        return 234.f;
    }
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    MyOrdersModel *model = _orders[section];
    
    return model.completed_date;
}


#pragma mark - Cancel Orders From Pending Tab

-(void)CancelOrderFromPending
{
    NSIndexPath *indexPath;
   MyOrdersModel *model = _orders[indexPath.section];
    
    NSLog(@"Store Details Description Is %@",model);

    
    NSString *parameterString = [NSString stringWithFormat:@"orderid=%@&reasonid=%@",[NSString stringWithFormat:@"%@",model.id],_selectedReasonTypeID.stringValue];
    
    NSLog(@"Parameter String Is %@",parameterString);
    
    NSString *url = [NSString stringWithFormat:@"http://neediator.net/NeediatorWebservice/NeediatorWS.asmx/cancelorder"];
    NSLog(@"URL is --> %@", url);
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://neediator.net/NeediatorWebservice/NeediatorWS.asmx/cancelorder"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody   = [NSData dataWithBytes:[parameterString UTF8String] length:[parameterString length]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",response);
        
        if (error)
        {
            NSLog(@"%@",error.localizedDescription);
        }
        else
        {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"%@",json);
            });
        }
    }];
    [task resume];
    
}


#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *collectionImages = _itemsImages[[(HorizontalCollectionView *)collectionView indexPath].section];
    
    return collectionImages.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyOrderCollectionViewCellIdentifier" forIndexPath:indexPath];
    cell.tag    = indexPath.item;
    
    NSLog(@"%@",_itemsImages[[(HorizontalCollectionView *)collectionView indexPath].section]);
    
    
    NSArray *collectionImages = _itemsImages[[(HorizontalCollectionView *)collectionView indexPath].section];
    
    if (collectionImages[indexPath.item] != nil) {
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", collectionImages[indexPath.item]]];
        
        [cell.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder_neediator"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                [cell.imageView setImage:[UIImage imageNamed:@"no_image"]];
            }
        }];
        
    }
    else {
        [cell.imageView setImage:[UIImage imageNamed:@"small_no_image"]];
    }
    
    return cell;
    
}


#pragma mark - UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}








-(NSArray *)getImagesForAll {
    
    for (int i=0; i< _orders.count; i++) {
        
        NSMutableArray *imagesParticularOrder = [NSMutableArray array];
        
        MyOrdersModel *model = _orders[i];
        NSArray *items;
        
        if (model.isPrescription.boolValue) {
            items = model.prescriptionArray;
        }
        else
            items = model.line_items;
        
        //        [items enumerateObjectsUsingBlock:^(LineItemsModel * _Nonnull line_item, NSUInteger idx, BOOL * _Nonnull stop) {
        ////            if (line_item.images.count != 0) {
        ////                VariantImagesModel *image = line_item.images[0];
        ////                [imagesParticularOrder addObject:image.small_url];
        ////            }
        //            [imagesParticularOrder addObject:line_item.imageURL];
        //        }];
        
        
        for (id item in items) {
            if ([item isKindOfClass:[LineItemsModel class]]) {
                
                LineItemsModel *model = (LineItemsModel *)item;
                
                [imagesParticularOrder addObject:model.imageURL];
            }
            else {
                NSDictionary *prescription = (NSDictionary *)item;
                
                [imagesParticularOrder addObject:prescription[@"image_url"]];
            }
        }
        [_itemsImages addObject:imagesParticularOrder];
    }
    
    NSLog(@"My Order Images Are %@", _itemsImages);
    
    return _itemsImages;
    
    /*
     // get scrollview & view frame
     CGRect scrollViewFrame = cell.scrollView.frame;
     CGRect currentFrame = cell.contentView.frame;
     
     // assign the visible frame to scrollview
     scrollViewFrame.size.width = currentFrame.size.width;
     cell.scrollView.frame = scrollViewFrame;
     
     __block UIImageView *previousImageView;
     
     [_itemsImages enumerateObjectsUsingBlock:^(NSString *image_url, NSUInteger idx, BOOL *stop)
     {
     
     UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(80 * idx, 0, 80, CGRectGetHeight(cell.scrollView.frame))];
     
     imageView.tag = idx;
     imageView.contentMode = UIViewContentModeScaleAspectFit;
     imageView.translatesAutoresizingMaskIntoConstraints = NO;
     
     [cell.scrollViewContentView addSubview:imageView];
     
     if (idx == 0) {
     
     [cell.scrollViewContentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.scrollViewContentView attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
     
     } else {
     [cell.scrollViewContentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:previousImageView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
     
     if (idx == [_itemsImages indexOfObject:[_itemsImages lastObject]]) {
     
     [cell.scrollViewContentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.scrollViewContentView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
     }
     
     }
     
     
     // Imageview constraints
     //        [cell.scrollViewContentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
     //        [cell.scrollViewContentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:cell.scrollViewContentView.frame.size.height]];
     
     
     [cell.scrollViewContentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.scrollViewContentView attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
     
     previousImageView = imageView;
     
     
     [imageView sd_setImageWithURL:[NSURL URLWithString:image_url]];
     
     }];
     
     */
}




-(NSString *)getFormattedDate:(NSString *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
    
    NSDate *completedDate = [dateFormatter dateFromString:date];
    
    [dateFormatter setDateFormat:@"EEEE, MMMM dd, yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:completedDate];
    
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *timeString = [dateFormatter stringFromDate:completedDate];
    
    return [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
}


#pragma mark - HUD

-(void)showHUD
{
    self.hud = [[NeediatorHUD alloc] initWithFrame:self.tableView.frame];
    self.hud.overlayColor = [NeediatorUtitity blurredDefaultColor];
    [self.hud fadeInAnimated:YES];
    self.hud.hudCenter = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetHeight(self.view.bounds) / 2);
    [self.navigationController.view insertSubview:self.hud belowSubview:self.navigationController.navigationBar];
}

-(void)hideHUD
{
    [self.hud fadeOutAnimated:YES];
    [self.hud removeFromSuperview];
    
}

- (IBAction)OrdersAction:(id)sender
{
    self.PrescriptionContainerView.hidden=YES;
}

- (IBAction)PrescriptionAction:(id)sender
{
    self.PrescriptionContainerView.hidden=NO;
    [self.view bringSubviewToFront:self.PrescriptionContainerView];
    smpc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShowMyPrescriptionVC"];
    [self addChildViewController:smpc];
    smpc.view.frame = self.PrescriptionContainerView.bounds;
    [self.PrescriptionContainerView addSubview:smpc.view];
    [smpc didMoveToParentViewController:self];
}

#pragma mark -  "PEnding"  ReasonTypeSheet........
-(void)showPendingReasonTypeSheet:(UIButton *)sender
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Select Reason Type" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *namess = [self ReasonTypes];
    NSArray *idss   = [self ReasonTypeIDs];
    
    [namess enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [sender setTitle:action.title forState:UIControlStateNormal];
            _selectedReasonTypeID = idss[idx];
            
            
            
                }];
        
        [controller addAction:action];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    [controller addAction:cancel];
    controller.popoverPresentationController.sourceView = sender;
    controller.popoverPresentationController.sourceRect = sender.bounds;
    [self presentViewController:controller animated:YES completion:nil];
}

-(NSArray *)ReasonTypes
{
    NSArray *address_types = [NeediatorUtitity savedDataForKey:kSAVE_Pending_Reason_Types];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    [address_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [names addObject:[type valueForKey:@"reason"]];
    }];
    return names;
}

-(NSArray *)ReasonTypeIDs {
    NSArray *address_types = [NeediatorUtitity savedDataForKey:kSAVE_Pending_Reason_Types];
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    
    [address_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [ids addObject:[type valueForKey:@"id"]];
    }];
    
    return ids;
}


#pragma mark -  "Processing"  ReasonTypeSheet........
-(void)showProcessingReasonTypeSheet:(UIButton *)sender
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Select Reason Type" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *namess = [self processingReasonTypes];
    NSArray *idss   = [self processingReasonTypeIDs];
    
    [namess enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [sender setTitle:action.title forState:UIControlStateNormal];
            _selectedReasonTypeID = idss[idx];
            
            
            
        }];
        
        [controller addAction:action];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    [controller addAction:cancel];
    controller.popoverPresentationController.sourceView = sender;
    controller.popoverPresentationController.sourceRect = sender.bounds;
    [self presentViewController:controller animated:YES completion:nil];
}

-(NSArray *)processingReasonTypes
{
    NSArray *address_types = [NeediatorUtitity savedDataForKey:kSAVE_Processing_Reason_Types];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    [address_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [names addObject:[type valueForKey:@"reason"]];
    }];
    return names;
}

-(NSArray *)processingReasonTypeIDs {
    NSArray *address_types = [NeediatorUtitity savedDataForKey:kSAVE_Processing_Reason_Types];
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    
    [address_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [ids addObject:[type valueForKey:@"id"]];
    }];
    
    return ids;
}


@end
