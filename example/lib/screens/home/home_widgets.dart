import 'dart:async';

import 'package:flutter/material.dart';
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
                  style: TextStyle(
                      color: VarianceColors.secondary, fontSize: 14.sp),
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
                  icon: const Icon(Icons.copy_all_rounded,
                      color: VarianceColors.secondary),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                8.horizontalSpace,
                Flexible(
                  // Changed from Expanded to Flexible
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
final CustomPaint qrCode = CustomPaint(
  size: const Size.square(150.0),
  painter: QrPainter(
    data: message.toString(),
    version: QrVersions.auto,
    eyeStyle: QrEyeStyle(
      eyeShape: QrEyeShape.circle,
      color: Colors.grey[300],
    ),
    dataModuleStyle: QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: Colors.grey[300],
    ),
  ),
);

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
              color: const Color(0xFF2A2A3C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: qrCode,
          ),
          20.verticalSpace, // Added bottom spacing
        ],
      ),
    );
  }
}
