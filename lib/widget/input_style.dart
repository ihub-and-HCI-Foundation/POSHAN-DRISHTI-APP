import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputStyle {
  /// Default primary input style (rounded, filled)
  static InputDecoration normalInput({
    String? label,
    String? hint,
    IconData? prefixIcon,
    IconData? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: Colors.grey[700], size: 16)
          : null,
      prefixIconConstraints: BoxConstraints(
        maxHeight: 48,
        maxWidth: 30,
        minHeight: 48,
        minWidth: 30,
      ),
      suffixIcon: suffix != null
          ? Icon(suffix, color: Colors.grey[700], size: 16)
          : null,
      labelStyle: GoogleFonts.inter(
        color: Colors.blue[50]!.withValues(alpha: 0.9),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: GoogleFonts.inter(
        color: Colors.grey[500]!.withValues(alpha: 0.7),
        fontSize: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5), // perfect rectangle
        borderSide: BorderSide(color: Colors.grey[500]!, width: 1.8),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: Colors.grey[500]!, width: 1.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: Colors.blue[900]!, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  /// Outlined input (no fill)
  /* static InputDecoration outlined({
    String? label,
    String? hint,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: false,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primarySwatch[600]) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      labelStyle: GoogleFonts.inter(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.inter(
        color: AppColors.textSecondary.withValues(alpha: 0.6),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primarySwatch[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primarySwatch[700]!),
      ),
    );
  }*/

  /// Minimal (borderless) input, for search bars etc.
  /* static InputDecoration minimal({
    String? hint,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.textSecondary.withValues(alpha: 0.8))
          : null,
      border: InputBorder.none,
      hintStyle: GoogleFonts.inter(
        color: AppColors.textSecondary.withValues(alpha: 0.6),
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    );
  }*/
}
