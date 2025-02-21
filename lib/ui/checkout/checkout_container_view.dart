import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutterstore/api/common/ps_resource.dart';
import 'package:flutterstore/api/ps_api_service.dart';
import 'package:flutterstore/config/ps_colors.dart';
import 'package:flutterstore/constant/ps_dimens.dart';
import 'package:flutterstore/constant/route_paths.dart';
import 'package:flutterstore/provider/basket/basket_provider.dart';
import 'package:flutterstore/provider/coupon_discount/coupon_discount_provider.dart';
import 'package:flutterstore/provider/shipping_cost/shipping_cost_provider.dart';
import 'package:flutterstore/provider/shipping_method/shipping_method_provider.dart';
import 'package:flutterstore/provider/shop_info/shop_info_provider.dart';
import 'package:flutterstore/provider/token/token_provider.dart';
import 'package:flutterstore/provider/transaction/transaction_header_provider.dart';
import 'package:flutterstore/provider/user/user_provider.dart';
import 'package:flutterstore/repository/basket_repository.dart';
import 'package:flutterstore/repository/coupon_discount_repository.dart';
import 'package:flutterstore/repository/shipping_cost_repository.dart';
import 'package:flutterstore/repository/shipping_method_repository.dart';
import 'package:flutterstore/repository/shop_info_repository.dart';
import 'package:flutterstore/repository/token_repository.dart';
import 'package:flutterstore/repository/transaction_header_repository.dart';
import 'package:flutterstore/repository/user_repository.dart';
import 'package:flutterstore/ui/common/dialog/confirm_dialog_view.dart';
import 'package:flutterstore/ui/common/dialog/error_dialog.dart';
import 'package:flutterstore/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterstore/utils/utils.dart';
import 'package:flutterstore/viewobject/api_status.dart';
import 'package:flutterstore/viewobject/basket.dart';
import 'package:flutterstore/viewobject/common/ps_value_holder.dart';
import 'package:flutterstore/viewobject/holder/intent_holder/credit_card_intent_holder.dart';
import 'package:flutterstore/viewobject/user.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../ui/checkout/checkout1_view.dart';
import '../../ui/checkout/checkout2_view.dart';
import '../../ui/checkout/checkout3_view.dart';

class CheckoutContainerView extends StatefulWidget {
  const CheckoutContainerView({
    Key key,
    @required this.basketList,
    @required this.publishKey,
  }) : super(key: key);

  final List<Basket> basketList;
  final String publishKey;

  @override
  _CheckoutContainerViewState createState() => _CheckoutContainerViewState();
}

class _CheckoutContainerViewState extends State<CheckoutContainerView> {
  int viewNo = 1;
  int maxViewNo = 5;
  UserRepository userRepository;
  UserProvider userProvider;
  TokenProvider tokenProvider;
  PsValueHolder valueHolder;
  CouponDiscountRepository couponDiscountRepo;
  TransactionHeaderRepository transactionHeaderRepo;
  BasketRepository basketRepository;
  ShippingCostRepository shippingCostRepository;
  ShippingMethodRepository shippingMethodRepository;
  ShopInfoRepository shopInfoRepository;
  String couponDiscount;
  ShippingMethodProvider shippingMethodProvider;
  CouponDiscountProvider couponDiscountProvider;
  BasketProvider basketProvider;
  ShippingCostProvider shippingCostProvider;
  TransactionHeaderProvider transactionSubmitProvider;
  PsApiService psApiService;
  TokenRepository tokenRepository;
  @override
  Widget build(BuildContext context) {
    void _closeCheckoutContainer() {
      Navigator.pop(context);
    }

    userRepository = Provider.of<UserRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);

