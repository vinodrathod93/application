//
//  NewMyOrdersViewController.m
//  Neediator
//
//  Created by Vinod Rathod on 17/04/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "NewMyOrdersViewController.h"
#import "NewOrderTableViewCell.h"
#import "CancelOrderView.h"


typedef enum : NSUInteger {
    PendingHeight = 190,
    InProcessHeight = 235,
    CompletedHeight = 208,
    CancelledHeight = 190
} OrderStatusesRowHeight;


@interface NewMyOrdersViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISegmentedControl *orderSegments;
@property (weak, nonatomic) IBOutlet UITableView *orderTableview;

@property (nonatomic) BOOL expand;
@property (nonatomic) BOOL pendingCancelExpand;
@property (nonatomic) NSUInteger currentSegment;
@end

@implementation NewMyOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    _currentSegment     =   0;
    
    [_orderSegments addTarget:self action:@selector(segmentControlDidChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDatasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewOrderTableViewCell *cell =   [tableView dequeueReusableCellWithIdentifier:@"newMyOrdersCell" forIndexPath:indexPath];
    cell.selectionStyle         =   UITableViewCellSelectionStyleNone;
    
    
    cell.orderStage     =   _currentSegment;
    cell.expand         =   self.expand;        // later remove this expand variable and use it by data model variable
    
    cell.pendingCancelExpand    = self.pendingCancelExpand;
    
    cell.expandAction = ^(BOOL expand, NewOrderTableViewCell *cell) {
        
        self.expand =   expand;     //  later set the expand to the corresponding model expand variable
        
        [self.orderTableview beginUpdates];
        [self.orderTableview endUpdates];
    };
    
    cell.pendingCancelAction = ^(BOOL expand, NewOrderTableViewCell *cell) {
        
        self.pendingCancelExpand    =   expand;
        
        
        [self.orderTableview beginUpdates];
        [self.orderTableview endUpdates];
    };
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    
    switch (_currentSegment) {
            // later change the expand variable to model variable of the corresponding index.
        case 1: {
            return (self.expand) ? InProcessHeight + 150 : InProcessHeight;
        }
            break;
            
        case 2: {
            return (self.expand) ? CompletedHeight + 150 : CompletedHeight;
        }
            break;
            
        case 3: {
            return (self.expand) ? CancelledHeight + 150 : CancelledHeight;
        }
            break;
            
        default:
            return (self.expand && self.pendingCancelExpand) ? PendingHeight + 150 + 134 :
                    (self.expand) ?  PendingHeight + 150 :
                    (self.pendingCancelExpand) ? PendingHeight + 134 :
                    PendingHeight;
            break;
    }
    
    
}


#pragma mark - UISegmented Control

-(void)segmentControlDidChanged:(UISegmentedControl *)control {
    _currentSegment =   control.selectedSegmentIndex;
    self.expand     =   NO;
    
    [self.orderTableview reloadData];
}


#pragma mark - Action


@end
