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

#include "DBManager.hpp"

using namespace std;

class Server {
private:
    int serv_sock;
    struct sockaddr_in serv_addr;
    struct sockaddr_in clnt_addr;
    socklen_t clnt_addr_size;
    
    static DBManager* dbManager;
    static vector<int> clnt_socks;
    static pthread_mutex_t mutx;
    
public:
    void openServer(const char* port);
    void connectDB();
    void* clnt_connection(void * arg);
    static void* clnt_connection_wrapper(void* object) {
        reinterpret_cast<Server*>(object)->clnt_connection(object);
        return 0;
    }
    void send_message(string str);
    void error_handling(char const* message);
};

#endif /* Server_hpp */
