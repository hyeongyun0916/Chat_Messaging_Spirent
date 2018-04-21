//
//  SocketSingleton.h
//  Chat
//
//  Created by 현균 문 on 2018. 4. 20..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@protocol SockDelegate;
//wrapper GCDAsyncSocket
@interface SocketSingleton : NSObject <GCDAsyncSocketDelegate>

+ (instancetype)getInstance;
- (void)sendCmd:(NSString *)cmd Str:(NSString *)str;
- (void)sendCmd:(NSString *)cmd Content:(NSDictionary *)content;

@property (nonatomic, weak) id<SockDelegate> delegate;

@end

@protocol SockDelegate <NSObject>

- (void)didRead:(NSMutableDictionary*)dic;
//- (void)didReadString:(NSString *)str;

@optional
- (void)didConnected;

@end
