import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _WalletHomeState extends State<WalletHome>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  TextEditingController amountController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

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
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Text('Send',
                        style: TextStyle(
                            fontSize: 20.sp, color: VarianceColors.secondary)),
                  ),
                  Tab(
                    child: Text('Receive',
                        style: TextStyle(
                            fontSize: 20.sp, color: VarianceColors.secondary)),
                  ),
                  Tab(
                    child: Text('NFT',
                        style: TextStyle(
                            fontSize: 20.sp, color: VarianceColors.secondary)),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  Send(
                      addressController: addressController,
                      formKey: _formKey,
                      amountController: amountController),
                  const Receive(),
                  const NFT(),
                ]),
              ),
              60.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class Send extends StatelessWidget {
  const Send({
    super.key,
    required this.addressController,
    required GlobalKey<FormState> formKey,
    required this.amountController,
  }) : _formKey = formKey;

  final TextEditingController addressController;
  final GlobalKey<FormState> _formKey;
  final TextEditingController amountController;

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        50.verticalSpace,
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
              hintStyle:
                  TextStyle(fontSize: 51, color: VarianceColors.secondary),
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
    );
  }
}

class NFT extends StatelessWidget {
  const NFT({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        50.verticalSpace,
        Row(
          children: [
            const CircleAvatar(),
            10.horizontalSpace,
            const Text(
              'NFT',
              style: TextStyle(color: VarianceColors.secondary),
            ),
            const Spacer(),
            const Text(
              '\$0.00',
              style: TextStyle(color: VarianceColors.secondary),
            ),
          ],
        ),
        10.verticalSpace,
        Row(children: [
          const CircleAvatar(),
          10.horizontalSpace,
          const Text(
            'NFT',
            style: TextStyle(color: VarianceColors.secondary),
          ),
          const Spacer(),
          const Text(
            '\$0.00',
            style: TextStyle(color: VarianceColors.secondary),
          ),
        ]),
        const Spacer(),
        ElevatedButton(
            onPressed: () {
              context.read<WalletProvider>().mintNFt();
            },
            child: const Text('Mint')),
      ],
    );
  }
}
