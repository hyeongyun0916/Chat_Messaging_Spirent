//
//  DefineString.h
//  Chat
//
//  Created by 현균 문 on 2018. 4. 21..
//  Copyright © 2018년 현균 문. All rights reserved.
//

#ifndef DefineString_h
#define DefineString_h

//#define kStatusSucess 0
//#define kStatusInvalidCmd -100
//#define kStatusInvalidPram -200
//#define kStatusNoDataFound 100
//#define kStatusAlreadyExists 200
//#define kStatusCouldntFindReason 999

typedef NS_ENUM(NSInteger, TCPStatusCode) {
    StatusSucess = 0,
    StatusInvalidCmd = -100,
    StatusInvalidPram = -200,
    StatusNoDataFound = 100,
    StatusAlreadyExists = 200,
    StatusCouldntFindReason = 999
};

typedef NS_ENUM(NSInteger, UserStatus) {
    UserStatusOffline = 1,
    UserStatusOnline = 2,
    UserStatusBusy = 3
};

#endif /* DefineString_h */
