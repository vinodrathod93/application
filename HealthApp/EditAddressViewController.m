//
//  EditAddressViewController.m
//  Neediator
//
//  Created by adverto on 26/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "EditAddressViewController.h"
#import "Order.h"


@implementation EditAddressViewController {
    NSMutableDictionary *_parameters;
    NSFetchedResultsController *_orderFetchedResultsController;
    Order *_orderModel;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    _parameters = [NSMutableDictionary dictionary];
    
    
    self.saveNContinueButton.layer.cornerRadius = 5.0f;
    self.firstNameTextField.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    
    self.firstNameTextField.text    = self.shipAddress[@"firstname"];
    self.lastNameTextField.text     = self.shipAddress[@"lastname"];
    self.address1TextField.text     = self.shipAddress[@"address1"];
    self.address2TextField.text     = self.shipAddress[@"address2"];
    self.phoneTextField.text        = self.shipAddress[@"phone"];
    self.pincodeTextField.text      = self.shipAddress[@"zipcode"];
    self.cityTextField.text         = self.shipAddress[@"city"];
    self.stateTextField.text        = [self.shipAddress valueForKeyPath:@"state.name"];
    self.countryTextField.text      = [self.shipAddress valueForKeyPath:@"country.name"];
    
    self.countryTextField.enabled   = NO;
    self.stateTextField.enabled     = NO;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}


- (IBAction)saveNContinueAction:(id)sender {
    
    
//    [APIManager sharedManager] putEditedAddressOfStore:<#(NSString *)#> andParameters:<#(NSDictionary *)#> WithSuccess:<#^(NSString *)success#> failure:<#^(NSError *)failure#>
    
}


-(void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.firstNameTextField])
        [_parameters setValue:textField.text forKey:@"firstname"];
    else if ([textField isEqual:self.lastNameTextField])
        [_parameters setValue:textField.text forKey:@"lastname"];
    else if ([textField isEqual:self.address1TextField])
        [_parameters setValue:textField.text forKey:@"address1"];
    else if ([textField isEqual:self.address2TextField])
        [_parameters setValue:textField.text forKey:@"address2"];
    else if ([textField isEqual:self.phoneTextField])
        [_parameters setValue:textField.text forKey:@"phone"];
    else if ([textField isEqual:self.pincodeTextField])
        [_parameters setValue:textField.text forKey:@"zipcode"];
    else if ([textField isEqual:self.cityTextField])
        [_parameters setValue:textField.text forKey:@"city"];
}


-(void)checkOrders {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    //    NSString *cacheName = @"cartOrderCache";
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.orderNumFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if(![self.orderNumFetchedResultsController performFetch:&error])
    {
        
        NSLog(@"Order Model Fetch Failure: %@",[error localizedDescription]);
    }
    
}


@end
