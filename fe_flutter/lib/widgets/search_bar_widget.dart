import 'dart:async';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final String hintText;
  final Duration debounceDuration;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    this.hintText = 'Cari produk...',
    this.debounceDuration = const Duration(milliseconds: 400),
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onSearch(value.trim());
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? const Color(0xFF7C3AED).withOpacity(0.15)
                : Colors.black.withOpacity(0.06),
            blurRadius: _isFocused ? 16 : 10,
            offset: const Offset(0, 4),
            spreadRadius: _isFocused ? 2 : 0,
          ),
        ],
        border: Border.all(
          color: _isFocused
              ? const Color(0xFF7C3AED).withOpacity(0.5)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onChanged,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _isFocused
                ? const Color(0xFF7C3AED)
                : Colors.grey.shade400,
            size: 22,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
