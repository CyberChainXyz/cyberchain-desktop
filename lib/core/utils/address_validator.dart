class AddressValidator {
  static final RegExp _evmAddressRegex = RegExp(r'^0x[a-fA-F0-9]{40}$');
  static final RegExp _evmAddressWithSuffixRegex =
      RegExp(r'^0x[a-fA-F0-9]{40}([./@][a-zA-Z0-9]+)*$');

  static bool isValidCCXAddress(String? address) {
    if (address == null || address.isEmpty) {
      return false;
    }
    return _evmAddressRegex.hasMatch(address) ||
        _evmAddressWithSuffixRegex.hasMatch(address);
  }

  static String? validateCCXAddress(String? address) {
    if (address == null || address.isEmpty) {
      return 'Please enter a CCX address';
    }
    if (!isValidCCXAddress(address)) {
      return 'Invalid CCX address format. Must be an EVM address (0x...) or EVM address with multiple suffixes (0x...{./@}name{./@}name...)';
    }
    return null;
  }
}
