import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/alert_dialogs.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  bool showSpinner = false;
  bool isButtonEnabled = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isEmpty();
  }

  // TODO: refactor, abstract
  submit() async {
    final bool emailIsValid = EmailValidator.validate(email);
    setState(() {
      showSpinner = true;
    });
    try {
      if (emailIsValid) {
        final credential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        emailController.clear();
        passwordController.clear();
        Navigator.pushNamed(context, ChatScreen.id);
      }
      setState(() {
        showSpinner = false;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          showSpinner = false;
        });
        Platform.isIOS
            ? showAlertDialog(context, 'Erro', 'Usuário não encontrado!')
            : showMyDialog(context, 'Erro', 'Usuário não encontrado!');
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        setState(() {
          showSpinner = false;
        });
        Platform.isIOS
            ? showAlertDialog(context, 'Erro', 'Senha errada!')
            : showMyDialog(context, 'Erro', 'Senha errada!');
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print(e);
    }
  }

  bool isEmpty() {
    setState(() {
      if (emailController.text == '') {
        isButtonEnabled = true;
      }
    });
    return isButtonEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Insira seu email',
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Insira sua senha',
                ),
              ),
              const SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                color: Colors.lightBlueAccent,
                buttonTitle: 'Log In',
                onPressed: isButtonEnabled ? submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
