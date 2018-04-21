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

@interface ViewController () <SockDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource> {
    NSMutableArray *busyChatArr;
    __weak IBOutlet UITextField *msgTF;
    __weak IBOutlet UITableView *chatTable;
    SettingViewController *settingVC;
    __weak IBOutlet UICollectionView *userCV;
    __weak IBOutlet UIButton *toBtn;
    __weak IBOutlet NSLayoutConstraint *bottomLayout;
    NSDictionary* whisperUser;
    __weak IBOutlet UIView *sendView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [SocketSingleton.getInstance setDelegate:self];
    busyChatArr = [NSMutableArray new];
    //initialize chatArr if there is no data for chat
    //채팅이 없다면 초기화
    if (!_chatArr || [_chatArr isEqual:[NSNull null]]) {
        _chatArr = [NSMutableArray new];
    }
    //initialize userArr if there is no data for user
    //but it wouldn't happen. because there are always 'all' and 'me'
    //나 한명이라도 있기때문에 있을수 없는 현상임.
    if (!_userArr || [_userArr isEqual:[NSNull null]]) {
        _userArr = [NSMutableArray new];
    }
    //setting auto height
    [chatTable setRowHeight:UITableViewAutomaticDimension];
    [chatTable setEstimatedRowHeight:40.f];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    settingVC = [storyboard instantiateViewControllerWithIdentifier:@"leftSlideMenuVC"];
    
    //if keyboardup then fix textfield postion
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [userCV setAllowsMultipleSelection:NO];
    
    whisperUser = _userArr.firstObject;
    [toBtn setTitle:whisperUser[@"name"] forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //scroll to bottom
    [chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:MAX(0, _chatArr.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)sendMessage:(id)sender {
    if (msgTF.text.length) {
        [SocketSingleton.getInstance sendCmd:@"msg" Content:@{@"from":_user[@"userid"], @"to":whisperUser[@"userid"], @"msg":msgTF.text}];
        [msgTF setText:@""];
    } else
        [Singleton.getInstance toast:@"input message"];
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

- (IBAction)openLeftMenu {
    [settingVC setUser:_user];
    [settingVC addSideVCto:self isDimmed:YES fromDirection:SideVCDirectionFromLeft];
}

- (IBAction)showUserCV:(id)sender {
    userCV.hidden ^= 1;
}

#pragma mark SocketDelegate

- (void)didRead:(NSMutableDictionary *)dic {
    DLog(@"%@", dic);
    if ([dic[@"result"] integerValue]) {
        [Singleton.getInstance toast:dic[@"msg"]];
    } else {
        if ([dic[@"cmd"] isEqualToString:@"msg"]) {
            //add timestamp
            NSDateFormatter *chatDF = [[NSDateFormatter alloc] init];
            [chatDF setDateFormat:@"a h:mm"];
            NSString *chatTime = [chatDF stringFromDate:NSDate.date];
            dic[@"content"][@"timestamp"] = chatTime;
            
            //if user is busy then store in busychatarr
            if ([_user[@"status"] isEqualToString:@"busy"]) {
                [busyChatArr addObject:dic[@"content"]];
            } else {
                [_chatArr addObject:dic[@"content"]];
                [chatTable reloadData];
                //scroll to bottom
                [chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:MAX(0, _chatArr.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
        else if ([dic[@"cmd"] isEqualToString:@"status"]) {
            //if target is me
            if ([_user[@"userid"] isEqualToString:dic[@"content"][@"userid"]]) {
                _user[@"status"] = dic[@"content"][@"status"];
                [settingVC setUser:_user];
                //if busy to online then take busychat to chatarr
                if ([_user[@"status"] isEqualToString:@"online"]) {
                    [_chatArr addObjectsFromArray:busyChatArr];
                    busyChatArr = [NSMutableArray new];
                    [sendView setUserInteractionEnabled:YES];
                } else {
                    [sendView setUserInteractionEnabled:NO];
                }
            }
            for (NSMutableDictionary *user in _userArr) {
                if ([user[@"userid"] isEqualToString:dic[@"content"][@"userid"]]) {
                    user[@"status"] = dic[@"content"][@"status"];
                    break;
                }
            }
            [chatTable reloadData];
            //if whisperUser out(offline or busy)
            if ([whisperUser[@"userid"] isEqualToString:dic[@"content"][@"userid"]]) {
                if (![dic[@"content"][@"status"] isEqualToString:@"online"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self->whisperUser = self->_userArr.firstObject;
                        [self->toBtn setTitle:self->whisperUser[@"name"] forState:UIControlStateNormal];
                    });
                }
            }
        }
        //name changed
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
        //user out in etc..
        else if ([dic[@"cmd"] isEqualToString:@"userchanged"]) {
            _userArr = dic[@"content"];
            [_userArr insertObject:[@{@"userid":@"", @"name":@"All", @"status":@""} mutableCopy] atIndex:0];
            BOOL isWhisperExist = NO;
            for (NSDictionary* user in _userArr) {
                if ([user[@"userid"] isEqualToString:whisperUser[@"userid"]]
                    && [user[@"status"] isEqualToString:@"online"]) {
                    isWhisperExist = YES;
                }
            }
            if (!isWhisperExist) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->whisperUser = self->_userArr.firstObject;
                    [self->toBtn setTitle:self->whisperUser[@"name"] forState:UIControlStateNormal];
                });
            }
            [userCV reloadData];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (!([touch.view isKindOfClass:[UITextView class]] || [touch.view isKindOfClass:[UITextField class]]))
        [self.view endEditing:YES];
}

- (NSString *)getName:(NSString *)userID {
    for (NSDictionary* user in _userArr) {
        if ([user[@"userid"] isEqualToString:userID]) {
            return user[@"name"];
        }
    }
    return @"";
}

//limit chat msg
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length)
        return NO;
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 800;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendMessage:nil];
    return YES;
}

#pragma mark TableDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _chatArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    if ([_chatArr[indexPath.row][@"to"] length]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"whisperCell"];
        [(UILabel*)[cell viewWithTag:4] setText:[self getName:_chatArr[indexPath.row][@"to"]]];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
    }
    [(UILabel*)[cell viewWithTag:1] setText:[self getName:_chatArr[indexPath.row][@"from"]]];
    [(UILabel*)[cell viewWithTag:2] setText:_chatArr[indexPath.row][@"msg"]];
    [(UILabel*)[cell viewWithTag:3] setText:_chatArr[indexPath.row][@"timestamp"]];
    
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
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return ([_userArr[indexPath.item][@"status"] isEqualToString:@"online"] || [_userArr[indexPath.item][@"userid"] isEqualToString:@""]) && ![_userArr[indexPath.item][@"userid"] isEqualToString:_user[@"userid"]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        [collectionView setHidden:YES];
        self->whisperUser = self->_userArr[indexPath.row];
        [self->toBtn setTitle:self->whisperUser[@"name"] forState:UIControlStateNormal];
    });
}

@end
