//
//  LeaveMemberViewController.m
//  Chat
//
//  Created by 현균 문 on 2018. 4. 21..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#import "LeaveMemberViewController.h"

@interface LeaveMemberViewController () <SockDelegate> {
    __weak IBOutlet UITextField *idTF;
    __weak IBOutlet UITextField *pwTF;
}

@end

@implementation LeaveMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [SocketSingleton.getInstance setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    [SocketSingleton.getInstance setDelegate:(EntranceViewController *)self.presentingViewController];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)removeUser:(id)sender {
    [SocketSingleton.getInstance sendCmd:@"removeuser"
                                 Content:@{@"userid":idTF.text, @"userpw":[pwTF.text AES128Encrypt]}];
}

- (void)didRead:(NSMutableDictionary *)dic {
    DLog(@"%@", dic);
    if ([dic[@"cmd"] isEqualToString:@"removeuser"]) {
        [Singleton.getInstance toast:dic[@"msg"]];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (!([touch.view isKindOfClass:[UITextView class]] || [touch.view isKindOfClass:[UITextField class]]))
        [self.view endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
