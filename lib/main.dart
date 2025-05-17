import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';

void main() {
  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const CurrencyConverterScreen(),
    );
  }
}

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  double amount = 1;
  String result = 'Result will appear here';
  bool isLoading = false;

  final List<String> currencies = ['USD', 'EUR', 'GBP', 'JPY'];

  Future<void> convertCurrency() async {
    if (amount <= 0) {
      setState(() {
        result = 'Enter a valid amount';
      });
      return;
    }

    setState(() {
      isLoading = true;
      result = '';
    });

    final url =
        'https://api.frankfurter.app/latest?amount=$amount&from=$fromCurrency&to=$toCurrency';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['rates'] != null && data['rates'][toCurrency] != null) {
        setState(() {
          result =
          '$amount $fromCurrency = ${data['rates'][toCurrency].toStringAsFixed(2)} $toCurrency';
          isLoading = false;
        });
      } else {
        setState(() {
          result = 'Conversion failed';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        result = 'Error fetching data';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF74ebd5), Color(0xFFACB6E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.white.withOpacity(0)),
          ),
          Center(
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '💱 Currency Converter',
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: fromCurrency,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(15),
              items: currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  fromCurrency = value!;
                });
              },
            ),
            const SizedBox(width: 12),
            const Icon(Icons.sync_alt, color: Colors.black54),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: toCurrency,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(15),
              items: currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  toCurrency = value!;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter amount',
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onChanged: (value) {
            amount = double.tryParse(value) ?? 1;
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6DD5FA),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
            shadowColor: Colors.blueAccent.withOpacity(0.5),
          ),
          onPressed: convertCurrency,
          child: const Text(
            'Convert',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        const SizedBox(height: 24),
        isLoading
            ? const CircularProgressIndicator(color: Colors.blueAccent)
            : Text(
          result,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
