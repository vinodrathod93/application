//
//  ShowMyPrescriptionVC.m
//  Neediator
//
//  Created by adverto on 28/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "ShowMyPrescriptionVC.h"
#import "MyOrdersVC.h"
#import "APIManager.h"
#import "MyOrdersModel.h"
#import "LineItemsModel.h"
#import "CustomCollectionViewCell.h"
#import "CustomPrescriptionViewCell.h"
#import "TrackPipelineView.h"
#import "CancelOrderView.h"
#import "MyOrderByStatus.h"
#import "TableViewCell.h"
#import "MyOrdersResponseModel.h"
#import "MyPrescriptionModel.h"
#import <MWPhotoBrowser/MWPhoto.h>
#import "NeediatorPhotoBrowser.h"
#import "PrescriptionLineItemsModel.h"
#import "ShowMyPrescriptionVC.h"
#import "CancelOrderNewView.h"



@interface ShowMyPrescriptionVC ()
{
    NSDictionary *PrescriptionDict;
    
    NSNumber     *_selectedreasonTypeId;

    
    BOOL _isCancelTouchesFromPending;
    
    BOOL _isCancelTouchesFromPending1;
    
    BOOL _cancelFlag;
    
    NSString *faaa;

}
@property (nonatomic, strong)  NSArray *colorArray;
@property (nonatomic, strong)  NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic, strong)  NeediatorHUD *hud;
@property(nonatomic,strong)     NSArray *offersarray;
@property(nonatomic,retain)     NSArray *ImagesArray;






@end

@implementation ShowMyPrescriptionVC
{
    NSMutableArray* entries;
    
    NSMutableArray *photoss;
    NSMutableArray *temp;
    
    ShowMyPrescriptionVC *smpc;
    NSMutableArray *_itemsImages;
    NSMutableArray *_itemImagesPrescription;
    NSArray *_orders;
    NSArray *_statusArray;
    NSArray *_numberOfPrescriptions;
    
    BOOL flag;
    BOOL _isTrackTapped;
    BOOL _isCancelTapped;
    UIScrollView *scroll;
    
    MyPrescriptionModel *mpv;
    
    NSString *selectedSegmentID;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    mpv=[[MyPrescriptionModel alloc]init];
    
    [self showHUD];
    [self HandleSegment];
    _itemImagesPrescription=[NSMutableArray array];
    
    [[NAPIManager sharedManager]getMyOrdersListingWithSuccess:^(MyOrdersResponseModel *myOrdersModel) {
        
        [self hideHUD];
        
        NSLog(@"%@", myOrdersModel.Prescriptions);
        
        //        _orders             =   myOrdersModel.orders;
        //        _statusArray        =   myOrdersModel.statusArray;
        _numberOfPrescriptions  =   myOrdersModel.Prescriptions;
        
        
        [self getimageForAllPrescription];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self hideHUD];
        UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertError show];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideHUD];
}




