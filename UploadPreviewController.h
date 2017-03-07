//
//  UploadPreviewController.h
//  Neediator
//
//  Created by adverto on 11/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NATextView.h"

@interface UploadPreviewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *collectionview;



@property (weak, nonatomic) IBOutlet UILabel *deliveryTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingAddressHeader;
@property (weak, nonatomic) IBOutlet UILabel *shippingTimeHeader;
@property (weak, nonatomic) IBOutlet UILabel *timeSlotFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeSlotToLabel;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *PromoCodeTF;
@property (weak, nonatomic) IBOutlet NATextView *CommentTF;

@property (nonatomic, copy) NSArray *selectedImages;
@property (nonatomic, copy) NSArray *base64Images;


@property (nonatomic, copy) NSString *takeAwayID;
@property (nonatomic, copy) NSString *deliveryTime;
@property (nonatomic, copy) NSString *shippingType;
@property (nonatomic, copy) NSString *shippingAddress;
@property(nonatomic,copy)   NSString *timeslotFrom;
@property(nonatomic,copy) NSString *timeslotTo;
@property(nonatomic,copy) NSString *AccountCode;


@property (nonatomic, copy) NSNumber *shippingTypeID;
@property (nonatomic, copy) NSNumber *shippingAddressID;
@property (nonatomic,copy)  NSNumber *shippingAddressTypeID;



- (IBAction)PromoCodeAction:(id)sender;

@end
