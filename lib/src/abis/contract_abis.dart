import 'package:web3dart/web3dart.dart';

/// Contract ABIs
/// Getters for contract ABIs for onchain operations
class ContractAbis {
  /// Get contract ABI
  /// - `name`: name of the contract
  ///
  /// Returns ABI of the contract.
  static ContractAbi get(String name) {
    String abi;
    switch (name) {
      case 'ERC20_BalanceOf':
        abi =
            '[{"constant":true,"inputs":[{"name":"owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"}]';
        break;
      case 'ERC20_Approve':
        abi =
            '[{"constant":false,"inputs":[{"name":"spender","type":"address"},{"name":"value","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"}]';
        break;
      case 'ERC20_Allowance':
        abi =
            '[{"constant":true,"inputs":[{"name":"owner","type":"address"},{"name":"spender","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"}]';
        break;
      case 'ERC20_Transfer':
        abi =
            '[{"constant":false,"inputs":[{"name":"to","type":"address"},{"name":"value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"}]';
        break;
      case 'ERC20_TransferFrom':
        abi =
            '[{"constant":false,"inputs":[{"name":"from","type":"address"},{"name":"to","type":"address"},{"name":"value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"}]';
        break;
      case 'ERC20_Mint':
        abi =
            '[{"constant":false,"inputs":[{"name":"to","type":"address"},{"name":"value","type":"uint256"}],"name":"mint","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"}]';
        break;
      case 'ERC721_BalanceOf':
        abi =
            '[{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]';
        break;
      case 'ERC721_OwnerOf':
        abi =
            '[{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"ownerOf","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"}]';
        break;
      case 'ERC721_Approve':
        abi =
            '[{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"approve","outputs":[],"stateMutability":"nonpayable","type":"function"}]';
        break;
      case 'ERC721_SafeMint':
        abi =
            '[{"type":"function","name":"safeMint","inputs":[{"name":"to","type":"address","internalType":"address"}],"outputs":[],"stateMutability":"nonpayable"}]';
        break;
      case 'ERC721_SafeTransferFrom':
        abi =
            '[{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"safeTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"bytes","name":"_data","type":"bytes"}],"name":"safeTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"}]';
        break;
      case 'ERC721_Burn':
        abi =
            '[{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"burn","outputs":[],"stateMutability":"nonpayable","type":"function"}]';
        break;
      case 'getNonce':
        abi =
            '[{"inputs":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"uint192","name":"key","type":"uint192"}],"name":"getNonce","outputs":[{"internalType":"uint256","name":"nonce","type":"uint256"}],"stateMutability":"view","type":"function"    }]';
        break;
      case 'execute':
        abi =
            '[{"inputs":[{"internalType":"address","name":"dest","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"},{"internalType":"bytes","name":"func","type":"bytes"}],"name":"execute","outputs":[],"stateMutability":"nonpayable","type":"function"}]';
        break;
      case 'executeUserOpWithErrorString':
        abi =
            '[{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"},{"internalType":"bytes","name":"data","type":"bytes"},{"internalType":"uint8","name":"operation","type":"uint8"}],"name":"executeUserOpWithErrorString","outputs":[],"stateMutability":"nonpayable","type":"function"}]';
        break;
      case 'executeBatch':
        abi =
            '[{"inputs":[{"internalType":"address[]","name":"dest","type":"address[]"},{"internalType":"uint256[]","name":"value","type":"uint256[]"},{"internalType":"bytes[]","name":"func","type":"bytes[]"}],"name":"executeBatch","outputs":[],"stateMutability":"nonpayable","type":"function"}]';
        break;
      case 'enableModules':
        abi =
            '[{"type":"function","name":"enableModules","inputs":[{"name":"modules","type":"address[]","internalType":"address[]"}],"outputs":[],"stateMutability":"nonpayable"}]';
        break;
      case 'setup':
        abi =
            '[{"type":"function","name":"setup","inputs":[{"name":"_owners","type":"address[]","internalType":"address[]"},{"name":"_threshold","type":"uint256","internalType":"uint256"},{"name":"to","type":"address","internalType":"address"},{"name":"data","type":"bytes","internalType":"bytes"},{"name":"fallbackHandler","type":"address","internalType":"address"},{"name":"paymentToken","type":"address","internalType":"address"},{"name":"payment","type":"uint256","internalType":"uint256"},{"name":"paymentReceiver","type":"address","internalType":"address payable"}],"outputs":[],"stateMutability":"nonpayable"}]';
        break;
      case 'multiSend':
        abi =
            '[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"bytes","name":"transactions","type":"bytes"}],"name":"multiSend","outputs":[],"stateMutability":"payable","type":"function"}]';
        break;
      default:
        throw 'ABI of $name is not available by default. Please provide the ABI manually.';
    }
    return ContractAbi.fromJson(abi, name);
  }
}
