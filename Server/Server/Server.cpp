//
//  Server.cpp
//  Server
//
//  Created by 현균 문 on 2018. 4. 20..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#include "Server.hpp"
#include "json/json.h"

using namespace Json;

#define BUFSIZE 1024

vector<int> Server::clnt_socks = vector<int>();
DBManager* Server::dbManager = new DBManager();
pthread_mutex_t Server::mutx;

void Server::openServer(const char* port) {
    connectDB();
    if(pthread_mutex_init(&mutx,NULL))
        error_handling("mutex init error");
    serv_sock = socket(PF_INET, SOCK_STREAM, 0);
    if(serv_sock == -1)
        error_handling("socket() error");
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(atoi(port));
    cout << 1 << endl;
    if(::bind(serv_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
        error_handling("bind() error");
    if(listen(serv_sock, 5) == -1)
        error_handling("listen() error");
    cout << 2 << endl;
    while(1) {
        pthread_t thread;
        cout << 3 << endl;
        clnt_addr_size = sizeof(clnt_addr);
        cout << 4 << endl;
        int clnt_sock;
        clnt_sock = accept(serv_sock, (struct sockaddr *)&clnt_addr, &clnt_addr_size);
        cout << 5 << endl;
        pthread_mutex_lock(&mutx);
        cout << 6 << endl;
        clnt_socks.push_back(clnt_sock);
        pthread_mutex_unlock(&mutx);
        cout << 7 << endl;
        pthread_create(&thread, NULL, &Server::clnt_connection_wrapper, (void*)(size_t)clnt_sock);
        cout << 8 << endl;
        printf(" IP : %s \n", inet_ntoa(clnt_addr.sin_addr));
        cout << 9 << endl;
        int result;
        pthread_join(thread, (void **)&result);
        cout << "result: " << result << endl;
    }
}

void Server::connectDB() {
    dbManager = new DBManager();
}

void *Server::clnt_connection(void *arg) {
    cout << 11 << endl;
    int clnt_sock = (int)(size_t)arg;
    int str_len=0;
    char message[BUFSIZE];
//    int i;
    cout << 12 << endl;
    while((str_len=read(clnt_sock, message, sizeof(message))) != 0 ) {
        Value val;
        CharReaderBuilder rBuiilder;
        CharReader *reader = rBuiilder.newCharReader();
        string errors;
        if (reader->parse(message, message+str_len, &val, &errors)) {
            /*
             cmd type
             signin
             singup
             signout
             status
             msg
             */
            cout << val["cmd"].asString() << endl;
            
            if (val["cmd"] == "signin") {
                
                if (dbManager->isUser(val["content"]["userid"].asString(), val["content"]["userpw"].asString()))
                    send_message("success\n");
                else
                send_message("fail\n");
            }
            else if (val["cmd"] == "msg") {
                send_message(val["content"].asString());
            }
            else
                cout << message << endl;
            
        }
        cout << 13 << endl;
    }
    cout << 14 << endl;
    pthread_mutex_lock(&mutx);
    cout << 15 << endl;
    for(vector<int>::iterator it = clnt_socks.begin();  it != clnt_socks.end(); it++) {
        if (*it == clnt_sock) {
            clnt_socks.erase(it);
            break;
        }
    }
    pthread_mutex_unlock(&mutx);
    cout << 16 << endl;
    close(clnt_sock);
    cout << 17 << endl;
    return 0;
    
}

void Server::send_message(string str) {
    int len = (int)str.length();
    char *message = new char[len + 1];
    strcpy(message, str.c_str());
    
    pthread_mutex_lock(&mutx);
    for(vector<int>::iterator it = clnt_socks.begin();  it != clnt_socks.end(); it++)
        write(*it, message, len);
    pthread_mutex_unlock(&mutx);
    delete [] message;
    
}

void Server::error_handling(char const* message) {
    fputs(message, stderr);
    fputc('\n',stderr);
    exit(1);
}

