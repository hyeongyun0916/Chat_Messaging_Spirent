//
//  Singleton.h
//  Chat
//
//  Created by 현균 문 on 2018. 4. 21..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject

+ (instancetype)getInstance;
- (void)toast:(NSString*)str;
- (void)calculateInterval:(NSString *)serverTime;

@property (nonatomic) BOOL isKeyboard;
@property (nonatomic) NSTimeInterval interval;

@end
