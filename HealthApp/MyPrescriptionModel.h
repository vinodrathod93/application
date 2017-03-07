//
//  MyPrescriptionModel.h
//  Neediator
//
//  Created by adverto on 01/02/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface MyPrescriptionModel : MTLModel<MTLJSONSerializing>



@property (nonatomic, retain) NSString *orderno;
@property (nonatomic, copy) NSString *storeid;
@property (nonatomic, copy) NSString *sectionid;
@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *storeName;
@property (nonatomic, copy) NSString *createdOn;


@property (nonatomic, copy) NSArray *line_itemss;


//@property (nonatomic, copy) NSNumber *isPrescription;
//@property (nonatomic, copy) NSArray  *prescriptionArray;
@property (nonatomic, copy) NSNumber *statusCode;


@property (nonatomic) BOOL isexpanded;
@property (nonatomic) BOOL iscancelexpanded;


@end
