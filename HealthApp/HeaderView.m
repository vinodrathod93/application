//
//  HeaderView.m
//  Chemist Plus
//
//  Created by adverto on 10/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "HeaderView.h"

@implementation HeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"Header view loaded");
        //1
        [[NSBundle mainBundle] loadNibNamed:@"HeaderView" owner:self options:nil];
        
        //2
        NSLog(@"%@",NSStringFromCGRect(self.view.bounds));
        self.bounds = self.view.bounds;
        
        [self.view addSubview:self.imagePagesView];
        [self.view addSubview:self.pageControl];
        //3
        [self addSubview:self.view];
    }
    return self;
}


- (IBAction)askPharmacistPressed:(id)sender {
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"askPharmacistPressed"
     object:self];
}

- (IBAction)askDoctorPressed:(id)sender {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"askDoctorPressed"
     object:self];
    
}

- (IBAction)uploadPrescriptionPressed:(id)sender {
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"uploadPrescriptionPressed"
     object:self];
    
}
@end
