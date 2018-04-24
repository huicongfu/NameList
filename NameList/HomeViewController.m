//
//  HomeViewController.m
//  NameList
//
//  Created by fu on 2018/4/15.
//  Copyright © 2018年 fhc. All rights reserved.
//

#import "HomeViewController.h"
#import "StudentModel.h"
#import "SQLManager.h"

@interface HomeViewController ()

@property (nonatomic, retain) NSMutableArray * studentArray;
@property (nonatomic, retain) UIRefreshControl * rfc;

@end

#define HomeCellIdentifier (@"StudentCell")

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rfc = [[UIRefreshControl alloc] init];
    self.rfc.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [self.rfc addTarget:self action:@selector(updateAllData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = self.rfc;
    
    self.studentArray = [[NSMutableArray alloc] init];
    [self updateAllData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.studentArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HomeCellIdentifier forIndexPath:indexPath];
    
    if (self.studentArray.count > 0) {
        StudentModel * model = [self.studentArray objectAtIndex:indexPath.row];
        cell.textLabel.text = model.idNum;
        cell.detailTextLabel.text = model.name;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (IBAction)addUserDone:(UIStoryboardSegue *)sender {
//    StudentModel * model = [[StudentModel alloc] init];
//    model.idNum = @"100";
//    StudentModel * result = [[SQLManager shareManager] searchWithIdNum:model];
    
    [self updateAllData];
}

- (void)updateAllData {
    
    if (self.refreshControl.refreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"刷新中···"];
    }
    
    [_studentArray removeAllObjects];
    [_studentArray addObjectsFromArray:[[SQLManager shareManager] selectData]];
    
    [self.refreshControl endRefreshing];
    
    [self.tableView reloadData];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        StudentModel * model = [self.studentArray objectAtIndex:indexPath.row];
        [[SQLManager shareManager] remove:model];
        [self.studentArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
