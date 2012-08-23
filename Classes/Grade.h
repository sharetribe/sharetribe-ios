//
//  Grade.h
//  Sharetribe
//
//  Created by Janne Käki on 8/20/12.
//
//

#import <Foundation/Foundation.h>

@interface Grade : NSObject

@property (assign) NSInteger grade;
@property (strong) NSString *name;
@property (assign) NSInteger amount;

@property (readonly) NSString *title;
@property (readonly) UIImage *icon;
@property (readonly) UIImage *bigIcon;

+ (Grade *)gradeFromArray:(NSArray *)array;
+ (NSArray *)gradesFromArrayOfArrays:(NSArray *)arrays;
+ (UIImage *)iconForGrade:(NSInteger)grade;
+ (UIImage *)bigIconForGrade:(NSInteger)grade;

@end
