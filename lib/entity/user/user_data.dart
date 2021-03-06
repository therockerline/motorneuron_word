import 'package:firebase_auth/firebase_auth.dart';

class UserData {
    String name;
    String surname;
    String medicode;
    User account;

    UserData({this.name, this.surname, this.account, this.medicode});

    factory UserData.fromJson(Map<String, dynamic> json, User account) {
        return UserData(
            name: json['name'],
            surname: json['surname'],
            medicode: json['medicode'],
            account: account
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['name'] = this.name;
        data['surname'] = this.surname;
        data['medicode'] = this.medicode;
        data['uid'] = this.account.uid;
        return data;
    }
}