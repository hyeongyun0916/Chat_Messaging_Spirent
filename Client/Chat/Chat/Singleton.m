//
//  Singleton.m
//  Chat
//
//  Created by 현균 문 on 2018. 4. 21..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#import "Singleton.h"

@implementation Singleton

+ (instancetype)getInstance {
    static Singleton *_instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _instance = [[Singleton alloc] init];
    });
    return _instance;
}

-(id)init {
    if (self = [super init]) {
        // do init here
        [self initSingleton];
    }
    return self;
}

- (void)initSingleton {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)calculateInterval:(NSString *)serverTime {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddHHmmss"];
    //ServerTime    20180422004422
    //DBTime        2018-04-21 06:41:53
    NSDate *serverDate = [df dateFromString:serverTime];
    _interval = [NSDate.date timeIntervalSinceDate:serverDate];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    _isKeyboard = YES;
}

// 키보드가 아래로 잠기는 이벤트 발생 시 실행할 이벤트 처리 메서드입니다.
- (void)keyboardWillHide:(NSNotification *)notification {
    _isKeyboard = NO;
}

- (void)toast:(NSString*)str {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication.sharedApplication.windows.lastObject hideAllToasts];
        [UIApplication.sharedApplication.windows.firstObject hideAllToasts];
        if (self->_isKeyboard)
            [UIApplication.sharedApplication.windows.lastObject makeToast:str];
        else
            [UIApplication.sharedApplication.windows.firstObject makeToast:str];
    });

}

@end
