//
//  main.cpp
//  Server
//
//  Created by 현균 문 on 2018. 4. 15..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#include <iostream>
#include "Server.hpp"

using namespace std;

int main(int argc, const char * argv[]) {
    // insert code here...
    if(argc != 2) {
        printf("Usage : %s <port>\n", argv[0]);
        exit(1);
    }
    Server server;
    server.openServer(argv[1]);
    return 0;
}
