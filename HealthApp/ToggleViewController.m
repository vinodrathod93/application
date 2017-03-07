//
//  ToggleViewController.m
//  Neediator
//
//  Created by Vinod Rathod on 04/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "ToggleViewController.h"
#import "ToggleTableViewCell.h"

@interface ToggleViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation ToggleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _toggleArray = @[
                     @{ @"name" : @"Open 24 Hours",
                        @"value": @1 },
                     @{ @"name" : @"Offers Available",
                        @"value": @0
                        },
                     @{ @"name" : @"Provides Delivery",
                        @"value" : @0
                        }
                     ];
    
    self.tableView.backgroundColor      =   [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableviewDatasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _toggleArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ToggleTableViewCell *cell   =   [tableView dequeueReusableCellWithIdentifier:@"toggleFilterCellIdentifer" forIndexPath:indexPath];
    
    NSDictionary *dictionary    =   _toggleArray[indexPath.row];
    
    BOOL toggleSwitchValue     =   [dictionary[@"value"] boolValue];
    
    cell.toggleLabel.text       =   dictionary[@"name"];
    [cell.toggleSwitch setOn: toggleSwitchValue];
    
    
    return cell;
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
