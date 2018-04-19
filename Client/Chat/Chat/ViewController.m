//
//  ViewController.m
//  Chat
//
//  Created by 현균 문 on 2018. 4. 18..
//  Copyright © 2018년 현균 문. All rights reserved.
//


@import CocoaAsyncSocket;

#import "ViewController.h"
#import "GCDAsyncSocket.h"

@interface ViewController () <GCDAsyncSocketDelegate, UITableViewDelegate, UITableViewDataSource> {
    GCDAsyncSocket *clientSocket;
    NSString *host;
    uint16_t portNumber;
    __weak IBOutlet UILabel *stateLabel;
    __weak IBOutlet UITextField *msgTF;
    NSMutableArray* chatArr;
    __weak IBOutlet UITableView *chatTable;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    chatArr = [NSMutableArray new];
    [chatTable setRowHeight:UITableViewAutomaticDimension];
    [chatTable setEstimatedRowHeight:40.f];
}

- (IBAction)connectToServer:(id)sender {
    clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    host = @"172.30.1.37";
    portNumber = 1111;
    
    NSError *error = nil;
    if (![clientSocket connectToHost:host onPort:portNumber error:&error])
        DLog(@"Client failed connecting to up server socket on port %d %@", portNumber, error);
}

- (IBAction)sendMessage:(id)sender {
    NSDictionary *dic = @{@"cmd":@"msg", @"content":[NSString stringWithFormat:@"%@\n", msgTF.text]};
    NSData* kData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString* kJsonStr = [[NSString alloc] initWithData:kData encoding:NSUTF8StringEncoding];
    NSData *requestData = [kJsonStr dataUsingEncoding:NSUTF8StringEncoding];
    [clientSocket writeData:requestData withTimeout:-1 tag:0];
    [clientSocket readDataToData:GCDAsyncSocket.LFData withTimeout:-1 tag:0];
}

- (IBAction)disConnectToServer:(id)sender {
    clientSocket = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return chatArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
    [(UILabel*)[cell viewWithTag:2] setText:chatArr[indexPath.row]];
    return cell;
}

#pragma SocketDelegate

- (dispatch_queue_t)newSocketQueueForConnectionFromAddress:(NSData *)address onSocket:(GCDAsyncSocket *)sock {
    return dispatch_get_main_queue();
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    DLog(@"");
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    DLog(@"");
    [stateLabel setText:@"isConnected? YES"];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url {
    DLog(@"");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DLog(@"%@", str);
    [chatArr addObject:str];
    [chatTable reloadData];
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
    DLog(@"");
    [stateLabel setText:@"isConnected? NO"];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock {
    DLog(@"");
}

- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler {
    DLog(@"");
}


#pragma mark UITableDelegate


@end
