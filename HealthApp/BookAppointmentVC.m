//
//  BookAppointmentVC.m
//  Neediator
//
//  Created by adverto on 29/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "BookAppointmentVC.h"
#import "NTextField.h"
#import "BookConfirmNewVC.h"
#import "UploadPrescriptionViewController.h"


@interface BookAppointmentVC ()

@end

@implementation BookAppointmentVC
{
    UIDatePicker *_dateTimePicker;
    NSNumber     *_selectedPurposeTypeID;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self GeneralCode];
    [self showDateTimePicker];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //    CGFloat lastViewHeight = CGRectGetHeight(((UIView *)[self.ContentView.subviews lastObject]).frame);
    //    int lastViewY = CGRectGetMaxY(((UIView *)[self.ContentView.subviews lastObject]).frame);
    //    CGFloat height = lastViewHeight + lastViewY + 300;
    //    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), height);
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), 610);
}

#pragma mark - General Code.
-(void)GeneralCode
{
    self.ConsultingView.hidden=YES;
    self.TreatmentView.hidden=YES;
    self.PatientDetailView.hidden=YES;
    self.RefferedByView.hidden=YES;
    self.Comunication_View.hidden=YES;
    self.ConsultingView.backgroundColor=[UIColor whiteColor];
    self.TreatmentView.backgroundColor=[UIColor whiteColor];
    self.PatientDetailView.backgroundColor=[UIColor whiteColor];
    self.RefferedByView.backgroundColor=[UIColor whiteColor];
    self.Comunication_View.backgroundColor=[UIColor whiteColor];
    
    [self.PurposeButton addTarget:self action:@selector(showPurposeTypeSheet:) forControlEvents:UIControlEventTouchUpInside];
    self.PurposeButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.PurposeButton.layer.borderWidth = 1.f;
    self.PurposeButton.layer.masksToBounds = YES;
    
    self.TreatmentTypeButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.TreatmentTypeButton.layer.borderWidth = 1.f;
    self.TreatmentTypeButton.layer.masksToBounds = YES;
    
    self.EditButtonOutlet.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.EditButtonOutlet.layer.borderWidth = 1.f;
    self.EditButtonOutlet.layer.masksToBounds = YES;
}



#pragma mark - Show Purpose Type Sheet.
-(void)showPurposeTypeSheet:(UIButton *)sender
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Select Purpose Type" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSMutableArray *namess = [self PurposeTypes];
    NSMutableArray *idss   = [self PurposeTypeIDs];
    
    [namess removeLastObject];
    [idss removeLastObject];
    
    [namess enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [sender setTitle:action.title forState:UIControlStateNormal];
            _selectedPurposeTypeID = idss[idx];
            
            if([_selectedPurposeTypeID isEqual:@1])
            {
                self.ConsultingView.hidden=NO;
                self.TreatmentView.hidden=YES;
                self.PatientDetailView.hidden=YES;
                self.RefferedByView.hidden=YES;
                
            }
            else if([_selectedPurposeTypeID isEqual:@2])
            {
                self.ConsultingView.hidden=YES;
                self.TreatmentView.hidden=NO;
                self.Comunication_View.hidden=YES;
                self.PatientDetailView.hidden=NO;
                self.RefferedByView.hidden=NO;
            }
            else if([_selectedPurposeTypeID isEqual:@3])
            {
                self.ConsultingView.hidden=YES;
                self.TreatmentView.hidden=YES;
                self.Comunication_View.hidden=YES;
                self.PatientDetailView.hidden=YES;
                self.RefferedByView.hidden=YES;
            }
        }];
        
        [controller addAction:action];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    [controller addAction:cancel];
    controller.popoverPresentationController.sourceView = sender;
    controller.popoverPresentationController.sourceRect = sender.bounds;
    [self presentViewController:controller animated:YES completion:nil];
}

-(NSMutableArray *)PurposeTypes
{
    NSMutableArray *address_types = [NeediatorUtitity savedDataForKey:kSAVE_Purpose_Types];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    [address_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [names addObject:[type valueForKey:@"purposetype"]];
    }];
    return names;
}

-(NSMutableArray *)PurposeTypeIDs {
    NSMutableArray *address_types = [NeediatorUtitity savedDataForKey:kSAVE_Purpose_Types];
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    
    [address_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [ids addObject:[type valueForKey:@"id"]];
    }];
    
    return ids;
}




#pragma mark - Consulting First Time.
- (IBAction)ConsultingFirstTimeAction:(UIButton *)sender
{
    NSLog(@"Consilting First Time Button Clicked");
    
    _Consulting_String=@"Yes";
    
    
    [_ConsultFstTimeOutlet setSelected:YES];
    [_DoneThisBeforeOutlet setSelected:NO];
    
    
    if(sender.isSelected)
    {
        
        [self.ConsultFstTimeOutlet setImage:[UIImage imageNamed:@"RadioSelected.png"] forState:UIControlStateSelected];
        self.PatientDetailView.hidden=NO;
        self.RefferedByView.hidden=NO;
        self.Comunication_View.hidden=YES;
    }
    else
    {
        [self.ConsultFstTimeOutlet setImage:[UIImage imageNamed:@"Radiodeselected.png"] forState:UIControlStateNormal];
    }
    
}

