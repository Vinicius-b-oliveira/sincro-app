import 'package:flutter/material.dart';

class CategoryUtils {
  static IconData getIcon(String category) {
    final cat = category.toLowerCase();

    // --- Entradas ---
    if (cat.contains('aluguel') && cat.contains('recebido')) {
      return Icons.real_estate_agent;
    }
    if (cat.contains('bônus')) return Icons.star;
    if (cat.contains('cashback')) return Icons.savings;
    if (cat.contains('dividendos')) return Icons.trending_up;
    if (cat.contains('freelance')) return Icons.laptop_mac;
    if (cat.contains('invest')) return Icons.show_chart;
    if (cat.contains('presente')) return Icons.card_giftcard;
    if (cat.contains('reembolso')) return Icons.keyboard_return;
    if (cat.contains('salário')) return Icons.work;
    if (cat.contains('venda')) return Icons.store;

    // --- Saídas ---
    if (cat.contains('aliment')) return Icons.restaurant;
    if (cat.contains('assinatura')) return Icons.subscriptions;
    if (cat.contains('beleza')) return Icons.brush;
    if (cat.contains('casa')) return Icons.home;
    if (cat.contains('compra')) return Icons.shopping_bag;
    if (cat.contains('conta')) return Icons.receipt_long;
    if (cat.contains('dívida')) return Icons.money_off;
    if (cat.contains('doaç')) return Icons.volunteer_activism;
    if (cat.contains('educaç')) return Icons.school;
    if (cat.contains('eletrônico')) return Icons.devices;
    if (cat.contains('imposto')) return Icons.account_balance;
    if (cat.contains('lazer')) return Icons.movie;
    if (cat.contains('mercado')) return Icons.shopping_cart;
    if (cat.contains('moradia')) return Icons.house;
    if (cat.contains('pet')) return Icons.pets;
    if (cat.contains('saúde')) return Icons.medical_services;
    if (cat.contains('serviço')) return Icons.build;
    if (cat.contains('transporte')) return Icons.directions_car;
    if (cat.contains('vestuário')) return Icons.checkroom;
    if (cat.contains('viagem')) return Icons.flight;

    return Icons.category_outlined;
  }
}
