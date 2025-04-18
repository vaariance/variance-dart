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

import '../../utils/shorten_address.dart';

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

    getBalance();
    return Consumer<WalletProvider>(
      builder: (context, value, child) {
        return // For the specific layout you shared earlier:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(color: VarianceColors.secondary, fontSize: 14.sp),
                  ),
                  10.horizontalSpace,
                  const Image(
                    image: AssetImage('assets/images/down-arrow.png'),
                    height: 10,
                    width: 10,
                    color: VarianceColors.secondary,
                  ),
                  const Spacer(), // This is fine in a Row
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: address));
                    },
                    icon: const Icon(Icons.copy_all_rounded, color: VarianceColors.secondary),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  8.horizontalSpace,
                  Flexible( // Changed from Expanded to Flexible
                    child: Text(
                      EthereumAddressUtils.shortenAddress(address),
                      style: const TextStyle(
                        color: VarianceColors.secondary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
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
    const double size = 150.0;
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
      child: Column(
        children: [
          20.verticalSpace,
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: qrFutureBuilder,
          ),
          20.verticalSpace, // Added bottom spacing
        ],
      ),
    );
  }
}