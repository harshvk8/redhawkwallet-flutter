import 'package:flutter/material.dart';

class DemoTransaction {
  final String vendor;
  final String amount;
  final String date;
  final String status;
  final Color statusColor;
  final String category;
  final String location;
  final String paymentMethod;
  final String note;

  const DemoTransaction({
    required this.vendor,
    required this.amount,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.category,
    required this.location,
    required this.paymentMethod,
    required this.note,
  });
}
