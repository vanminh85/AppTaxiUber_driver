import 'package:drivers_app/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
{
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();


  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);

    signInFormValidation();
  }

  signInFormValidation()
  {
    if (!emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("Please write valid email.", context);
    }
    else if (passwordTextEditingController.text.trim().length < 5) {
      cMethods.displaySnackBar("Your password must be at least 6 or more characters.", context);
    }
    else
    {
      signInUser();
    }
  }

  signInUser() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Allowing to your login..."),
    );

    final User? userFirebase = (
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).catchError((errorMsg) {
          Navigator.pop(context);
          cMethods.displaySnackBar(errorMsg.toString(), context);
        })
    ).user;

    if(!context.mounted) return;
    Navigator.pop(context);

    if (userFirebase != null)
    {
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("drivers").child(userFirebase!.uid);
      usersRef.once().then((snap)
      {
        if (snap.snapshot.value != null)
        {
          if ((snap.snapshot.value as Map)["blockStatus"] == "no")
          {
            //userName = (snap.snapshot.value as Map)["name"];
            Navigator.push(context, MaterialPageRoute(builder: (c)=> Dashboard()));
          }
          else
          {
            FirebaseAuth.instance.signOut();
            cMethods.displaySnackBar("you are blocked. Contact admin: nvminh09@gmail.com", context);
          }
        }
        else
        {
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackBar("your record do not exists as a Driver.", context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              Image.asset(
                "assets/images/uberexec.png"
              ),

              Text(
                "Login as a Driver",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Text fields + button
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [

                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "your Email",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "your Password",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32,),

                    ElevatedButton(
                      onPressed: ()
                      {
                        checkIfNetworkIsAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                      ),
                      child: const Text(
                          "Login"
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12,),

              // Text button
              TextButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> SignUpScreen()));
                },
                child: const Text(
                  "Don\'t have an Account ? Register Here",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
