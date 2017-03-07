//
//  BookingViewController.m
//  Pods
//
//  Created by adverto on 25/01/16.
//
//

#import "BookingViewController.h"
#import "TimeSlotCollectionViewCell.h"
#import "TimeSlotModel.h"
#import "BookConfirmViewController.h"


@implementation BookingViewController {
    NSURLSessionDataTask *_task;
    NSArray *_complete_timeSlots;
    NSDictionary *_day_timeSlots;
    NSArray *_sortedTimes;
    MBProgressHUD *_hud;
    UIView *_dimView;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"SELECT TIME SLOT";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.calendar addTarget:self action:@selector(updateSelectedDate:) forControlEvents:UIControlEventValueChanged];
//    [self.calendar fillDatesFromDate:[NSDate date] numberOfDays:7];
    
    NSLog(@"%@", self.calendar.dates);
    NSLog(@"Current date %@", [NSDate date]);
    [self.calendar selectDate:[NSDate date]];
    
    
    NSDictionary *parameter = @{
                                @"StoreId" : self.entity_id,
                                @"Sectionid" : self.category_id
                                };
    
    NSLog(@"Request Parameter %@", parameter);
    
    
    
    [self showHUD];
    
    _task = [[NAPIManager sharedManager]getTimeSlotsWithRequest:parameter success:^(TimeSlotResponseModel *response)
    {
        _complete_timeSlots = response.timeSlots;
        
        TimeSlotModel *model = [_complete_timeSlots firstObject];
        _day_timeSlots      = model.timeSlot;
        
        self.metaInfo.text  = response.categoryName;
        
        [self hideHUD];
        
        [self.collectionView reloadData];
        
    } failure:^(NSError *error) {
        
        [self hideHUD];
        
        NSLog(@"Error %@", error.localizedDescription);
    }];
    
    
    
    self.name.text = self.entity_name;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
    
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:self.image_url]];

}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TimeSlotCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"timeSlotCellIdentifier" forIndexPath:indexPath];
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObjectsFromArray:[_day_timeSlots allValues]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    
    _sortedTimes = [values sortedArrayUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString  *_Nonnull obj2) {
        NSDate *date1 = [dateFormatter dateFromString:obj1];
        NSDate *date2 = [dateFormatter dateFromString:obj2];
        return [date1 compare:date2];
    }];
    
    cell.timeLabel.text = _sortedTimes[indexPath.item];

    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _day_timeSlots.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *keys   = [_day_timeSlots allKeysForObject:_sortedTimes[indexPath.item]];
    NSString *time_key = [keys lastObject];
    
    NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
    [inFormat setDateFormat:@"MMM dd, yyyy"];
    
    
    BookConfirmViewController *bookConfirmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"bookConfirmVC"];
    bookConfirmVC.cat_id = self.category_id;
    bookConfirmVC.entity_id = self.entity_id;
    bookConfirmVC.entity_name = self.entity_name;
    bookConfirmVC.image_url = self.image_url;
    bookConfirmVC.entity_meta_string = self.metaInfo.text;
    bookConfirmVC.timeSlot_id = time_key;
    bookConfirmVC.date      = [inFormat stringFromDate:self.calendar.selectedDate];
    bookConfirmVC.time      = _sortedTimes[indexPath.item];
    
    [self.navigationController pushViewController:bookConfirmVC animated:YES];
}


- (void)updateSelectedDate:(id)sender
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEEEddMMMM" options:0 locale:nil];
    NSDate *today = [NSDate date];
    
    
    [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay startDate:&today interval:NULL forDate:today];
    if ([self.calendar.selectedDate isEqual:today]) {
        self.selected_dateLabel.text = @"Today";
    }
    else
        self.selected_dateLabel.text = [formatter stringFromDate:self.calendar.selectedDate];
    
    
    [_complete_timeSlots enumerateObjectsUsingBlock:^(TimeSlotModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model.date isEqual:self.calendar.selectedDate]) {
            
            NSLog(@"Found");
            _day_timeSlots = model.timeSlot;
            [self.collectionView reloadData];
            
        }
    }];
    
}

-(void)showHUD
{
   
    _dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.view.frame.size.height - 64 - 44)];
    _dimView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_dimView];
    
    _hud = [MBProgressHUD showHUDAddedTo:_dimView animated:YES];
}

-(void)hideHUD
{
    [_hud hide:YES];
    
    [_dimView removeFromSuperview];
}

@end
