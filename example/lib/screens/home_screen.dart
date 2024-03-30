import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:variancedemo/providers/wallet_provider.dart';
import 'package:variancedemo/variance_colors.dart';
import 'dart:ui' as ui;

import 'package:web3_signers/web3_signers.dart';

class WalletHome extends StatefulWidget {
  const WalletHome({super.key});

  @override
  State<WalletHome> createState() => _WalletHomeState();
}

class _WalletHomeState extends State<WalletHome> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: VarianceColors.primary,
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 19.h, horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WalletBalance(),
              110.verticalSpace,
              AddressBar(
                hintText: 'Eth Address',
                textEditingController: addressController,
              ),
              18.verticalSpace,
              TextFormField(
                  style: TextStyle(
                      fontSize: 51.sp,
                      fontWeight: FontWeight.w600,
                      color: VarianceColors.secondary),
                  key: _formKey,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    } else if (int.parse(value) > 100) {
                      return 'Value should be less than or equal to 100';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.isEmpty) {
                      return;
                    }
                  },
                  textAlign: TextAlign.center,
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    focusColor: Colors.white,
                    fillColor: Colors.white,
                    border: InputBorder.none,
                    hintText: '0.0',
                    hintStyle: TextStyle(
                        fontSize: 51, color: VarianceColors.secondary),
                  ),
                  cursorColor: VarianceColors.secondary,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\.?\d*(?<!\.)\.?\d*'),
                    )
                  ]),
              SizedBox(
                height: 58.h,
                width: double.infinity,
                child: TextButton(
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        backgroundColor: VarianceColors.white),
                    onPressed: () {
                      log(amountController.text);
                      log(addressController.text);
                      context.read<WalletProvider>().sendTransaction(
                          addressController.text, amountController.text);
                    },
                    child: const Text('Send')),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.large(
          child: const Icon(Icons.qr_code_2_sharp),
          onPressed: () {
            showModalBottomSheetContent(context);
          },
        ),
      ),
    );
  }
}

String address = '';

class WalletBalance extends StatefulWidget {
  const WalletBalance({super.key});

  @override
  State<WalletBalance> createState() => _WalletBalanceState();
}

class _WalletBalanceState extends State<WalletBalance> {
  Uint256 balance = Uint256.zero;

  @override
  Widget build(BuildContext context) {
    final wallet = context.select(
      (WalletProvider provider) => provider.wallet,
    );
    // final hdWallet = context.select(
    //   (WalletProvider provider) => provider.hdWalletSigner,
    // );

    address = wallet.address.hex;

    Future<void> getBalance() async {
      final ether = await wallet.balance;
      setState(() {
        balance = Uint256.fromWei(ether);
      });
    }
    //if the wallet is created with a passkey

    getBalance();
    return Consumer<WalletProvider>(
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Total Balance',
                  style: TextStyle(
                      color: VarianceColors.secondary, fontSize: 14.sp),
                ),
                10.horizontalSpace,
                const Image(
                  image: AssetImage(
                    'assets/images/down-arrow.png',
                  ),
                  height: 10,
                  width: 10,
                  color: VarianceColors.secondary,
                ),
                const Spacer(),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(
                      color: VarianceColors.secondary,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              ],
            ),
            18.verticalSpace,
            Text(
              '${balance.fromUnit(18)} ETH',
              style: TextStyle(color: Colors.white, fontSize: 24.sp),
            ),
            18.verticalSpace,
          ],
        );
      },
    );
  }
}

class CryptoTransaction {
  final String name;
  final double amount;
  final String date;

  CryptoTransaction({
    required this.name,
    required this.amount,
    required this.date,
  });
}

class AddressBar extends StatefulWidget {
  final String hintText;
  final TextEditingController? textEditingController;
  final TextStyle? hintTextStyle;

  // Add an optional parameter for the initial value
  final String initialValue;

  const AddressBar({
    required this.hintText,
    this.hintTextStyle,
    this.textEditingController,
    this.initialValue = "0.0", // Provide a default initial value
    Key? key,
  }) : super(key: key);

  @override
  State<AddressBar> createState() => _AddressBarState();
}

class _AddressBarState extends State<AddressBar> {
  bool pwdVisibility = false;
  final formKey = GlobalKey<FormState>();
  late final TextEditingController textEditingController;
  @override
  void initState() {
    super.initState();
    // Initialize the TextEditingController with the initial value
    textEditingController = widget.textEditingController ??
        TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: VarianceColors.primary,
      controller: widget.textEditingController,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        fillColor: VarianceColors.secondary,
        filled: true,
        hintText: widget.hintText,
        hintStyle: widget.hintTextStyle,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.white,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10)),
      ),
      validator: (val) {
        if (val!.isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }
}

String message = address;
final FutureBuilder<ui.Image> qrFutureBuilder = FutureBuilder<ui.Image>(
  future: _loadOverlayImage(),
  builder: (BuildContext ctx, AsyncSnapshot<ui.Image> snapshot) {
    const double size = 280.0;
    if (!snapshot.hasData) {
      return const SizedBox(width: size, height: size);
    }
    return CustomPaint(
      size: const Size.square(size),
      painter: QrPainter(
        data: message.toString(),
        version: QrVersions.auto,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(0xff000000),
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.circle,
          color: Color(0xff000000),
        ),
        // size: 320.0,
        embeddedImage: snapshot.data,
        embeddedImageStyle: const QrEmbeddedImageStyle(
          size: Size.square(60),
        ),
      ),
    );
  },
);
Future<ui.Image> _loadOverlayImage() async {
  final Completer<ui.Image> completer = Completer<ui.Image>();
  final ByteData byteData = await rootBundle.load('assets/images/ethereum.png');
  ui.decodeImageFromList(byteData.buffer.asUint8List(), completer.complete);
  return completer.future;
}

showModalBottomSheetContent(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.89,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: qrFutureBuilder, // Replace with your content
                ),
              ),
              const SizedBox(height: 50),
              Container(
                width: 280,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Ethereum address',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: const Color(0xff32353E).withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: 280,
                          child: Text(
                            message,
                            style: const TextStyle(
                              color: Color(0xff32353E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                            text: message,
                          ));
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xff32353E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'copy',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
