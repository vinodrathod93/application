//
//  ShowMyBookingsVC.m
//  Neediator
//
//  Created by adverto on 14/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "ShowMyBookingsVC.h"
#import "MyBookingCell.h"
#import "MyBookingModel.h"
#import "MyBookingResponseModel.h"
#import "MyBookingByStatus.h"


#import "APIManager.h"
#import "LineItemsModel.h"
#import "CancelOrderView.h"
#import <MWPhotoBrowser/MWPhoto.h>
#import "NeediatorPhotoBrowser.h"

#import "CancelOrderNewView.h"


@interface ShowMyBookingsVC ()
@property (nonatomic, strong)  NeediatorHUD *hud;


@end

@implementation ShowMyBookingsVC
{
    NSArray *_Bookings;
    NSArray *_statusArray;
    
    BOOL _isCancelTapped;
    BOOL _isTrackTapped;
    BOOL _HeightFlag;
    BOOL _PendingHeightFlag;
    
    NSString *selectedSegmentID;
    UIScrollView *scroll;
    
}

#pragma mark - View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self showHUD];
    [self HandleSegment];
    
    
    [[NAPIManager sharedManager] getMyBookingListingWithSuccess:^(MyBookingResponseModel *myOrdersModel) {
        [self hideHUD];
        NSLog(@"%@", myOrdersModel.Bookings);
        
        _Bookings = myOrdersModel.Bookings;
        _statusArray=myOrdersModel.Status;
        
        //     [self getimageForAllPrescription];
        
        selectedSegmentID=@"0";
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





#pragma mark - Segment Control....
-(void)HandleSegment
{
    [self.tableView reloadData];
    NSArray *itemArray = [NSArray arrayWithObjects: @"Pending", @"In process", @"Completed",@"Cancelled", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray]; //provide array of segment names
    segmentedControl.tintColor=[UIColor blackColor];
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
    scroll.showsHorizontalScrollIndicator = NO; //disable horizontal scroll
    scroll.showsVerticalScrollIndicator = NO; //disable vertical scroll
    scroll.bounces=NO;
    [segmentedControl addTarget:self action:@selector(SegmentChanged:) forControlEvents:UIControlEventValueChanged];
    [scroll addSubview:segmentedControl]; // add segment
    scroll.contentSize = CGSizeMake(segmentedControl.frame.size.width, segmentedControl.frame.size.height); //change accordingly
    [self.view addSubview:scroll]; //add scroll view
    
}


#pragma mark - Segment Changed.
-(void)SegmentChanged:(UISegmentedControl *)sender
{
    NSLog(@"Segment Selected");
    
    if (sender.selectedSegmentIndex == 0)
    {
        selectedSegmentID=[NSString stringWithFormat:@"%ld",(long)sender.selectedSegmentIndex];
        
        [[NAPIManager sharedManager] getMyBookingListingWithSuccess:^(MyBookingResponseModel *myOrdersModel) {
            [self hideHUD];
            NSLog(@"%@", myOrdersModel.Bookings);
            
            _Bookings = myOrdersModel.Bookings;
            _statusArray=myOrdersModel.Status;
            
            [self.tableView reloadData];
            
        } failure:^(NSError *error) {
            [self hideHUD];
            UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertError show];
        }];
    }
    
    if (sender.selectedSegmentIndex == 1)
    {
        
        selectedSegmentID=[NSString stringWithFormat:@"%ld",(long)sender.selectedSegmentIndex];
        User *user  = [User savedUser];
        
        
        MyBookingByStatus *requestModel = [MyBookingByStatus new];
        requestModel.userid=user.userID;
        requestModel.status=@"14";
        
        [[NAPIManager sharedManager] getMyBookingListingByStatus:requestModel success:^(MyBookingResponseModel *response)
         {
             
             NSLog(@" Index 2 Is Selected %@", response.Bookings);
             
             _Bookings = response.Bookings;
             _statusArray=response.Status;
             
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
        selectedSegmentID=[NSString stringWithFormat:@"%ld",(long)sender.selectedSegmentIndex];
        MyBookingByStatus *requestModel = [MyBookingByStatus new];
        User *user  = [User savedUser];
        
        requestModel.userid=user.userID;
        requestModel.status=@"15";
        
        [[NAPIManager sharedManager] getMyBookingListingByStatus:requestModel success:^(MyBookingResponseModel *response)
         {
             
             NSLog(@" Index 2 Is Selected %@", response.Bookings);
             
             _Bookings = response.Bookings;
             _statusArray=response.Status;
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
        
        selectedSegmentID=[NSString stringWithFormat:@"%ld",(long)sender.selectedSegmentIndex];
        NSLog(@"Selected Segment ID is %@",selectedSegmentID);
        
        User *user  = [User savedUser];
        MyBookingByStatus *requestModel = [MyBookingByStatus new];
        requestModel.userid=user.userID;
        requestModel.status=@"16";
        
        [[NAPIManager sharedManager] getMyBookingListingByStatus:requestModel success:^(MyBookingResponseModel *response)
         {
             
             NSLog(@" Index 2 Is Selected %@", response.Bookings);
             
             _Bookings = response.Bookings;
             _statusArray=response.Status;
             [self hideHUD];
             [self.tableView reloadData];
         } failure:^(NSError *error)
         {
             [self hideHUD];
             NSLog(@"Error: %@", error.localizedDescription);
         }];
    }
}



#pragma mark - Table View Datasource & Delegates.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return _Bookings.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyBookingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"bookcell" forIndexPath:indexPath];
    
    MyBookingModel *model = _Bookings[indexPath.section];
    
    if (!cell) {
        cell = [[MyBookingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bookcell"];
    }
    
   
    cell.DoctorName.text = model.Name;
    cell.ReferenceNo.text = model.BookingNo;
    cell.DoctorArea.text = model.Area;
    cell.DateLbl.text=model.Date;
    cell.Statuslabel.text=model.Status;
    cell.AppointmentLbl.text=model.PurposeType;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    
    if([selectedSegmentID isEqualToString:@"0"])
    {
        _HeightFlag=NO;

        NSLog(@"Selected Segment ID is %@",selectedSegmentID);
        //cell.cancelOrderButton.hidden=YES;
        cell.beforeCompleteOptionView.hidden=NO;
        
        cell.BeforeViewConstraintOutlet.constant=-20;
        cell.Statuslabel.hidden=YES;
        cell.stlabel.hidden=YES;
        cell.ShowInfo.hidden=YES;
        [cell.cancelOrderButton addTarget:self action:@selector(showCancelViewOFBooking:) forControlEvents:UIControlEventTouchUpInside];

    }
    
    if([selectedSegmentID isEqualToString:@"1"])
    {
        _HeightFlag=NO;
        

        cell.beforeCompleteOptionView.hidden=NO;
        cell.Statuslabel.hidden=NO;
        cell.stlabel.hidden=NO;
        
        cell.BeforeViewConstraintOutlet.constant=3;
        [cell.cancelOrderButton addTarget:self action:@selector(showCancelViewOFBooking:) forControlEvents:UIControlEventTouchUpInside];


    }
    
    if([selectedSegmentID isEqualToString:@"2"])
    {
        _HeightFlag=YES;
        cell.beforeCompleteOptionView.hidden=YES;
        cell.ShowInfo.hidden=NO;
        cell.BeforeViewConstraintOutlet.constant=-20;
        cell.stlabel.hidden=YES;
        
    }

    if([selectedSegmentID isEqualToString:@"3"])
    {
         _HeightFlag=YES;
        cell.beforeCompleteOptionView.hidden=YES;
        cell.ShowInfo.hidden=YES;

        cell.BeforeViewConstraintOutlet.constant=-20;
    }

    
//        else
//    {
//        _HeightFlag=NO;
//        cell.Statuslabel.hidden=YES;
//        cell.ShowInfo.hidden=YES;
//        cell.beforeCompleteOptionView.hidden=NO;
//        [cell.cancelOrderButton addTarget:self action:@selector(showCancelViewOFBooking:) forControlEvents:UIControlEventTouchUpInside];
//    }
    
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_HeightFlag)
    {
        return 124;
    }
    else
    {
//        if (indexPath.section==0)
//        {
            _HeightFlag=NO;
            MyBookingModel *model = _Bookings[indexPath.section];
            if (model.isExpanded) {
                return 120+190;
            }
            else if (model.isCancelExpanded)
            {
                return 120+190;
            }
     //   }
    }
    return 192;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    MyBookingModel *model = _Bookings[section];
    return model.Date;
}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 0.01f;
//}



#pragma mark - Cell Button Actions.
-(void)showCancelViewOFBooking:(UIButton *)sender {
    
    MyBookingCell *cell = (MyBookingCell *)[[sender superview] superview];
    
    if (![cell isKindOfClass:[MyBookingCell class]]) {
        cell = (MyBookingCell *)[[[sender superview] superview] superview];
    }
    
    //    if (!_isTrackTapped)
    //    {
    _isCancelTapped = !_isCancelTapped;
    
//    cell.cancelOrderButton.alpha = 1.0;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    MyBookingModel *model = _Bookings[indexPath.section];
    model.isCancelExpanded = _isCancelTapped;
    
    CancelOrderNewView *cancelView = [[[NSBundle mainBundle] loadNibNamed:@"CancelOrderNewView" owner:self options:nil] firstObject];
    [cell.contentView addSubview:cancelView];
    
    cancelView.frame = CGRectMake(0, 200, self.view.frame.size.width, 90);
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    // }
}


#pragma mark - Helper Methods.
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
