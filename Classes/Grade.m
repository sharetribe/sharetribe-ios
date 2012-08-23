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

@dynamic title;
@dynamic icon;
@dynamic bigIcon;

- (NSString *)title
{
    NSString *titleKey = [NSString stringWithFormat:@"grade.%@", name];
    return NSLocalizedString(titleKey, @"");
}

- (UIImage *)icon
{
    return [Grade iconForGrade:grade];
}

- (UIImage *)bigIcon
{
    return [Grade bigIconForGrade:grade];
}

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

+ (UIImage *)iconForGrade:(NSInteger)grade
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"kaapo-grade-%d", grade]];
}

+ (UIImage *)bigIconForGrade:(NSInteger)grade
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"kaapo-big-grade-%d", grade]];
}

@end
