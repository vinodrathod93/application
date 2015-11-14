//
//  TaxonsViewController.m
//  Chemist Plus
//
//  Created by adverto on 14/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "TaxonsViewController.h"
#import "APIManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <SLExpandableTableView/SLExpandableTableView.h>

@interface SLExpandableTableViewControllerHeaderCell : UITableViewCell <UIExpandingTableViewCell>

@property (nonatomic, assign, getter = isLoading) BOOL loading;

@property (nonatomic, readonly) UIExpansionStyle expansionStyle;
- (void)setExpansionStyle:(UIExpansionStyle)expansionStyle animated:(BOOL)animated;

@end

@implementation SLExpandableTableViewControllerHeaderCell

- (NSString *)accessibilityLabel
{
    return self.textLabel.text;
}

- (void)setLoading:(BOOL)loading
{
    if (loading != _loading) {
        _loading = loading;
        [self _updateDetailTextLabel];
    }
}

- (void)setExpansionStyle:(UIExpansionStyle)expansionStyle animated:(BOOL)animated
{
    if (expansionStyle != _expansionStyle) {
        _expansionStyle = expansionStyle;
        [self _updateDetailTextLabel];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self _updateDetailTextLabel];
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

- (void)_updateDetailTextLabel
{
    if (self.isLoading) {
        self.detailTextLabel.text = @"Loading data";
    } else {
        switch (self.expansionStyle) {
            case UIExpansionStyleExpanded:
                self.detailTextLabel.text = @"Click to collapse";
                break;
            case UIExpansionStyleCollapsed:
                self.detailTextLabel.text = @"Click to expand";
                break;
        }
    }
}

@end

@interface TaxonsViewController ()

@property (nonatomic, strong) NSArray *taxonomies;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSMutableIndexSet *expandableSections;

@end

@implementation TaxonsViewController

#pragma mark - setters and getters

#pragma mark - Initialization


- (void)loadView
{
    SLExpandableTableView *tableView = [[SLExpandableTableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [tableView expandSection:0 animated:YES];
    self.view = tableView;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    _expandableSections = [NSMutableIndexSet indexSet];
    
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


#pragma mark - SLExpandableTableViewDatasource

- (BOOL)tableView:(SLExpandableTableView *)tableView canExpandSection:(NSInteger)section
{
    return YES;
}

- (BOOL)tableView:(SLExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section
{
    return ![self.expandableSections containsIndex:section];
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(SLExpandableTableView *)tableView expandingCellForSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"SLExpandableTableViewControllerHeaderCell";
    SLExpandableTableViewControllerHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[SLExpandableTableViewControllerHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.taxonomies[section] taxonomyName];
    
    return cell;
}


#pragma mark - SLExpandableTableViewDelegate

- (void)tableView:(SLExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section
{
    [self.expandableSections addIndex:section];
    [tableView expandSection:section animated:YES];
}

- (void)tableView:(SLExpandableTableView *)tableView didCollapseSection:(NSUInteger)section animated:(BOOL)animated
{
    [self.expandableSections removeIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return UITableViewAutomaticDimension;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.taxonomies.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TaxonomyModel *taxonomy = self.taxonomies[section];
    
    return taxonomy.taxons.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"taxonomiesCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray *taxons = [self.taxonomies[indexPath.section] taxons];
    
    if (taxons.count != 0) {
        TaxonModel *taxon = taxons[indexPath.row - 1];
        cell.textLabel.text = taxon.taxonName;
    }
    
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - Private Methods

-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = self.tableView.tintColor;
}

-(void)hideHUD {
    [self.hud hide:YES];
}


@end