#pragma mark - Done This Befor Action.
- (IBAction)DoneThisBeforeAction:(UIButton *)sender
{
    User *saved_user = [User savedUser];
    
    [_DoneThisBeforeOutlet setSelected:YES];
    [_ConsultFstTimeOutlet setSelected:NO];
    _Consulting_String=@"No";
    
    NSLog(@"Done This Before Button Clicked");
    if(sender.isSelected)
    {
        [self.DoneThisBeforeOutlet setImage:[UIImage imageNamed:@"RadioSelected.png"] forState:UIControlStateSelected];
        self.PatientDetailView.hidden=NO;
        self.RefferedByView.hidden=NO;
        self.Comunication_View.hidden=NO;
        
        NSString *parameterString = [NSString stringWithFormat:@"isConsultingFirstTime=%@&userid=%@&storeid=%@&Sectionid=%@",_Consulting_String,saved_user.userID,[NeediatorUtitity savedDataForKey:kSAVE_STORE_ID],[NeediatorUtitity savedDataForKey:kSAVE_SEC_ID]];
        NSString *url = [NSString stringWithFormat:@"http://neediator.net/NeediatorWebservice/NeediatorWS.asmx/ConsultationDetails"];
        NSLog(@"URL is --> %@", url);
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://neediator.net/NeediatorWebservice/NeediatorWS.asmx/ConsultationDetails"]];
        request.HTTPMethod = @"POST";
        request.HTTPBody   = [NSData dataWithBytes:[parameterString UTF8String] length:[parameterString length]];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSLog(@"%@",response);
            if (error) {
                NSLog(@"%@",error.localizedDescription);
            }
            else
            {
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSMutableArray *ResponsrArray=json[@"lastdetails"];
                    NSDictionary *dict=[ResponsrArray firstObject];
                    
                    self.OptionalTF.text=dict[@"refferedby"];
                    self.PatientIDOptionalTF.text=[NSString stringWithFormat:@"%@",dict[@"userid"]];
                    self.Communication_Date_TF.text=dict[@"lastcommunicationdate"];
                    NSLog(@"%@",json);
                });
            }
        }];
        [task resume];
    }
    else
    {
        [self.DoneThisBeforeOutlet setImage:[UIImage imageNamed:@"Radiodeselected.png"] forState:UIControlStateNormal];
    }
    
}


#pragma mark - Proceed Action.
- (IBAction)Proceed:(id)sender {
    
    NSLog(@"Consulting String Is %@",_Consulting_String);
    
    NSLog(@"Proceed Button From Book Appointment Clicked.....");
    BookConfirmNewVC *bcvc = [self.storyboard instantiateViewControllerWithIdentifier:@"BookConfirmNewVC"];
    
    bcvc.Date=self.DateTextField.text;
    bcvc.Time_Slot_From=self.TimeFromTF.text;
    bcvc.Time_Slot_To=self.TimeToTF.text;
    bcvc.Purpose_Type_ID=_selectedPurposeTypeID.stringValue;
    bcvc.PatientID=self.PatientIDOptionalTF.text;
    bcvc.Commn_Date=self.Communication_Date_TF.text;
    bcvc.refferdby=self.OptionalTF.text;
    bcvc.ConsultingString=self.Consulting_String;
    [self.navigationController pushViewController:bcvc animated:YES];
}

#pragma mark - Other Action.
- (IBAction)OtherAction:(id)sender
{
    NSLog(@"Other Button Clicked");
}


#pragma mark - Date Picker..
-(void)showDateTimePicker
{
    _dateTimePicker = [[UIDatePicker alloc]initWithFrame:CGRectZero];
    _dateTimePicker.datePickerMode = UIDatePickerModeDate;
    
    NSDate *currentDate = [NSDate date];
    NSDate *nextDate = [currentDate dateByAddingTimeInterval:60*60*24*30];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"cccc, MMM d, hh:mm aa"];
    
    NSLog(@"Current Date = %@", [dateFormat stringFromDate:currentDate]);
    NSLog(@"Next Date = %@", [dateFormat stringFromDate:nextDate]);
    
    [_dateTimePicker setMinimumDate:currentDate];
    [_dateTimePicker setMaximumDate:nextDate];
    
    self.DateTextField.inputView = _dateTimePicker;
    self.DateTextField.inputAccessoryView = [self pickupDateTimePickerToolBar];
    
    [_dateTimePicker addTarget:self action:@selector(setSelectedDateTime:) forControlEvents:UIControlEventValueChanged];
}


-(UIToolbar *)pickupDateTimePickerToolBar {
    UIToolbar *toolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,44)];
    toolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 150, 21.f)];
    message.font = [NeediatorUtitity mediumFontWithSize:15.f];
    message.textAlignment = NSTextAlignmentCenter;
    message.backgroundColor = [UIColor clearColor];
    message.textColor = [UIColor darkGrayColor];
    message.text = @"Select Date and Time";
    
    UIBarButtonItem *flexibleSpaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *titleButton = [[UIBarButtonItem alloc] initWithCustomView:message];
    
UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissDateTimePickerView)];
    
    [toolbar setItems:@[flexibleSpaceLeft, titleButton, flexibleSpaceRight,doneButton] animated:YES];
    
    return toolbar;
}

-(void)dismissDateTimePickerView {
    
    [self.DateTextField resignFirstResponder];
}

-(void)setSelectedDateTime:(UIDatePicker *)picker {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
 //sb  [dateFormat setDateFormat:@"cccc, MMM d, hh:mm aa"];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];

    self.DateTextField.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:picker.date]];
}

-(void)dismissPicker:(UITapGestureRecognizer *)recognizer {
    
    [self.DateTextField resignFirstResponder];
}


@end
