//
//  Server.hpp
//  Server
//
//  Created by 현균 문 on 2018. 4. 20..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#ifndef Server_hpp
#define Server_hpp

#include <stdio.h>
#include <iostream>
#include <string>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <pthread.h>
#include <vector>
#include <map>

#include "DBManager.hpp"
#include "json/json.h"

using namespace Json;
using namespace std;

enum class StatusCode {
    Sucess = 0,
    InvalidCmd = -100,
    InvalidPram = -200,
    NoDataFound = 100,
    AlreadyExists = 200,
    CouldntFindReason = 999
};

class Server {
private:
    int serv_sock;
    struct sockaddr_in serv_addr;
    struct sockaddr_in clnt_addr;
    socklen_t clnt_addr_size;
    
    //static for thread
    static DBManager* dbManager;
    static vector<int> clnt_socks;
    static map<string, int> user_socks;
    static pthread_mutex_t mutx;
    
public:
    void openServer(const char* port);
    void* clnt_connection(void * arg);
    static void* clnt_connection_wrapper(void* object) {
        reinterpret_cast<Server*>(object)->clnt_connection(object);
        return 0;
    }
    void send_message(Value val, int sock);
    void error_handling(char const* message);
};

#endif /* Server_hpp */
