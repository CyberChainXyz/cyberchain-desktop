import 'package:web3dart/credentials.dart';

class AddressValidator {
  static final RegExp _evmAddressWithSuffixRegex =
      RegExp(r'^0x[a-fA-F0-9]{40}([./@][a-zA-Z0-9]+)*$');

  static bool _isValidEVMAddress(String address) {
    try {
      EthereumAddress.fromHex(address, enforceEip55: false);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool isValidMiningAddress(String? address) {
    if (address == null || address.isEmpty) {
      return false;
    }

    // Trim whitespace
    final trimmedAddress = address.trim();

    // For addresses with suffix
    if (_evmAddressWithSuffixRegex.hasMatch(trimmedAddress)) {
      String baseAddress = trimmedAddress.substring(0, 42);
      return _isValidEVMAddress(baseAddress);
    }

    // For simple EVM addresses
    return _isValidEVMAddress(trimmedAddress);
  }

  static String? validateMiningAddress(String? address) {
    if (address == null || address.isEmpty) {
      return 'Please enter a XCC address';
    }

    // Trim whitespace
    final trimmedAddress = address.trim();

    if (!trimmedAddress.startsWith('0x')) {
      return 'Address must start with 0x';
    }

    if (trimmedAddress.length < 42) {
      return 'Address must be at least 42 characters long (including 0x prefix)';
    }

    if (!isValidMiningAddress(trimmedAddress)) {
      return 'Must be an EVM address (0x...) or EVM address with suffixes(0x...{./@}name{./@}name...)';
    }

    return null;
  }
}
