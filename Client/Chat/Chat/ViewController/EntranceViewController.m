//
//  EntranceViewController.m
//  Chat
//
//  Created by 현균 문 on 2018. 4. 20..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#import "EntranceViewController.h"

@interface EntranceViewController () {
    __weak IBOutlet UITextField *idTF;
    __weak IBOutlet UITextField *pwTF;
    
}

@end

@implementation EntranceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startSocket:(id)sender {
    [SocketSingleton.getInstance setDelegate:self];
}

- (IBAction)signIn:(id)sender {
    [SocketSingleton.getInstance sendCmd:@"signin" Content:@{@"userid":idTF.text,@"userpw":pwTF.text}];
}

#pragma mark SocketDelegate

- (void)didRead:(NSDictionary *)dic {
    if ([dic[@"result"] integerValue] == StatusSucess) {
        [self performSegueWithIdentifier:@"entrance" sender:nil];
    } else {
        [Singleton.getInstance toast:dic[@"msg"]];
    }
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
