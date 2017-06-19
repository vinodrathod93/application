//
//  TypeSendViewController.m
//  Neediator
//
//  Created by Vinod Rathod on 20/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "TypeSendViewController.h"
#import "TypeSendTableViewCell.h"

@interface TypeSendViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSInteger orderCount;

@end

@implementation TypeSendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title      =   @"Order";
    
    _orderCount     =   1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _orderCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TypeSendTableViewCell *cell =   [tableView dequeueReusableCellWithIdentifier:@"typeSendCellIdentifier" forIndexPath:indexPath];
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView  =   [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 40)];
    
    
    
    UIButton *addButton =   [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
    addButton.layer.cornerRadius    =   25/2;
    addButton.layer.masksToBounds   =   YES;
    [addButton setBackgroundColor:[UIColor blackColor]];
    
    [addButton setTitle:@"+" forState:UIControlStateNormal];
    [addButton.titleLabel setFont:boldFont(22)];
    [addButton addTarget:self action:@selector(addNewCell:) forControlEvents:UIControlEventTouchUpInside];
    addButton.tag   =   section;
    
    [footerView addSubview:addButton];
    
    return footerView;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView  =   [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 30)];
    
    UILabel *title      =   [[UILabel alloc] initWithFrame:CGRectMake(10, 10, MAIN_WIDTH/2, 10)];
    title.text          =   [NSString stringWithFormat:@"ITEM %ld", (long)section + 1];
    title.font          =   regularFont(12);
    
    UIButton *close     =   [[UIButton alloc] initWithFrame:CGRectMake(MAIN_WIDTH - 100, 10, 100, 10)];
    [close setTitle:@"Remove" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [close.titleLabel setFont:regularFont(12)];
    [close.titleLabel setTextAlignment:NSTextAlignmentRight];
    close.tag   =   section;
    [close addTarget:self action:@selector(removeCell:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [headerView addSubview:title];
    
    if (section != 0) {
        [headerView addSubview:close];
    }
    
    
    return headerView;
}


-(void)addNewCell:(UIButton *)button {
    
    [self.view endEditing:YES];
    
    TypeSendTableViewCell *cell =   [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:button.tag]];
    
    if ([self validateOrderCell:cell]) {
        _orderCount += 1;
        
        [self.tableView beginUpdates];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:_orderCount-1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    
    
    
    
}


-(void)removeCell:(UIButton *)button {

    [self.view endEditing:YES];
    
    _orderCount -= 1;
    
    [self.tableView beginUpdates];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:_orderCount] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}


-(BOOL)validateOrderCell:(TypeSendTableViewCell *)cell {
    
    BOOL isValidated = NO;
    
    if (isValid(cell.productNameTF.text) && ![cell.productNameTF.text  isEqual: @""]) {
        isValidated =  YES;
    }
    else if (isValid(cell.productDescription.text) && ![cell.productDescription.text  isEqual: @""]) {
        isValidated =   YES;
    }
    else if (isValid(cell.featureDescription.text) && ![cell.featureDescription.text  isEqual: @""]) {
        isValidated =   YES;
    }
    else if (isValid(cell.quantityTF.text) && ![cell.quantityTF.text  isEqual: @""]) {
        isValidated =   YES;
    }
    else
        isValidated =   NO;
    
    
        return isValidated;
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
