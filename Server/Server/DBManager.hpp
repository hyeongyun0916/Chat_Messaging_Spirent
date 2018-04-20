//
//  DBManager.hpp
//  Server
//
//  Created by 현균 문 on 2018. 4. 20..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#ifndef DBManager_hpp
#define DBManager_hpp

#include <iostream>

#include "include/mysql_connection.h"
#include "include/mysql_error.h"
#include "include/mysql_driver.h"
#include "include/cppconn/resultset.h"
#include "include/cppconn/statement.h"
#include "include/cppconn/prepared_statement.h"

#include "json/json.h"

using namespace std;
using namespace sql;
using namespace Json;

class DBManager {
private:
    Driver *driver;
    Connection *con;
    Statement *stmt;
    ResultSet *res;
public:
    DBManager();
    bool addUser(string userid, string userpw, string name);
    bool isExistUser(string userid);
    bool isUser(string userid, string userpw);
    bool updateUserStatus(string userid, int status);
    bool removeUser(string userid, string userpw);
    
    Value getAllUser();
    Value getAllChat();
    
    bool addChat(string from, string to, string msg);
};

#endif /* DBManager_hpp */
