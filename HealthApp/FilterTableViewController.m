//
//  FilterTableViewController.m
//  Neediator
//
//  Created by adverto on 19/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "FilterTableViewController.h"
#import "FilterDefaultViewCell.h"


@interface FilterTableViewController ()
{
    BOOL _isExpanded;
    BOOL _sliderCellTapped;
    NSMutableArray *_tempArray;
    NSIndexPath *lastSelectedIndexPath;
    NSMutableDictionary *_selectedIndexes;
    FilterDefaultViewCell *_mainTappedDefaultCell;
}
@end

@implementation FilterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"Refine";
    
    _tempArray = [[NSMutableArray alloc] init];
    [_tempArray addObjectsFromArray:_filterArray];
    
    
    _selectedIndexes = [[NSMutableDictionary alloc] init];
   
    
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
    
    
    if ([self.delegate respondsToSelector:@selector(appliedFilterListingDelegate:)]) {
        NSMutableDictionary *parameter = [[NSMutableDictionary alloc] init];
        
        
        for (FilterListModel *model in _filterArray) {
            [parameter setObject:@"" forKey:model.filterParameter];
        }
        
        NSLog(@"%@", _selectedIndexes);
        
        [_selectedIndexes enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull filterSection, NSNumber * _Nonnull selectedValues, BOOL * _Nonnull stop) {
            
            
            FilterListModel *model = _filterArray[filterSection.intValue];
            
            if ([model.type isEqualToString:@"Slider"]) {
                
                NSInteger index;
                
                if (selectedValues.integerValue > model.filterValues.count) {
                    index = 0;
                }
                else
                    index = selectedValues.integerValue;
                
                
                FilterHelperModel *options = model.filterValues[index];
                
                [parameter setObject:options.filterID forKey:model.filterParameter];
            }
            else if ([model.type isEqualToString:@"Switch"]) {
                
                FilterHelperModel *options = model.filterValues[selectedValues.integerValue];
                
                [parameter setObject:options.filterID forKey:model.filterParameter];
            }
            else {
                
                FilterHelperModel *options = model.filterValues[selectedValues.integerValue-1];
                
                [parameter setObject:options.filterID forKey:model.filterParameter];
                
            }
            
            
            
        }];
        
        
        NSLog(@"%@", parameter);
        
        [self.delegate appliedFilterListingDelegate:parameter];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

