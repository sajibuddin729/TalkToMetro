import 'package:flutter/material.dart';

class OtherInfoCategory {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final String categoryTag; // 'Schedule', 'Rules', 'Contact', 'Passes', 'Accessibility'
  final List<String>? bulletPoints;
  final String? actionLabel;
  final String? actionType; // 'tel', 'email', 'route'
  final String? actionPayload;

  const OtherInfoCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.categoryTag,
    this.bulletPoints,
    this.actionLabel,
    this.actionType,
    this.actionPayload,
  });
}