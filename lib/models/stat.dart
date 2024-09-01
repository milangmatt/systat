// To parse this JSON data, do
//
//     final stat = statFromJson(jsonString);

import 'dart:convert';

Stat statFromJson(String str) => Stat.fromJson(json.decode(str));

String statToJson(Stat data) => json.encode(data.toJson());

class Stat {
  double cpuUsagePercentage;
  Usage memoryUsage;
  Usage diskUsage;

  Stat({
    required this.cpuUsagePercentage,
    required this.memoryUsage,
    required this.diskUsage,
  });

  factory Stat.fromJson(Map<String, dynamic> json) => Stat(
        cpuUsagePercentage: json["cpu_usage_percentage"]?.toDouble(),
        memoryUsage: Usage.fromJson(json["memory_usage"]),
        diskUsage: Usage.fromJson(json["disk_usage"]),
      );

  Map<String, dynamic> toJson() => {
        "cpu_usage_percentage": cpuUsagePercentage,
        "memory_usage": memoryUsage.toJson(),
        "disk_usage": diskUsage.toJson(),
      };
}

class Usage {
  int totalMb;
  int usedMb;
  int freeMb;
  double usePercent;

  Usage({
    required this.totalMb,
    required this.usedMb,
    required this.freeMb,
    required this.usePercent,
  });

  factory Usage.fromJson(Map<String, dynamic> json) => Usage(
        totalMb: json["total_mb"],
        usedMb: json["used_mb"],
        freeMb: json["free_mb"],
        usePercent: double.parse(
            (((json["used_mb"].toDouble() / json["total_mb"].toDouble()) * 100))
                .toDouble()
                .toStringAsFixed(2)),
      );

  Map<String, dynamic> toJson() => {
        "total_mb": totalMb,
        "used_mb": usedMb,
        "free_mb": freeMb,
      };
}
