//
//  SortListObject.h
//  Neediator
//
//  Created by adverto on 18/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Realm/Realm.h>

@interface SortListObject : RLMObject

@property NSString *name;
@property NSString *type;
@property NSNumber<RLMInt> *id;

@end
