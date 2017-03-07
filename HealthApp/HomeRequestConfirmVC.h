//
//  HomeRequestConfirmVC.h
//  Neediator
//
//  Created by adverto on 11/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeRequestConfirmVC : UIViewController


@property (weak, nonatomic) IBOutlet UILabel *Date_lbl;
@property (weak, nonatomic) IBOutlet UILabel *timeFrom_lbl;
@property (weak, nonatomic) IBOutlet UILabel *timeTo_lbl;
@property (weak, nonatomic) IBOutlet UILabel *PurposeType_lbl;
@property (weak, nonatomic) IBOutlet UITextField *refferedBy_TF;
@property (weak, nonatomic) IBOutlet UITextField *PromoCode_TF;
@property (weak, nonatomic) IBOutlet UITextView *Comment_TF;
- (IBAction)SubmitAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *PatientAddress;







@property(nonatomic,retain)NSString *Date;
@property(nonatomic,retain)NSString *Time_Slot_From;
@property(nonatomic,retain)NSString *Time_Slot_To;
@property(nonatomic,retain)NSString *Purpose_Type_ID;
@property(nonatomic,retain)NSString *Address_Type_ID;
@property(nonatomic,retain)NSString *PatientID;
@property(nonatomic,retain)NSString *Commn_Date;
@property(nonatomic,retain)NSString *refferdby;
@property(nonatomic,retain)NSString *ConsultingString;
@property(nonatomic,retain)NSString *purposeName;
@property(nonatomic,retain)NSString *AddressString;



@end
