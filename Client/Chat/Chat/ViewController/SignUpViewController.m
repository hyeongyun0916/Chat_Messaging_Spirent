//
//  SignUpViewController.m
//  Chat
//
//  Created by 현균 문 on 2018. 4. 20..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController () <SockDelegate> {
    NSString* checkedID;
    __weak IBOutlet UITextField *idTF;
    __weak IBOutlet UITextField *pwTF;
    __weak IBOutlet UITextField *pw2TF;
    __weak IBOutlet UITextField *nameTF;
}

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    checkedID = @"";
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

- (IBAction)checkExist:(id)sender {
    if (idTF.text.length) {
        [SocketSingleton.getInstance sendCmd:@"isexist" Content:@{@"userid":idTF.text}];
    }
    else {
        [Singleton.getInstance toast:@"input ID please"];
    }
}

- (IBAction)signup:(id)sender {
    if (checkedID.length) {
        if (pwTF.text.length) {
            if ([pwTF.text isEqualToString:pw2TF.text]) {
                [SocketSingleton.getInstance sendCmd:@"signup"
                                             Content:@{@"userid":checkedID, @"userpw":pwTF.text, @"name":nameTF.text}];
            } else {
                [Singleton.getInstance toast:@"passwords are not same"];
            }
        } else {
            [Singleton.getInstance toast:@"input password please"];
        }
    } else {
        [Singleton.getInstance toast:@"check ID please"];
    }
}

- (void)didRead:(NSDictionary *)dic {
    DLog(@"%@", dic);
    if ([dic[@"cmd"] isEqualToString:@"isexist"]) {
        if ([dic[@"result"] integerValue] == StatusNoDataFound) {
            [Singleton.getInstance toast:@"You can use this ID"];
            checkedID = dic[@"content"];
        } else {
            [Singleton.getInstance toast:dic[@"msg"]];
        }
    } else if ([dic[@"cmd"] isEqualToString:@"signup"]) {
        if ([dic[@"result"] integerValue] == StatusSucess) {
            [Singleton.getInstance toast:@"Thank you"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self close:nil];
            });
        } else {
            [Singleton.getInstance toast:dic[@"msg"]];
        }
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
