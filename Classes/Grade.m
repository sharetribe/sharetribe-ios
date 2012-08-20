//
//  Grade.m
//  Sharetribe
//
//  Created by Janne Käki on 8/20/12.
//
//

#import "Grade.h"

@implementation Grade

@synthesize grade;
@synthesize name;
@synthesize amount;

+ (Grade *)gradeFromArray:(NSArray *)array
{
    Grade *grade = [[Grade alloc] init];
    
    grade.name = [array objectOrNilAtIndex:0];
    grade.amount = [[array objectOrNilAtIndex:1] intValue];
    grade.grade = [[array objectOrNilAtIndex:2] intValue];
    
    return grade;
}

+ (NSArray *)gradesFromArrayOfArrays:(NSArray *)arrays
{
    NSMutableArray *grades = [NSMutableArray array];
    
    for (NSArray *array in arrays) {
        Grade *grade = [Grade gradeFromArray:array];
        [grades addObject:grade];
    }
    
    return grades;
}

@end
