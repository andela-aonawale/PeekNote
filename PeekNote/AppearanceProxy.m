//
//  AppearanceProxy.m
//  PeekNote
//
//  Created by Ahmed Onawale on 4/8/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppearanceProxy.h"
#import <UIKit/UIKit.h>

@implementation UIView (AppearanceProxy)
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}
@end