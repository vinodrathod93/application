//
//  TaxonsViewController.m
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "TaxonsViewController.h"
#import "APIManager.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface TaxonsViewController ()

@property (nonatomic, strong) NSArray *taxonomies;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation TaxonsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[APIManager sharedManager] getTaxonomiesWithSuccess:^(TaxonomyListResponseModel *responseModel) {
        self.taxonomies = responseModel.taxonomies;
        
        NSLog(@"%@",self.taxonomies);
        
        [self.tableView reloadData];
        [self hideHUD];
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

#pragma mark - RRNCollapsableTableView

-(NSString *)sectionHeaderNibName {
    return @"TaxonTaxonomyHeaderView";
}

//-(NSArray *)model {
//    return self.menu;
//}

-(UITableView *)collapsableTableView {
    return self.tableView;
}

#pragma mark - UITableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //id <RRNCollapsableSectionItemProtocol> mSection = self.menu[indexPath.section];
    //id item = mSection.items[indexPath.row];
    
    return [tableView dequeueReusableCellWithIdentifier:@"Cell"];
}

-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = self.tableView.tintColor;
}

-(void)hideHUD {
    [self.hud hide:YES];
}


@end
