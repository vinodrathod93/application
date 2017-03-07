//
//  FilterViewController.m
//  Neediator
//
//  Created by Vinod Rathod on 03/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "FilterViewController.h"
#import "ToggleViewController.h"
#import "AreaFilterViewController.h"
#import "WorkingHoursViewController.h"
#import "OptionsViewController.h"

@interface FilterViewController ()<UITableViewDelegate, UITableViewDataSource, ToggleFilterDelegate, AreaFilterDelegate, WorkingHoursDelegate>


{
    NSArray *filterOptionsArray;
}
@property (weak, nonatomic) IBOutlet UITableView *filterOptionTableview;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;



@end

@implementation FilterViewController

- (void)viewDidLoad {
    
    UIStoryboard *storeStoryboard  =   [UIStoryboard storyboardWithName:@"StoreStoryboard" bundle:nil];
    ToggleViewController *toggleVC  =   [storeStoryboard instantiateViewControllerWithIdentifier:@"toggleFilterVC"];
    toggleVC.delegate               =   self;
    
    [self addChild:toggleVC];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.filterOptionTableview.delegate = self;
    self.filterOptionTableview.dataSource   =   self;
    
    filterOptionsArray      =   @[
                                  @"Toggles",
                                  @"Area",
                                  @"Working\nHours",
                                  @"Rating",
                                  @"Min. Delivery\nAmount"
                                  ];
    
    
    self.filterOptionTableview.estimatedRowHeight   =   100;
    self.filterOptionTableview.rowHeight            =   UITableViewAutomaticDimension;
    
    [self.filterOptionTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    [self.applyButton addTarget:self action:@selector(applyTapped:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)applyTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableviewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return filterOptionsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell   =   [tableView dequeueReusableCellWithIdentifier:@"filterOptionsCellIdentifier" forIndexPath:indexPath];
    
    
    cell.detailTextLabel.text   =   @"";
    
    cell.textLabel.text             =   filterOptionsArray[indexPath.row];
    cell.textLabel.numberOfLines    =   0;
    cell.textLabel.textColor        =   [UIColor blackColor];
    cell.textLabel.font             =   mediumFont(15);
    cell.backgroundColor            =   [UIColor groupTableViewBackgroundColor];
    cell.selectionStyle             =   UITableViewCellSelectionStyleNone;
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell       =   [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor        =   [UIColor whiteColor];
    cell.textLabel.textColor    =   [UIColor blackColor];
    
    
    UIStoryboard *storeStoryboard  =   [UIStoryboard storyboardWithName:@"StoreStoryboard" bundle:nil];
    
    
    
    switch (indexPath.row) {
        case 0:
        {
            
            [self removeAllChilds];
            
            ToggleViewController *toggleVC  =   [storeStoryboard instantiateViewControllerWithIdentifier:@"toggleFilterVC"];
            
            [self addChild:toggleVC];
            
        }
            break;
            
        case 1: {
            
            [self removeAllChilds];
            
            
            AreaFilterViewController *areaFilterVC  =   [storeStoryboard instantiateViewControllerWithIdentifier:@"areaFilterVC"];
            
            [self addChild:areaFilterVC];
            
        }
            break;
            
        case 2: {
            
            [self removeAllChilds];
            
            WorkingHoursViewController *workingHoursVC  =   [storeStoryboard instantiateViewControllerWithIdentifier:@"workingHoursFilterVC"];
            
            [self addChild:workingHoursVC];
            
        }
            break;
            
            
        case 3: {
            
            [self removeAllChilds];
            
            OptionsViewController *optionsVC    =   [storeStoryboard instantiateViewControllerWithIdentifier:@"optionsFilterVC"];
            
            optionsVC.isRating      =   YES;
            
            [self addChild:optionsVC];
        }
            break;
            
        case 4: {
            
            
            [self removeAllChilds];
            
            OptionsViewController *optionsVC    =   [storeStoryboard instantiateViewControllerWithIdentifier:@"optionsFilterVC"];
            
            optionsVC.isRating      =   NO;
            
            [self addChild:optionsVC];
        }
            break;
            
        default: {
            
            NSLog(@"%@", self.childViewControllers);
            
            
            [self removeAllChilds];
            
        }
            break;
    }
}



-(void)removeAllChilds {
    
    for (UIViewController *viewcontroller in self.childViewControllers) {
        [viewcontroller willMoveToParentViewController:nil];
        [viewcontroller.view removeFromSuperview];
        
        [viewcontroller removeFromParentViewController];
        
    }
}


-(void)addChild:(UIViewController *)controller {
    
    [self addChildViewController:controller];
    
    controller.view.frame             =   CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    [self.containerView addSubview:controller.view];
    
    [controller didMoveToParentViewController:self];
}



-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell       =   [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor        =   [UIColor groupTableViewBackgroundColor];
    cell.textLabel.textColor    =   [UIColor blackColor];
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5;
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
