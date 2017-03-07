//
//  UploadReportsPreviewController.h
//  Neediator
//
//  Created by adverto on 31/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadReportsPreviewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *collectionview;
@property (weak, nonatomic) IBOutlet UITextField *patientIDTf;
@property (weak, nonatomic) IBOutlet UITextField *patientCommunicationdate;



//@property (weak, nonatomic) IBOutlet UILabel *deliveryTypeLabel;
//@property (weak, nonatomic) IBOutlet UILabel *deliveryAddressLabel;
//@property (weak, nonatomic) IBOutlet UILabel *deliveryTimeLabel;
//@property (weak, nonatomic) IBOutlet UILabel *shippingAddressHeader;
//@property (weak, nonatomic) IBOutlet UILabel *shippingTimeHeader;
//@property (weak, nonatomic) IBOutlet UILabel *timeSlotFromLabel;
//@property (weak, nonatomic) IBOutlet UILabel *timeSlotToLabel;







@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
//@property (weak, nonatomic) IBOutlet UIView *contentView;

//
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//
//@property (weak, nonatomic) IBOutlet UITextField *PromoCodeTF;
//@property (weak, nonatomic) IBOutlet UITextView *CommentTF;
//



@property (nonatomic, copy) NSArray *selectedImages;
@property (nonatomic, copy) NSArray *base64Images;


@property(nonatomic,copy)   NSString *timeslotFrom;
@property(nonatomic,copy)   NSString *timeslotTo;
@property(nonatomic,copy)   NSString *AccountCode;
@property(nonatomic,retain) NSString *PatientIDString;
@property(nonatomic,retain) NSString *PatientCommunicationDate;





@property (nonatomic, copy) NSNumber *shippingTypeID;
@property (nonatomic, copy) NSNumber *shippingAddressID;
@property (nonatomic,copy)  NSNumber *shippingAddressTypeID;


@end