//    FilterListModel *model = _filterArray[section];
//    
//    if ([model.type isEqualToString:@"Slider"] || [model.type isEqualToString:@"Switch"]) {
//        return 1;
//    }
//    else
//        return model.filterValues.count;
    
    return _tempArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *defaultCellIdentifier = @"filterListCellIdentifier";
    static NSString *sliderCellIdentifier  = @"filterSliderCellIdentifier";
    static NSString *switchCellIdentifier  = @"filterSwitchCellIdentifier";

    NSString *cellIdentifier;
    
    id data = _tempArray[indexPath.row];
    
    
    if ([data isKindOfClass:[FilterListModel class]]) {
        FilterListModel *filter = (FilterListModel *)data;
        
        if ([filter.type isEqualToString:@"Slider"]) {
            cellIdentifier = sliderCellIdentifier;
        }
        else if ([filter.type isEqualToString:@"Switch"]) {
            cellIdentifier = switchCellIdentifier;
        }
        else
            cellIdentifier = defaultCellIdentifier;
    }
    else
        cellIdentifier = defaultCellIdentifier;
    
    
    
    id cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    
    
    if ([data isKindOfClass:[FilterListModel class]]) {
        
        FilterListModel *filter = (FilterListModel *)data;
        
        if ([filter.type isEqualToString:@"Slider"]) {
            [self configureSliderCell:cell withFilter:filter forIndexPath:indexPath];
        }
        else if ([filter.type isEqualToString:@"Switch"]) {
            [self configureSwitchCell:cell withFilter:filter forIndexPath:indexPath];
        }
        else {
            filter.canBeExpanded = YES;
            [self configureDefaultCell:cell withFilter:filter forIndexPath:indexPath];
        }
    }
    else {
        
        
        [self configureOptionsCell:cell withFilterValue:data forIndexPath:indexPath];
    }
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id allModel = _tempArray[indexPath.row];
    
    if ([allModel isKindOfClass:[FilterListModel class]]) {
        
        FilterListModel *model = (FilterListModel *)allModel;
        
        
        if ([model.type isEqualToString:@"Slider"] && _sliderCellTapped) {
            return 105.f;
        }
        else
            return 44.f;
    }
    else
        return 44.f;
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    id allModel = _tempArray[indexPath.row];
    
    FilterDefaultViewCell *selected_cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    if ([allModel isKindOfClass:[FilterListModel class]]) {
        
        FilterListModel *model = (FilterListModel *)allModel;
        
        if ([model.type isEqualToString:@"Slider"]) {
            // Slider
            
            _sliderCellTapped = !_sliderCellTapped;
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
            
        }
        else if ([model.type isEqualToString:@"Switch"]) {
            // Switch
        }
        else { // Default Cell
            
            _mainTappedDefaultCell = selected_cell;
            
            // Decorate according to selected or deselected.
            if (model.canBeExpanded) {
                if (model.isExpanded) {
                    [self collapseCellsFromIndexOf:model indexPath:indexPath tableView:tableView];
                    selected_cell.accessoryImageView.image = [self viewForDisclosureForState:NO];
                    
                }
                else {
                    [self expandCellsFromIndexOf:model indexPath:indexPath tableView:tableView];
                    selected_cell.accessoryImageView.image = [self viewForDisclosureForState:YES];
                    
                }
            }
            
            
        }
    }
    else {
        NSLog(@"Selected");
        
        FilterHelperModel *valueModel = (FilterHelperModel *)allModel;
        NSInteger filterIndex = [_filterArray indexOfObject:valueModel.filterModel];
        
        
        if (lastSelectedIndexPath) {
            [self deselectFilterOptionForTableview:tableView forIndexPath:lastSelectedIndexPath];
            
        }
        
        [self selectFilterOptionForTableview:tableView forIndexPath:indexPath];
        [_selectedIndexes setObject:valueModel.filterID forKey:@(filterIndex)];
        _mainTappedDefaultCell.defaultValue.text = valueModel.name;
        
        
        lastSelectedIndexPath = indexPath;
        
        
       
        NSLog(@"After Indexes %@", _selectedIndexes);
    }
 
}






#pragma mark - Custom Table View Cell

-(void)configureOptionsCell:(FilterDefaultViewCell *)cell withFilterValue:(FilterHelperModel *)model forIndexPath:(NSIndexPath *)indexPath {
    
    cell.defaultLabel.text = model.name;
    cell.defaultValue.text = nil;
    cell.accessoryImageView.image = nil;
    
    if (model.filterModel.isExpanded) {
        cell.leadingDefaultLabelConstraint.constant = 30.f;
    }
    
//    NSNumber *filterID = [_selectedIndexes objectForKey:@([_filterArray indexOfObject:model.filterModel])];
//    
//    
//    if (model.filterModel.isExpanded) {
//        if (filterID != nil) {
//            [self selectFilterOptionForTableview:self.tableView forIndexPath:indexPath];
//        }
//        else
//            [self deselectFilterOptionForTableview:self.tableView forIndexPath:indexPath];
//    }
    
    
    
    
}


-(void)configureSliderCell:(FilterSliderViewCell *)cell withFilter:(FilterListModel *)filter forIndexPath:(NSIndexPath *)indexPath {
    
    cell.filterName.text = filter.filterName;
    cell.sliderDelegate = self;
    cell.slider.minimumValue = 0.f;
    cell.slider.maximumValue = 5.f;
    
    
    NSNumber *value = [_selectedIndexes objectForKey:@([_filterArray indexOfObject:filter])];
    
    if(value) {
        [cell.slider setValue:value.integerValue]; //set the slider value
        [cell.sliderValue setText:[NSString stringWithFormat:@"%ld",(long)value.integerValue]];
    }
    else {
        [cell.slider setValue:(NSInteger)0];
        [cell.sliderValue setText:@"0"];
    }
}



