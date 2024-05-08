import 'package:meta/meta.dart'; // For @immutable annotation

@immutable
class Contract {
  final String id;
  final String name; // Human-readable name of the contract
  final String userId; // User associated with this contract
  final String contractAddress; // Address of the contract on the blockchain
  final String abi; // Contract ABI for interaction
  // Include additional fields as needed for your application

  Contract({
    required this.id,
    required this.name,
    required this.userId,
    required this.contractAddress,
    required this.abi,
  })   : assert(id.isNotEmpty),
        assert(name.isNotEmpty),
        assert(userId.isNotEmpty),
        assert(contractAddress.isNotEmpty),
        assert(abi.isNotEmpty);

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userId: json['userId'] ?? '',
      contractAddress: json['contractAddress'] ?? '',
      abi: json['abi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'contractAddress': contractAddress,
      'abi': abi,
    };
  }

  // Include contract interaction methods here
}
