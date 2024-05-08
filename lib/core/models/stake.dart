class Stake {
  final String id;
  final String userId;
  final String tokenSymbol;
  final double amount;
  final DateTime startTime;
  final DateTime? endTime;
  final double interestRate;
  final String status;
  List<StakePeriod> periods; // Support for multiple staking periods

  Stake({
    required this.id,
    required this.userId,
    required this.tokenSymbol,
    required this.amount,
    required this.startTime,
    required this.endTime,
    required this.interestRate,
    required this.status,
    List<StakePeriod>? periods,
  }) : periods = periods ?? [];

  factory Stake.fromJson(Map<String, dynamic> json) {
    return Stake(
      id: json['id'],
      userId: json['userId'],
      tokenSymbol: json['tokenSymbol'],
      amount: json['amount'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      interestRate: json['interestRate'],
      status: json['status'],
      periods: (json['periods'] as List<dynamic>?)
          ?.map((periodJson) => StakePeriod.fromJson(periodJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tokenSymbol': tokenSymbol,
      'amount': amount,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'interestRate': interestRate,
      'status': status,
      'periods': periods.map((period) => period.toJson()).toList(),
    };
  }
}

class StakePeriod {
  final DateTime startTime;
  final DateTime? endTime;
  final double rewardsEarned; // Rewards earned during the staking period

  StakePeriod({
    required this.startTime,
    required this.endTime,
    required this.rewardsEarned,
  });

  factory StakePeriod.fromJson(Map<String, dynamic> json) {
    return StakePeriod(
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      rewardsEarned: json['rewardsEarned'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'rewardsEarned': rewardsEarned,
    };
  }
}
