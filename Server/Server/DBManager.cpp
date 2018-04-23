//
//  DBManager.cpp
//  Server
//
//  Created by 현균 문 on 2018. 4. 20..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#include "DBManager.hpp"
//executeQuery when select
//executeUpdate when insert, update, delete

/**
 * @brief constructor
 * setting connection
 */
DBManager::DBManager() {
    driver = get_driver_instance();
    con = driver->connect("tcp://localhost:3306", "root", "root");
    con->setSchema("Chat");
    stmt = con->createStatement();
}

/**
 * @brief add user to database.
 * @param userid a string
 * @param userpw a string
 * @param name a string
 * @return bool Returns true if the user has been added.
 */
bool DBManager::addUser(string userid, string userpw, string name) {
    int result = stmt->executeUpdate("insert into `User` VALUES \
                                     ('"+userid+"', '"+userpw+"', '"+name+"', 'offline');");
    return result;
}

/**
 * @brief Check wehether the user is in the database
 * @param userid a string
 * @result bool Returns true if the user is in the database
 */
bool DBManager::isExistUser(string userid) {
    res = stmt->executeQuery("select id from `User` \
                             where id='"+userid+"';");
    return res->rowsCount();
}

/**
 * @brief Check whether user information (ID, password) is correct
 * @param userid a string
 * @param userpw a string
 * @return bool Returns true if the user is in the database
 */
bool DBManager::isUser(string userid, string userpw) {
    res = stmt->executeQuery("select id from `User` \
                             where id='"+userid+"' and pw='"+userpw+"';");
    return res->rowsCount();
}

/**
 * @brief update user's status
 * @param userid a string
 * @param status a string (online, offline, busy)
 * @return bool Returns true if the status change succeeds.
 */
bool DBManager::updateUserStatus(string userid, string status) {
    int result = stmt->executeUpdate("update `User` SET status='"+status+"' where id='"+userid+"';");
    return result;
}

/**
 * @brief update user's name
 * @param userid a string
 * @param name a string
 * @return bool Returns true if the name change succeeds.
 */
bool DBManager::updateUserName(string userid, string name) {
    int result = stmt->executeUpdate("update `User` SET name='"+name+"' where id='"+userid+"';");
    return result;
}


/**
 * @brief remove user from database
 * @param userid a string
 * @param userpw a string
 * @result bool if Returns true if the deletion succeeds.
 */
bool DBManager::removeUser(string userid, string userpw) {
    int result = stmt->executeUpdate("DELETE FROM `User` \
                                     WHERE id='"+userid+"' and pw='"+userpw+"';");
    return result;
}


/**
 * @brief change user's status to online if user's status is offline
 * @param userid a string
 * @return bool Returns true if the user is not offline or the status change succeeds.
 */
bool DBManager::changeOnlineifOffline(string userid) {
    res = stmt->executeQuery("select id, status from `User` where id='"+userid+"';");
    res->next();
    if (res->getString("status") == "offline") {
        return updateUserStatus(userid, "online");
    }
    else
        return true;
}

/**
 * @brief change user's status to offline if user's status is online
 * @param userid a string
 * @return bool Returns true if the status change succeeds.
 */
bool DBManager::changeOfflineifOnline(string userid) {
    res = stmt->executeQuery("select id, status from `User` where id='"+userid+"';");
    res->next();
    if (res->getString("status") == "online") {
        return updateUserStatus(userid, "offline");
    }
    else
        return false;
}

/**
 * @brief get all user from database
 * @return Value Returns user json array
 */
Value DBManager::getAllUser() {
    Value users;
    res = stmt->executeQuery("select id, name, status from `User`;");
    while (res->next()) {
        Value user;
        user["userid"] = res->getString("id").c_str();
        user["name"] = res->getString("name").c_str();
        user["status"] = res->getString("status").c_str();
        users.append(user);
    }
    return users;
}


/**
 * @brief get all chat from database
 * @return Value Returns chat json array
 */
Value DBManager::getAllChat() {
    Value chats;
    res = stmt->executeQuery("select * from `Message`;");
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

/**
 * @brief get all chat that person has sent or received.
 * @param userid string
 * @return Value Returns chat json array
 */
Value DBManager::getAllChatbyID(string userid) {
    Value chats;
    res = stmt->executeQuery("select * from `Message` where \
                             `from`='"+userid+"' or `to`='"+userid+"' or `to`='';");
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

/**
 * @brief add chat to database
 * @param from a string The user ID of the person who sent the chat.
 * @param to a string The user ID of the person who receive the chat. An empty string if chat is sent to everyone.
 * @param msg a string The content of the chat
 * @return bool Return true if chat is added.
 */
bool DBManager::addChat(string from, string to, string msg) {
    int result = stmt->executeUpdate("insert INTO `Message` \
                             (`Message`.from, `Message`.to, msg) VALUES \
                             ('"+from+"', '"+to+"', '"+msg+"');");
    return result;
}
