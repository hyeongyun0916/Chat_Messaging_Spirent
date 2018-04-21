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
#import "SettingViewController.h"

@interface ViewController () <SockDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource> {
    NSMutableArray *busyChatArr;
    __weak IBOutlet UITextField *msgTF;
    __weak IBOutlet UITableView *chatTable;
    SettingViewController *settingVC;
    __weak IBOutlet UICollectionView *userCV;
    __weak IBOutlet UIButton *toBtn;
    __weak IBOutlet NSLayoutConstraint *bottomLayout;
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
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    settingVC = [storyboard instantiateViewControllerWithIdentifier:@"leftSlideMenuVC"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [userCV setAllowsMultipleSelection:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [userCV selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    [[userCV cellForItemAtIndexPath:indexPath] setSelected:YES];
    [[userCV cellForItemAtIndexPath:indexPath].contentView setBackgroundColor:UIColor.redColor];
}

- (IBAction)sendMessage:(id)sender {
//    [SocketSingleton.getInstance sendCmd:@"msg" Str:msgTF.text];
    [SocketSingleton.getInstance sendCmd:@"msg" Content:@{@"from":_user[@"userid"], @"to":_userArr[userCV.indexPathsForSelectedItems.firstObject.item][@"userid"], @"msg":msgTF.text}];
    [msgTF setText:@""];
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

- (void)keyboardWillShow:(NSNotification *)notification {
    [bottomLayout setConstant:-[[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [bottomLayout setConstant:0];
}

//- (BOOL)checkIsSideVCOpen:(NSString *)storyboardID {
//    for (id vc in self.childViewControllers)
//        if ([[vc valueForKey:@"storyboardIdentifier"] isEqualToString:storyboardID]) {
//            [vc closeSelf];
//            return YES;
//        }
//    return NO;
//}

- (IBAction)openLeftMenu {
    [settingVC setUser:_user];
    [settingVC addSideVCto:self isDimmed:YES fromDirection:SideVCDirectionFromLeft];
}

- (IBAction)showUserCV:(id)sender {
    userCV.hidden ^= 1;
}

#pragma mark SocketDelegate

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
                [chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:MAX(0, _chatArr.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
        else if ([dic[@"cmd"] isEqualToString:@"status"]) {
            if ([_user[@"userid"] isEqualToString:dic[@"content"][@"userid"]]) {
                _user[@"status"] = dic[@"content"][@"status"];
                [settingVC setUser:_user];
                if ([_user[@"status"] isEqualToString:@"online"]) {
                    [_chatArr addObjectsFromArray:busyChatArr];
                    busyChatArr = [NSMutableArray new];
                    [chatTable reloadData];
                }
            }
            for (NSMutableDictionary *user in _userArr) {
                if ([user[@"userid"] isEqualToString:dic[@"content"][@"userid"]]) {
                    user[@"status"] = dic[@"content"][@"status"];
                    break;
                }
            }
        }
        else if ([dic[@"cmd"] isEqualToString:@"name"]) {
            if ([_user[@"userid"] isEqualToString:dic[@"content"][@"userid"]]) {
                _user[@"name"] = dic[@"content"][@"name"];
                [settingVC setUser:_user];
            }
            for (NSMutableDictionary *user in _userArr) {
                if ([user[@"userid"] isEqualToString:dic[@"content"][@"name"]]) {
                    user[@"status"] = dic[@"content"][@"name"];
                    break;
                }
            }
        }
        else if ([dic[@"cmd"] isEqualToString:@"otherusercome"]) {
            _userArr = dic[@"content"];
            [_userArr insertObject:[@{@"userid":@"", @"name":@"All", @"status":@""} mutableCopy] atIndex:0];
            [userCV reloadData];
        }
    }
}

//- (void)didReadString:(NSString *)str {
//    [chatArr addObject:str];
//    [chatTable reloadData];
//}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (!([touch.view isKindOfClass:[UITextView class]] || [touch.view isKindOfClass:[UITextField class]]))
        [self.view endEditing:YES];
}

#pragma mark TableDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _chatArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
    [(UILabel*)[cell viewWithTag:1] setText:_chatArr[indexPath.row][@"from"]];
    [(UILabel*)[cell viewWithTag:2] setText:_chatArr[indexPath.row][@"msg"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

#pragma mark CollecttionDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _userArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"user" forIndexPath:indexPath];
    [(UILabel *)[cell viewWithTag:1] setText:_userArr[indexPath.item][@"name"]];
    [(UILabel *)[cell viewWithTag:2] setText:_userArr[indexPath.item][@"status"]];
    if (cell.isSelected)
        [cell.contentView setBackgroundColor:UIColor.redColor];
    else
        [cell.contentView setBackgroundColor:UIColor.whiteColor];
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return ([_userArr[indexPath.item][@"status"] isEqualToString:@"online"] || [_userArr[indexPath.item][@"userid"] isEqualToString:@""]) && ![_userArr[indexPath.item][@"userid"] isEqualToString:_user[@"userid"]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView setHidden:YES];
    [toBtn setTitle:_userArr[userCV.indexPathsForSelectedItems.firstObject.item][@"name"] forState:UIControlStateNormal];
    [[collectionView cellForItemAtIndexPath:indexPath].contentView setBackgroundColor:UIColor.redColor];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[collectionView cellForItemAtIndexPath:indexPath].contentView setBackgroundColor:UIColor.whiteColor];
}

@end
