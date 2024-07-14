import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:dart_web3/dart_web3.dart';
import 'package:web_socket_channel/io.dart';

class ContractLinking extends ChangeNotifier {
  final String _rpcURl = "http://127.0.0.1:7545";
  final String _wsURl = "ws://10.0.2.2:7545/";
  final String _privateKey =
      "0x35eb341ccf3bf40d2d31f511fd0800eb95e75efa47079e0005f30477f4e418f8";

  late Web3Client _client;
  late String _abiCode;

  late EthereumAddress _contractAddress;
  late Credentials _credentials;

  late DeployedContract _contract;
  late ContractFunction _yourName;
  late ContractFunction _setName;

  bool isLoading = true;
  String? deployedName;
  List<Map<String, String>> submittedData = []; // List to store submitted data

  ContractLinking() {
    initialSetup();
  }

  Future<void> initialSetup() async {
    try {
      _client = Web3Client(_rpcURl, Client(), socketConnector: () {
        return IOWebSocketChannel.connect(_wsURl).cast<String>();
      });

      await getAbi();
      await getCredentials();
      await getDeployedContract();
    } catch (e) {
      print('Error during initial setup: $e');
    }
  }

  Future<void> getAbi() async {
    try {
      String abiStringFile =
          await rootBundle.loadString("src/artifacts/HelloWorld.json");
      var jsonAbi = jsonDecode(abiStringFile);
      _abiCode = jsonEncode(jsonAbi["abi"]);

      _contractAddress =
          EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
    } catch (e) {
      print('Error loading ABI: $e');
    }
  }

  Future<void> getCredentials() async {
    try {
      _credentials = EthPrivateKey.fromHex(_privateKey);
    } catch (e) {
      print('Error getting credentials: $e');
    }
  }

  Future<void> getDeployedContract() async {
    try {
      _contract = DeployedContract(
          ContractAbi.fromJson(_abiCode, "HelloWorld"), _contractAddress);

      _yourName = _contract.function("yourName");
      _setName = _contract.function("setName");
      await getName();
    } catch (e) {
      print('Error getting deployed contract: $e');
    }
  }

  Future<void> getName() async {
    try {
      var currentName = await _client
          .call(contract: _contract, function: _yourName, params: []);
      deployedName = currentName[0];
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error getting name: $e');
    }
  }

  Future<void> setName(String nameToSet, String mobileNumber) async {
    try {
      isLoading = true;
      notifyListeners();

      final address = await _credentials.extractAddress();
      final nonce = await _client.getTransactionCount(address);

      final tx = Transaction.callContract(
        contract: _contract,
        function: _setName,
        parameters: [nameToSet],
        from: address,
        nonce: nonce,
      );

      await _client.sendTransaction(
        _credentials,
        tx,
        chainId: 1337,
      );

      // Add the submitted data to the list
      submittedData.add({'name': nameToSet, 'mobile': mobileNumber});

      // Retrieve the updated name
      await getName();
    } catch (e) {
      print('Error setting name: $e');
    }
  }
}
