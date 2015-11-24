//
//  ProductImageViewCell.m
//  Chemist Plus
//
//  Created by adverto on 17/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "ProductImageViewCell.h"

@implementation ProductImageViewCell

- (void)awakeFromNib {
    // Initialization code
    
//    UILabel *name = self.productLabel;
//    UIScrollView *scrollview = self.productImage;
//    UILabel *price = self.priceLabel;
//    UILabel *summary = self.summaryLabel;
    
//    self.productLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    self.priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    self.summaryLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    
//    NSDictionary *views = NSDictionaryOfVariableBindings(scrollview, name, price, summary);
    
    // ScrollView constraints
    
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.productImage attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.productImage attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
//    
//    
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.productImage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollview][name][price][summary]" options:0 metrics:nil views:views]];
    
    
    
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[name]|" options:0 metrics:nil views:views]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[price]|" options:0 metrics:nil views:views]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[summary]|" options:0 metrics:nil views:views]];
    
    
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
//    UIView *superview = [[self superview] superview];r
    
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.productImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:superview.frame.size.height/2]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
