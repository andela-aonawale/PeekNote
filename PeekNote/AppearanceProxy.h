//
//  AppearanceProxy.h
//  PeekNote
//
//  Created by Ahmed Onawale on 4/8/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AppearanceProxy)
// appearanceWhenContainedIn: is not available in Swift. This fixes that.
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end
