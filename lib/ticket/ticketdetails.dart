import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrts/modules/travel_log/controller/travel_log_controller.dart';
import 'package:mrts/modules/travel_log/model/travel_log_model.dart';
import 'package:mrts/modules/wallet/controller/wallet_controller.dart';
import 'package:mrts/services/payment_service.dart';
import 'confirmation.dart';

class TicketDetails extends StatefulWidget {
  final String fromStation;
  final String toStation;
  final String trainNumber;
  final double fare;
  final DateTime date;
  final String onboardingTime;
  final String arrivalTime;
  final int numberOfTickets;

  const TicketDetails({
    super.key,
    required this.fromStation,
    required this.toStation,
    required this.trainNumber,
    required this.fare,
    required this.date,
    required this.onboardingTime,
    required this.arrivalTime,
    required this.numberOfTickets,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TicketDetailsState createState() => _TicketDetailsState();
}

class _TicketDetailsState extends State<TicketDetails> {
  late int _numberOfTickets;
  late double _totalFare;

  /// Selected payment method
  /// Options: 'Metro Digital Wallet', 'bKash', 'Nagad', 'Visa/Mastercard'
  String _selectedPaymentMethod = 'Metro Digital Wallet';
  bool _isProcessingPayment = false;

  late final WalletController walletController;

  @override
  void initState() {
    super.initState();
    _numberOfTickets = widget.numberOfTickets;
    _totalFare = widget.fare * _numberOfTickets;
    walletController = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(WalletController());
  }

  void _updateFare(int count) {
    setState(() {
      _numberOfTickets = count;
      _totalFare = widget.fare * _numberOfTickets;
    });
  }

  /// Main payment handler — routes to wallet or SSLCommerz based on selection
  Future<void> _handlePayment() async {
    if (_isProcessingPayment) return;

    setState(() => _isProcessingPayment = true);

    try {
      if (_selectedPaymentMethod == 'Metro Digital Wallet') {
        // ─── Wallet Payment (instant, no SSLCommerz) ─────────────
        final success = walletController.deductFare(
          _totalFare,
          'Ticket: ${widget.fromStation} ➔ ${widget.toStation}',
        );
        if (success) {
          _navigateToConfirmation(paymentRef: 'WALLET-PAY');
        }
      } else {
        // ─── SSLCommerz Payment (bKash / Nagad / Card) ────────────
        final result = await PaymentService().initiateTicketPayment(
          amount: _totalFare,
          paymentMethod: _selectedPaymentMethod,
          fromStation: widget.fromStation,
          toStation: widget.toStation,
          numberOfTickets: _numberOfTickets,
          customerName: 'Metro Passenger',
          customerPhone: '01700000000',
          customerEmail: 'passenger@metrorail.bd',
        );

        if (!mounted) return;

        if (result.status == PaymentStatus.success) {
          // Payment successful — navigate to confirmation
          _navigateToConfirmation(paymentRef: result.transactionId);
        } else if (result.status == PaymentStatus.cancelled) {
          // User cancelled — just show message, stay on same screen
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Payment cancelled.'),
                backgroundColor: Colors.orange.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          // Payment failed
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.errorMessage ?? 'Payment failed. Please try again.'),
                backgroundColor: Colors.red.shade800,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  void _navigateToConfirmation({String? paymentRef}) {
    if (Get.isRegistered<TravelLogController>()) {
      Get.find<TravelLogController>().addTravelLog(
        TravelLogModel(
          id: 'TRIP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          fromStation: widget.fromStation,
          toStation: widget.toStation,
          trainNumber: widget.trainNumber,
          date: widget.date,
          onboardingTime: widget.onboardingTime,
          arrivalTime: widget.arrivalTime,
          fare: _totalFare,
          numberOfTickets: _numberOfTickets,
          paymentMethod: _selectedPaymentMethod,
          paymentRef: paymentRef ?? 'N/A',
          status: 'Upcoming',
          turnstileGate: 'Turnstile #04',
        ),
      );
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Confirmation(
          fromStation: widget.fromStation,
          toStation: widget.toStation,
          trainNumber: widget.trainNumber,
          fare: widget.fare,
          date: widget.date,
          onboardingTime: widget.onboardingTime,
          arrivalTime: widget.arrivalTime,
          numberOfTickets: _numberOfTickets,
          paymentMethod: _selectedPaymentMethod,
          paymentRef: paymentRef ?? 'N/A',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF3F1),
      appBar: AppBar(
        title: const Text('Checkout & Payment',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ── Journey Summary Card ──────────────────────────────
            _buildJourneySummaryCard(),
            const SizedBox(height: 20),

            // ── Payment Method Selection Card ─────────────────────
            _buildPaymentMethodCard(),
            const SizedBox(height: 24),

            // ── Pay Button ────────────────────────────────────────
            _buildPayButton(),

            const SizedBox(height: 12),
            _buildSecurityNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneySummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Journey Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.trainNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('From Station',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(widget.fromStation,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Dep: ${widget.onboardingTime}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Icon(Icons.east, color: Colors.green.shade700),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('To Station',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(widget.toStation,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Arr: ${widget.arrivalTime}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Passengers:',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Row(
                children: [
                  IconButton(
                    onPressed: _numberOfTickets > 1
                        ? () => _updateFare(_numberOfTickets - 1)
                        : null,
                    icon: Icon(Icons.remove_circle_outline,
                        color: Colors.green.shade700),
                  ),
                  Text('$_numberOfTickets',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(
                    onPressed: () => _updateFare(_numberOfTickets + 1),
                    icon: Icon(Icons.add_circle_outline,
                        color: Colors.green.shade700),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Fare Amount:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              Text(
                '৳ ${_totalFare.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
            ),
          ),
          const SizedBox(height: 12),

          // Wallet option with live balance
          Obx(() => _buildPaymentOption(
                value: 'Metro Digital Wallet',
                label: 'Metro Digital Wallet',
                subtitle:
                    'Balance: ৳ ${walletController.walletBalance.value.toStringAsFixed(0)}',
                assetType: 'wallet',
                iconColor: Colors.green.shade700,
                isInsufficient:
                    walletController.walletBalance.value < _totalFare,
              )),

          _buildPaymentOption(
            value: 'bKash',
            label: 'bKash Mobile Banking',
            subtitle: 'via SSLCommerz',
            assetType: 'images/bkash.png',
            iconColor: const Color(0xFFE2136E),
          ),

          _buildPaymentOption(
            value: 'Nagad',
            label: 'Nagad Digital Payment',
            subtitle: 'via SSLCommerz',
            assetType: 'nagad_badge',
            iconColor: const Color(0xFFFF6B00),
          ),

          _buildPaymentOption(
            value: 'Visa/Mastercard',
            label: 'Visa / Mastercard',
            subtitle: 'Debit or Credit Card via SSLCommerz',
            assetType: 'cards',
            iconColor: const Color(0xFF1A1F71),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String label,
    required String subtitle,
    required String assetType,
    required Color iconColor,
    bool isInsufficient = false,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? iconColor.withValues(alpha: 0.07)
              : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? iconColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildBrandWidget(assetType),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? iconColor : Colors.black87,
                    ),
                  ),
                  Text(
                    isInsufficient && value == 'Metro Digital Wallet'
                        ? '⚠ Insufficient balance — please top up'
                        : subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isInsufficient && value == 'Metro Digital Wallet'
                          ? Colors.red.shade600
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            // ignore: deprecated_member_use
            Radio<String>(
              value: value,
              // ignore: deprecated_member_use
              groupValue: _selectedPaymentMethod,
              // ignore: deprecated_member_use
              onChanged: (val) =>
                  setState(() => _selectedPaymentMethod = val!),
              activeColor: iconColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandWidget(String assetType) {
    if (assetType == 'images/bkash.png') {
      return Container(
        width: 32,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFE2136E).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Image.asset('images/bkash.png', fit: BoxFit.contain),
      );
    } else if (assetType == 'nagad_badge') {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B00),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Center(
          child: Text(
            'নগদ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      );
    } else if (assetType == 'cards') {
      return Container(
        width: 40,
        height: 32,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/visacard.png', width: 16, fit: BoxFit.contain),
            const SizedBox(width: 2),
            Image.asset('images/mastercard.png', width: 16, fit: BoxFit.contain),
          ],
        ),
      );
    } else {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(Icons.account_balance_wallet,
            color: Colors.green.shade800, size: 20),
      );
    }
  }

  Widget _buildPayButton() {
    final isWalletInsufficient = _selectedPaymentMethod ==
            'Metro Digital Wallet' &&
        walletController.walletBalance.value < _totalFare;

    return AnimatedOpacity(
      opacity: _isProcessingPayment ? 0.7 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: _isProcessingPayment || isWalletInsufficient
            ? null
            : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          disabledBackgroundColor: Colors.grey.shade300,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
        ),
        child: _isProcessingPayment
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Processing Payment...',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    isWalletInsufficient
                        ? 'Insufficient Balance'
                        : 'Pay ৳${_totalFare.toStringAsFixed(0)} & Get NFC Pass',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.security, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          'Payment secured by SSLCommerz',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
