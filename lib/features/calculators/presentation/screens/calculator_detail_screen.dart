import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/calculator_models.dart';
import '../providers/calculator_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class CalculatorDetailScreen extends ConsumerStatefulWidget {
  final String calculatorId;

  const CalculatorDetailScreen({super.key, required this.calculatorId});

  @override
  ConsumerState<CalculatorDetailScreen> createState() =>
      _CalculatorDetailScreenState();
}

class _CalculatorDetailScreenState
    extends ConsumerState<CalculatorDetailScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _selectedUnits = {};
  bool _showInfo = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculatorAsync = ref.watch(calculatorProvider(widget.calculatorId));
    final result = ref.watch(calculationResultProvider(widget.calculatorId));

    return calculatorAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (calculator) {
        if (calculator == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Calculator not found')),
          );
        }

        // Initialize controllers
        for (final input in calculator.inputs) {
          _controllers.putIfAbsent(
            input.id,
            () => TextEditingController(
              text: input.defaultValue?.toString() ?? '',
            ),
          );
          _selectedUnits.putIfAbsent(input.id, () => input.defaultUnit);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(calculator.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => setState(() => _showInfo = !_showInfo),
                tooltip: 'Info',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info panel (collapsible)
                if (_showInfo) _buildInfoPanel(calculator),

                // Formula display
                _buildFormulaCard(calculator),

                const SizedBox(height: 16),

                // Input fields
                ...calculator.inputs.map((input) => _buildInputField(input)),

                const SizedBox(height: 16),

                // Calculate button
                FilledButton.icon(
                  onPressed: () => _calculate(calculator),
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculate'),
                ),

                const SizedBox(height: 16),

                // Results
                if (result != null && result.isSuccessful)
                  _buildResultsCard(calculator, result),

                // Warnings
                if (result != null)
                  ...result.inputValidations.entries
                      .where((e) => e.value.hasWarning)
                      .map((e) => _buildWarning(e.value.warningMessage!)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoPanel(CalculatorDefinition calculator) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.secondaryContainer,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About this calculator',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(calculator.description),
            const SizedBox(height: 12),
            Text(
              'Clinical Note',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              calculator.clinicalNote,
              style: theme.textTheme.bodyMedium,
            ),
            if (calculator.sourceUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Sources',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...calculator.sourceUrls.map((url) => InkWell(
                    onTap: () => _launchUrl(url),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        url,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaCard(CalculatorDefinition calculator) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              calculator.formula,
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(calculator.category),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(InputField input) {
    final controller = _controllers[input.id]!;
    final hasAlternateUnits = input.alternateUnits.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: InputDecoration(
                labelText: input.label,
                hintText: input.hint,
                suffixText:
                    hasAlternateUnits ? null : input.defaultUnit,
              ),
              onChanged: (value) {
                final numValue = double.tryParse(value);
                if (numValue != null) {
                  ref
                      .read(calculatorInputProvider(widget.calculatorId).notifier)
                      .setValue(input.id, numValue);
                }
              },
            ),
          ),
          if (hasAlternateUnits) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _selectedUnits[input.id],
                isExpanded: true,
                items: input.allUnits.map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (unit) {
                  if (unit != null) {
                    setState(() => _selectedUnits[input.id] = unit);
                    ref
                        .read(calculatorUnitProvider(widget.calculatorId).notifier)
                        .setUnit(input.id, unit);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsCard(
      CalculatorDefinition calculator, CalculationResult result) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Results',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...calculator.outputs.map((output) {
              final value = result.outputs[output.id];
              if (value == null) return const SizedBox.shrink();

              final formattedValue = value.toStringAsFixed(output.decimalPlaces);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            output.label,
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (output.interpretation != null)
                            Text(
                              output.interpretation!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '$formattedValue ${output.unit}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () => _copyResult(formattedValue, output.unit),
                          tooltip: 'Copy',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _saveToHistory(calculator, result),
                  icon: const Icon(Icons.save),
                  label: const Text('Save to History'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarning(String message) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.tertiaryContainer,
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: theme.colorScheme.tertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: theme.colorScheme.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculate(CalculatorDefinition calculator) {
    // Update all input values from controllers
    for (final input in calculator.inputs) {
      final value = double.tryParse(_controllers[input.id]?.text ?? '');
      if (value != null) {
        ref
            .read(calculatorInputProvider(widget.calculatorId).notifier)
            .setValue(input.id, value);
      }
    }

    // Update selected units
    for (final entry in _selectedUnits.entries) {
      ref
          .read(calculatorUnitProvider(widget.calculatorId).notifier)
          .setUnit(entry.key, entry.value);
    }
  }

  void _copyResult(String value, String unit) {
    Clipboard.setData(ClipboardData(text: '$value $unit'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _saveToHistory(
      CalculatorDefinition calculator, CalculationResult result) {
    final inputs = <String, dynamic>{};
    for (final input in calculator.inputs) {
      final value = double.tryParse(_controllers[input.id]?.text ?? '');
      inputs[input.label] = '$value ${_selectedUnits[input.id]}';
    }

    final outputs = <String, dynamic>{};
    for (final output in calculator.outputs) {
      final value = result.outputs[output.id];
      if (value != null) {
        outputs[output.label] =
            '${value.toStringAsFixed(output.decimalPlaces)} ${output.unit}';
      }
    }

    ref.read(historyProvider.notifier).saveCalculation(
          calculatorId: calculator.id,
          calculatorName: calculator.name,
          inputs: inputs,
          outputs: outputs,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to history')),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
