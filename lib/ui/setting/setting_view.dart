import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutterstore/config/ps_colors.dart';
import 'package:flutterstore/config/ps_config.dart';
import 'package:flutterstore/constant/ps_dimens.dart';
import 'package:flutterstore/constant/route_paths.dart';
import 'package:flutterstore/ui/common/ps_admob_banner_widget.dart';
import 'package:flutterstore/utils/utils.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';

class SettingView extends StatefulWidget {
  const SettingView({Key key, @required this.animationController})
      : super(key: key);
  final AnimationController animationController;
  @override
  _SettingViewState createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;

  void checkConnection() {
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
      if (isConnectedToInternet && PsConfig.showAdMob) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: widget.animationController,
            curve: const Interval(0.5 * 1, 1.0, curve: Curves.fastOutSlowIn)));
    widget.animationController.forward();

    if (!isConnectedToInternet && PsConfig.showAdMob) {
      print('loading ads....');
      checkConnection();
    }
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 100 * (1.0 - animation.value), 0.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  _SettingPrivacyWidget(),
                  const SizedBox(height: PsDimens.space8),
                  _SettingNotificationWidget(),
                  const SizedBox(height: PsDimens.space8),
                  _SettingDarkAndWhiteModeWidget(
                      animationController: widget.animationController),
                  const SizedBox(height: PsDimens.space8),
                  _SettingAppVersionWidget(),
                  const PsAdMobBannerWidget(
                    admobBannerSize: AdmobBannerSize.MEDIUM_RECTANGLE,
                  ),
                  // Visibility(
                  //   visible: PsConfig.showAdMob &&
                  //       isSuccessfullyLoaded &&
                  //       isConnectedToInternet,
                  //   child: AdmobBanner(
                  //     adUnitId: Utils.getBannerAdUnitId(),
                  //     adSize: AdmobBannerSize.MEDIUM_RECTANGLE,
                  //     listener: (AdmobAdEvent event, Map<String, dynamic> map) {
                  //       print('BannerAd event is $event');
                  //       if (event == AdmobAdEvent.loaded) {
                  //         isSuccessfullyLoaded = true;
                  //       } else {
                  //         isSuccessfullyLoaded = false;
                  //         setState(() {});
                  //       }
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingPrivacyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('App Info');
        Navigator.pushNamed(context, RoutePaths.privacyPolicy, arguments: 1);
      },
      child: Container(
        color: PsColors.backgroundColor,
        padding: const EdgeInsets.all(PsDimens.space16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Utils.getString(context, 'setting__privacy_policy'),
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                const SizedBox(
                  height: PsDimens.space10,
                ),
                Text(
                  Utils.getString(context, 'setting__policy_statement'),
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: PsColors.mainColor,
              size: PsDimens.space12,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingNotificationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Notification Setting');
        Navigator.pushNamed(context, RoutePaths.notiSetting);
      },
      child: Container(
        color: PsColors.backgroundColor,
        padding: const EdgeInsets.all(PsDimens.space16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Utils.getString(context, 'setting__notification_setting'),
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                const SizedBox(
                  height: PsDimens.space10,
                ),
                Text(
                  Utils.getString(context, 'setting__control_setting'),
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: PsColors.mainColor,
              size: PsDimens.space12,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingDarkAndWhiteModeWidget extends StatefulWidget {
  const _SettingDarkAndWhiteModeWidget({Key key, this.animationController})
      : super(key: key);
  final AnimationController animationController;
  @override
  __SettingDarkAndWhiteModeWidgetState createState() =>
      __SettingDarkAndWhiteModeWidgetState();
}

class __SettingDarkAndWhiteModeWidgetState
    extends State<_SettingDarkAndWhiteModeWidget> {
  bool checkClick = false;
  bool isDarkOrWhite = false;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        color: PsColors.backgroundColor,
        padding: const EdgeInsets.only(
            top: PsDimens.space16,
            left: PsDimens.space16,
            bottom: PsDimens.space12,
            right: PsDimens.space12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              Utils.getString(context, 'setting__change_mode'),
              style: Theme.of(context).textTheme.subtitle1,
            ),
            if (checkClick)
              Switch(
                value: isDarkOrWhite,
                onChanged: (bool value) {
                  setState(() {
                    PsColors.loadColor2(value);
                    isDarkOrWhite = value;

                    changeBrightness(context);
                  });
                },
                activeTrackColor: PsColors.mainColor,
                activeColor: PsColors.mainColor,
              )
            else
              Switch(
                value: isDarkOrWhite,
                onChanged: (bool value) {
                  setState(() {
                    PsColors.loadColor2(value);
                    isDarkOrWhite = value;

                    changeBrightness(context);
                  });
                },
                activeTrackColor: PsColors.mainColor,
                activeColor: PsColors.mainColor,
              ),
          ],
        ));
  }
}

void changeBrightness(BuildContext context) {
  DynamicTheme.of(context).setBrightness(
      Utils.isLightMode(context) ? Brightness.dark : Brightness.light);
}

class _SettingAppVersionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('App Info');
      },
      child: Container(
        width: double.infinity,
        color: PsColors.backgroundColor,
        padding: const EdgeInsets.all(PsDimens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              Utils.getString(context, 'setting__app_version'),
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const SizedBox(
              height: PsDimens.space10,
            ),
            Text(
              PsConfig.app_version,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ),
      ),
    );
  }
}
