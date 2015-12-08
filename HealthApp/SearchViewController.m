//
//  SearchViewController.m
//  Neediator
//
//  Created by adverto on 07/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()<UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, assign) BOOL isTapped;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeSearchController];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initializeSearchController {
    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.definesPresentationContext = YES;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellReuseId = @"SearchReuseCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellReuseId];
    
    if(cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellReuseId];
    }
    
    cell.textLabel.text = @"Locality...";
    
    return cell;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Category";
    }
    else
        return @"Stores";
    
}


#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchText = [self.searchController.searchBar text];
    
    if(![searchText length] > 0) {
        
        return;
    }
    
    
    
    
}

- (IBAction)nearByButtonPressed:(UIBarButtonItem *)sender {
    
    if (!self.isTapped) {
        self.isTapped = YES;
        
        [self.nearByButton setImage:[UIImage imageNamed:@"near_me_filled"]];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.navigationController.navigationItem.title = @"Current Location";
            
            
        } completion:^(BOOL finished) {
            NSLog(@"Finished");
        }];
        
        
    } else {
        self.isTapped = NO;
        
        [self.nearByButton setImage:[UIImage imageNamed:@"near_me"]];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.navigationController.navigationItem.title = @"Neediator";
        } completion:^(BOOL finished) {
            NSLog(@"Finished");
        }];
    }
    
    
    
}

@end
