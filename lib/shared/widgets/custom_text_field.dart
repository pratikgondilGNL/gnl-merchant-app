import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final AutovalidateMode autoValidateMode;
  final FocusNode? focusNode;
  final bool enabled;
  final int? maxLines;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextCapitalization textCapitalization;
  final List<String>? autofillHints;
  final TextStyle? labelStyle;
  final List<TextInputFormatter>? inputFormatters;

  final Color? filledColor;
  final Color? focusedBorderColor;
  final Color? enabledBorderColor;
  final Color? errorBorderColor;
  final Color? prefixIconColor;
  final Color? hintColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final bool showBorder;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.validator,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.focusNode,
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.labelStyle,
    this.inputFormatters,
    this.filledColor,
    this.focusedBorderColor,
    this.enabledBorderColor,
    this.errorBorderColor,
    this.prefixIconColor,
    this.hintColor,
    this.textColor,
    this.borderRadius,
    this.contentPadding,
    this.showBorder = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  FocusNode? _internalFocusNode;
  bool _isFocused = false;
  String? _errorText;
  bool _hasInteracted = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChange);
      widget.focusNode?.addListener(_onFocusChange);
      if (widget.focusNode == null) {
        (_internalFocusNode ??= FocusNode()).addListener(_onFocusChange);
      }
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChange);
      _internalFocusNode?.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onChanged(String value) {
    widget.onChanged?.call(value);
    _hasInteracted = true;
    if (widget.autoValidateMode == AutovalidateMode.always) {
      setState(() {
        _errorText = widget.validator?.call(value);
      });
    } else if (widget.autoValidateMode == AutovalidateMode.onUserInteraction && _hasInteracted) {
      setState(() {
        _errorText = widget.validator?.call(value);
      });
    } else if (_errorText != null) {
      setState(() {
        _errorText = widget.validator?.call(value);
      });
    }
  }

  void _onSubmitted(String value) {
    widget.onSubmitted?.call(value);
    if (widget.validator != null) {
      final error = widget.validator!(value);
      if (error != _errorText) {
        setState(() {
          _errorText = error;
        });
      }
    }
  }

  void validate() {
    _hasInteracted = true;
    setState(() {
      _errorText = widget.validator?.call(widget.controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final error = _errorText;
    final hasError = error != null;

    final currentBorderColor = hasError
        ? (widget.errorBorderColor ?? AppColors.primaryDark)
        : _isFocused
            ? (widget.focusedBorderColor ?? AppColors.primaryDark)
            : (widget.enabledBorderColor ?? AppColors.border);

    final effectiveFilledColor = widget.filledColor ?? AppColors.card;
    final effectiveIconColor = widget.prefixIconColor ?? AppColors.hint;
    final effectiveHintColor = widget.hintColor ?? AppColors.hint;
    final effectiveTextColor = widget.textColor ?? AppColors.textPrimary;
    final effectiveRadius = widget.borderRadius ?? 12.0;
    final effectivePadding =
        widget.contentPadding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: widget.labelStyle ??
                const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: effectiveFilledColor,
            borderRadius: BorderRadius.circular(effectiveRadius),
            border: widget.showBorder
                ? Border.all(color: currentBorderColor)
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            onChanged: _onChanged,
            onSubmitted: _onSubmitted,
            textCapitalization: widget.textCapitalization,
            autofillHints: widget.autofillHints,
            inputFormatters: widget.inputFormatters,
            style: TextStyle(color: effectiveTextColor),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: effectiveHintColor),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16, right: 12),
                      child: Icon(
                        widget.prefixIcon,
                        color: effectiveIconColor,
                        size: 20,
                      ),
                    )
                  : null,
              suffixIcon: widget.suffix,
              border: InputBorder.none,
              contentPadding: effectivePadding,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              error,
              style: const TextStyle(color: AppColors.primaryDark, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}
