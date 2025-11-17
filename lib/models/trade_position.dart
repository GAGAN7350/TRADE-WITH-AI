import 'package:cloud_firestore/cloud_firestore.dart';

/// Trading position model
class TradePosition {
  final String id;
  final String userId;
  final String symbol;
  final String type; // 'buy' or 'sell'
  final double quantity;
  final double entryPrice;
  final double? exitPrice;
  final String status; // 'open', 'closed', 'pending'
  final DateTime createdAt;
  final DateTime? closedAt;

  TradePosition({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.entryPrice,
    this.exitPrice,
    required this.status,
    required this.createdAt,
    this.closedAt,
  });

  /// Calculate profit/loss
  double get profitLoss {
    if (exitPrice == null) return 0.0;
    if (type == 'buy') {
      return (exitPrice! - entryPrice) * quantity;
    } else {
      return (entryPrice - exitPrice!) * quantity;
    }
  }

  /// Create TradePosition from Firestore document
  factory TradePosition.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TradePosition(
      id: doc.id,
      userId: data['userId'] ?? '',
      symbol: data['symbol'] ?? '',
      type: data['type'] ?? 'buy',
      quantity: (data['quantity'] ?? 0).toDouble(),
      entryPrice: (data['entryPrice'] ?? 0).toDouble(),
      exitPrice: data['exitPrice']?.toDouble(),
      status: data['status'] ?? 'open',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      closedAt: data['closedAt'] != null
          ? (data['closedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert TradePosition to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'symbol': symbol,
      'type': type,
      'quantity': quantity,
      'entryPrice': entryPrice,
      'exitPrice': exitPrice,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
    };
  }
}
