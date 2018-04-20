//
//  UIViewController+Spirent.m
//  Chat
//
//  Created by 현균 문 on 2018. 4. 21..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#import "UIViewController+Spirent.h"

@implementation UIViewController (Spirent)

- (UIViewController *)my_visibleViewController {
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        // do not use method visibleViewController as the presentedViewController could beingDismissed
        return [[(UINavigationController *)self topViewController] my_visibleViewController];
    }
    
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [[(UITabBarController *)self selectedViewController] my_visibleViewController];
    }
    
    if (self.presentedViewController == nil || self.presentedViewController.isBeingDismissed) {
        return self;
    }
    
    return [self.presentedViewController my_visibleViewController];
}

@end
