//
//  SideViewController.m
//  test0920
//
//  Created by hyeongyun on 2017. 3. 14..
//  Copyright © 2017년 hyeongyun. All rights reserved.
//

#import "SideViewController.h"

@interface SideViewController () {
    IBOutlet NSLayoutConstraint *sizeLayout;
    NSLayoutConstraint *keyLayout;
    SideVCDirectionFrom direction;
}

@end

@implementation SideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.3f animations:^{
        [keyLayout setConstant:0];
        [self.view.superview layoutIfNeeded];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    DLog(@"dealloc");
}

- (void)addSideVCto:(UIViewController *)vc isDimmed:(BOOL)isDimmed fromDirection:(SideVCDirectionFrom)pDirection {
    dispatch_async(dispatch_get_main_queue(), ^{
        direction = pDirection;
        [vc addChildViewController:self];
        [vc.view addSubview:self.view];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changedChildViewControllers" object:nil];
        
        //    id topItem = ![self.parentViewController isKindOfClass:[SideViewController class]] ? vc.topLayoutGuide : vc.view;
        //    NSLayoutAttribute topAttribute = (topItem == vc.topLayoutGuide) ? NSLayoutAttributeBottom : NSLayoutAttributeTop;
        
        [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        if (isDimmed) {
            [vc.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual toItem:vc.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
            [vc.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual toItem:vc.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
            [vc.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual toItem:vc.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
            [vc.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight
                                                                relatedBy:NSLayoutRelationEqual toItem:vc.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        } else {
            
            if (direction == SideVCDirectionFromTop)
                [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:sizeLayout.constant]];
            else
                [vc.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual toItem:vc.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
            
            if (direction == SideVCDirectionFromLeft)
                [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:sizeLayout.constant]];
            else
                [vc.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight
                                                                    relatedBy:NSLayoutRelationEqual toItem:vc.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
            if (direction == SideVCDirectionFromBottom)
                [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:sizeLayout.constant]];
            else
                [vc.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual toItem:vc.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
            
            if (direction == SideVCDirectionFromRight)
                [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:sizeLayout.constant]];
            else
                [vc.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual toItem:vc.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
            
        }
        
        if (direction == SideVCDirectionFromTop) {
            for (NSLayoutConstraint* c in vc.view.constraints)
                if (c.firstItem == self.view && c.firstAttribute == NSLayoutAttributeTop) {
                    keyLayout = c;
                    [keyLayout setConstant:-sizeLayout.constant];
                    break;
                }
        }
        else if (direction == SideVCDirectionFromLeft) {
            for (NSLayoutConstraint* c in vc.view.constraints)
                if (c.firstItem == self.view && c.firstAttribute == NSLayoutAttributeLeft) {
                    keyLayout = c;
                    [keyLayout setConstant:-sizeLayout.constant];
                    break;
                }
        }
        else if (direction == SideVCDirectionFromBottom) {
            for (NSLayoutConstraint* c in vc.view.constraints)
                if (c.firstItem == self.view && c.firstAttribute == NSLayoutAttributeBottom) {
                    keyLayout = c;
                    [keyLayout setConstant:sizeLayout.constant];
                    break;
                }
        }
        else if (direction == SideVCDirectionFromRight) {
            for (NSLayoutConstraint* c in vc.view.constraints)
                if (c.firstItem == self.view && c.firstAttribute == NSLayoutAttributeRight) {
                    keyLayout = c;
                    [keyLayout setConstant:sizeLayout.constant];
                    break;
                }
        }
    });
}

- (IBAction)closeSelf {
    [self closeSelf:nil];
}

- (void)closeSelf:(SimpleBlock)completion {
    CGFloat constant = (direction == SideVCDirectionFromBottom || direction == SideVCDirectionFromRight) ? sizeLayout.constant : -sizeLayout.constant;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f animations:^{
            [keyLayout setConstant:constant];
            [self.view.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changedChildViewControllers" object:nil];
            [self.view endEditing:YES];
            if (completion)
                completion();
        }];
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.anyObject.view == self.view)
        [self closeSelf];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
