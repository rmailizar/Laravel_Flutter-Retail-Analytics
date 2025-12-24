import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final bool isUpdating;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade100,
                    Colors.teal.shade100,
                  ],
                ),
              ),
              child: Icon(
                Icons.shopping_bag_rounded,
                color: Colors.deepPurple.shade400,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${_formatPrice(item.product.sellPrice)} × ${item.qty}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${_formatPrice(item.subtotal)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                ],
              ),
            ),
            // Quantity Controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decrease Button
                _QuantityButton(
                  icon: item.qty == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                  onTap: item.qty == 1 ? onRemove : onDecrement,
                  isDestructive: item.qty == 1,
                  isLoading: isUpdating,
                ),
                Container(
                  width: 36,
                  alignment: Alignment.center,
                  child: isUpdating
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.deepPurple.shade400,
                          ),
                        )
                      : Text(
                          '${item.qty}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                ),
                // Increase Button
                _QuantityButton(
                  icon: Icons.add_rounded,
                  onTap: onIncrement,
                  isLoading: isUpdating,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    return intPrice.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isLoading;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isDestructive
                ? Colors.red.shade50
                : Colors.deepPurple.shade50,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDestructive
                ? Colors.red.shade600
                : Colors.deepPurple.shade600,
          ),
        ),
      ),
    );
  }
}
