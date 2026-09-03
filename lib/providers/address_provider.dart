import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../models/address.dart';
import '../services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  AddressProvider(this._addressService);

  final AddressService _addressService;

  List<Address> addresses = [];
  bool isLoading = false;
  String? errorMessage;

  /// The address Home's "Deliver to" should show - the one marked default,
  /// or if none is marked default but there's exactly one address, that
  /// one. Null if there are zero addresses, or 2+ with none marked
  /// default (ambiguous - Home falls back to a neutral "Select address"
  /// prompt in that case rather than guessing which one to show).
  Address? get deliveryAddress {
    if (addresses.isEmpty) return null;
    final defaultAddress = addresses.where((a) => a.isDefault).firstOrNull;
    if (defaultAddress != null) return defaultAddress;
    return addresses.length == 1 ? addresses.first : null;
  }

  Future<void> loadAddresses() async {
    isLoading = true;
    notifyListeners();

    try {
      addresses = await _addressService.getAddresses();
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAddress({
    String? label,
    required String line1,
    String? line2,
    required String city,
    required String state,
    required String pincode,
    bool isDefault = false,
  }) async {
    try {
      await _addressService.addAddress(
        label: label,
        line1: line1,
        line2: line2,
        city: city,
        state: state,
        pincode: pincode,
        isDefault: isDefault,
      );
      await loadAddresses();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteAddress(int id) async {
    await _addressService.deleteAddress(id);
    await loadAddresses();
  }
}
