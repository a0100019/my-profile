import 'package:flutter/material.dart';

class AppColors {
  static const pastelPink = Color(0xFFFFB5C2);
  static const pastelPeach = Color(0xFFFFD4A8);
  static const pastelYellow = Color(0xFFFFF3B0);
  static const pastelMint = Color(0xFFB8F0D8);
  static const pastelBlue = Color(0xFFB8D4F0);
  static const pastelPurple = Color(0xFFD4B8F0);
  static const background = Color(0xFFF8F6FF);
  static const card = Colors.white;
  static const foreground = Color(0xFF1A1A2E);
  static const muted = Color(0xFF8E8EA0);
}

class CategoryInfo {
  final String key;
  final String emoji;
  final String label;
  const CategoryInfo(this.key, this.emoji, this.label);
}

const allCategories = [
  CategoryInfo('food', '🍕', '음식'),
  CategoryInfo('movie', '🎬', '영화'),
  CategoryInfo('music', '🎵', '음악'),
  CategoryInfo('book', '📚', '책'),
  CategoryInfo('hobby', '⚽', '취미'),
  CategoryInfo('travel', '✈️', '여행'),
  CategoryInfo('game', '🎮', '게임'),
  CategoryInfo('drama', '📺', '드라마'),
  CategoryInfo('drink', '🥤', '음료'),
  CategoryInfo('comic', '📖', '만화'),
  CategoryInfo('pokemon', '🐾', '포켓몬'),
  CategoryInfo('youtube', '▶️', '유튜브'),
  CategoryInfo('exercise', '💪', '운동'),
  CategoryInfo('webtoon', '📱', '웹툰'),
  CategoryInfo('brand', '🏷️', '브랜드'),
  CategoryInfo('mbti', '💼', 'MBTI'),
  CategoryInfo('ideal', '💕', '이상형'),
];

const rowColors = [
  (color: AppColors.pastelPink, opacity: 0.25),
  (color: AppColors.pastelPeach, opacity: 0.25),
  (color: AppColors.pastelYellow, opacity: 0.25),
  (color: AppColors.pastelMint, opacity: 0.25),
  (color: AppColors.pastelBlue, opacity: 0.25),
  (color: AppColors.pastelPurple, opacity: 0.25),
];
