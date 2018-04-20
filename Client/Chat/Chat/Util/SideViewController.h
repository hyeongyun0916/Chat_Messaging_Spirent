//
//  SideViewController.h
//  test0920
//
//  Created by hyeongyun on 2017. 3. 14..
//  Copyright © 2017년 hyeongyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SideVCDirectionFrom) {
    SideVCDirectionFromTop,
    SideVCDirectionFromLeft,
    SideVCDirectionFromBottom,
    SideVCDirectionFromRight
};

typedef void (^SimpleBlock)();

@interface SideViewController : UIViewController

//@property IBOutlet UIButton *handBtn;
- (void)addSideVCto:(UIViewController *)vc isDimmed:(BOOL)isDimmed fromDirection:(SideVCDirectionFrom)direction;
- (IBAction)closeSelf;
- (void)closeSelf:(SimpleBlock)completion;

//@property BOOL Dimmed;
//@property NSLayoutConstraint *size;
//@property SideVCDirection direction;

@end
