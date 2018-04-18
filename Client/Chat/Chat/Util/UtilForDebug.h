//
//  UtilForDebug.h
//  fbwebapp
//
//  Created by hyeongyun on 2016. 7. 21..
//
//

#import <UIKit/UIKit.h>

#ifndef UtilForDebug_h
#define UtilForDebug_h

#ifdef DEBUG
#define kInformStr [NSString stringWithFormat:@"\n%@:(%d) %@\n%s\n", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [self description], __PRETTY_FUNCTION__]
#define DLog( s, ... )  NSLog(@"%@%@\n\n", kInformStr, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
    #define kInformStr @""
    #define DLog(...)
#endif

@interface UIAlertView (Debug)

-(void)DShow;

@end

@interface UIViewController (Debug)

-(void)DpresentViewController:(UIAlertController*)alertCon;

@end

#endif /* UtilForDebug_h */
