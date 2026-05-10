import 'package:flutter/material.dart';
import '../app_theme.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final bool obscure;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final IconData? prefixIcon;
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.validator,
    this.obscure = false,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 14,
        fontFamily: 'Poppins',
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        border:OutlineInputBorder(),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppTheme.textSecondary, size: 20)
            : null,
        // Toggle show/hide for password fields
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
    );
  }
}