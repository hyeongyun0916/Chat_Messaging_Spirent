//
//  SocketSingleton.m
//  Chat
//
//  Created by 현균 문 on 2018. 4. 20..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#import "SocketSingleton.h"

@implementation SocketSingleton {
    GCDAsyncSocket *clientSocket;
    NSString *host;
    uint16_t portNumber;
}

+ (instancetype)getInstance {
    static SocketSingleton *_instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _instance = [[SocketSingleton alloc] init];
    });
    return _instance;
}

-(id)init {
    if (self = [super init]) {
        // do init here
        [self initSocketSingleton];
    }
    return self;
}

- (void)initSocketSingleton {
    clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    host = @"172.30.1.35";
    portNumber = 1111;
    
    NSError *error = nil;
    if (![clientSocket connectToHost:host onPort:portNumber error:&error])
        DLog(@"Client failed connecting to up server socket on port %d %@", portNumber, error);
}

- (void)sendCmd:(NSString *)cmd Str:(NSString *)str {
    NSDictionary *dic = @{@"cmd":cmd, @"content":[NSString stringWithFormat:@"%@\n", str]};
    NSData* kData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString* kJsonStr = [[NSString alloc] initWithData:kData encoding:NSUTF8StringEncoding];
    NSData *requestData = [kJsonStr dataUsingEncoding:NSUTF8StringEncoding];
    [clientSocket writeData:requestData withTimeout:-1 tag:0];
    [clientSocket readDataToData:GCDAsyncSocket.LFData withTimeout:-1 tag:0];
}

- (void)sendCmd:(NSString *)cmd Content:(NSDictionary *)content {
    NSDictionary *dic = @{@"cmd":cmd, @"content":content};
    NSData* kData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString* kJsonStr = [[NSString alloc] initWithData:kData encoding:NSUTF8StringEncoding];
    NSData *requestData = [kJsonStr dataUsingEncoding:NSUTF8StringEncoding];
    [clientSocket writeData:requestData withTimeout:-1 tag:0];
    [clientSocket readDataToData:GCDAsyncSocket.LFData withTimeout:-1 tag:0];
}

#pragma SocketDelegate

//- (dispatch_queue_t)newSocketQueueForConnectionFromAddress:(NSData *)address onSocket:(GCDAsyncSocket *)sock {
//    DLog(@"");
//    return dispatch_get_main_queue();
//}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    DLog(@"");
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    DLog(@"");
//    [_delegate didConnected];
//    [stateLabel setText:@"isConnected? YES"];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url {
    DLog(@"");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DLog(@"%@", str);
    [_delegate didReadString:str];
//    [chatArr addObject:str];
//    [chatTable reloadData];
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    DLog(@"");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    DLog(@"");
}

- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    DLog(@"");
}

//- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
//
//}

//- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
//
//}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {
    DLog(@"");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    DLog(@"%@", err);
//    [stateLabel setText:@"isConnected? NO"];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock {
    DLog(@"");
}

- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler {
    DLog(@"");
}

@end
