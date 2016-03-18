//
//  SortListObject.m
//  Neediator
//
//  Created by adverto on 18/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "SortListObject.h"

@implementation SortListObject

- (id)initWithMantleModel:(SortListModel *)model{
    self = [super init];
    if(!self) return nil;
    
    self.name = model.name;
    self.type = model.type;
    self.id   = model.sortID;
    
    return self;
}

@end
