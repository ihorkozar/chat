import 'package:chat/presentation/bloc/onboarding/onboarding_cubit.dart';
import 'package:chat/presentation/bloc/onboarding/onboarding_state.dart';
import 'package:chat/presentation/custom_widgets/common/custom_text_field.dart';
import 'package:chat/presentation/custom_widgets/onboarding/logo.dart';
import 'package:chat/presentation/custom_widgets/onboarding/profile_avatar.dart';
import 'package:chat/services/avatar_service.dart';
import 'package:chat/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'onboarding_router.dart';

class Onboarding extends StatefulWidget {
  final IOnboardingRouter router;

  Onboarding(this.router);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final AvatarService _avatarService = AvatarService();

  String _username = '';
  String _imageUrl = '';

  @override
  void initState() {
    _imageUrl = _avatarService.getRandomAvatarUrl();
    super.initState();
  }

  _updateAvatar() {
    setState(() {
      _imageUrl = _avatarService.getRandomAvatarUrl();
    });
  }

  _connectSession() async {
    await context.read<OnboardingCubit>().connect(_username, _imageUrl);
  }

  String _checkInputs() {
    var error = '';
    if (_username.isEmpty) {
      error = 'Please enter a username';
    }

    return error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Logo(),
                      ]),
                  Spacer(),
                  ProfileAvatar(onUpdateAvatar: _updateAvatar, imageUrl: _imageUrl),
                  Spacer(flex: 1),
                  Padding(
                      padding: EdgeInsets.only(left: 25, right: 25),
                      child: CustomTextField(
                        hint: 'What\'s your name?',
                        height: 45.0,
                        onChanged: (value) {
                          _username = value;
                        },
                        inputAction: TextInputAction.done,
                      )),
                  SizedBox(height: 30),
                  Padding(
                      padding: EdgeInsets.only(left: 25, right: 25),
                      child: ElevatedButton(
                          onPressed: () async {
                            final error = _checkInputs();
                            if (error.isNotEmpty) {
                              final snackBar = SnackBar(
                                  backgroundColor: Colors.redAccent,
                                  content: Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(error,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold))));

                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            } else {
                              await _connectSession();
                            }
                          },
                          child: Container(
                              height: 45,
                              alignment: Alignment.center,
                              child: Text('Let\'s chat!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .button
                                      ?.copyWith(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                          style: ElevatedButton.styleFrom(
                              primary: appColor,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(45))))),
                  Spacer(),
                  BlocConsumer<OnboardingCubit, OnboardingState>(
                      builder: (context, state) => state is Loading
                          ? Center(child: CircularProgressIndicator())
                          : Container(),
                      listener: (_, state) {
                        if (state is OnboardingSuccess) {
                          widget.router.onSessionSuccess(context, state.user);
                        }
                      }),
                  Spacer(flex: 2)

                  // CustomTextField()
                ])));
  }
}
