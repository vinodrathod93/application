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

#define kHeight 44

@interface NEntityDetailViewController ()

@property (nonatomic, strong ) MBProgressHUD *hud;

@end

@implementation NEntityDetailViewController {
    NSMutableArray *_entityDescriptionArray;
    NSMutableDictionary *_selectedIndexes;
    NSURLSessionDataTask *_task;
    NSInteger _selectedIndex;
    BOOL _selected;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _entityDescriptionArray = [NSMutableArray array];
    _selectedIndexes        = [[NSMutableDictionary alloc] init];
    
    NSDictionary *parameters = @{
                                 @"catid": self.cat_id,
                                 @"id"   : self.entity_id
                                 };
    
    [self showHUD];
    
    _task = [[NAPIManager sharedManager] getEntityDetailsWithRequest:parameters success:^(EntityDetailsResponseModel *response) {
        
        
        [_entityDescriptionArray addObjectsFromArray:response.details];
        
        [self hideHUD];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [self hideHUD];
        NSLog(@"%@", error.localizedDescription);
        
        UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertError show];
        
    }];
    
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
    
    NEntityDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
        cell = [[NEntityDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    EntityDetailModel *model    = _entityDescriptionArray[indexPath.row];
    
    cell.titleLabel.text        = model.title.uppercaseString;
    cell.bodyLabel.text         = model.body;
    cell.accessoryView          = [self viewForDisclosureForState:NO];
    
    
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    EntityDetailModel *model    = _entityDescriptionArray[indexPath.row];
    
    NSInteger height = [self findHeightForText:model.body havingWidth:self.view.frame.size.width andFont:[UIFont fontWithName:@"AvenirNext-Regular" size:15.f]].height;
    
    height = MAX(height, kHeight);
    
    if ([self cellIsSelected:indexPath]) {
        return kHeight + height;
    }
    
    return kHeight;
    
//    if (_selected && _selectedIndex == indexPath.row) {
//        return kHeight + height;
//    }
//    else if (_selectedIndex == indexPath.row)
//        return kHeight;
//    else
//        return kHeight;
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
    /*
    if ([_entityDescriptionArray[indexPath.row] isKindOfClass:[EntityDetailModel class]]) {
        EntityDetailModel *model = _entityDescriptionArray[indexPath.row];
        
        UITableViewCell *selected_cell = [tableView cellForRowAtIndexPath:indexPath];
        
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
        else {
            
            NSLog(@"Tapped Heyy");
            
        }

    }
    else
        NSLog(@"Could not proceed");
     
    */
    
    
//    if (_selected) {
//        _selected = NO;
//    }
//    else
//        _selected = YES;
//    
//    _selectedIndex = indexPath.row;
    
    [tableView beginUpdates];
    [tableView endUpdates];
    
    
}



/*

-(void)collapseCellsFromIndexOf:(EntityDetailModel *)model indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    
    NSInteger collapseCount = [self numberOfCellsToBeCollapsed:model];
    NSRange collapseRange   = NSMakeRange(indexPath.row + 1, collapseCount);
    
    [_entityDescriptionArray removeObjectsInRange:collapseRange];
    model.isExpanded    = NO;
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (int i = 0; i<collapseRange.length; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:collapseRange.location+i inSection:0]];
    }
    // Animate and delete
    [tableView deleteRowsAtIndexPaths:indexPaths
                     withRowAnimation:UITableViewRowAnimationLeft];
    
}



-(void)expandCellsFromIndexOf:(EntityDetailModel *)model indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    
    if (model.body != nil) {
        model.isExpanded = YES;
        
        [_entityDescriptionArray insertObject:model.body atIndex:indexPath.row + 1];
        
        NSRange expandedRange = NSMakeRange(indexPath.row, 1);
        
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (int i=0; i< expandedRange.length; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:expandedRange.location + i + 1 inSection:0]];
        }
        
        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


*/






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

/*
-(NSInteger) numberOfCellsToBeCollapsed:(EntityDetailModel *) model
{
    NSInteger total = 0;
    
    if(model.isExpanded)
    {
        // Set the expanded status to no
        model.isExpanded = NO;
        
        total = 1;
        
    }
    return total;
}
 */


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


@end
