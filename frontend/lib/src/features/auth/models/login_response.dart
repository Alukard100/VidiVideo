class LoginResponse {

    final String id;
    final String userName;
    final String role;
    final String token;

    LoginResponse({

        required this.id,
        required this.userName,
        required this.role,
        required this.token,

    });

    factory LoginResponse.fromJson(Map<String,dynamic> json){

        return LoginResponse(

            id: json["id"],
            userName: json["userName"],
            role: json["role"],
            token: json["token"],

        );

    }

}