//
//  SQLManager.m
//  NameList
//
//  Created by fu on 2018/4/15.
//  Copyright © 2018年 fhc. All rights reserved.
//

#import "SQLManager.h"

@implementation SQLManager

#define kNameFile (@"Student.sqlite")

static SQLManager * manager = nil;

+ (SQLManager *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        [manager createDataBaseTableIfNeeded];
    });
    return manager;
}

- (NSString *)applicationDocumentsDirectorFile {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [paths lastObject];
    NSString * filePath = [documentDirectory stringByAppendingPathComponent:kNameFile];
    return filePath;
}

- (void)createDataBaseTableIfNeeded {
    NSString * writeTablePath = [self applicationDocumentsDirectorFile];
    NSLog(@"数据库的地址是：%@",writeTablePath);
    
    //第一个参数是数据库文件所在的完整路径
    //第二个参数是数据库 DataBase 对象
    if (sqlite3_open([writeTablePath UTF8String], &db) != SQLITE_OK) {// SQLITE_OK 打开成功
        //失败 无论成功还是失败都要关闭数据库
        sqlite3_close(db);
        NSAssert(NO, @"数据库打开失败！");
    }else {
        char * err;
        NSString * createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS StudentName (idNum TEXT PRIMARY KEY, name TEXT);"];
        /*
         第一个参数 db 对象
         第二个参数 语句
         第三个参数 和 第四个参数 回调函数和回调函数传递的参数
         第五个参数 是一个错误信息
         */
        if (sqlite3_exec(db, [createSQL UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            //失败
            sqlite3_close(db);
            NSAssert(NO, @"建表失败! %s",err);
        }
        sqlite3_close(db);
    }
}

//查询
- (StudentModel *)searchWithIdNum:(StudentModel *)model {
    
    NSString * path = [self applicationDocumentsDirectorFile];
    
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        [self openDatabaseError];
    }else {
        NSString * qsql = @"SELECT idNum,name FROM StudentName where idNum = ?";
        sqlite3_stmt * statement;//语句对象
        
        /// 预处理函数 v2
        //第一个参数 数据库的对象
        //第二个参数 SQL语句
        //第三个参数 执行语句的长度 -1是指全部长度
        //第四个参数 语句对象
        //第五个参数 没有执行的语句部分 NULL
        if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            //进行 按主键查询数据库
            NSString * idNum = model.idNum;
            //绑定操作
            //第一个参数 语句对象
            //第二个参数 参数执行的序号,就是sql语句预留的占位符？的序号 1代表sql语句中的第一个问号，问号的下标是从1开始的
            //第三个参数 我们要绑定的值
            //第四个参数 绑定的字符串的长度
            //第五个参数 指针 NULL
            sqlite3_bind_text(statement, 1, [idNum UTF8String], -1, NULL);
            //遍历结果集 有一个返回值  SQLITE_ROW常量代表查出来了
            if (sqlite3_step(statement) == SQLITE_ROW) {//查出来了
                //提取数据
                //第一个参数 语句对象
                //第二个参数 字段索引 0 查询结果集的竖列顺序
                char * idNum = (char *)sqlite3_column_text(statement, 0);
                //数据转换
                NSString * idNumStr = [[NSString alloc] initWithUTF8String:idNum];
                char * name = (char *)sqlite3_column_text(statement, 1);
                NSString * nameStr = [NSString stringWithUTF8String:name];
                
                StudentModel * model = [[StudentModel alloc] init];
                model.idNum = idNumStr;
                model.name = nameStr;
                
                //释放资源
                sqlite3_finalize(statement);
                sqlite3_close(db);
                
                return model;
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
    
    return nil;
}

//插入
- (int)insert:(StudentModel *)model {
    NSString * path = [self applicationDocumentsDirectorFile];
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        [self openDatabaseError];
    }else {
        NSString * sql = @"INSERT OR REPLACE INTO StudentName (idNum, name) VALUES (?, ?)";// ;?
        sqlite3_stmt * statement;
        //预处理
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [model.idNum UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 2, [model.name UTF8String], -1, NULL);
            
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSAssert(NO, @"插入数据库失败！");
            }
            
            sqlite3_finalize(statement);
            sqlite3_close(db);
        }
    }
    return 0;
}

- (void)remove:(StudentModel *)model {
    /* */
    NSString * path = [self applicationDocumentsDirectorFile];
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        [self openDatabaseError];
    }else {
        NSString * sql = @"DELETE FROM StudentName WHERE idNum = ?";
        sqlite3_stmt * statement;
        //预处理
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [model.idNum UTF8String], -1, NULL);
            
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSAssert(NO, @"删除数据失败！");
            }
            
            sqlite3_finalize(statement);
            sqlite3_close(db);
        }
    }
}

- (void)modify:(StudentModel *)model {
    
}

// 查找所有的数据
- (NSArray *)selectData {
    NSString * path = [self applicationDocumentsDirectorFile];
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        [self openDatabaseError];
    }else {
        NSString * sql = @"SELECT * FROM StudentName";
        sqlite3_stmt * statement;
        NSMutableArray * arr = nil;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            arr = [NSMutableArray array];
            while (sqlite3_step(statement) == SQLITE_ROW) {
                //获取记录中的字段值 第一个参数是语句对象，第二个参数是字段的下标，从0开始
                char * cName = (char *)sqlite3_column_text(statement, 0);
                char * cIdNum = (char *)sqlite3_column_text(statement, 1);
                
                NSString * name = [NSString stringWithUTF8String:cName];
                NSString * idNum = [NSString stringWithUTF8String:cIdNum];
                StudentModel * model = [[StudentModel alloc] init];
                model.name = name;
                model.idNum = idNum;
                [arr addObject:model];
            }
            return arr;
        }
    }
    return nil;
}

- (void)openDatabaseError {
    sqlite3_close(db);
    NSAssert(NO, @"数据库打开失败");
}

@end
