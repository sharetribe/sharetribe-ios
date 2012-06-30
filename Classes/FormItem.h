//
//  FormItem.h
//  Kassi
//
//  Created by Janne Käki on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FormItemTypeTextField = 0,
    FormItemTypeTextArea,
    FormItemTypeChoice,
    FormItemTypeDate,
    FormItemTypeLocation,
    FormItemTypePhoto
} FormItemType;

@interface FormItem : NSObject

@property (assign, nonatomic) FormItemType type;
@property (strong, nonatomic) NSString *typeAsString;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSString *mapsTo;
@property (strong, nonatomic) NSString *whatIsThis;
@property (assign, nonatomic) BOOL mandatory;
@property (strong, nonatomic) NSArray *alternatives;
@property (strong, nonatomic) NSString *defaultAlternative;
@property (assign, nonatomic) NSInteger defaultTimeIntervalInDays;
@property (assign, nonatomic) BOOL includeTime;
@property (assign, nonatomic) BOOL autocapitalization;

+ (NSArray *)formItemsFromDataArray:(NSArray *)dataArray;

@end
