//
//  NEntityDetailViewController.m
//  Neediator
//
//  Created by adverto on 20/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "NEntityDetailViewController.h"
#import "EntityDetailModel.h"

@interface NEntityDetailViewController ()

@property (nonatomic, strong ) MBProgressHUD *hud;

@end

@implementation NEntityDetailViewController {
    NSMutableArray *_entityDescriptionArray;
    NSArray *_contentArray;
    NSURLSessionDataTask *_task;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _entityDescriptionArray = [NSMutableArray array];
    
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    
    
    
    
    
    
    
    
    
    
    if ([_entityDescriptionArray[indexPath.row] isKindOfClass:[EntityDetailModel class]]) {
        
        EntityDetailModel *model    = _entityDescriptionArray[indexPath.row];
        
        cell.textLabel.text         = model.title.uppercaseString;
        cell.textLabel.font   = [UIFont fontWithName:@"AvenirNext-Medium" size:15.f];
        cell.indentationWidth = 20;
        
        if (model.body != nil) {
            model.canBeExpanded = YES;
            cell.accessoryView  = [self viewForDisclosureForState:NO];
        }
        else
            cell.accessoryView  = nil;
    }
    else {
        NSString *body          = _entityDescriptionArray[indexPath.row];
        
        cell.textLabel.text     = body;
        cell.textLabel.textColor    = [UIColor darkGrayColor];
        cell.textLabel.font   = [UIFont fontWithName:@"AvenirNext-Regular" size:13.f];
        
    }
    
    
    
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Row: %ld,selected", (long)indexPath.row);
    
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
    
    
}




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
    UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [imgView setFrame:CGRectMake(0, 6, 24, 24)];
    [myView addSubview:imgView];
    return myView;
}


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



@end