#pragma mark - Handle The Segment Progrmatically.....
-(void)HandleSegment
{
    NSArray *itemArray = [NSArray arrayWithObjects: @"Pending", @"Inprocess", @"Completed",@"Cancelled", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray]; //provide array of segment names
    segmentedControl.tintColor=[UIColor blackColor];
    segmentedControl.backgroundColor=[UIColor clearColor];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                              NSForegroundColorAttributeName :[UIColor darkGrayColor]
                                                              } forState:UIControlStateNormal];
    
    segmentedControl.apportionsSegmentWidthsByContent=YES;
    segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
    segmentedControl.selectedSegmentIndex = 0; //by default selected index
    UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [segmentedControl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // The device is an iPad running iOS 3.2 or later.
        scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 60)];
        segmentedControl.frame = CGRectMake(3,0, scroll.frame.size.width, 50); //change accordingly
    }
    
    else
    {
        scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 60)];
        segmentedControl.frame = CGRectMake(3,0, self.view.frame.size.width, 50);//change accordingly
    }
    
    scroll.backgroundColor=[UIColor whiteColor];
    scroll.showsHorizontalScrollIndicator = NO; //disable horizontal scroll
    scroll.showsVerticalScrollIndicator = NO; //disable vertical scroll
    scroll.bounces=NO;
    [segmentedControl addTarget:self action:@selector(SegmentChanged:) forControlEvents:UIControlEventValueChanged];
    [scroll addSubview:segmentedControl]; // add segment
    scroll.contentSize = CGSizeMake(segmentedControl.frame.size.width, segmentedControl.frame.size.height); //change accordingly
    [self.view addSubview:scroll]; //add scroll view
    
}
-(void)SegmentChanged:(UISegmentedControl *)sender
{
    NSLog(@"Segment Selected");
    
    if (sender.selectedSegmentIndex == 0)
    {
        _cancelFlag=0;

        [[NAPIManager sharedManager] getMyOrdersListingWithSuccess:^(MyOrdersResponseModel *myOrdersModel) {
            
            [self hideHUD];
            
            NSLog(@"%@", myOrdersModel.orders);
            
//            _orders = myOrdersModel.orders;
//            _statusArray=myOrdersModel.statusArray;
            _numberOfPrescriptions=myOrdersModel.Prescriptions;
            
            [self getimageForAllPrescription];
            [self.tableView reloadData];
            
        } failure:^(NSError *error) {
            
            [self hideHUD];
            UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertError show];
        }];
    }
    
    if (sender.selectedSegmentIndex == 1)
    {
        _cancelFlag=0;

        User *user  = [User savedUser];
        MyOrderByStatus *requestModel = [MyOrderByStatus new];
        requestModel.userid=user.userID;
        requestModel.status=@"2";
        [[NAPIManager sharedManager] getMyOrdersListingByStatus:requestModel success:^(MyOrdersResponseModel *response)
         {
             
             NSLog(@" Index 2 Is Selected %@", response.orders);
             
//             _orders = response.orders;
//             _statusArray=response.statusArray;
             
             _numberOfPrescriptions=response.Prescriptions;
             
             [self getimageForAllPrescription];
             
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
        _cancelFlag=0;

        MyOrderByStatus *requestModel = [MyOrderByStatus new];
        User *user  = [User savedUser];
        
        requestModel.userid=user.userID;
        requestModel.status=@"5";
        [[NAPIManager sharedManager] getMyOrdersListingByStatus:requestModel success:^(MyOrdersResponseModel *response)
         {
             NSLog(@" Index 2 Is Selected");
//             _orders = response.orders;
//             _statusArray=response.statusArray;
             _numberOfPrescriptions=response.Prescriptions;
             
             [self getimageForAllPrescription];
             
             
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
        _cancelFlag=1;
        User *user  = [User savedUser];
        MyOrderByStatus *requestModel = [MyOrderByStatus new];
        requestModel.userid=user.userID;
        requestModel.status=@"6";
        
        [[NAPIManager sharedManager] getMyOrdersListingByStatus:requestModel success:^(MyOrdersResponseModel *response)
         {
             
             NSLog(@" Index 2 Is Selected %@", response.orders);
             
//             _orders = response.orders;
//             _statusArray=response.statusArray;
             _numberOfPrescriptions=response.Prescriptions;
             
             [self getimageForAllPrescription];
             [self hideHUD];
             [self.tableView reloadData];
             
         } failure:^(NSError *error)
         {
             [self hideHUD];
             NSLog(@"Error: %@", error.localizedDescription);
         }];
    }
}


#pragma mark - Table View DataSource..
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _numberOfPrescriptions.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"mycell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[TableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mycell"];
    }
    NSLog(@" Prescription Section Is %ld,Row Is %ld",(long)indexPath.section,(long)indexPath.row);
    
    MyPrescriptionModel *model = _numberOfPrescriptions[indexPath.section];
    ///    cell.orderNumber.text=model.orderno;
    
    cell.beforeCompleteOptionView.hidden=NO;
    
    PrescriptionDict=_numberOfPrescriptions[indexPath.section];
    
    NSLog(@"Prescription Dict Is %@",PrescriptionDict);
    
    cell.orderNumber.text=PrescriptionDict[@"orderno"];
    cell.StoreName.text=PrescriptionDict[@"storename"];
    cell.AreaName.text=PrescriptionDict[@"area"];
    
    [cell.trackButton addTarget:self action:@selector(showTrackView:) forControlEvents:UIControlEventTouchUpInside];
    [cell.beforeCompleteTrackOrderButton addTarget:self action:@selector(showTrackView:) forControlEvents:UIControlEventTouchUpInside];
    [cell.PendingCancelOrdrBtn addTarget:self action:@selector(showcancelxibPending:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


-(void)showcancelxibPending:(UIButton *)sender {
    
    TableViewCell *cell = (TableViewCell *)[[sender superview] superview];
    
    if (![cell isKindOfClass:[TableViewCell class]]) {
        cell = (TableViewCell *)[[[sender superview] superview] superview];
    }
    
    //    if (!_isTrackTapped) {
    //        _isCancelTapped = !_isCancelTapped;
    
    _isCancelTouchesFromPending=!_isCancelTouchesFromPending;
    
    //        cell.beforeCompleteTrackOrderButton.alpha = 0.5;
    //        cell.cancelOrderButton.alpha = 1.0;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"IndexPath Section Is %ld",(long)indexPath.section);
    
    MyPrescriptionModel *model = _numberOfPrescriptions[indexPath.section];
   
    PrescriptionDict=_numberOfPrescriptions[indexPath.section];
    
    faaa=PrescriptionDict[@"id"];
    
    NSLog(@"My order 007 %@",model);
    
    
    _isCancelTouchesFromPending1 = _isCancelTouchesFromPending;
    
    CancelOrderNewView *cancelView = [[[NSBundle mainBundle] loadNibNamed:@"CancelOrderNewView" owner:self options:nil] firstObject];
    [cell.contentView addSubview:cancelView];
    
    
    cancelView.frame = CGRectMake(0, 240, self.view.frame.size.width, 101);
    
    [cancelView.selectReasonBtn addTarget:self action:@selector(showPendingReasonSheet:) forControlEvents:UIControlEventTouchUpInside];
    [cancelView.SubmitBtn addTarget:self action:@selector(CancelOrderPending:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tableView reloadData];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_cancelFlag==1)
    {
        return 150;
    }
    
    MyPrescriptionModel *model = _numberOfPrescriptions[indexPath.section];
    NSMutableDictionary *prescription1 = (NSMutableDictionary *)model;
    model=prescription1;
    
    if (_isCancelTouchesFromPending) {
                return 130+230;
            }
            else if (_isCancelTouchesFromPending1)
            {
                return 134+230;
            }
    else
    {
        return 250.f;
    }
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//             MyPrescriptionModel *model = _numberOfPrescriptions[section];
//           return model.createdOn;
    
    NSDictionary *l=_numberOfPrescriptions[section];
    NSLog(@"Getting Dict Parameter is %@",l);
    NSString *date=l[@"createdon"];
    return date;
    
}



-(void)tableView:(UITableView *)tableView willDisplayCell:(TableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
}

#pragma mark -  "PEnding"  ReasonTypeSheet........
-(void)showPendingReasonSheet:(UIButton *)sender
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Select Reason Type" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *namess = [self ReasonTypes];
    NSArray *idss   = [self ReasonTypeIDs];
    
    [namess enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [sender setTitle:action.title forState:UIControlStateNormal];
            _selectedreasonTypeId = idss[idx];
            
            
            
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


-(void)CancelOrderPending:(NSDictionary *)te
{
    NSIndexPath *indexPath;
    PrescriptionDict = _orders[indexPath.section];
    
    NSLog(@"Store Details Description Is %@",_numberOfPrescriptions[indexPath.section]);
    
    
    NSString *parameterString = [NSString stringWithFormat:@"orderid=%@&reasonid=%@",faaa,_selectedreasonTypeId.stringValue];
    
    NSLog(@"Parameter String Is %@",parameterString);
    
    NSString *url = [NSString stringWithFormat:@"http://192.168.1.199/NeediatorWebservice/NeediatorWS.asmx/cancelorder"];
    NSLog(@"URL is --> %@", url);
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.168.1.199/NeediatorWebservice/NeediatorWS.asmx/cancelorder"]];
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
            dispatch_async(dispatch_get_main_queue(),^{
                
                NSLog(@"%@",json);
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

            });
        }
    }];
    [task resume];
}



#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *collectionImages = _itemImagesPrescription[[(HorizontalCollectionView1 *)collectionView indexPath].section];
    
    return collectionImages.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomPrescriptionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyPrescriptionCollectionCellIdentifier" forIndexPath:indexPath];
    cell.tag    = indexPath.item;
    
    NSArray *collectionImagess = _itemImagesPrescription[[(HorizontalCollectionView1 *)collectionView indexPath].section];
    
    if (collectionImagess[indexPath.item] != nil) {
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", collectionImagess[indexPath.item]]];
        
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



-(void)showTrackView:(UIButton *)sender {
    
    TableViewCell *cell = (TableViewCell *)[[sender superview] superview];
    
    if (![cell isKindOfClass:[TableViewCell class]]) {
        cell = (TableViewCell *)[[[sender superview] superview] superview];
    }
    
    if (!_isCancelTapped) {
        
        cell.cancelOrderButton.alpha = 0.5;
        cell.beforeCompleteTrackOrderButton.alpha = 1.0;
        
        _isTrackTapped = !_isTrackTapped;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        MyPrescriptionModel *model = _orders[indexPath.section];
      //  model.isExpanded = _isTrackTapped;
        
        //        TrackPipelineView *trackView = [[[NSBundle mainBundle] loadNibNamed:@"TrackPipelineView" owner:self options:nil] firstObject];
        //        [trackView drawCurrentOrderState:model.orderState orderDateTime:model.completed_date withCode:model.statusCode.intValue];
        //        [cell.contentView addSubview:trackView];
        //        trackView.frame = CGRectMake(0, 230, self.view.frame.size.width, 186);
        
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

//-(void)showCancelView:(UIButton *)sender {
//    
//    TableViewCell *cell = (TableViewCell *)[[sender superview] superview];
//    
//    if (![cell isKindOfClass:[TableViewCell class]]) {
//        cell = (TableViewCell *)[[[sender superview] superview] superview];
//    }
//    
//    if (!_isTrackTapped) {
//        _isCancelTapped = !_isCancelTapped;
//        
//        cell.beforeCompleteTrackOrderButton.alpha = 0.5;
//        cell.cancelOrderButton.alpha = 1.0;
//        
//        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//        
//        MyPrescriptionModel *model = _orders[indexPath.section];
//        model.iscancelexpanded = _isCancelTapped;
//        
//        CancelOrderView *cancelView = [[[NSBundle mainBundle] loadNibNamed:@"CancelOrderView" owner:self options:nil] firstObject];
//        [cell.contentView addSubview:cancelView];
//        
//        cancelView.frame = CGRectMake(0, 230, self.view.frame.size.width, 134);
//        
//        
//        [self.tableView beginUpdates];
//        [self.tableView endUpdates];
//    }
//}






#pragma mark - UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

-(NSArray *)getimageForAllPrescription
{
    for (int i=0; i< _numberOfPrescriptions.count;i++) {
        
        NSMutableArray *imagesParticular = [NSMutableArray array];
        
        MyPrescriptionModel *model = _numberOfPrescriptions[i];
        NSArray *items;
        
       // NSDictionary *imageDict=_numberOfPrescriptions[i];
        
      //  items=[imageDict objectForKey:@"prelist"];
        
        NSMutableDictionary *prescription1 = (NSMutableDictionary *)model;
        
         items=prescription1[@"prelist"];
        
        
      //  [items addObject:prescription1];
        
        ////        if (model.isPrescription.boolValue) {
        ////            items = model.line_items;
        ////        }
        // //       else
        //            items = model.line_items;
        
        
        
        for (id item in items) {
            if ([item isKindOfClass:[PrescriptionLineItemsModel class]]) {
                
                PrescriptionLineItemsModel *modell = (PrescriptionLineItemsModel *)item;
                [imagesParticular addObject:modell.imageURL];
            }
            else {
                NSDictionary *prescription = (NSDictionary *)item;
                
                [imagesParticular addObject:prescription[@"image_url"]];
            }
        }
        
        [_itemImagesPrescription addObject:imagesParticular];
    }
    
    NSLog(@" Item Prescription Array Description --> %@", _itemImagesPrescription);
    return _itemImagesPrescription;
}


#pragma mark - Formatted Date.

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
-(void)showHUD {
    self.hud = [[NeediatorHUD alloc] initWithFrame:self.tableView.frame];
    self.hud.overlayColor = [NeediatorUtitity blurredDefaultColor];
    [self.hud fadeInAnimated:YES];
    self.hud.hudCenter = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetHeight(self.view.bounds) / 2);
    [self.navigationController.view insertSubview:self.hud belowSubview:self.navigationController.navigationBar];
}
-(void)hideHUD {
    [self.hud fadeOutAnimated:YES];
    [self.hud removeFromSuperview];
    
}


@end
