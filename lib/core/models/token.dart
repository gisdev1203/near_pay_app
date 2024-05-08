import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class Token {
  final String id;
  final String symbol;
  final String name;
  final int decimals;
  final String contractAddress;
  final String? imageUrl; // URL of the token image

  Token({
    required this.id,
    required this.symbol,
    required this.name,
    required this.decimals,
    required this.contractAddress,
    this.imageUrl,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      id: json['id'],
      symbol: json['symbol'],
      name: json['name'],
      decimals: json['decimals'],
      contractAddress: json['contractAddress'],
      imageUrl: json['imageUrl'], // Assuming imageUrl is included in JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'decimals': decimals,
      'contractAddress': contractAddress,
      'imageUrl': imageUrl,
    };
  }

  // Override toString for better representation
  @override
  String toString() {
    return 'Token(id: $id, symbol: $symbol, name: $name, '
        'decimals: $decimals, contractAddress: $contractAddress, '
        'imageUrl: $imageUrl)';
  }

  // Override == and hashCode for equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Token &&
        other.id == id &&
        other.symbol == symbol &&
        other.name == name &&
        other.decimals == decimals &&
        other.contractAddress == contractAddress &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        symbol.hashCode ^
        name.hashCode ^
        decimals.hashCode ^
        contractAddress.hashCode ^
        imageUrl.hashCode;
  }

  // Method for converting token amount to a different decimal precision
  double convertAmount(double amount, int targetDecimals) {
    // Calculate the conversion factor based on source and target decimals
    num conversionFactor = pow(10, targetDecimals - decimals);

    // Apply the conversion factor to the amount
    return amount * conversionFactor;
  }

  // Method for fetching token information from a blockchain API
  Future<TokenInfo> fetchTokenInfoFromAPI() async {
    // Replace the URL placeholder with the actual API endpoint
    final apiUrl = 'https://api.example.com/token_info?symbol=$symbol';

    // Make a GET request to the API endpoint
    final response = await http.get(Uri.parse(apiUrl));

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      final jsonResponse = json.decode(response.body);

      // Extract token information from the response
      final tokenId = jsonResponse['id'];
      final tokenName = jsonResponse['name'];
      final tokenDecimals = jsonResponse['decimals'];
      final tokenContractAddress = jsonResponse['contractAddress'];

      // Create a TokenInfo object with the extracted information
      final tokenInfo = TokenInfo(
        id: tokenId,
        name: tokenName,
        decimals: tokenDecimals,
        contractAddress: tokenContractAddress,
      );

      // Return the token information
      return tokenInfo;
    } else {
      // If the request was not successful, throw an error
      throw Exception('Failed to fetch token information');
    }
  }
}

class TokenInfo {
  final String id;
  final String name;
  final int decimals;
  final String contractAddress;

  TokenInfo({
    required this.id,
    required this.name,
    required this.decimals,
    required this.contractAddress,
  });
}
