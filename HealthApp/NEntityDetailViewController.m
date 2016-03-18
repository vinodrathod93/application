//
//  NEntityDetailViewController.m
//  Neediator
//
//  Created by adverto on 20/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "NEntityDetailViewController.h"
#import "EntityDetailModel.h"
#import "NEntityDetailCell.h"
#import "BookingViewController.h"

#define kHeight 44
#define kFooterHeight 50

@interface NEntityDetailViewController ()

@property (nonatomic, strong ) MBProgressHUD *hud;

@end

@implementation NEntityDetailViewController {
    NSMutableArray *_entityDescriptionArray;
    NSMutableDictionary *_selectedIndexes;
    NSURLSessionDataTask *_task;
    CGFloat _footerHeight;
    BOOL _hasLoaded;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _footerHeight = 0.0f;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _entityDescriptionArray = [NSMutableArray array];
    _selectedIndexes        = [[NSMutableDictionary alloc] init];
    
    
    if (!self.isStoreInfo) {
        NSDictionary *parameters = @{
                                     @"catid": self.cat_id,
                                     @"id"   : self.entity_id
                                     };
        
        [self showHUD];
        
        _task = [[NAPIManager sharedManager] getEntityDetailsWithRequest:parameters success:^(EntityDetailsResponseModel *response) {
            
            
            [_entityDescriptionArray addObjectsFromArray:response.details];
            _footerHeight   = kFooterHeight;
            _hasLoaded      = YES;
            
            [self hideHUD];
            [self.tableView reloadData];
            
        } failure:^(NSError *error) {
            [self hideHUD];
            NSLog(@"%@", error.localizedDescription);
            
            UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertError show];
            
        }];
    }
    else {
        _entityDescriptionArray = [NSMutableArray arrayWithArray:self.storeInfoArray];
    }
    
    
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%lu", (unsigned long)_entityDescriptionArray.count);
    
    return [_entityDescriptionArray count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"entityDescriptionCell";
    
    NSLog(@"%@", _selectedIndexes);
    
    [_selectedIndexes setObject:@1 forKey:indexPath];
    
    NEntityDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
        cell = [[NEntityDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    EntityDetailModel *model    = _entityDescriptionArray[indexPath.row];
    
    cell.titleLabel.text        = model.title.uppercaseString;
    cell.bodyLabel.text         = model.body;
    cell.accessoryView          = [self viewForDisclosureForState:[self cellIsSelected:indexPath]];
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    EntityDetailModel *model    = _entityDescriptionArray[indexPath.row];
    
    NSInteger height = [self findHeightForText:model.body havingWidth:self.view.frame.size.width andFont:[UIFont fontWithName:@"AvenirNext-Regular" size:15.f]].height;
    
    height = MAX(height, kHeight);
    
    if (![self cellIsSelected:indexPath]) {
        return kHeight + height;
    }
    
    return kHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Row: %ld,selected", (long)indexPath.row);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL isSelected = ![self cellIsSelected:indexPath];
    
    NSNumber *selectedIndex = [NSNumber numberWithBool:isSelected];
    [_selectedIndexes setObject:selectedIndex forKey:indexPath];
    
    NEntityDetailCell *cell = (NEntityDetailCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView      = [self viewForDisclosureForState:isSelected];
    
    
    [tableView beginUpdates];
    [tableView endUpdates];
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 130.f;
    }
    else
        return 0.f;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0 && self.isBooking == TRUE && _hasLoaded == TRUE) {
        return _footerHeight;
    }
    else
        return 0.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0 && self.isBooking == TRUE && _hasLoaded == TRUE) {
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), _footerHeight)];
        [button setBackgroundColor:[UIColor blackColor]];
        [button setTitle:@"MAKE APPOINTMENT" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(makeAppointmentTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:16.f]];
        [button.titleLabel setTextColor:[UIColor whiteColor]];
        
        return button;
    }
    else
        return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 130)];
        UIImageView *entityImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, headerView.frame.size.height/2 - 50, CGRectGetWidth(self.view.frame) - (2*20), 100)];
        entityImage.contentMode = UIViewContentModeScaleAspectFit;
        [entityImage sd_setImageWithURL:[NSURL URLWithString:self.entity_image]];
        entityImage.layer.cornerRadius = 5.f;
        entityImage.layer.borderColor = [UIColor blackColor].CGColor;
        entityImage.layer.borderWidth = 2.f;
        entityImage.layer.masksToBounds = YES;
        
        [headerView addSubview:entityImage];
        
        return headerView;
    }
    else
        return nil;
}


#pragma mark - Private Methods

-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    self.hud.color = self.tableView.tintColor;
}

-(void)hideHUD {
    [self.hud hide:YES];
}



-(UIView*) viewForDisclosureForState:(BOOL) isExpanded
{
    NSString *imageName;
    if(isExpanded)
    {
        imageName = @"Expand Arrow";
    }
    else
    {
        imageName = @"Collapse Arrow";
    }
    UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    [imgView setFrame:CGRectMake(0, 6, 15, 15)];
    [myView addSubview:imgView];
    return myView;
}




- (CGSize)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font {
    CGSize size = CGSizeZero;
    if (text) {
        //iOS 7
        CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font } context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height + 8.f);
    }
    return size;
}

-(BOOL)cellIsSelected:(NSIndexPath *)indexPath {
    NSNumber *selectedIndex     = [_selectedIndexes objectForKey:indexPath];
    
    return selectedIndex == nil ? FALSE : [selectedIndex boolValue];
}


-(void)makeAppointmentTapped:(UIButton *)button {
    NSLog(@"%ld", (long)button.tag);
    
    BookingViewController *bookingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"makeBookingVC"];
    bookingVC.category_id               = self.cat_id;
    bookingVC.entity_id                 = self.entity_id;
    bookingVC.entity_name               = self.entity_name;
    bookingVC.image_url                 = self.entity_image;
    
    [self.navigationController pushViewController:bookingVC animated:YES];
}

@end
