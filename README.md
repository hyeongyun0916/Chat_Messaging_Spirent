# Chat Program

This is Chat Program with TCP.\
Server written by c++.\
Client written by Objective-C

## Run

To run the Server project, clone the repo, and run `g++ main.cpp Server.cpp DBManager.cpp -I ./boost_1_67_0/ -I ./ -l mysqlcppconn -l jsoncpp -o chat.out -std=c++11` from the ./Server/Server directory.

To run the Client project, clone the repo and open `./Client/Chat/Chat.xcworkspace` and run with Xcode.

## Requirements

You need jsoncpp and mysql-connector-c++ and boost


```ruby
brew install jsoncpp
brew install mysql-connector-c++
brew install boost
```

## Author

mhg5303@gmail.com

## License

CampaignAdvisor is available under the MIT license. See the LICENSE file for more info.
