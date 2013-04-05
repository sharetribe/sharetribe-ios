//
//  ListingAnnotationView.m
//  Sharetribe
//
//  Created by Janne Käki on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListingAnnotationView.h"

#import "Listing.h"
#import "ListingCluster.h"

@implementation ListingAnnotationView

@synthesize iconView;
@synthesize countLabel;

@synthesize strokeColor, fillColor;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    [self setup];
    return self;
}

- (id)init
{
    self = [super init];
    [self setup];
    return self;
}

- (void)setup
{
    self.frame = CGRectMake(0, 0, 30, 30);
    self.opaque = NO;
    self.strokeColor = [UIColor colorWithWhite:1 alpha:0.9];
    
    [self setSelected:NO];
}

- (void)setAnnotation:(id<MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    
    if ([annotation isKindOfClass:Listing.class]) {
        
        if (iconView == nil) {
            self.iconView = [[UIImageView alloc] init];
            iconView.frame = CGRectMake(3, 3, 24, 24);
            iconView.contentMode = UIViewContentModeCenter;
            [self addSubview:iconView];
        }
        
        iconView.image = [Listing tinyIconForCategory:[(Listing *) annotation category]];
        
        iconView.hidden = NO;
        countLabel.hidden = YES;
        
        self.canShowCallout = NO;
        
    } else if ([annotation isKindOfClass:ListingCluster.class]) {
        
        if (countLabel == nil) {
            self.countLabel = [[UILabel alloc] init];
            countLabel.frame = CGRectMake(3, 3, 24, 24);
            countLabel.font = [UIFont boldSystemFontOfSize:13];
            countLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1];
            countLabel.shadowColor = [UIColor colorWithWhite:1 alpha:0.2];
            countLabel.shadowOffset = CGSizeMake(0, 1);
            countLabel.backgroundColor = [UIColor clearColor];
            countLabel.textAlignment = UITextAlignmentCenter;
            countLabel.userInteractionEnabled = NO;
            [self addSubview:countLabel];
        }
        
        countLabel.text = [NSString stringWithFormat:@"%d", [(ListingCluster *) annotation listings].count];
        
        countLabel.hidden = NO;
        iconView.hidden = YES;
        
        self.canShowCallout = YES;
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGRect pinRect = CGRectMake(4, 4, rect.size.width - 2 * 4, rect.size.height - 2 * 4);
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextClearRect(c, rect);
    CGContextSetStrokeColorWithColor(c, strokeColor.CGColor);
    CGContextSetFillColorWithColor(c, fillColor.CGColor);
    CGContextFillEllipseInRect(c, pinRect);
    CGContextStrokeEllipseInRect(c, pinRect);
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.fillColor = (self.selected) ? kSharetribeDarkOrangeColor : kSharetribeBrownColor;
    
    [self setNeedsDisplay];
}

@end
