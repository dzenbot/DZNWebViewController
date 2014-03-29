//
//  DZNPolyActivity.h
//  Sample
//
//  Created by Ignacio on 3/28/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, DZNPolyActivityType) {
    DZNPolyActivityTypeSafari,
    DZNPolyActivityTypeChrome,
    DZNPolyActivityTypeOpera,
    DZNPolyActivityTypeLink
};

@interface DZNPolyActivity : UIActivity

+ (instancetype)activityWithType:(DZNPolyActivityType)type;
- (instancetype)initWithActivityType:(DZNPolyActivityType)type;

@end
