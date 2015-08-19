//
//  InputFormViewController.m
//  Chemist Plus
//
//  Created by adverto on 29/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "InputFormViewController.h"

@interface InputFormViewController ()

@end

NSString *const kName = @"name";
NSString *const kEmail = @"email";
NSString *const kPhone = @"phone";
NSString *const kAddress = @"address";
NSString *const kPassword = @"password";
NSString *const kCity = @"city";
NSString *const kState = @"state";


@implementation InputFormViewController


-(id) init {
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Text Fields"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    // Name Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Validation Required"];
    [formDescriptor addFormSection:section];
    
    // Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeText title:@"Name"];
    [row.cellConfigAtConfigure setObject:@"Required..." forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.required = YES;
    row.value = @"Martin";
    [section addFormRow:row];
    
    // Email Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Validation Email"];
    [formDescriptor addFormSection:section];
    
    // Email
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEmail rowType:XLFormRowDescriptorTypeText title:@"Email"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.required = NO;
    row.value = @"not valid email";
    [row addValidator:[XLFormValidator emailValidator]];
    [section addFormRow:row];
    
    // password Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Validation Password"];
    section.footerTitle = @"between 6 and 32 charachers, 1 alphanumeric and 1 numeric";
    [formDescriptor addFormSection:section];
    
    // Password
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPassword rowType:XLFormRowDescriptorTypePassword title:@"Password"];
    [row.cellConfigAtConfigure setObject:@"Required..." forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.required = YES;
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"At least 6, max 32 characters" regex:@"^(?=.*\\d)(?=.*[A-Za-z]).{6,32}$"]];
    [section addFormRow:row];
    
    // number Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Validation Numbers"];
    section.footerTitle = @"greater than 50 and less than 100";
    [formDescriptor addFormSection:section];
    
    // Integer
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhone rowType:XLFormRowDescriptorTypeInteger title:@"Integer"];
    [row.cellConfigAtConfigure setObject:@"Required..." forKey:@"textField.placeholder"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.required = YES;
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"greater than 50 and less than 100" regex:@"^([5-9][0-9]|100)$"]];
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
