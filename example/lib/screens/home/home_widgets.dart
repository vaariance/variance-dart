import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:variancedemo/providers/wallet_provider.dart';
import 'package:variancedemo/variance_colors.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/web3dart.dart';

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

    address = wallet?.address.hex ?? '';

    Future<void> getBalance() async {
      final ether = await wallet?.balance;
      setState(() {
        balance = Uint256.fromWei(ether ?? EtherAmount.zero());
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

class Receive extends StatelessWidget {
  const Receive({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.89,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            50.verticalSpace,
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              // margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 200,
                    child: Text(
                      message,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        overflow: TextOverflow.ellipsis,
                        color: const Color(0xff32353E).withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text: message,
                        ));
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xff32353E),
                        padding: const EdgeInsets.only(left: 30, right: 30),
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
  }
}
