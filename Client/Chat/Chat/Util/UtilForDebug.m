//
//  UtilForDebug.m
//  fbwebapp
//
//  Created by hyeongyun on 2016. 7. 21..
//
//


#import "UtilForDebug.h"

@implementation UIAlertView (FB)

-(void)DShow {
#ifdef DEBUG
    [self show];
#endif
}

@end

@implementation UIViewController (Debug)

-(void)DpresentViewController:(UIAlertController*)alertCon {
#ifdef DEBUG
    [self presentViewController:alertCon animated:YES completion:nil];
#endif
}

@end