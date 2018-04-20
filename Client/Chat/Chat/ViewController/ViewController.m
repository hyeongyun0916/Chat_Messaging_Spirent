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
    NSMutableArray *busyChatArr;
    __weak IBOutlet UITextField *msgTF;
    __weak IBOutlet UITableView *chatTable;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [SocketSingleton.getInstance setDelegate:self];
    busyChatArr = [NSMutableArray new];
    //채팅이 없다면 초기화
    if (!_chatArr || [_chatArr isEqual:[NSNull null]]) {
        _chatArr = [NSMutableArray new];
    }
    //나 한명이라도 있기때문에 있을수 없는 현상임.
    if (!_userArr || [_userArr isEqual:[NSNull null]]) {
        _userArr = [NSMutableArray new];
    }
    [chatTable setRowHeight:UITableViewAutomaticDimension];
    [chatTable setEstimatedRowHeight:40.f];
}

- (IBAction)sendMessage:(id)sender {
    [SocketSingleton.getInstance sendCmd:@"msg" Str:msgTF.text];
}

- (IBAction)disConnectToServer:(id)sender {
//    clientSocket = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    NSString* userID = _user[@"userid"];
    NSString* status = _user[@"status"];
    [SocketSingleton.getInstance sendCmd:@"signout" Content:@{@"userid":userID, @"status":status}];
    [SocketSingleton.getInstance setDelegate:(EntranceViewController *)self.presentingViewController];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    DLog(@"");
}

- (void)didRead:(NSDictionary *)dic {
    DLog(@"%@", dic);
    if ([dic[@"result"] integerValue]) {
        [Singleton.getInstance toast:dic[@"msg"]];
    } else {
        if ([dic[@"cmd"] isEqualToString:@"msg"]) {
            if ([_user[@"status"] isEqualToString:@"busy"]) {
                //timeStamp추가
                [busyChatArr addObject:dic[@"content"]];
            } else {
                [_chatArr addObject:dic[@"content"]];
                [chatTable reloadData];
            }
        }
        else if ([dic[@"cmd"] isEqualToString:@"status"]) {
            if ([_user[@"userid"] isEqualToString:dic[@"content"][@"userid"]]) {
                _user[@"status"] = dic[@"content"][@"status"];
            }
            for (NSMutableDictionary *user in _userArr) {
                if ([user[@"userid"] isEqualToString:dic[@"content"][@"userid"]]) {
                    user[@"status"] = dic[@"content"][@"status"];
                    break;
                }
            }
        }
    }
}

//- (void)didReadString:(NSString *)str {
//    [chatArr addObject:str];
//    [chatTable reloadData];
//}

#pragma mark TableDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _chatArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
    [(UILabel*)[cell viewWithTag:2] setText:_chatArr[indexPath.row]];
    return cell;
}

#pragma mark SockDelegate

@end
