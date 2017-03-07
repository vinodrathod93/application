//
//  NeediatorHelper.h
//  Neediator
//
//  Created by Vinod Rathod on 03/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#ifndef NeediatorHelper_h
#define NeediatorHelper_h

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"

#define MAIN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define MAIN_WIDTH  [[UIScreen mainScreen] bounds].size.width


static UIFont *regularFont(CGFloat size) {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:size];
}

static UIFont *mediumFont(CGFloat size) {
    return [UIFont fontWithName:@"AvenirNext-Medium" size:size];
}

static UIFont *demiBoldFont(CGFloat size) {
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:size];
}

static UIFont *boldFont(CGFloat size) {
    return [UIFont fontWithName:@"AvenirNext-Bold" size:size];
}


static UIColor *defaultColor() // Gray color.
{
    return [UIColor colorWithRed:235/255.f green:235/255.f blue:240/255.f alpha:1.0];
}


static UIColor *mainColor() {   // yellow color.
    return [UIColor colorWithRed:246/255.f green:236/255.f blue:84/255.f alpha:1.0];
}


static UIColor *blurredDefaultColor() {     // light gray color.
    return [UIColor colorWithRed:247/255.f green:247/255.f blue:249/255.f alpha:1.0];
}



#endif /* NeediatorHelper_h */

