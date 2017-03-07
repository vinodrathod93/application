//
//  AreaFilterViewController.m
//  Neediator
//
//  Created by Vinod Rathod on 04/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "AreaFilterViewController.h"

@interface AreaFilterViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation AreaFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.allowsMultipleSelection  =   YES;
    
    
    _areas = @[
               @"Dadar", @"Prabhadevi", @"Parel", @"Matunga",@"Worli", @"Bandra", @"Marine\nLines"
               ];
    
    
    self.tableView.estimatedRowHeight   =   100;
    self.tableView.rowHeight            =   UITableViewAutomaticDimension;
    self.tableView.backgroundColor      =   [UIColor whiteColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _areas.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell   =   [tableView dequeueReusableCellWithIdentifier:@"areaFilterCellIdentifier" forIndexPath:indexPath];
    
    cell.textLabel.font     =   regularFont(15);
    cell.textLabel.text     =   _areas[indexPath.row];
    cell.selectionStyle     =   UITableViewCellSelectionStyleNone;
    
    
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell   =   [tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType      =   UITableViewCellAccessoryCheckmark;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell   =   [tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType      =   UITableViewCellAccessoryNone;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5f;
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
