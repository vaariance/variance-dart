import 'package:pks_4337_sdk/pks_4337_sdk.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract.dart';
import 'package:pks_4337_sdk/src/4337/modules/contract_abis.dart';
import 'package:pks_4337_sdk/src/4337/modules/enum.dart';
import 'package:pks_4337_sdk/src/dio_client.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

/// uses alchemy nft api
/// if want to use another api, you have to create a custom class
class NFT {
  final Uri _baseNftApiUrl;

  final DioClient _dioClient = DioClient();

  NFT(String rpcUrl) : _baseNftApiUrl = Uri.parse(NFT.getBaseNftApiUrl(rpcUrl));

  String encodeERC721ApproveCall(
      EthereumAddress contractAddress, EthereumAddress to, Uint256 tokenId) {
    return bytesToHex(
        Contract.encodeFunctionCall("approve", contractAddress,
            ContractAbis.get("ERC721"), [to.hex, tokenId.value]),
        include0x: true,
        padToEvenLength: true);
  }

  String encodeERC721SafeTransferCall(EthereumAddress contractAddress,
      EthereumAddress from, EthereumAddress to, Uint256 tokenId) {
    return bytesToHex(
        Contract.encodeFunctionCall("safeTransferFrom", contractAddress,
            ContractAbis.get("ERC721"), [from.hex, to.hex, tokenId.value]),
        include0x: true,
        padToEvenLength: true);
  }

  Future<NftPrice> getFloorPrice(EthereumAddress contractAddress) async {
    final response = await _fetchNftRequest(
        {'contractAddress': contractAddress.hex}, 'getFloorPrice');
    return NftPrice.fromMap(response);
  }

  Future<NftMetadata> getNftMetadata(
      EthereumAddress contractAddress, Uint256 tokenId,
      {NftTokenType? type, bool refreshCache = false}) async {
    final queryParams = {
      'contractAddress': contractAddress.hex,
      'tokenId': tokenId.toInt(),
      'refreshCache': refreshCache,
    };
    if (type != null) {
      queryParams['tokenType'] = type.name.toUpperCase();
    }

    final response = await _fetchNftRequest(queryParams, 'getNFTMetadata');
    return NftMetadata.fromMap(response);
  }

  Future<NftResponse> getNftsForOwner(EthereumAddress address,
      {bool orderByTransferTime = false,
      bool withMetadata = true,
      String? pageKey}) async {
    final queryParams = {
      'owner': address.hex,
      'withMetadata': withMetadata,
      'orderBy': orderByTransferTime ? 'transferTime' : null,
    };

    if (pageKey != null) {
      queryParams['pageKey'] = pageKey;
    }

    final response = await _fetchNftRequest(queryParams, 'getOwnersForNFT');

    return NftResponse.fromMap(
        response,
        withMetadata
            ? ResponseType.withMetadata
            : ResponseType.withoutMetadata);
  }

  Future<bool> isAirdropNFT(
      EthereumAddress contractAddress, Uint256 tokenId) async {
    final response = await _fetchNftRequest(
        {'contractAddress': contractAddress.hex, 'tokenId': tokenId.toInt()},
        'isAirdropNFT');
    return response["isAirdrop"] as bool;
  }

  Future<bool> isSpamContract(EthereumAddress contractAddress) async {
    final response = await _fetchNftRequest(
        {'contractAddress': contractAddress.hex}, "isSpamContract");
    return response["isSpamContract"] as bool;
  }

  Future<Map<String, dynamic>> _fetchNftRequest(
      Map<String, Object?> queryParams, String path) async {
    final String requestUrl = _baseNftApiUrl
        .replace(path: path)
        .replace(queryParameters: queryParams)
        .toString();

    return await _dioClient.callNftApi<Map<String, dynamic>>(
      requestUrl,
    );
  }

  static String getBaseNftApiUrl(String rpcUrl) {
    final sections = rpcUrl.split('/v2/');
    sections[1] = "/nft/v3/${sections[1]}";
    return sections.join('');
  }
}
