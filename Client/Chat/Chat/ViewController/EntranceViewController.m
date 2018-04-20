//
//  EntranceViewController.m
//  Chat
//
//  Created by 현균 문 on 2018. 4. 20..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#import "EntranceViewController.h"

@interface EntranceViewController ()

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
    [SocketSingleton.getInstance sendCmd:@"signin" Content:@{@"userid":@"mhg5303",@"userpw":@"root"}];
}

#pragma mark SocketDelegate

- (void)didReadString:(NSString *)str {
    [self performSegueWithIdentifier:@"entrance" sender:nil];
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
