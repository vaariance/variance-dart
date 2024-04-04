import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:variancedemo/providers/wallet_provider.dart';
import 'package:variancedemo/screens/home/home_widgets.dart';
import 'package:variancedemo/utils/widgets.dart';
import 'package:variancedemo/variance_colors.dart';

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
    return Scaffold(
      backgroundColor: VarianceColors.primary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 19.h, horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WalletBalance(),
              50.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                      onPressed: () {
                        showModalBottomSheetContent(context);
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: const Color(0xffE1FF01)),
                      icon: const Icon(Icons.qr_code_2_sharp),
                      label: const Text(' Receive')),
                  50.horizontalSpace,
                  TextButton.icon(
                      onPressed: () {
                        context.read<WalletProvider>().mintNFt();
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: const Color(0xffE1FF01)),
                      icon: const Icon(
                        Icons.all_inclusive_outlined,
                      ),
                      label: const Text('Mint NFT')),
                ],
              ),
              60.verticalSpace,
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
      ),
    );
  }
}
