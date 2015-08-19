//
//  DoctorViewController.m
//  Chemist Plus
//
//  Created by adverto on 31/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "DoctorViewController.h"
#import "DoctorViewCell.h"
#import "DoctorDetailsViewController.h"

NSString *const CellIdentifier = @"doctorsCell";

@interface DoctorViewController ()

@end

@implementation DoctorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DoctorViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    
    return cell;
}


- (IBAction)bookButtonPressed:(id)sender {
    
    
    
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"doctorDetailsVC"]) {
        NSLog(@"Doctor DetailsVC");
    }
}


@end
