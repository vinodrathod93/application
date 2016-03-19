//
//  FilterTableViewController.m
//  Neediator
//
//  Created by adverto on 19/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "FilterTableViewController.h"
#import "FilterListModel.h"
#import "FilterHelperModel.h"

@interface FilterTableViewController ()
{
    BOOL _isExpanded;
    NSMutableArray *_tempArray;
    BOOL _isOptionSelected;
}
@end

@implementation FilterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"Filters";
    
    _tempArray = [[NSMutableArray alloc] init];
    [_tempArray addObjectsFromArray:_filterArray];
    
    UIButton *applyLabel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    applyLabel.titleLabel.font = [NeediatorUtitity mediumFontWithSize:15.f];
    applyLabel.backgroundColor = [UIColor clearColor];
    [applyLabel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [applyLabel setTitle:@"Apply" forState:UIControlStateNormal];
    [applyLabel addTarget:self action:@selector(applyTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithCustomView:applyLabel];
    self.navigationItem.rightBarButtonItem = applyButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)applyTapped:(UIBarButtonItem *)item {
    NSLog(@"Applying Filter...");
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _tempArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"filterListCellIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    
    
    
    
    cell.textLabel.font = [NeediatorUtitity regularFontWithSize:17.f];
    cell.indentationWidth = 20;
    
    
    
    
    
    if ([_tempArray[indexPath.row] isKindOfClass:[FilterListModel class]]) {
        
        FilterListModel *model = _tempArray[indexPath.row];
        
        if (model.filterValues.count > 0) {
            
            
            cell.textLabel.text = model.filterName;
            
            model.canBeExpanded = YES;
            cell.accessoryView  = [self viewForDisclosureForState:_isExpanded];
        }
        else {
            
            cell.accessoryView  = nil;
        }
    }
    else if ([_tempArray[indexPath.row] isKindOfClass:[FilterHelperModel class]]) {
        FilterHelperModel *valueModel = _tempArray[indexPath.row];
        
        cell.textLabel.text = valueModel.name;
        cell.indentationLevel = 1;
        
        if (valueModel.canBeExpanded) {
            cell.accessoryView = [self viewForDisclosureForState:_isExpanded];
        }
        else
            cell.accessoryView = nil;
        
    }
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    id allModel = _tempArray[indexPath.row];
    
    UITableViewCell *selected_cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    if ([allModel isKindOfClass:[FilterListModel class]]) {
        
        FilterListModel *model = (FilterListModel *)allModel;
        
        if (model.canBeExpanded) {
            if (model.isExpanded) {
                [self collapseCellsFromIndexOf:model indexPath:indexPath tableView:tableView];
                selected_cell.accessoryView = [self viewForDisclosureForState:NO];
            }
            else {
                [self expandCellsFromIndexOf:model indexPath:indexPath tableView:tableView];
                selected_cell.accessoryView = [self viewForDisclosureForState:YES];
            }
        }
    }
    else {
        NSLog(@"Selected");
        
//        selected_cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        if (_isOptionSelected) {
            [self deselectPaymentOptionForTableview:tableView forIndexPath:indexPath];

        }
        else {
            [self selectPaymentOptionForTableview:tableView forIndexPath:indexPath];

        }
    }
    
    
}


-(void)deselectPaymentOptionForTableview:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [_proceedPaymentOption setEnabled:NO];
//    _proceedPaymentOption.alpha = 0.5f;
    
    _isOptionSelected = NO;
    
    UITableViewCell *unSelectCell = [tableView cellForRowAtIndexPath:indexPath];
    unSelectCell.accessoryType = UITableViewCellAccessoryNone;
}

-(void)selectPaymentOptionForTableview:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [_proceedPaymentOption setEnabled:YES];
//    _proceedPaymentOption.alpha = 1.f;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    _isOptionSelected = YES;
}


-(UIView*) viewForDisclosureForState:(BOOL) isExpanded
{
    NSString *imageName;
    if(isExpanded)
    {
        imageName = @"Collapse Arrow";
    }
    else
    {
        imageName = @"Expand Arrow";
    }
    UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [imgView setFrame:CGRectMake(0, 6, 24, 24)];
    [myView addSubview:imgView];
    return myView;
}



#pragma mark - Collapse - Expand Methods

-(void)collapseCellsFromIndexOf:(FilterListModel *)model indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    NSLog(@"collapseCellsFromIndexOf");
    
    NSInteger collapseCount = [self numberOfCellsToBeCollapsed:model];
    NSRange collapseRange = NSMakeRange(indexPath.row + 1, collapseCount);
    
    
    [_tempArray removeObjectsInRange:collapseRange];
    model.isExpanded = NO;
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (int i = 0; i<collapseRange.length; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:collapseRange.location+i inSection:indexPath.section]];
    }
    // Animate and delete
    [tableView deleteRowsAtIndexPaths:indexPaths
                     withRowAnimation:UITableViewRowAnimationTop];
    
    
}



-(void)expandCellsFromIndexOf:(FilterListModel *)model indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    
    NSLog(@"expandCellsFromIndexOf");
    
    if (model.filterValues.count > 0) {
        model.isExpanded = YES;
        
        int i=0;
        
        for (FilterHelperModel *valuesModel in model.filterValues) {
            
            NSLog(@"Inserting at index %ld", indexPath.row + i + 1);
            [_tempArray insertObject:valuesModel atIndex:indexPath.row + i + 1];
            i++;
        }
        
        NSRange expandedRange = NSMakeRange(indexPath.row, i);
        
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (int i=0; i< expandedRange.length; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:expandedRange.location + i + 1 inSection:indexPath.section]];
            NSLog(@"Adding at index %ld", expandedRange.location + i + 1);
        }
        
        for (NSIndexPath *indexpath in indexPaths) {
            NSLog(@"%ld, %ld", (long)indexpath.section, (long)indexpath.row);
        }
        
        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        
        [tableView scrollToRowAtIndexPath:indexPaths[0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    
}




-(NSInteger) numberOfCellsToBeCollapsed:(FilterListModel *) model
{
    
    NSLog(@"numberOfCellsToBeCollapsed");
    
    NSInteger total = 0;
    
    if(model.isExpanded)
    {
        // Set the expanded status to no
        model.isExpanded = NO;
        NSArray *child = model.filterValues;
        
        total = child.count;
        
    }
    return total;
}
@end