    couponDiscountRepo = Provider.of<CouponDiscountRepository>(context);
    transactionHeaderRepo = Provider.of<TransactionHeaderRepository>(context);
    shippingCostRepository = Provider.of<ShippingCostRepository>(context);
    shippingMethodRepository = Provider.of<ShippingMethodRepository>(context);
    shopInfoRepository = Provider.of<ShopInfoRepository>(context);
    basketRepository = Provider.of<BasketRepository>(context);
    psApiService = Provider.of<PsApiService>(context);
    tokenRepository = Provider.of<TokenRepository>(context);
    return MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<CouponDiscountProvider>(
              lazy: false,
              create: (BuildContext context) {
                couponDiscountProvider =
                    CouponDiscountProvider(repo: couponDiscountRepo);

                return couponDiscountProvider;
              }),
          ChangeNotifierProvider<BasketProvider>(
              lazy: false,
              create: (BuildContext context) {
                basketProvider = BasketProvider(repo: basketRepository);

                return basketProvider;
              }),
          ChangeNotifierProvider<UserProvider>(
              lazy: false,
              create: (BuildContext context) {
                userProvider = UserProvider(
                    repo: userRepository, psValueHolder: valueHolder);
                userProvider
                    .getUserFromDB(userProvider.psValueHolder.loginUserId);
                return userProvider;
              }),
          ChangeNotifierProvider<ShippingCostProvider>(
              lazy: false,
              create: (BuildContext context) {
                shippingCostProvider =
                    ShippingCostProvider(repo: shippingCostRepository);

                return shippingCostProvider;
              }),
          ChangeNotifierProvider<TransactionHeaderProvider>(
              lazy: false,
              create: (BuildContext context) {
                transactionSubmitProvider = TransactionHeaderProvider(
                    repo: transactionHeaderRepo, psValueHolder: valueHolder);

                return transactionSubmitProvider;
              }),
          ChangeNotifierProvider<TokenProvider>(
              lazy: false,
              create: (BuildContext context) {
                tokenProvider = TokenProvider(repo: tokenRepository);
                return tokenProvider;
              }),
          ChangeNotifierProvider<ShippingMethodProvider>(
              lazy: false,
              create: (BuildContext context) {
                shippingMethodProvider = ShippingMethodProvider(
                    repo: shippingMethodRepository,
                    psValueHolder: valueHolder,
                    defaultShippingId: valueHolder.shippingId);
                shippingMethodProvider.loadShippingMethodList();
                return shippingMethodProvider;
              }),
          ChangeNotifierProvider<ShopInfoProvider>(
              lazy: false,
              create: (BuildContext context) {
                final ShopInfoProvider provider = ShopInfoProvider(
                    repo: shopInfoRepository,
                    psValueHolder: valueHolder,
                    ownerCode: 'CheckoutContainerView');
                provider.loadShopInfo();
                return provider;
              }),
        ],
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: PsDimens.space160,
                child: _TopImageForCheckout(
                  viewNo: viewNo,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              checkForTopImage(),
            ],
          ),
          bottomNavigationBar: checkHideOrShowBackArrowBar(
              _closeCheckoutContainer, tokenProvider),
        ));
  }

  Container checkForTopImage() {
    if (viewNo == 4) {
      return Container(child: checkToShowView());
    } else {
      return Container(
          margin: const EdgeInsets.only(top: PsDimens.space160),
          child: checkToShowView());
    }
  }

  dynamic checkout1ViewState;
  dynamic checkout2ViewState;
  dynamic checkout3ViewState;
  bool isApiSuccess = false;

  void updateCheckout1ViewState(State state) {
    checkout1ViewState = state;
  }

  void updateCheckout2ViewState(State state) {
    checkout2ViewState = state;
  }

  void updateCheckout3ViewState(State state) {
    checkout3ViewState = state;
  }

  dynamic checkToShowView() {
    if (viewNo == 1) {
      return Checkout1View(updateCheckout1ViewState);
    } else if (viewNo == 2) {
      shippingMethodProvider.loadShippingMethodList();
      return Container(
        color: PsColors.coreBackgroundColor,
        child: Checkout2View(
          basketList: widget.basketList,
          publishKey: widget.publishKey,
        ),
      );
    } else if (viewNo == 3) {
      return Container(
        color: PsColors.coreBackgroundColor,
        child: Checkout3View(
          updateCheckout3ViewState,
          widget.basketList,
        ),
      );
    }
  }

  dynamic checkHideOrShowBackArrowBar(
      Function _closeCheckoutContainer, TokenProvider tokenProvider) {
    if (viewNo == 4) {
      return Container(
        height: 0,
      );
    } else {
      return Container(
          height: 60,
          color: PsColors.mainColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              checkHideOrShowBackArrow(),
              Container(
                  height: 50,
                  color: PsColors.mainColor,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Stack(
                      alignment: const Alignment(0.0, 0.0),
                      children: <Widget>[
                        Container(
                          margin:
                              const EdgeInsets.only(right: PsDimens.space36),
                          child: GestureDetector(
                            child: Text(
                                viewNo == 3
                                    ? Utils.getString(context,
                                        'basket_list__checkout_button_name')
                                    : Utils.getString(
                                        context, 'checkout_container__next'),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(color: PsColors.white)),
                            onTap: () {
                              clickToNextCheck(userProvider.user.data,
                                  _closeCheckoutContainer, tokenProvider);
                            },
                          ),
                        ),
                        Positioned(
                          right: 1,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: PsColors.white,
                              size: PsDimens.space16,
                            ),
                            onPressed: () {
                              clickToNextCheck(userProvider.user.data,
                                  _closeCheckoutContainer, tokenProvider);
                            },
                          ),
                        )
                      ],
                    ),
                  ))
            ],
          ));
    }
  }

  dynamic clickToNextCheck(User user, Function _closeCheckoutContainer,
      TokenProvider tokenProvider) async {
    if (viewNo < maxViewNo) {
      if (viewNo == 3) {
        checkout3ViewState.checkStatus();
        if (checkout3ViewState.isCheckBoxSelect) {
          if (checkout3ViewState.isPaypalClicked) {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmDialogView(
                      description: Utils.getString(
                          context, 'checkout_container__confirm_order'),
                      leftButtonText: Utils.getString(
                          context, 'home__logout_dialog_cancel_button'),
                      rightButtonText: Utils.getString(
                          context, 'home__logout_dialog_ok_button'),
                      onAgreeTap: () async {
                        Navigator.pop(context);
                        final PsResource<ApiStatus> tokenResource =
                            await tokenProvider.loadToken();
                        final dynamic returnData =
                            await checkout3ViewState.payNow(
                                tokenResource.data.message,
                                userProvider,
                                transactionSubmitProvider,
                                couponDiscountProvider,
                                shippingMethodProvider,
                                shippingCostProvider,
                                valueHolder,
                                basketProvider);
                        if (returnData != null && returnData) {
                          _closeCheckoutContainer();
                        }
                      });
                });
          } else if (checkout3ViewState.isStripeClicked) {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmDialogView(
                      description: Utils.getString(
                          context, 'checkout_container__confirm_order'),
                      leftButtonText: Utils.getString(
                          context, 'home__logout_dialog_cancel_button'),
                      rightButtonText: Utils.getString(
                          context, 'home__logout_dialog_ok_button'),
                      onAgreeTap: () async {
                        Navigator.pop(context);
                        final dynamic returnData = await Navigator.pushNamed(
                            context, RoutePaths.creditCard,
                            arguments: CreditCardIntentHolder(
                                basketList: widget.basketList,
                                couponDiscount:
                                    couponDiscountProvider.couponDiscount ??
                                        '0.0',
                                transactionSubmitProvider:
                                    transactionSubmitProvider,
                                userProvider: userProvider,
                                basketProvider: basketProvider,
                                psValueHolder: valueHolder,
                                shippingCostProvider: shippingCostProvider,
                                shippingMethodProvider: shippingMethodProvider,
                                memoText:
                                    checkout3ViewState.memoController.text,
                                publishKey: widget.publishKey));

                        if (returnData != null && returnData) {
                          _closeCheckoutContainer();
                        }
                      });
                });
          } else if (checkout3ViewState.isCashClicked) {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmDialogView(
                      description: Utils.getString(
                          context, 'checkout_container__confirm_order'),
                      leftButtonText: Utils.getString(
                          context, 'home__logout_dialog_cancel_button'),
                      rightButtonText: Utils.getString(
                          context, 'home__logout_dialog_ok_button'),
                      onAgreeTap: () async {
                        Navigator.pop(context);
                        final dynamic returnData =
                            await checkout3ViewState.callCardNow(
                          basketProvider,
                          userProvider,
                          transactionSubmitProvider,
                          shippingMethodProvider,
                        );
                        if (returnData != null && returnData) {
                          _closeCheckoutContainer();
                        }
                      });
                });
          } else if (checkout3ViewState.isBankClicked) {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmDialogView(
                      description: Utils.getString(
                          context, 'checkout_container__confirm_order'),
                      leftButtonText: Utils.getString(
                          context, 'home__logout_dialog_cancel_button'),
                      rightButtonText: Utils.getString(
                          context, 'home__logout_dialog_ok_button'),
                      onAgreeTap: () async {
                        Navigator.pop(context);
                        final dynamic returnData =
                            await checkout3ViewState.callBankNow(
                          basketProvider,
                          userProvider,
                          transactionSubmitProvider,
                          shippingMethodProvider,
                        );
                        if (returnData != null && returnData) {
                          _closeCheckoutContainer();
                        }
                      });
                });
          } else if (checkout3ViewState.isRazorClicked) {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmDialogView(
                      description: Utils.getString(
                          context, 'checkout_container__confirm_order'),
                      leftButtonText: Utils.getString(
                          context, 'home__logout_dialog_cancel_button'),
                      rightButtonText: Utils.getString(
                          context, 'home__logout_dialog_ok_button'),
                      onAgreeTap: () async {
                        Navigator.pop(context);
                        final dynamic returnData =
                            await checkout3ViewState.payRazorNow(
                                userProvider,
                                transactionSubmitProvider,
                                couponDiscountProvider,
                                valueHolder,
                                basketProvider);
                        if (returnData != null && returnData) {
                          _closeCheckoutContainer();
                        }
                      });
                });
          } else {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ErrorDialog(
                    message: Utils.getString(
                        context, 'checkout_container__choose_payment'),
                  );
                });
          }
        } else {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return WarningDialog(
                  message: Utils.getString(
                      context, 'checkout_container__agree_term_and_con'),
                );
              });
        }
      } else if (viewNo == 1) {
        if (checkout1ViewState.userEmailController.text.isEmpty) {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message:
                      Utils.getString(context, 'warning_dialog__input_email'),
                );
              });
        } else if (checkout1ViewState.shippingAddress1Controller.text.isEmpty) {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__shipping_address'),
                );
              });
        } else if (checkout1ViewState.billingAddress1Controller.text.isEmpty) {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(
                      context, 'warning_dialog__billing_address'),
                );
              });
        } else if (checkout1ViewState.shippingCityController.text.isEmpty) {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message:
                      Utils.getString(context, 'error_dialog__select_city'),
                );
              });
        } else {
          if (!await checkout1ViewState.checkIsDataChange(userProvider)) {
            isApiSuccess =
                await checkout1ViewState.callUpdateUserProfile(userProvider);
            //chang checkout1 data
            if (isApiSuccess) {
              viewNo++;
            }
          } else {
            //not chang checkout1 data
            viewNo++;
          }
        }
      } else {
        viewNo++;
      }
      setState(() {});
    }
  }

  dynamic checkHideOrShowBackArrow() {
    if (viewNo == 1) {
      return const Text('');
    } else {
      return Container(
          height: 50,
          color: PsColors.mainColor,
          child: Align(
            alignment: Alignment.centerRight,
            child: Stack(
              alignment: const Alignment(0.0, 0.0),
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(left: PsDimens.space36),
                  child: GestureDetector(
                    child: Text(
                        Utils.getString(context, 'checkout_container__back'),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(color: PsColors.white)),
                    onTap: () {
                      goToBackViewCheck();
                    },
                  ),
                ),
                Positioned(
                  left: 1,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: PsColors.white,
                      size: PsDimens.space16,
                    ),
                    onPressed: () {
                      goToBackViewCheck();
                    },
                  ),
                )
              ],
            ),
          ));
    }
  }

  void goToBackViewCheck() {
    if (viewNo < maxViewNo) {
      viewNo--;

      setState(() {});
    }
  }
}

