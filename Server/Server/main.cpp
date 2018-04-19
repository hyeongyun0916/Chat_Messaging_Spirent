//
//  main.cpp
//  Server
//
//  Created by 현균 문 on 2018. 4. 15..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <pthread.h>

#include "json/json.h"

using namespace std;
using namespace Json;

#define BUFSIZE 1024

void* clnt_connection(void * arg);
void send_message(char* message, int len);
void error_handling(char const* message);


int clnt_number=0;
int clnt_socks[10];

pthread_mutex_t mutx;


int main(int argc, const char * argv[]) {
    // insert code here...

    int serv_sock;
    int clnt_sock;
    struct sockaddr_in serv_addr;
    struct sockaddr_in clnt_addr;
    socklen_t clnt_addr_size;
    if(argc != 2) {
        printf("Usage : %s <port>\n", argv[0]);
        exit(1);
    }
    if(pthread_mutex_init(&mutx,NULL))
        error_handling("mutex init error");
    serv_sock = socket(PF_INET, SOCK_STREAM, 0);
    if(serv_sock == -1)
        error_handling("socket() error");
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(atoi(argv[1]));
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
        clnt_sock = accept(serv_sock, (struct sockaddr *)&clnt_addr, &clnt_addr_size);
        cout << 5 << endl;
        pthread_mutex_lock(&mutx);
        cout << 6 << endl;
        clnt_socks[clnt_number++]=clnt_sock;
        pthread_mutex_unlock(&mutx);
        cout << 7 << endl;
        pthread_create(&thread, NULL, clnt_connection, (void*)(size_t)clnt_sock);
        cout << 8 << endl;
        printf(" IP : %s \n", inet_ntoa(clnt_addr.sin_addr));
        cout << 9 << endl;
    }
    cout << 10 << endl;
    return 0;
}

void *clnt_connection(void *arg) {
    cout << 11 << endl;
    int clnt_sock = (int)(size_t)arg;
    int str_len=0;
    char message[BUFSIZE];
    int i;
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
             state
             
             msg
             */
            if (val["cmd"] == "msg") {
                string contentS = val["content"].asString();
                cout << "contentS" << contentS << endl;
                char *contentC = new char[contentS.length() + 1];
                strcpy(contentC, contentS.c_str());
                cout << "contentC" << contentC << endl;
                send_message(contentC, (int)contentS.length());
                delete [] contentC;
            }
            else
                cout << message << endl;
        }
        cout << 13 << endl;
    }
    cout << 14 << endl;
    pthread_mutex_lock(&mutx);
    cout << 15 << endl;
    for(i=0;i<clnt_number;i++){
        if(clnt_sock == clnt_socks[i]) {
            for(;i<clnt_number-1;i++)
                clnt_socks[i] = clnt_socks[i+1];
            break;
        }
    }
    clnt_number--;
    pthread_mutex_unlock(&mutx);
    cout << 16 << endl;
    close(clnt_sock);
    cout << 17 << endl;
    return 0;
    
}

void send_message(char * message, int len) {
    int i;
    pthread_mutex_lock(&mutx);
    for(i=0;i<clnt_number;i++)
        write(clnt_socks[i], message, len);
    pthread_mutex_unlock(&mutx);
}

void error_handling(char const* message) {
    fputs(message, stderr);
    fputc('\n',stderr);
    exit(1);
}

