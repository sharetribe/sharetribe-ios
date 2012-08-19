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

+ (Grade *)gradeFromArray:(NSArray *)array;
+ (NSArray *)gradesFromArrayOfArrays:(NSArray *)arrays;

@end
