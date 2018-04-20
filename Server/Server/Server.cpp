//
//  Server.cpp
//  Server
//
//  Created by 현균 문 on 2018. 4. 20..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#include "Server.hpp"

#define BUFSIZE 1024

vector<int> Server::clnt_socks = vector<int>();
DBManager* Server::dbManager = new DBManager();
map<string, int> Server::user_socks = map<string, int>();
pthread_mutex_t Server::mutx;


void Server::openServer(const char* port) {
    cout << "start" << endl;
    if(pthread_mutex_init(&mutx,NULL))
        error_handling("mutex init error");
    serv_sock = socket(PF_INET, SOCK_STREAM, 0);
    if(serv_sock == -1)
        error_handling("socket() error");
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(atoi(port));
    dbManager->getAllUser();
    if(::bind(serv_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
        error_handling("bind() error");
    if(listen(serv_sock, 5) == -1)
        error_handling("listen() error");
    while(1) {
        pthread_t thread;
        clnt_addr_size = sizeof(clnt_addr);
        int clnt_sock;
        clnt_sock = accept(serv_sock, (struct sockaddr *)&clnt_addr, &clnt_addr_size);
        pthread_mutex_lock(&mutx);
        clnt_socks.push_back(clnt_sock);
        pthread_mutex_unlock(&mutx);
        pthread_create(&thread, NULL, &Server::clnt_connection_wrapper, (void*)(size_t)clnt_sock);
        printf(" IP : %s \n", inet_ntoa(clnt_addr.sin_addr));
        int result;
        pthread_join(thread, (void **)&result);
        cout << "result: " << result << endl;
    }
}

void *Server::clnt_connection(void *arg) {
    int clnt_sock = (int)(size_t)arg;
    int str_len=0;
    char message[BUFSIZE];
    while((str_len=read(clnt_sock, message, sizeof(message))) != 0 ) {
        Value val;
        CharReaderBuilder rBuiilder;
        CharReader *reader = rBuiilder.newCharReader();
        string errors;
        if (reader->parse(message, message+str_len, &val, &errors)) {
            /*
             cmd type
             isexist
             signin
             singup
             signout
             status
             msg
             */
//            cout << val["cmd"].asString() << endl;
            if (val["cmd"]) {
                if (val["cmd"] == "isexist") {
                    //해당 아이디가 존재함 -> 가입불가
                    cout << 0 << endl;
                    if (dbManager->isExistUser(val["content"]["userid"].asString())) {
                        Value result;
                        result["cmd"] = val["cmd"];
                        result["result"] = static_cast<int>(StatusCode::Sucess);
                        result["msg"] = "Alreadyexist";
                        cout << 1 << endl;
                        send_message(result, clnt_sock);
                    }
                    //해당 아이디가 존재하지 않음 -> 가입가능
                    else {
                        Value result;
                        result["cmd"] = val["cmd"];
                        result["result"] = static_cast<int>(StatusCode::NoDataFound);
                        result["msg"] = "NoDataFound";
                        result["content"] = val["content"]["userid"];
                        cout << 2 << endl;
                        send_message(result, clnt_sock);
                    }
                }
                else if (val["cmd"] == "signup") {
                    if (dbManager->addUser(val["content"]["userid"].asString(), val["content"]["userpw"].asString(), val["content"]["name"].asString())) {
                        //success signin
                        Value result;
                        result["cmd"] = val["cmd"];
                        result["result"] = static_cast<int>(StatusCode::Sucess);
                        result["msg"] = "success";
                        send_message(result, clnt_sock);
                    } else {
                        //fail signup
                        Value result;
                        result["cmd"] = val["cmd"];
                        result["result"] = static_cast<int>(StatusCode::CouldntFindReason);
                        result["msg"] = "fail";
                        send_message(result, clnt_sock);
                    }
                }
                else if (val["cmd"] == "signin") {
                    //userid가 없을때 예외처리 필요
                    string userid = val["content"]["userid"].asString();
                    //Duplicate Signin Check 중복로그인체크
                    if (user_socks.find(userid) == user_socks.end()) {
                        //isMember 가입된유저인지 체크
                        if (dbManager->isUser(userid, val["content"]["userpw"].asString())) {
                            Value result;
                            result["cmd"] = val["cmd"];
                            result["result"] = static_cast<int>(StatusCode::Sucess);
                            result["msg"] = "success";
                            Value content;
                            content["users"] = dbManager->getAllUser();
                            content["chats"] = dbManager->getAllChat();
                            result["content"] = content;
                            user_socks.insert({userid, clnt_sock});
                            send_message(result, clnt_sock);
                        }
                        else {
                            Value result;
                            result["cmd"] = val["cmd"];
                            result["result"] = static_cast<int>(StatusCode::NoDataFound);
                            result["msg"] = "You are Not Member";
                            send_message(result, clnt_sock);
                        }
                    } else {
                        Value result;
                        result["cmd"] = val["cmd"];
                        result["result"] = static_cast<int>(StatusCode::AlreadyExists);
                        result["msg"] = "Already SignIn";
                        send_message(result, clnt_sock);
                    }
                }
                else if (val["cmd"] == "msg") {
                    Value result;
                    result["cmd"] = val["cmd"];
                    result["from"] = val["from"];
                    result["to"] = val["to"];
                    result["msg"] = val["msg"];
                    result["result"] = static_cast<int>(StatusCode::Sucess);
                    result["msg"] = "success";
                    send_message(result, -1);
                }
                else if (val["cmd"] == "status") {
                    if (dbManager->updateUserStatus(val["content"]["userid"].asString(), val["content"]["status"].asInt())) {
                        Value result;
                        result["cmd"] = val["cmd"];
                        result["result"] = static_cast<int>(StatusCode::Sucess);
                        result["msg"] = "success";
                        send_message(result, -1);
                    } else {
                        Value result;
                        result["cmd"] = val["cmd"];
                        result["result"] = static_cast<int>(StatusCode::CouldntFindReason);
                        result["msg"] = "CouldntFindReason";
                        send_message(result, -1);
                    }
                }
                else if (val["cmd"] == "signout") {
                    Value result;
                    result["cmd"] = val["cmd"];
                    result["result"] = static_cast<int>(StatusCode::Sucess);
                    result["msg"] = "success";
                    pthread_mutex_lock(&mutx);
                    //user_socks에서 지워주기
                    for (map<string,int>::iterator it = user_socks.begin(); it != user_socks.end(); it++) {
                        if (it->second == clnt_sock) {
                            user_socks.erase(it);
                            break;
                        }
                    }
                    pthread_mutex_unlock(&mutx);
                    send_message(result, clnt_sock);
                }
                else {
                    Value result;
                    result["cmd"] = val["cmd"];
                    result["result"] = static_cast<int>(StatusCode::InvalidCmd);
                    result["msg"] = "InvalidCmd";
                    send_message(result, clnt_sock);
                }
            } else {
                Value result;
                result["cmd"] = "cmd";
                result["result"] = static_cast<int>(StatusCode::InvalidPram);
                result["msg"] = "InvalidPram";
                send_message(result, clnt_sock);
            }
        }
    }
    //유저가 나갔을때
    pthread_mutex_lock(&mutx);
    //user_socks에서 지워주기 (signout을 하고 나가지 않은 경우)
    for (map<string,int>::iterator it = user_socks.begin(); it != user_socks.end(); it++) {
        if (it->second == clnt_sock) {
            user_socks.erase(it);
            break;
        }
    }
    //clnt_socks에서 지워주기
    for(vector<int>::iterator it = clnt_socks.begin();  it != clnt_socks.end(); it++) {
        if (*it == clnt_sock) {
            clnt_socks.erase(it);
            break;
        }
    }
    pthread_mutex_unlock(&mutx);
    close(clnt_sock);
    return 0;
    
}

void Server::send_message(Value val, int sock) {
    StreamWriterBuilder builder;
    string str = writeString(builder, val);
    
    str.erase(remove(str.begin(), str.end(), '\n'), str.end());
    str += "\n";
    
    cout << "str: \n" << str << endl;
    int len = (int)str.length();
    char *message = new char[len + 1];
    strcpy(message, str.c_str());
    cout << "message: \n" << str << endl;
    if (sock != -1) {
        pthread_mutex_lock(&mutx);
        for(vector<int>::iterator it = clnt_socks.begin();  it != clnt_socks.end(); it++)
            write(*it, message, len);
        pthread_mutex_unlock(&mutx);
    } else {
        write(sock, message, len);
    }
    delete [] message;
    
}

void Server::error_handling(char const* message) {
    fputs(message, stderr);
    fputc('\n',stderr);
    exit(1);
}