class _TopImageForCheckout extends StatelessWidget {
  const _TopImageForCheckout({Key key, this.viewNo, this.onTap})
      : super(key: key);

  final int viewNo;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    StatelessWidget checkSecondCircle() {
      return Icon(
        viewNo == 3
            ? MaterialCommunityIcons.checkbox_marked_circle
            : MaterialCommunityIcons.checkbox_blank_circle_outline,
        size: PsDimens.space28,
        color: viewNo != 1 ? PsColors.mainColor : PsColors.grey,
      );
    }

    StatelessWidget checkFirstCircle() {
      return Icon(
        viewNo == 1
            ? MaterialCommunityIcons.checkbox_blank_circle_outline
            : MaterialCommunityIcons.checkbox_marked_circle,
        size: PsDimens.space28,
        color: PsColors.mainColor,
      );
    }

    StatelessWidget checkThirdCircle() {
      return Icon(
        MaterialCommunityIcons.checkbox_blank_circle_outline,
        size: PsDimens.space28,
        color: viewNo == 3 ? PsColors.mainColor : PsColors.grey,
      );
    }

    if (viewNo == 4) {
      return Container();
    } else {
      return Container(
        color: PsColors.coreBackgroundColor,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                const SizedBox(
                  height: PsDimens.space32,
                ),
                Text(Utils.getString(context, 'checkout_container__checkout'),
                    style: Theme.of(context).textTheme.headline5),
                const SizedBox(
                  height: PsDimens.space16,
                ),
                Container(
                  margin: const EdgeInsets.only(
                      left: PsDimens.space32, right: PsDimens.space32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          checkFirstCircle(),
                          const SizedBox(
                            height: PsDimens.space12,
                          ),
                          Text(
                              Utils.getString(
                                  context, 'checkout_container__address'),
                              style: viewNo == 1
                                  ? Theme.of(context).textTheme.bodyText2
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                          color:
                                              PsColors.textPrimaryDarkColor)),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          margin:
                              const EdgeInsets.only(bottom: PsDimens.space32),
                          child: Divider(
                            height: 2,
                            color: PsColors.mainColor,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          checkSecondCircle(),
                          const SizedBox(
                            height: PsDimens.space12,
                          ),
                          Text(
                              Utils.getString(
                                  context, 'checkout_container__confirm'),
                              style: Theme.of(context).textTheme.bodyText2),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          margin:
                              const EdgeInsets.only(bottom: PsDimens.space32),
                          child: Divider(
                            height: 2,
                            color: PsColors.mainColor,
                          ),
                        ),
                      ),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            checkThirdCircle(),
                            const SizedBox(
                              height: PsDimens.space12,
                            ),
                            Text(
                                Utils.getString(
                                    context, 'checkout_container__payment'),
                                style: Theme.of(context).textTheme.bodyText2),
                          ]),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(
                  top: PsDimens.space24, left: PsDimens.space2),
              child: IconButton(
                icon: Icon(
                  Icons.clear,
                  size: PsDimens.space24,
                ),
                onPressed: onTap,
              ),
            ),
          ],
        ),
      );
    }
  }
}
