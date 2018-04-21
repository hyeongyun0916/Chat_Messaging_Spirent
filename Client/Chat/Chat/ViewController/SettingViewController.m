//
//  SettingViewController.m
//  Chat
//
//  Created by 현균 문 on 2018. 4. 21..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController () {
    __weak IBOutlet UILabel *idLabel;
    __weak IBOutlet UITextField *nameTF;
    __weak IBOutlet UISwitch *busySwitch;
    __weak IBOutlet UIButton *modifyBtn;
}

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUser:_user];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUser:(NSMutableDictionary *)user {
    _user = user;
    [idLabel setText:user[@"userid"]];
    [nameTF setText:user[@"name"]];
    [busySwitch setOn:[user[@"status"] isEqualToString:@"busy"]];
    [modifyBtn setUserInteractionEnabled:YES];
    [busySwitch setUserInteractionEnabled:YES];
}

- (IBAction)modifyName:(UIButton *)sender {
    [SocketSingleton.getInstance sendCmd:@"name"
                                 Content:@{@"userid":_user[@"userid"], @"name":nameTF.text}];
    [sender setUserInteractionEnabled:NO];

}
- (IBAction)switchBusy:(UISwitch *)sender {
    [SocketSingleton.getInstance sendCmd:@"status"
                                 Content:@{@"userid":_user[@"userid"], @"status":sender.on ? @"busy" : @"online"}];
    [sender setUserInteractionEnabled:NO];
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
