//
//  ListingAnnotationView.m
//  Kassi
//
//  Created by Janne Käki on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListingAnnotationView.h"

#import "Listing.h"

@implementation ListingAnnotationView

@synthesize iconView;
@synthesize pinHeadView;

- (void)setAnnotation:(id<MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    
    if ([annotation isKindOfClass:Listing.class]) {
        
        if (pinHeadView == nil) {
            self.pinHeadView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin-head"]];
            pinHeadView.frame = CGRectMake(-7, -5, 28, 28);
            [self addSubview:pinHeadView];
        }
        
        if (iconView == nil) {
            self.iconView = [[UIImageView alloc] init];
            iconView.frame = CGRectMake(-5, -3, 24, 24);
            [self addSubview:iconView];
        }
                
        iconView.image = [Listing iconForCategory:[(Listing *) annotation category]];
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.pinHeadView.image = (selected) ? [UIImage imageNamed:@"pin-head-active"] : [UIImage imageNamed:@"pin-head"];
}

@end
