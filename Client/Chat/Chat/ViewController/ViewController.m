//
//  ViewController.m
//  Chat
//
//  Created by 현균 문 on 2018. 4. 18..
//  Copyright © 2018년 현균 문. All rights reserved.
//


@import CocoaAsyncSocket;

#import "ViewController.h"
#import "EntranceViewController.h"

@interface ViewController () <SockDelegate, UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UITextField *msgTF;
    NSMutableArray* chatArr;
    __weak IBOutlet UITableView *chatTable;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [SocketSingleton.getInstance setDelegate:self];
    chatArr = [NSMutableArray new];
    [chatTable setRowHeight:UITableViewAutomaticDimension];
    [chatTable setEstimatedRowHeight:40.f];
}

- (IBAction)connectToServer:(id)sender {

}

- (IBAction)sendMessage:(id)sender {
    [SocketSingleton.getInstance sendCmd:@"msg" Str:msgTF.text];
//    NSDictionary *dic = @{@"cmd":@"msg", @"content":[NSString stringWithFormat:@"%@\n", msgTF.text]};
//    NSData* kData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//    NSString* kJsonStr = [[NSString alloc] initWithData:kData encoding:NSUTF8StringEncoding];
//    NSData *requestData = [kJsonStr dataUsingEncoding:NSUTF8StringEncoding];
//    [clientSocket writeData:requestData withTimeout:-1 tag:0];
//    [clientSocket readDataToData:GCDAsyncSocket.LFData withTimeout:-1 tag:0];
}

- (IBAction)disConnectToServer:(id)sender {
//    clientSocket = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    [SocketSingleton.getInstance setDelegate:(EntranceViewController *)self.presentingViewController];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    DLog(@"");
}

- (void)didReadString:(NSString *)str {
    [chatArr addObject:str];
    [chatTable reloadData];
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

#pragma mark SockDelegate

@end
