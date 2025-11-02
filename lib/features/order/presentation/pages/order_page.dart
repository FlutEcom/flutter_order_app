import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_order_app/core/di/injector.dart';
import 'package:flutter_order_app/features/order/domain/entities/order_analysis_result.dart';
import 'package:flutter_order_app/features/order/presentation/bloc/order_bloc.dart';
import 'package:flutter_order_app/features/products/presentation/bloc/product_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Tworzymy BLoC lokalnie, ponieważ jest potrzebny tylko na tym ekranie
    return BlocProvider(
      create: (context) => sl<OrderBloc>(),
      child: const OrderView(),
    );
  }
}

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  final _textController = TextEditingController();

  // Przykładowe teksty do testów
  final String _exampleText1 =
      "Poproszę 2x iPhone 9 oraz 1x Samsung Universe 9. Dodatkowo 3 sztuki Apple AirPods.";
  final String _exampleText2 =
      "Zamawiam: iPhone 9 (qty: 2), AirPods (qty: 3), Universe 9 (1).";

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onAnalyzePressed() {
    final productState = context.read<ProductBloc>().state;
    if (productState is ProductLoaded) {
      context.read<OrderBloc>().add(AnalyzeOrderEvent(
            orderText: _textController.text,
            allProducts: productState.allProducts,
          ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Poczekaj, aż lista produktów zostanie załadowana.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _exportToJson(OrderAnalysisResult result) async {
    try {
      final jsonString = jsonEncode(result.toJson());
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/order_result.json').create();
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Wynik analizy zamówienia',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd podczas eksportu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sprawdzamy stan ProductBloc, aby wiedzieć, czy możemy analizować
    final productState = context.watch<ProductBloc>().state;
    bool canAnalyze = false;
    if (productState is ProductLoaded) {
      // Możemy analizować tylko, jeśli stan to ProductLoaded ORAZ lista nie jest pusta
      canAnalyze = productState.allProducts.isNotEmpty;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analiza Zamówienia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextInput(context),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: canAnalyze && _textController.text.isNotEmpty
                  ? _onAnalyzePressed
                  : null,
              icon: const Icon(Icons.smart_toy_outlined),
              label: const Text('Analizuj tekst przez AI'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            if (!canAnalyze)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Analiza będzie dostępna po załadowaniu listy produktów.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildResultView(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wklej tekst (np. mail z zamówieniem):',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _textController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Np. "Poproszę 2x iPhone 9..."',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (text) => setState(() {}), 
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                _textController.text = _exampleText1;
                setState(() {}); 
              },
              child: const Text('Test 1'),
            ),
            TextButton(
              onPressed: () {
                _textController.text = _exampleText2;
                setState(() {}); 
              },
              child: const Text('Test 2'),
            ),
            TextButton(
              onPressed: () {
                _textController.clear();
                setState(() {}); 
              },
              child: const Text('Wyczyść', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return BlocConsumer<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Analizowanie...'),
              ],
            ),
          );
        }
        if (state is OrderAnalysisSuccess) {
          return _buildResultTable(state.result);
        }
        if (state is OrderError) {
          return Center(
            child: Text(
              'Błąd analizy:\n${state.message}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildResultTable(OrderAnalysisResult result) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Wyniki analizy', style: textTheme.titleLarge),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Eksportuj do JSON (Bonus)',
              onPressed: () => _exportToJson(result),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
            columns: const [
              DataColumn(label: Text('Nazwa produktu')),
              DataColumn(label: Text('Ilość'), numeric: true),
              DataColumn(label: Text('Cena jedn.'), numeric: true),
              DataColumn(label: Text('Suma'), numeric: true),
            ],
            rows: result.items.map((item) {
              if (item.isMatched) {
                return DataRow(cells: [
                  DataCell(Text(item.productName)),
                  DataCell(Text(item.quantity.toString())),
                  DataCell(Text('${item.unitPrice!.toStringAsFixed(2)} zł')),
                  DataCell(Text(
                    '${item.itemSum!.toStringAsFixed(2)} zł',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                ]);
              } else {
                // Niedopasowane
                return DataRow(
                  color: MaterialStateProperty.all(Colors.red[50]),
                  cells: [
                    DataCell(Text(
                      item.productName,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    )),
                    DataCell(Text(item.quantity.toString())),
                    DataCell(
                      Text(
                        'Niedopasowane',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                    const DataCell(Text('-')),
                  ],
                );
              }
            }).toList(),
          ),
        ),
        const Divider(height: 32),
        Text(
          'Suma całkowita: ${result.totalSum.toStringAsFixed(2)} zł',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}