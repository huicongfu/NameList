//
//  AddViewController.m
//  NameList
//
//  Created by fu on 2018/4/15.
//  Copyright © 2018年 fhc. All rights reserved.
//

#import "AddViewController.h"
#import "SQLManager.h"
#import "StudentModel.h"

@interface AddViewController ()
@property (strong, nonatomic) IBOutlet UITextField *idNumTF;
@property (strong, nonatomic) IBOutlet UITextField *nameTF;

@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"AddUser"]) {
        //写入数据库
        StudentModel * model = [[StudentModel alloc] init];
        model.idNum = self.idNumTF.text;
        model.name = self.nameTF.text;
        
        [[SQLManager shareManager] insert:model];
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
