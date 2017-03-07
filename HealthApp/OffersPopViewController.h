//
//  OffersPopViewController.h
//  Pods
//
//  Created by adverto on 30/03/16.
//
//

#import <UIKit/UIKit.h>

@interface OffersPopViewController : UIViewController


#pragma outlets

@property (weak, nonatomic) IBOutlet UIView *offerContentView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIImageView *offerImageView;
@property (weak, nonatomic) IBOutlet UILabel *offerDescriptionlbl;
@property (weak, nonatomic) IBOutlet UILabel *promoCodeLbl;
@property (weak, nonatomic) IBOutlet UITextView *termsAndConditiontxt;
@property (weak, nonatomic) IBOutlet UILabel *ValidityLbl;


@property (weak, nonatomic) IBOutlet UITextField *promoCodeTF;



@property(nonatomic,retain)NSString *DescriptionString;
@property(nonatomic,retain)NSString *PromoCodeString;
@property(nonatomic,retain)NSString *termsAndCondition;
@property(nonatomic,retain)NSString *imageurlString;
@property(nonatomic,retain)NSString *validityString;



- (IBAction)CopyPromoCodeAction:(id)sender;



@end
