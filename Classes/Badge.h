//
//  Badge.h
//  Sharetribe
//
//  Created by Janne Käki on 8/19/12.
//
//

#import <Foundation/Foundation.h>

@interface Badge : NSObject

@property (assign) NSInteger badgeId;
@property (strong) NSString *name;
@property (strong) NSString *description;
@property (strong) NSDate *createdAt;
@property (strong) NSURL *pictureURL;

+ (Badge *)badgeFromDict:(NSDictionary *)dict;
+ (NSArray *)badgesFromArrayOfDicts:(NSArray *)dicts;

@end
