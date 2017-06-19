//
//  NotificationViewController.m
//  Neediator
//
//  Created by adverto on 04/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationTableViewCell.h"

@interface NotificationViewController ()

@property (nonatomic, strong) NSMutableArray *notificationArray;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Nofitications";
    
    self.notificationArray  =   [[NSMutableArray alloc] initWithArray:@[
                                                                        @"Notification 1",
                                                                        @"Notification 1",
                                                                        @"Notification 1"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _notificationArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCellIdentifier" forIndexPath:indexPath];
    cell.selectionStyle =   UITableViewCellSelectionStyleNone;
    
    [cell.clearButton addTarget:self action:@selector(clearNotification:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


-(void)clearNotification:(UIButton *)button {
    
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];

    [self.notificationArray removeObjectAtIndex:indexPath.section];
    
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *header  =   [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 5)];
    header.backgroundColor  =   [UIColor clearColor];
    
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

@end
