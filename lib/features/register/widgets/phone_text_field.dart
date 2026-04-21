import 'package:aspiro_trade/ui/theme/theme.dart';
import 'package:flutter/material.dart';

/// Country model for phone code selector
class CountryCode {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const CountryCode({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

/// Top 30+ most common countries for phone registration
const List<CountryCode> countryCodes = [
  CountryCode(name: 'Russia', code: 'RU', dialCode: '+7', flag: '🇷🇺'),
  CountryCode(name: 'United States', code: 'US', dialCode: '+1', flag: '🇺🇸'),
  CountryCode(name: 'United Kingdom', code: 'GB', dialCode: '+44', flag: '🇬🇧'),
  CountryCode(name: 'Ukraine', code: 'UA', dialCode: '+380', flag: '🇺🇦'),
  CountryCode(name: 'Kazakhstan', code: 'KZ', dialCode: '+7', flag: '🇰🇿'),
  CountryCode(name: 'Belarus', code: 'BY', dialCode: '+375', flag: '🇧🇾'),
  CountryCode(name: 'Germany', code: 'DE', dialCode: '+49', flag: '🇩🇪'),
  CountryCode(name: 'France', code: 'FR', dialCode: '+33', flag: '🇫🇷'),
  CountryCode(name: 'Italy', code: 'IT', dialCode: '+39', flag: '🇮🇹'),
  CountryCode(name: 'Spain', code: 'ES', dialCode: '+34', flag: '🇪🇸'),
  CountryCode(name: 'Turkey', code: 'TR', dialCode: '+90', flag: '🇹🇷'),
  CountryCode(name: 'Poland', code: 'PL', dialCode: '+48', flag: '🇵🇱'),
  CountryCode(name: 'Canada', code: 'CA', dialCode: '+1', flag: '🇨🇦'),
  CountryCode(name: 'Brazil', code: 'BR', dialCode: '+55', flag: '🇧🇷'),
  CountryCode(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳'),
  CountryCode(name: 'China', code: 'CN', dialCode: '+86', flag: '🇨🇳'),
  CountryCode(name: 'Japan', code: 'JP', dialCode: '+81', flag: '🇯🇵'),
  CountryCode(name: 'South Korea', code: 'KR', dialCode: '+82', flag: '🇰🇷'),
  CountryCode(name: 'UAE', code: 'AE', dialCode: '+971', flag: '🇦🇪'),
  CountryCode(name: 'Saudi Arabia', code: 'SA', dialCode: '+966', flag: '🇸🇦'),
  CountryCode(name: 'Israel', code: 'IL', dialCode: '+972', flag: '🇮🇱'),
  CountryCode(name: 'Australia', code: 'AU', dialCode: '+61', flag: '🇦🇺'),
  CountryCode(name: 'Netherlands', code: 'NL', dialCode: '+31', flag: '🇳🇱'),
  CountryCode(name: 'Sweden', code: 'SE', dialCode: '+46', flag: '🇸🇪'),
  CountryCode(name: 'Norway', code: 'NO', dialCode: '+47', flag: '🇳🇴'),
  CountryCode(name: 'Finland', code: 'FI', dialCode: '+358', flag: '🇫🇮'),
  CountryCode(name: 'Czech Republic', code: 'CZ', dialCode: '+420', flag: '🇨🇿'),
  CountryCode(name: 'Portugal', code: 'PT', dialCode: '+351', flag: '🇵🇹'),
  CountryCode(name: 'Georgia', code: 'GE', dialCode: '+995', flag: '🇬🇪'),
  CountryCode(name: 'Armenia', code: 'AM', dialCode: '+374', flag: '🇦🇲'),
  CountryCode(name: 'Azerbaijan', code: 'AZ', dialCode: '+994', flag: '🇦🇿'),
  CountryCode(name: 'Uzbekistan', code: 'UZ', dialCode: '+998', flag: '🇺🇿'),
  CountryCode(name: 'Kyrgyzstan', code: 'KG', dialCode: '+996', flag: '🇰🇬'),
  CountryCode(name: 'Tajikistan', code: 'TJ', dialCode: '+992', flag: '🇹🇯'),
  CountryCode(name: 'Moldova', code: 'MD', dialCode: '+373', flag: '🇲🇩'),
  CountryCode(name: 'Mexico', code: 'MX', dialCode: '+52', flag: '🇲🇽'),
  CountryCode(name: 'Argentina', code: 'AR', dialCode: '+54', flag: '🇦🇷'),
  CountryCode(name: 'Thailand', code: 'TH', dialCode: '+66', flag: '🇹🇭'),
  CountryCode(name: 'Indonesia', code: 'ID', dialCode: '+62', flag: '🇮🇩'),
  CountryCode(name: 'Singapore', code: 'SG', dialCode: '+65', flag: '🇸🇬'),
];

class PhoneTextField extends StatefulWidget {
  const PhoneTextField({
    super.key,
    required this.phoneController,
    required this.phoneFocus,
    required this.onChanged,
  });

  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final ValueChanged<String> onChanged;

  @override
  State<PhoneTextField> createState() => _PhoneTextFieldState();
}

class _PhoneTextFieldState extends State<PhoneTextField> {
  CountryCode _selected = countryCodes[0]; // Default: Russia

  void _onPhoneChanged(String value) {
    // Combine country code + local number
    final fullPhone = '${_selected.dialCode}${value.replaceAll(RegExp(r'\D'), '')}';
    widget.onChanged(fullPhone);
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CountryPickerSheet(
        selected: _selected,
        onSelect: (country) {
          setState(() => _selected = country);
          Navigator.pop(ctx);
          _onPhoneChanged(widget.phoneController.text);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: widget.phoneController,
          focusNode: widget.phoneFocus,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          onChanged: _onPhoneChanged,
          onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            hintText: '000 000 0000',
            prefixIcon: GestureDetector(
              onTap: _showCountryPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selected.code,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selected.dialCode,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 24,
                      color: AppColors.border,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet with search for country picker
class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({
    required this.selected,
    required this.onSelect,
  });

  final CountryCode selected;
  final ValueChanged<CountryCode> onSelect;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchController = TextEditingController();
  List<CountryCode> _filtered = countryCodes;

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = countryCodes;
      } else {
        final q = query.toLowerCase();
        _filtered = countryCodes
            .where((c) =>
                c.name.toLowerCase().contains(q) ||
                c.dialCode.contains(q) ||
                c.code.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textQuaternary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Select Country',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filter,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search country...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.elevated,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Country list
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: _filtered.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final country = _filtered[index];
                final isSelected = country.code == widget.selected.code;
                return ListTile(
                  onTap: () => widget.onSelect(country),
                  leading: Container(
                    width: 38,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      country.code,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  title: Text(
                    country.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.brand
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: Text(
                    country.dialCode,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.brand
                          : AppColors.textSecondary,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  selectedTileColor: AppColors.brand.withValues(alpha: 0.08),
                  selected: isSelected,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
