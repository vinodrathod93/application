//
//  BookAppointmentVC.h
//  Neediator
//
//  Created by adverto on 29/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTextField.h"
#import "TPKeyboardAvoidingScrollView.h"


@interface BookAppointmentVC : UIViewController<UIScrollViewDelegate>

//All General Outlets
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *ContentView;
@property (weak, nonatomic) IBOutlet NTextField *DateTextField;
@property (weak, nonatomic) IBOutlet UITextField *TimeFromTF;
@property (weak, nonatomic) IBOutlet UITextField *TimeToTF;
@property (weak, nonatomic) IBOutlet UIButton *PurposeButton;
- (IBAction)Proceed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *proceedoulet;




//Consulting View All Outlets And Actions
@property (weak, nonatomic) IBOutlet UIView *ConsultingView;
- (IBAction)ConsultingFirstTimeAction:(UIButton *)sender;
- (IBAction)DoneThisBeforeAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *ConsultFstTimeOutlet;
@property (weak, nonatomic) IBOutlet UIButton *DoneThisBeforeOutlet;


//Treatment View All Outlets And Actions

@property (weak, nonatomic) IBOutlet UIView *TreatmentView;
@property (weak, nonatomic) IBOutlet UIButton *TreatmentTypeButton;
- (IBAction)OtherAction:(id)sender;


//Patient Details View Outlets And Actions
@property (weak, nonatomic) IBOutlet UIView *PatientDetailView;
@property (weak, nonatomic) IBOutlet UIButton *EditButtonOutlet;


//Reffered By View Outlets And Actions..
@property (weak, nonatomic) IBOutlet UIView *RefferedByView;
@property (weak, nonatomic) IBOutlet UITextField *OptionalTF;


// Patient Id And Communication Date View Outletes And Actions
@property (weak, nonatomic) IBOutlet UIView *Comunication_View;
@property (weak, nonatomic) IBOutlet UITextField *PatientIDOptionalTF;
@property (weak, nonatomic) IBOutlet UITextField *Communication_Date_TF;




@property(nonatomic,retain)NSString *Consulting_String;








@end
