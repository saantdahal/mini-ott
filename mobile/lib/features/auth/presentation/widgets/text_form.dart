import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniott/core/utils/responsive_query.dart';

class CustomTextFormField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  ConsumerState<CustomTextFormField> createState() =>
      _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends ConsumerState<CustomTextFormField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);
    final colorScheme = Theme.of(context).colorScheme;

    Widget? resolvedSuffix = widget.suffixIcon;
    if (widget.obscureText && resolvedSuffix == null) {
      resolvedSuffix = IconButton(
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        splashRadius: 20,
        tooltip: _obscure ? 'Show password' : 'Hide password',
      );
    }

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscure,
      enabled: true,
      readOnly: false,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: const TextStyle(fontSize: 14),
        prefixIcon: Icon(
          widget.prefixIcon,
          size: 20,
          color: colorScheme.primary,
        ),
        suffixIcon: resolvedSuffix,
        labelStyle: TextStyle(
          fontSize: screen.isMobile ? 14 : 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextStyle(fontSize: screen.isMobile ? 14 : 16),
      validator: widget.validator,
    );
  }
}
