//
//  Server.cpp
//  Server
//
//  Created by 현균 문 on 2018. 4. 20..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#include "Server.hpp"
#include <ctime>
#include <sstream>
#include <iomanip>

#define BUFSIZE 1024

//initialize for static thread function
vector<int> Server::clnt_socks = vector<int>();
DBManager* Server::dbManager = new DBManager();
map<string, int> Server::user_socks = map<string, int>();
pthread_mutex_t Server::mutx;


void Server::openServer(const char* port) {
    cout << "start" << endl;
    //lock init
    if(pthread_mutex_init(&mutx,NULL))
        error_handling("mutex init error");
    //set socket
    serv_sock = socket(PF_INET, SOCK_STREAM, 0);
    if(serv_sock == -1)
        error_handling("socket() error");
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(atoi(port));
    
    //bind -> listen -> accept
    if(::bind(serv_sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
        error_handling("bind() error");
    if(listen(serv_sock, 5) == -1)
        error_handling("listen() error");
    while(1) {
        //make pthread_t for client
        pthread_t thread;
        clnt_addr_size = sizeof(clnt_addr);
        int clnt_sock;
        clnt_sock = accept(serv_sock, (struct sockaddr *)&clnt_addr, &clnt_addr_size);
        //lock
        pthread_mutex_lock(&mutx);
        clnt_socks.push_back(clnt_sock);
        pthread_mutex_unlock(&mutx);
        //make threadFunction
        pthread_create(&thread, NULL, &Server::clnt_connection_wrapper, (void*)(size_t)clnt_sock);
        printf(" IP : %s \n", inet_ntoa(clnt_addr.sin_addr));
        
//        int result;
//        pthread_join(thread, (void **)&result);
//        cout << "result: " << result << endl;
    }
}

void *Server::clnt_connection(void *arg) {
    int clnt_sock = (int)(size_t)arg;
    int str_len=0;
    char message[BUFSIZE];
    
    //get time for calculate interval between Server and Client
    time_t t = time(0);   // get time now
    tm* now = localtime(&t);
    stringstream ss;
    ss << setfill('0')
    << setw(2) <<  now->tm_year+1900 << setw(2) << now->tm_mon + 1 << setw(2) << now->tm_mday << setw(2) << now->tm_hour << setw(2) << now->tm_min << setw(2) << now->tm_sec;
    cout << "time: " << ss.str() << endl;
    Value time;
    time["result"] = static_cast<int>(StatusCode::Sucess);
    time["msg"] = "success";
    time["cmd"] = "time";
    time["content"] = ss.str();
    send_message(time, clnt_sock);
    
    while((str_len=read(clnt_sock, message, sizeof(message))) != 0 ) {
        Value val;
        CharReaderBuilder rBuiilder;
        CharReader *reader = rBuiilder.newCharReader();
        string errors;
        //message to json
        if (reader->parse(message, message+str_len, &val, &errors)) {
            /*
             cmd type
             isexist
             singup
             signin
             msg
             status
             signout
             removeuser
             */
            if (val["cmd"]) {
                if (val["cmd"] == "isexist") {
                    //exist id so can't join member
                    //해당 아이디가 존재함 -> 가입불가
                    if (dbManager->isExistUser(val["content"]["userid"].asString())) {
                        Value result;
                        result["cmd"] = val["cmd"];
                        result["result"] = static_cast<int>(StatusCode::Sucess);
                        result["msg"] = "Alreadyexist";
                        send_message(result, clnt_sock);
                    }
                    //no exist id so can join member
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
                    string userid = val["content"]["userid"].asString();
                    //Duplicate Signin Check 중복로그인체크
                    if (user_socks.find(userid) == user_socks.end()) {
                        //is Member 가입된유저인지 체크
                        if (dbManager->isUser(userid, val["content"]["userpw"].asString())) {
                            if (dbManager->changeOnlineifOffline(userid)) {
                                Value result;
                                result["cmd"] = val["cmd"];
                                result["result"] = static_cast<int>(StatusCode::Sucess);
                                result["msg"] = "success";
                                Value content;
                                content["userid"] = userid;
                                Value users = dbManager->getAllUser();
                                content["users"] = users;
                                content["chats"] = dbManager->getAllChat();
                                result["content"] = content;
                                user_socks.insert({userid, clnt_sock});
                                
                                //notify to other that one's status changed
                                //다른사람들에게 현 사람의 status가 바뀌었음을 알림.
                                Value forOthers;
                                forOthers["cmd"] = "userchanged";
                                forOthers["result"] = static_cast<int>(StatusCode::Sucess);
                                forOthers["msg"] = "success";
                                forOthers["content"] = users;
                                send_message(forOthers, clnt_sock*-1);
                                
                                send_message(result, clnt_sock);
                            }
                            else {
                                //fail query
                                Value result;
                                result["cmd"] = val["cmd"];
                                result["result"] = static_cast<int>(StatusCode::CouldntFindReason);
                                result["msg"] = "CouldntFindReason";
                                send_message(result, clnt_sock);
                            }
                        }
                        else {
                            //not member
                            Value result;
                            result["cmd"] = val["cmd"];
                            result["result"] = static_cast<int>(StatusCode::NoDataFound);
                            result["msg"] = "You are Not Member";
                            send_message(result, clnt_sock);
                        }
                    }
                    //Already SignIn
                    else {
                        Value result;
                        result["cmd"] = val["cmd"];
                        result["result"] = static_cast<int>(StatusCode::AlreadyExists);
                        result["msg"] = "Already SignIn";
                        send_message(result, clnt_sock);
                    }
                }
                //notify message
                else if (val["cmd"] == "msg") {
                    dbManager->addChat(val["content"]["from"].asString(), val["content"]["to"].asString(), val["content"]["msg"].asString());
                    Value result;
                    result["cmd"] = val["cmd"];
                    result["result"] = static_cast<int>(StatusCode::Sucess);
                    result["msg"] = "success";
                    result["content"] = val["content"];
                    //if content has to then it is whisper
                    if (val["content"]["to"] == "") {
                        send_message(result, 0);
                    }
                    else {
                        if (user_socks.find(val["content"]["to"].asString()) == user_socks.end()) {
                            cout << "it's whisper but couldn't find" << endl;
                            send_message(result, 0);
                        } else {
                            send_message(result, user_socks[val["content"]["to"].asString()]);
                            send_message(result, user_socks[val["content"]["from"].asString()]);
                        }
                    }
                    
                }
                //change status
                else if (val["cmd"] == "status") {
                    if (dbManager->updateUserStatus(val["content"]["userid"].asString(), val["content"]["status"].asString())) {
                        Value result;
                        result["cmd"] = val["cmd"];
                        result["result"] = static_cast<int>(StatusCode::Sucess);
                        result["msg"] = "success";
                        Value content;
                        content["userid"] = val["content"]["userid"];
                        content["status"] = val["content"]["status"];
                        result["content"] = content;
                        send_message(result, 0);
                    } else {
                        cout << "else" << endl;
                        Value result;
                        result["cmd"] = val["cmd"];
                        result["result"] = static_cast<int>(StatusCode::CouldntFindReason);
                        result["msg"] = "CouldntFindReason";
                        send_message(result, 0);
                    }
                }
                //change name
                else if (val["cmd"] == "name") {
                    if (dbManager->updateUserName(val["content"]["userid"].asString(), val["content"]["name"].asString())) {
                        Value result;
                        result["cmd"] = val["cmd"];
                        result["result"] = static_cast<int>(StatusCode::Sucess);
                        result["msg"] = "success";
                        Value content;
                        content["userid"] = val["content"]["userid"];
                        content["name"] = val["content"]["name"];
                        result["content"] = content;
                        send_message(result, 0);
                    } else {
                        Value result;
                        result["cmd"] = val["cmd"];
                        result["result"] = static_cast<int>(StatusCode::CouldntFindReason);
                        result["msg"] = "CouldntFindReason";
                        send_message(result, 0);
                    }
                }
                else if (val["cmd"] == "signout") {
                    Value result;
                    result["cmd"] = val["cmd"];
                    result["result"] = static_cast<int>(StatusCode::Sucess);
                    result["msg"] = "success";
                    string status = val["content"]["status"] == "busy" ? "busy" : "offline";
                    dbManager->updateUserStatus(val["content"]["userid"].asString(), status);
                    pthread_mutex_lock(&mutx);
                    //remove from user_socks
                    //user_socks에서 지워주기
                    for (map<string,int>::iterator it = user_socks.begin(); it != user_socks.end(); it++) {
                        if (it->second == clnt_sock) {
                            user_socks.erase(it);
                            break;
                        }
                    }
                    pthread_mutex_unlock(&mutx);
                    send_message(result, clnt_sock);
                    
                    //notify that one's status changed
                    //다른사람들에게 현 사람의 status가 바뀌었음을 알림.
                    Value forOthers;
                    forOthers["cmd"] = "userchanged";
                    forOthers["result"] = static_cast<int>(StatusCode::Sucess);
                    forOthers["msg"] = "success";
                    forOthers["content"] = dbManager->getAllUser();
                    send_message(forOthers, clnt_sock*-1);

                }
                //remove member
                else if (val["cmd"] == "removeuser") {
                    if (dbManager->removeUser(val["content"]["userid"].asString(), val["content"]["userpw"].asString())) {
                        Value result;
                        result["cmd"] = val["cmd"];
                        result["result"] = static_cast<int>(StatusCode::Sucess);
                        result["msg"] = "success";
                        send_message(result, clnt_sock);
                    }
                    else {
                        Value result;
                        result["cmd"] = val["cmd"];
                        result["result"] = static_cast<int>(StatusCode::CouldntFindReason);
                        result["msg"] = "FailCouldntFindReason";
                        send_message(result, clnt_sock);
                    }
                }
                //exception
                else {
                    Value result;
                    result["cmd"] = val["cmd"];
                    result["result"] = static_cast<int>(StatusCode::InvalidCmd);
                    result["msg"] = "InvalidCmd";
                    send_message(result, clnt_sock);
                }
            }
            //exception
            else {
                Value result;
                result["cmd"] = "cmd";
                result["result"] = static_cast<int>(StatusCode::InvalidPram);
                result["msg"] = "InvalidPram";
                send_message(result, clnt_sock);
            }
        }
    }
    //remove from user_socks when user out(not signout ex. exit app)
    //유저가 나갔을때
    //user_socks에서 지워주기 (signout을 하고 나가지 않은 경우)
    for (map<string,int>::iterator it = user_socks.begin(); it != user_socks.end(); it++) {
        if (it->second == clnt_sock) {
            if (dbManager->changeOfflineifOnline(it->first)) {
                //notify that one's status changed
                //다른사람들에게 현 사람의 status가 바뀌었음을 알림.
                Value forOthers;
                forOthers["cmd"] = "userchanged";
                forOthers["result"] = static_cast<int>(StatusCode::Sucess);
                forOthers["msg"] = "success";
                forOthers["content"] = dbManager->getAllUser();
                send_message(forOthers, clnt_sock*-1);
            }
            user_socks.erase(it);
            break;
        }
    }
    //remove from clnt_socks
    //clnt_socks에서 지워주기
    pthread_mutex_lock(&mutx);
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
    cout << str << endl;
    int len = (int)str.length();
    char *message = new char[len + 1];
    strcpy(message, str.c_str());
    //if sock is 0 notify to all, if negative notify except that person, if positive send only that person
    //0이면 전체에게, 0미만이면 해당사람빼고 모두, 0이상이면 그사람에게만
    if (sock == 0) {
        pthread_mutex_lock(&mutx);
        for (int i = 0; i < clnt_socks.size(); i++) {
            write(clnt_socks[i], message, len);
        }
        pthread_mutex_unlock(&mutx);
    } else if (sock < 0) {
        pthread_mutex_lock(&mutx);
        for (int i = 0; i < clnt_socks.size(); i++) {
            if (clnt_socks[i] != sock*-1)
                write(clnt_socks[i], message, len);
        }
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

