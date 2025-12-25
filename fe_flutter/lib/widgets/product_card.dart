import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback? onViewDetail;
  final bool isLoading;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    this.onViewDetail,
    this.isLoading = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final bool isOutOfStock = product.stock <= 0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: () {
          if (widget.onViewDetail != null) {
            widget.onViewDetail!();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isOutOfStock
                  ? [Colors.grey.shade300, Colors.grey.shade400]
                  : [Colors.white, Colors.grey.shade50],
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? Colors.deepPurple.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
                blurRadius: _isPressed ? 20 : 12,
                offset: Offset(0, _isPressed ? 8 : 4),
                spreadRadius: _isPressed ? 2 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // ================= MAIN CONTENT =================
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image / Icon
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.deepPurple.shade100,
                                Colors.teal.shade100,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _getProductIcon(product.name),
                              size: 40,
                              color: Colors.deepPurple.shade400,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Name
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isOutOfStock
                              ? Colors.grey.shade600
                              : Colors.grey.shade800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // SKU
                      Text(
                        product.sku,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const Spacer(),

                      // ================= PRICE + ADD BUTTON =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rp ${_formatPrice(product.sellPrice)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isOutOfStock
                                  ? Colors.grey.shade500
                                  : Colors.deepPurple.shade700,
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (isOutOfStock || widget.isLoading) return;
                              widget.onAddToCart();
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isOutOfStock
                                    ? null
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFF7C3AED),
                                          Color(0xFF2DD4BF),
                                        ],
                                      ),
                                color:
                                    isOutOfStock ? Colors.grey.shade400 : null,
                              ),
                              child: widget.isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      isOutOfStock
                                          ? Icons.block_rounded
                                          : Icons.add_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ================= STOCK BADGE =================
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isOutOfStock
                          ? Colors.red.shade400
                          : product.stock < 10
                              ? Colors.orange.shade400
                              : Colors.green.shade400,
                    ),
                    child: Text(
                      isOutOfStock ? 'Habis' : '${product.stock}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getProductIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('kopi') || lower.contains('coffee')) {
      return Icons.coffee_rounded;
    } else if (lower.contains('minum') || lower.contains('drink')) {
      return Icons.local_drink_rounded;
    } else if (lower.contains('makan') || lower.contains('food')) {
      return Icons.restaurant_rounded;
    } else if (lower.contains('snack')) {
      return Icons.cookie_rounded;
    }
    return Icons.shopping_bag_rounded;
  }

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    return intPrice.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
