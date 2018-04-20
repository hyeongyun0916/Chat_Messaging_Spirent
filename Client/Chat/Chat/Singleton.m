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

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect rectKeyboard; // 키보드에 대한 위치와 크기의 사각 영역을 나타낼 CGRect 구조체입니다.
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
        if (_isKeyboard)
            [UIApplication.sharedApplication.windows.lastObject makeToast:str];
        else
            [UIApplication.sharedApplication.windows.firstObject makeToast:str];
    });

}

@end
