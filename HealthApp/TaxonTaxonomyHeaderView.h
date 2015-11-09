//
//  TaxonTaxonomyHeaderView.h
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRNCollapsableSectionHeaderProtocol.h"

@interface TaxonTaxonomyHeaderView : UITableViewHeaderFooterView<RRNCollapsableSectionHeaderProtocol>

@property (weak, nonatomic) IBOutlet UIImageView *downArrowImageView;
@property (weak, nonatomic) IBOutlet UILabel *taxonomyTitle;
@end
