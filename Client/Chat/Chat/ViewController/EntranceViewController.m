//
//  EntranceViewController.m
//  Chat
//
//  Created by 현균 문 on 2018. 4. 20..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#import "EntranceViewController.h"
#import "ViewController.h"

@interface EntranceViewController () {
    __weak IBOutlet UITextField *idTF;
    __weak IBOutlet UITextField *pwTF;
    
}

@end

@implementation EntranceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Singleton getInstance];    //initSingleton
    [SocketSingleton.getInstance setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signIn:(id)sender {
    [SocketSingleton.getInstance sendCmd:@"signin" Content:@{@"userid":idTF.text,@"userpw":[pwTF.text AES128Encrypt]}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSDictionary *)sender {
    if ([segue.destinationViewController isKindOfClass:ViewController.class]) {
        ViewController* VC = segue.destinationViewController;
        VC.userArr = sender[@"users"];
        [VC.userArr insertObject:[@{@"userid":@"", @"name":@"All", @"status":@""} mutableCopy] atIndex:0];
        VC.chatArr = sender[@"chats"];  //timestamp변경
        for (NSDictionary* user in sender[@"users"]) {
            if ([sender[@"userid"] isEqualToString:user[@"userid"]]) {
                VC.user = [user mutableCopy];
                break;
            }
        }
    }
    DLog(@"");
}

#pragma mark SocketDelegate

- (void)didRead:(NSDictionary *)dic {
    if ([dic[@"result"] integerValue] == StatusSucess) {
        if ([dic[@"cmd"] isEqualToString:@"signin"]) {
            [self performSegueWithIdentifier:@"entrance" sender:dic[@"content"]];
        }
    } else {
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
