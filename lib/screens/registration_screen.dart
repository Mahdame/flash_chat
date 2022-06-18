import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flash_chat/components/alert_dialogs.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late String email;
  late String password;
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
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
      if (e.code == 'weak-password') {
        var weakPasswordMsg = 'Senha fraca!';
        Platform.isIOS
            ? showAlertDialog(context, 'Erro', weakPasswordMsg)
            : showMyDialog(context, 'Erro', weakPasswordMsg);
        print(weakPasswordMsg);
      } else if (e.code == 'email-already-in-use') {
        var emailAlreadyInUseMsg = 'Já existe uma conta utilizando este email.';
        Platform.isIOS
            ? showAlertDialog(context, 'Erro', emailAlreadyInUseMsg)
            : showMyDialog(context, 'Erro', emailAlreadyInUseMsg);
        print(emailAlreadyInUseMsg);
      }
      setState(() {
        showSpinner = false;
      });
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
                color: Colors.blueAccent,
                buttonTitle: 'Register',
                onPressed: isButtonEnabled ? submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
