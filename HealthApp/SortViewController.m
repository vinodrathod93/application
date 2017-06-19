//
//  SortViewController.m
//  Neediator
//
//  Created by Vinod Rathod on 20/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "SortViewController.h"
#import "SortTableViewCell.h"
#import "SortOrderModel.h"
#import "SortListModel.h"

@interface SortViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SortViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.title = @"Sort";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 
 if ([model.currentSortOrderIndex  isEqual: @-1]) {
 model.currentSortOrderIndex = @0;
 }
 
 
 SortOrderModel *sortOrderModel = model.typeArray[model.currentSortOrderIndex.intValue];
 
 NSString *code = [sortOrderModel.name substringFromIndex: [sortOrderModel.name length] - 1];
 
 NSLog(@"%@",code);
 
 //        NSString *name = [NSString stringWithFormat:@"%@ - %@", model.name.capitalizedString, sortOrderModel.name.capitalizedString];
 
 //displaying for asc and desc symbol in action sheet
 NSString *name = [NSString stringWithFormat:@"%@  %@", model.name.capitalizedString,code];
 
 UIAlertAction *typeAction = [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
 NSLog(@"Sort by %@", name);
 
 [self requestListingBySortID:model.sortID.stringValue andTypeID:sortOrderModel.sortOrderID.stringValue];
 
 int index = model.currentSortOrderIndex.intValue;
 
 if (++index == model.typeArray.count) {
 model.currentSortOrderIndex = 0;
 }
 else
 model.currentSortOrderIndex = @(index);
 
 }];
 
 */


#pragma mark - UITableViewDatasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sortListing.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SortTableViewCell *cell =   [tableView dequeueReusableCellWithIdentifier:@"sortTableViewCellIdentifier" forIndexPath:indexPath];
    
    
    SortListModel *model    =   self.sortListing[indexPath.row];
    
    
    
    switch (model.currentSortOrderIndex.intValue) {
        case 0:
        {
            cell.ascending.hidden   =   NO;
            cell.descending.hidden  =   NO;
            [cell.ascending setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [cell.descending setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
            break;
            
        case 1: {
            cell.ascending.hidden   =   NO;
            cell.descending.hidden  =   NO;
            [cell.ascending setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [cell.descending setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
            break;
            
        default: {
            cell.ascending.hidden   =   YES;
            cell.descending.hidden  =   YES;
        }
            break;
    }
    
    
    
    
    cell.sortLabel.text     =   model.name;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SortListModel *model        =   self.sortListing[indexPath.row];
    
    int index = model.currentSortOrderIndex.intValue;
    
    if (++index == model.typeArray.count) {
        model.currentSortOrderIndex = 0;
    }
    else
        model.currentSortOrderIndex = @(index);
    
    SortOrderModel *sortOrderModel = model.typeArray[model.currentSortOrderIndex.intValue];
    
    [self.delegate sortViewController:self didSelectSort:model withSortOrderModel:sortOrderModel];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

@end
