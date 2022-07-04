import 'package:chat/util/composition_root.dart';
import 'package:chat/util/theme.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CompositionRoot.configure();
  final firstPage = CompositionRoot.start();
  runApp(MyApp(firstPage));
}

class MyApp extends StatelessWidget {
  final Widget firstPage;

  const MyApp(this.firstPage, {Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Chat App',
        debugShowCheckedModeBanner: false,
        theme: lightTheme(context),
        darkTheme: darkTheme(context),
        home: firstPage);
  }
}
