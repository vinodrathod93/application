//
//  BookConfirmNewVC.h
//  Neediator
//
//  Created by adverto on 30/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface BookConfirmNewVC : UIViewController<UIScrollViewDelegate>



@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *Scroll_View;


@property (weak, nonatomic) IBOutlet UILabel *Booking_Date;
@property (weak, nonatomic) IBOutlet UILabel *Time_From;
@property (weak, nonatomic) IBOutlet UILabel *Time_To;
@property (weak, nonatomic) IBOutlet UILabel *Purpose_Type;

@property (weak, nonatomic) IBOutlet UILabel *Patient_Name;
@property (weak, nonatomic) IBOutlet UILabel *Patient_PhoneNo;
@property (weak, nonatomic) IBOutlet UILabel *Patient_Male_OR_Female;
@property (weak, nonatomic) IBOutlet UILabel *Patient_Age;

@property (weak, nonatomic) IBOutlet UITextField *Patient_ID_OptionalTF;
@property (weak, nonatomic) IBOutlet UITextField *Patient_Communication_Date;


@property (weak, nonatomic) IBOutlet UITextField *Reffered_By_Optional_TF;
@property (weak, nonatomic) IBOutlet UITextField *PromoCode_TF;
@property (weak, nonatomic) IBOutlet UITextView *Comment_TextView;
@property (weak, nonatomic) IBOutlet UIButton *Apply_Outlet;


- (IBAction)Apply_Action:(id)sender;
- (IBAction)CheckBoxAction:(UIButton *)sender;
- (IBAction)Submit_Action:(id)sender;






@property(nonatomic,retain)NSString *Date;
@property(nonatomic,retain)NSString *Time_Slot_From;
@property(nonatomic,retain)NSString *Time_Slot_To;
@property(nonatomic,retain)NSString *Purpose_Type_ID;
@property(nonatomic,retain)NSString *PatientID;
@property(nonatomic,retain)NSString *Commn_Date;
@property(nonatomic,retain)NSString *refferdby;
@property(nonatomic,retain)NSString *ConsultingString;























@end
