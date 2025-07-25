import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inscribevs/components/login/my_forgotpasswordbutton.dart';
import 'dart:convert';
import 'package:inscribevs/authentication/data_service.dart';
import 'package:inscribevs/components/login/my_loginbutton.dart';
import 'package:inscribevs/components/login/my_signupbutton.dart';
import 'package:inscribevs/components/login/my_logintextfield.dart';
import 'package:inscribevs/pages/home_page.dart';
import 'package:inscribevs/globals.dart' as globals;


//class LoginScreen extends StatefulWidget{
class LoginPage extends StatefulWidget{
  
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {
/*
  showDialog(
    context: context,
    builder: (context){
    return const body: Center(child: CircularProgressIndicator(),)
    },
  );*/

  // Local Token Storage
  final secureStorage = DataService.getInstance;

  //Holds the values types in by the user
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login() async{

      final String username =  usernameController.text;
      final String password = passwordController.text;

      //API endpoint url
      String URL = '${globals.base_url}/auth/login';
      //const String URL = 'https://inscribed-22337aee4c1b.herokuapp.com/api/auth/login';
      //final String URL = 'http://10.0.2.2:5000/api/auth/login';

    try{
      //Call the API endpoint 
      final response = await http.post(
        Uri.parse(URL),
        headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: json.encode(<String, String>{
          'username' : username,
          'password': password
        })
      );

      //if the response is ok
      if (response.statusCode == 200){
        // print("Token Before Deletion ${await secureStorage.read('token')}\n");
        // secureStorage.delete();
        //  print("Token After ${await secureStorage.read('token')}");

        final responseData = jsonDecode(response.body);
        var myToken = responseData['token'];
        secureStorage.addItem('token', myToken);
        String tokenStr = await secureStorage.read('token');
        print('Registration successful and here is token :${await secureStorage.read('token')}');

        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(token: tokenStr)),);



        // print('Registration successful: Token: ${token}');

      } else {
        print('Login failed: ${response.body}');
        final responseData = jsonDecode(response.body);
        String error =responseData['message'];

        var snackbar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error', 
            message: error, 
            contentType: ContentType.failure
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
  } catch (e){
      // Handle client-side errors
      print('Error during login: $e');
  }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
       backgroundColor: Color.fromARGB(255, 216, 243, 220),
      // body: MainPage(),
       body: SingleChildScrollView(
          child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                  //Welcome back! Log in
                  const SizedBox(height: 100),
                  const Text(
                    'Log In',
                    style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.w400
                    )
                  ),


                  //username text field
                  const SizedBox(height:20),

                  Form(
                    key: _form,
                    child: Column(children: [
                      MyLoginTextField(
                      controller: usernameController,
                      obscureText: false,
                      hintText: 'Username',
                      isUsernameField: true,
                      isPasswordField: false,            
                      ),
           
           
                  //password text field
                        const SizedBox(height: 10),
                        MyLoginTextField(
                            controller: passwordController,
                            obscureText: true,
                            hintText: 'Password',
                            isUsernameField: false,
                            isPasswordField: true,            
                        ),
                    ],)
                  ),
                  
                  

                  const SizedBox(height: 10),
                  ForgotPasswordbutton(),

                  const SizedBox(height: 20),
                  MyLoginButton(
                    onPressed: () {
                      if (_form.currentState!.validate()) {
                        print("Login Success");
                        _login();
                      }
                       
                    }
                  ),

                  const SizedBox(height: 10),
                  Signupbutton(),
                  ],
                ),
              ),
           
          ),
        )
      ),
    );
  }
}
