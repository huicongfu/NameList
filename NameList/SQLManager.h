//
//  SQLManager.h
//  NameList
//
//  Created by fu on 2018/4/15.
//  Copyright © 2018年 fhc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "StudentModel.h"

@interface SQLManager : NSObject{
    sqlite3 * db;
}

+ (SQLManager *)shareManager;

- (StudentModel *)searchWithIdNum:(StudentModel *)model;

- (int)insert:(StudentModel *)model;

- (void)remove:(StudentModel *)model;

- (void)modify:(StudentModel *)model;

@end
