import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:variance_dart/variance_dart.dart';
import 'package:wallet/wallet.dart';
import 'package:web3_signers/web3_signers.dart';
import 'package:web3dart/web3dart.dart';

SmartWallet? globalSmartWallet;
void main() async {
  return runApp(const HomeScratchTest());
}

class HomeScratchTest extends StatefulWidget {
  const HomeScratchTest({super.key});

  @override
  State<HomeScratchTest> createState() => _HomeScratchTestState();
}

class _HomeScratchTestState extends State<HomeScratchTest> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: TextButton(
                onPressed: createLightAccount,
                child: const Text('Create Light Account'),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                child: const Text('Check Balance'),
                onPressed: () async {
                  await claimSignUpReward(globalSmartWallet!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void createLightAccount() async {
    const signingOptions = SignatureOptions(prefix: [0]);
    final signer = EOAWallet.createWallet(WordLength.word_12, signingOptions);
    log('get address(): ${signer.exportMnemonic()}');
    final factory = SmartWalletFactory(ChainConfiguration().getChain(), signer);
    final userSalt = Uint256.zero;
    final smartWallet = await factory.createAlchemyLightAccount(userSalt);
    globalSmartWallet = smartWallet;
    log('Wallet created: ${smartWallet.address.eip55With0x}');
  }
}

Future<BigInt?> checkBalanceOf(SmartWallet smartWallet) async {
  log('checkBalanceOf(): ${smartWallet.address.eip55With0x}');
  final value = await smartWallet.balanceOf(smartWallet.address);
  log('My Balance: $value');
  final balance = value;
  return balance;
}

Future<void> claimSignUpReward(SmartWallet smartWallet) async {
  try {
    log('SmartWALLET ${smartWallet.toString()}');
    smartWallet.paymasterAddress =
        EthereumAddress.fromHex('0x982F51c0f430F3592A5E039F7c76Db16F9FeC970');
    final trx = await smartWallet.sendTransaction(
      EthereumAddress.fromHex('0x982F51c0f430F3592A5E039F7c76Db16F9FeC970'),
      ContractUtils.encodeFunctionCall(
        'claim',
        EthereumAddress.fromHex('0x982F51c0f430F3592A5E039F7c76Db16F9FeC970'),
        ContractAbi.fromJson(
          ContractAbiGetter.learnWayFaucet,
          'LearnWayToken',
        ),
        [],
      ),
    );
    final trackOps = await trx.wait();
    log('UserOps logs from claimSignUp(): ${trackOps?.logs}');
  } on Exception catch (e) {
    throw Exception(e);
  }
}

class ChainConfiguration {
  Chain getChain() {
    return Chain(
      chainId: 4202,
      entrypoint: EntryPointAddress.v07,
      explorer: 'https://sepolia-blockscout.lisk.com',
      accountFactory:
          EthereumAddress.fromHex('0x37e25C06bf19E2D1CD0499c9EB4f941475B78271'),
      bundlerConfig: RPCEndpointConfig.withClientId(
        url: 'https://4202.bundler.thirdweb.com/v2',
        clientId: '4a927b4c7a0a1b92b8bc1bec0eb390fd',
      ),
      paymasterConfig: RPCEndpointConfig.fromUrl(
        'https://4202.bundler.thirdweb.com/v2',
      ),
      jsonRpcConfig:
          RPCEndpointConfig.fromUrl('https://rpc.sepolia-api.lisk.com'),
    );
  }
}

class ContractAbiGetter {
  static const String learnWayQuiz = '''
  [{
    "inputs": [
      {
        "internalType": "address",
        "name": "_lwtAddress",
        "type": "address"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "inputs": [
      {
        "internalType": "enum LearnWayPOC.QuizState",
        "name": "_state",
        "type": "uint8"
      }
    ],
    "name": "InvalidState",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "InvalidTotalStake",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "InvalidWinner",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "InvariantCheckFailed",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "IsParticipant",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "NotParticipant",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "owner",
        "type": "address"
      }
    ],
    "name": "OwnableInvalidOwner",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "account",
        "type": "address"
      }
    ],
    "name": "OwnableUnauthorizedAccount",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "ParticipantAlreadySubmitted",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "QuizExists",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "QuizMissing",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "token",
        "type": "address"
      }
    ],
    "name": "SafeERC20FailedOperation",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "ZeroAddress",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "ZeroNumber",
    "type": "error"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "previousOwner",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "OwnershipTransferred",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "bytes32",
        "name": "quizHash",
        "type": "bytes32"
      },
      {
        "indexed": false,
        "internalType": "enum LearnWayPOC.QuizState",
        "name": "state",
        "type": "uint8"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "participant",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "score",
        "type": "uint256"
      }
    ],
    "name": "PartipantEvaluated",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "bytes32",
        "name": "quizHash",
        "type": "bytes32"
      },
      {
        "indexed": false,
        "internalType": "enum LearnWayPOC.QuizState",
        "name": "state",
        "type": "uint8"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "participant",
        "type": "address"
      }
    ],
    "name": "PartipantJoined",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "bytes32",
        "name": "quizHash",
        "type": "bytes32"
      },
      {
        "indexed": false,
        "internalType": "enum LearnWayPOC.QuizState",
        "name": "state",
        "type": "uint8"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "winner",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "won",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "fee",
        "type": "uint256"
      }
    ],
    "name": "QuizClosed",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "bytes32",
        "name": "quizHash",
        "type": "bytes32"
      },
      {
        "indexed": false,
        "internalType": "enum LearnWayPOC.QuizState",
        "name": "state",
        "type": "uint8"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "operator",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "entryFee",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "joinTime",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "endTime",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "submitTime",
        "type": "uint256"
      }
    ],
    "name": "QuizOpened",
    "type": "event"
  },
  {
    "inputs": [],
    "name": "accumulatedFee",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "adminFeeBps",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "_quizHash",
        "type": "bytes32"
      }
    ],
    "name": "closeQuiz",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "entryFee",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "feeAddress",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "joinPeriod",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "_quizHash",
        "type": "bytes32"
      }
    ],
    "name": "joinQuiz",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "lwt",
    "outputs": [
      {
        "internalType": "contract IERC20",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "owner",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      },
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "name": "participants",
    "outputs": [
      {
        "internalType": "bool",
        "name": "playing",
        "type": "bool"
      },
      {
        "internalType": "uint256",
        "name": "score",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "quizDuration",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      }
    ],
    "name": "quizzes",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "participants",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "highestScore",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "totalStake",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "entryFee",
        "type": "uint256"
      },
      {
        "internalType": "address",
        "name": "topScorer",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "operator",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "joinTime",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "endTime",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "submitTime",
        "type": "uint256"
      },
      {
        "internalType": "enum LearnWayPOC.QuizState",
        "name": "state",
        "type": "uint8"
      },
      {
        "internalType": "bytes32",
        "name": "offchianHash",
        "type": "bytes32"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "renounceOwnership",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "_quizHash",
        "type": "bytes32"
      }
    ],
    "name": "startQuiz",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "submitPeriod",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "_quizHash",
        "type": "bytes32"
      },
      {
        "internalType": "uint256",
        "name": "_score",
        "type": "uint256"
      }
    ],
    "name": "submitScore",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "transferOwnership",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]  
''';
  static const String learnWayFaucet = '''
[
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_lwtAddress",
        "type": "address"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "inputs": [],
    "name": "AlreadyClaimed",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "owner",
        "type": "address"
      }
    ],
    "name": "OwnableInvalidOwner",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "account",
        "type": "address"
      }
    ],
    "name": "OwnableUnauthorizedAccount",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "token",
        "type": "address"
      }
    ],
    "name": "SafeERC20FailedOperation",
    "type": "error"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "_cliamer",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "_amount",
        "type": "uint256"
      }
    ],
    "name": "Claimed",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "previousOwner",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "OwnershipTransferred",
    "type": "event"
  },
  {
    "inputs": [],
    "name": "claim",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "claimInterval",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "dailyClaim",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "drain",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "name": "lastClaimed",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "lwt",
    "outputs": [
      {
        "internalType": "contract IERC20",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "owner",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "renounceOwnership",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_amt",
        "type": "uint256"
      }
    ],
    "name": "setDailyClaim",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "transferOwnership",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]''';
}