-(void)configureSwitchCell:(FilterSwitchViewCell *)cell withFilter:(FilterListModel *)filter forIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger filterIndex = [_filterArray indexOfObject:filter];
    
    cell.filterName.text = filter.filterName;
    cell.filterSwitch.tag = filterIndex;
    [cell.filterSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    NSNumber *value = [_selectedIndexes objectForKey:@(filterIndex)];
    [cell.filterSwitch setOn:value.boolValue animated:YES];
}

-(void)switchValueChanged:(UISwitch *)sender {
    
    
    [_selectedIndexes setObject:@([sender isOn]) forKey:@(sender.tag)];
}

-(void)configureDefaultCell:(FilterDefaultViewCell *)cell withFilter:(FilterListModel *)filter forIndexPath:(NSIndexPath *)indexPath {
    
    
//    FilterHelperModel *filterValue = filter.filterValues[indexPath.row];
    
    
    cell.defaultLabel.text = filter.filterName;
    
    NSNumber *filterID = [_selectedIndexes objectForKey:@([_filterArray indexOfObject:filter])];
    
    if (filterID != nil) {
        for (FilterHelperModel *valueModel in filter.filterValues) {
            if ([valueModel.filterID isEqual:filterID]) {
                cell.defaultValue.text = valueModel.name;
            }
            else
                cell.defaultValue.text = @"";
        }
    }
    else
        cell.defaultValue.text = @"";
    
    
//    NSIndexPath *selectedIndexPath = [_selectedIndexes objectForKey:@(indexPath.section)];
//    
//    if (selectedIndexPath != nil) {
//        if (selectedIndexPath.section == indexPath.section && selectedIndexPath.row == indexPath.row) {
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        }
//        else
//            cell.accessoryType = UITableViewCellAccessoryNone;
//    }
//    else
//        cell.accessoryType = UITableViewCellAccessoryNone;
}



#pragma mark - Select - Deselect Method



-(void)deselectFilterOptionForTableview:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *unSelectCell = [tableView cellForRowAtIndexPath:indexPath];
    unSelectCell.accessoryType = UITableViewCellAccessoryNone;
}

-(void)selectFilterOptionForTableview:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
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
                     withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
}



-(void)expandCellsFromIndexOf:(FilterListModel *)model indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    
    NSLog(@"expandCellsFromIndexOf");
    
    if (model.filterValues.count > 0) {
        model.isExpanded = YES;
        
        int i=0;
        
        for (FilterHelperModel *valuesModel in model.filterValues) {
            // To know who is the parent filter.
            valuesModel.filterModel = model;
            
            NSLog(@"Inserting at index %ld", indexPath.row + i + 1);
            [_tempArray insertObject:valuesModel atIndex:indexPath.row + i + 1];
            i++;
        }
        
        NSRange expandedRange = NSMakeRange(indexPath.row, i);
        
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (int i=0; i< expandedRange.length; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:expandedRange.location + i + 1 inSection:indexPath.section]];
            NSLog(@"Adding at index %lu", expandedRange.location + i + 1);
        }
        
        for (NSIndexPath *indexpath in indexPaths) {
            NSLog(@"%ld, %ld", (long)indexpath.section, (long)indexpath.row);
        }
        
        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
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

-(UIImage *) viewForDisclosureForState:(BOOL) isExpanded
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
    
    
    return [UIImage imageNamed:imageName];
}


#pragma mark - Slider Delegate Method

-(void)sliderChanged:(FilterSliderViewCell *)cell {
    NSIndexPath *path = [self.tableView indexPathForCell:cell]; //get the indexpath
    if(path)//check if valid path
    {
        int value = cell.slider.value;
        
        
        NSString *filterName = cell.filterName.text;
        
        
        for (FilterListModel *model in _filterArray) {
            if ([model.filterName isEqualToString:filterName]) {
                [_selectedIndexes setObject:[NSNumber numberWithInt:value] forKey:@([_filterArray indexOfObject:model])];
            }
        }
        
        
        
        NSLog(@"%d", value);
    }
}


@end
