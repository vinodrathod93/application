//
//  WorkingHoursViewController.m
//  Neediator
//
//  Created by Vinod Rathod on 04/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "WorkingHoursViewController.h"

@interface WorkingHoursViewController ()
{
    UIDatePicker *fromTimePicker, *toTimePicker;
}
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UITextField *toTextField;
@end

@implementation WorkingHoursViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    fromTimePicker    =   [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 216)];
    fromTimePicker.datePickerMode   =   UIDatePickerModeTime;
    [fromTimePicker addTarget:self action:@selector(changedTime:) forControlEvents:UIControlEventValueChanged];
    
    
    toTimePicker    =   [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 216)];
    toTimePicker.datePickerMode   =   UIDatePickerModeTime;
    [toTimePicker addTarget:self action:@selector(changedTime:) forControlEvents:UIControlEventValueChanged];
    
    
    UIToolbar *toolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,44)];
    toolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissPicker)];
    
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpaceLeft, doneButton, nil]];

    
    _fromTextField.inputAccessoryView   =   toolbar;
    _toTextField.inputAccessoryView     =   toolbar;
    _fromTextField.inputView   =   fromTimePicker;
    _toTextField.inputView     =   toTimePicker;
    
}


-(void)dismissPicker {
    [self.view endEditing:YES];
}


-(void)changedTime:(UIDatePicker *)timePicker {
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateStyle:NSDateFormatterShortStyle];
    
    
    if ([timePicker isEqual:fromTimePicker]) {
        _fromTextField.text          =   [dateformatter stringFromDate:timePicker.date];
    }
    else
        _toTextField.text          =   [dateformatter stringFromDate:timePicker.date];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
