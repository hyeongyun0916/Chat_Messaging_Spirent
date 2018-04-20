//
//  DBManager.cpp
//  Server
//
//  Created by 현균 문 on 2018. 4. 20..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#include "DBManager.hpp"

DBManager::DBManager() {
    driver = get_driver_instance();
    con = driver->connect("tcp://localhost:3306", "root", "root");
    con->setSchema("Chat");
    stmt = con->createStatement();
}

bool DBManager::addUser(string userid, string userpw, string name) {
    int result = stmt->executeUpdate("insert into `User` VALUES \
                                     ('"+userid+"', '"+userpw+"', '"+name+"', 'offline');");
    return result;
}

bool DBManager::isExistUser(string userid) {
    res = stmt->executeQuery("select * from `User` \
                             where id='"+userid+"';");
    return res->rowsCount();
}

bool DBManager::isUser(string userid, string userpw) {
    res = stmt->executeQuery("select * from `User` \
                             where id='"+userid+"' and pw='"+userpw+"';");
    return res->rowsCount();
}

bool DBManager::updateUserStatus(string userid, int status) {
    PreparedStatement  *prep_stmt;
    prep_stmt = con->prepareStatement("update `User` SET status=? where id='"+userid+"';");
    prep_stmt->setInt(1, status);
    int result = prep_stmt->executeUpdate();
    return result;
}

bool DBManager::removeUser(string userid, string userpw) {
    int result = stmt->executeUpdate("DELETE FROM `User` \
                                     WHERE id='"+userid+"' and pw='"+userpw+"';");
    return result;
}

Value DBManager::getAllUser() {
    Value users;
    res = stmt->executeQuery("select * from `User`;");
    while (res->next()) {
        Value user;
        user["name"] = res->getString("name").c_str();
        user["state"] = res->getString("status").c_str();
        users.append(user);
    }
    return users;
}

Value DBManager::getAllChat() {
    Value chats;
    res = stmt->executeQuery("select * from `Chat`;");
    while (res->next()) {
        Value chat;
        chat["chatno"] = res->getInt("chatno");
        chat["from"] = res->getString("from").c_str();
        chat["to"] = res->getString("to").c_str();
        chat["msg"] = res->getString("msg").c_str();
        chat["timestamp"] = res->getString("timestamp").c_str();
        chats.append(chat);
    }
    return chats;
}

bool DBManager::addChat(string from, string to, string msg) {
    int result = stmt->executeUpdate("insert INTO `Message` \
                             (`Message`.from, `Message`.to, msg) VALUES \
                             ('"+from+"', '"+to+"', '"+msg+"');");
    return result;
}
