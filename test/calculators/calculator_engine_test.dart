import 'package:flutter_test/flutter_test.dart';
import 'package:rt_onestop/features/calculators/domain/calculator_engine.dart';
import 'package:rt_onestop/features/calculators/domain/models/calculator_models.dart';

void main() {
  late CalculatorEngine engine;

  setUp(() {
    engine = CalculatorEngine();
  });

  group('Ventilation Calculators', () {
    test('Minute Ventilation calculation', () {
      final calculator = CalculatorDefinition(
        id: 'minute_ventilation',
        name: 'Minute Ventilation',
        category: 'Ventilation',
        description: '',
        formula: 'VE = VT × RR',
        inputs: [
          const InputField(id: 'tidal_volume', label: 'VT', defaultUnit: 'mL'),
          const InputField(id: 'respiratory_rate', label: 'RR', defaultUnit: 'breaths/min'),
        ],
        outputs: [
          const OutputField(id: 'minute_ventilation', label: 'VE', unit: 'L/min'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'tidal_volume': 500.0, 'respiratory_rate': 12.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['minute_ventilation'], equals(6.0));
    });

    test('Alveolar Ventilation calculation', () {
      final calculator = CalculatorDefinition(
        id: 'alveolar_ventilation',
        name: 'Alveolar Ventilation',
        category: 'Ventilation',
        description: '',
        formula: 'VA = (VT - VD) × RR',
        inputs: [
          const InputField(id: 'tidal_volume', label: 'VT', defaultUnit: 'mL'),
          const InputField(id: 'dead_space', label: 'VD', defaultUnit: 'mL'),
          const InputField(id: 'respiratory_rate', label: 'RR', defaultUnit: 'breaths/min'),
        ],
        outputs: [
          const OutputField(id: 'alveolar_ventilation', label: 'VA', unit: 'L/min'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'tidal_volume': 500.0, 'dead_space': 150.0, 'respiratory_rate': 12.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['alveolar_ventilation'], closeTo(4.2, 0.01));
    });

    test('Dead Space Ratio (Vd/Vt) calculation', () {
      final calculator = CalculatorDefinition(
        id: 'dead_space_ratio',
        name: 'Dead Space Ratio',
        category: 'Ventilation',
        description: '',
        formula: 'Vd/Vt = (PaCO2 - PeCO2) / PaCO2',
        inputs: [
          const InputField(id: 'paco2', label: 'PaCO2', defaultUnit: 'mmHg'),
          const InputField(id: 'peco2', label: 'PeCO2', defaultUnit: 'mmHg'),
        ],
        outputs: [
          const OutputField(id: 'vd_vt_ratio', label: 'Vd/Vt', unit: ''),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'paco2': 40.0, 'peco2': 28.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['vd_vt_ratio'], closeTo(0.3, 0.01));
    });

    test('Rapid Shallow Breathing Index calculation', () {
      final calculator = CalculatorDefinition(
        id: 'rapid_shallow_breathing',
        name: 'RSBI',
        category: 'Ventilation',
        description: '',
        formula: 'RSBI = f / VT',
        inputs: [
          const InputField(id: 'respiratory_rate', label: 'RR', defaultUnit: 'breaths/min'),
          const InputField(id: 'tidal_volume', label: 'VT', defaultUnit: 'mL'),
        ],
        outputs: [
          const OutputField(id: 'rsbi', label: 'RSBI', unit: 'breaths/min/L'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'respiratory_rate': 25.0, 'tidal_volume': 300.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['rsbi'], closeTo(83.33, 0.1));
    });

    test('Static Compliance calculation', () {
      final calculator = CalculatorDefinition(
        id: 'static_compliance',
        name: 'Static Compliance',
        category: 'Ventilation',
        description: '',
        formula: 'Cstat = VT / (Pplat - PEEP)',
        inputs: [
          const InputField(id: 'tidal_volume', label: 'VT', defaultUnit: 'mL'),
          const InputField(id: 'plateau_pressure', label: 'Pplat', defaultUnit: 'cmH2O'),
          const InputField(id: 'peep', label: 'PEEP', defaultUnit: 'cmH2O'),
        ],
        outputs: [
          const OutputField(id: 'static_compliance', label: 'Cstat', unit: 'mL/cmH2O'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'tidal_volume': 500.0, 'plateau_pressure': 25.0, 'peep': 5.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['static_compliance'], equals(25.0));
    });

    test('Dynamic Compliance calculation', () {
      final calculator = CalculatorDefinition(
        id: 'dynamic_compliance',
        name: 'Dynamic Compliance',
        category: 'Ventilation',
        description: '',
        formula: 'Cdyn = VT / (PIP - PEEP)',
        inputs: [
          const InputField(id: 'tidal_volume', label: 'VT', defaultUnit: 'mL'),
          const InputField(id: 'peak_inspiratory_pressure', label: 'PIP', defaultUnit: 'cmH2O'),
          const InputField(id: 'peep', label: 'PEEP', defaultUnit: 'cmH2O'),
        ],
        outputs: [
          const OutputField(id: 'dynamic_compliance', label: 'Cdyn', unit: 'mL/cmH2O'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'tidal_volume': 500.0, 'peak_inspiratory_pressure': 35.0, 'peep': 5.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['dynamic_compliance'], closeTo(16.67, 0.1));
    });

    test('Airway Resistance calculation', () {
      final calculator = CalculatorDefinition(
        id: 'airway_resistance',
        name: 'Airway Resistance',
        category: 'Ventilation',
        description: '',
        formula: 'Raw = (PIP - Pplat) / Flow',
        inputs: [
          const InputField(id: 'peak_inspiratory_pressure', label: 'PIP', defaultUnit: 'cmH2O'),
          const InputField(id: 'plateau_pressure', label: 'Pplat', defaultUnit: 'cmH2O'),
          const InputField(id: 'flow', label: 'Flow', defaultUnit: 'L/min'),
        ],
        outputs: [
          const OutputField(id: 'airway_resistance', label: 'Raw', unit: 'cmH2O/L/sec'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'peak_inspiratory_pressure': 35.0, 'plateau_pressure': 25.0, 'flow': 60.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['airway_resistance'], equals(10.0));
    });
  });

  group('Oxygenation Calculators', () {
    test('A-a Gradient calculation', () {
      final calculator = CalculatorDefinition(
        id: 'aa_gradient',
        name: 'A-a Gradient',
        category: 'Oxygenation',
        description: '',
        formula: 'A-a = PAO2 - PaO2',
        inputs: [
          const InputField(id: 'alveolar_po2', label: 'PAO2', defaultUnit: 'mmHg'),
          const InputField(id: 'arterial_po2', label: 'PaO2', defaultUnit: 'mmHg'),
        ],
        outputs: [
          const OutputField(id: 'aa_gradient', label: 'A-a', unit: 'mmHg'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'alveolar_po2': 100.0, 'arterial_po2': 90.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['aa_gradient'], equals(10.0));
    });

    test('Alveolar Gas Equation calculation', () {
      final calculator = CalculatorDefinition(
        id: 'alveolar_gas_equation',
        name: 'Alveolar Gas Equation',
        category: 'Oxygenation',
        description: '',
        formula: 'PAO2 = FiO2(PB - PH2O) - (PaCO2/RQ)',
        inputs: [
          const InputField(id: 'fio2', label: 'FiO2', defaultUnit: '%'),
          const InputField(id: 'barometric_pressure', label: 'PB', defaultUnit: 'mmHg'),
          const InputField(id: 'water_vapor_pressure', label: 'PH2O', defaultUnit: 'mmHg'),
          const InputField(id: 'paco2', label: 'PaCO2', defaultUnit: 'mmHg'),
          const InputField(id: 'respiratory_quotient', label: 'RQ', defaultUnit: ''),
        ],
        outputs: [
          const OutputField(id: 'alveolar_po2', label: 'PAO2', unit: 'mmHg'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {
          'fio2': 21.0,
          'barometric_pressure': 760.0,
          'water_vapor_pressure': 47.0,
          'paco2': 40.0,
          'respiratory_quotient': 0.8,
        },
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['alveolar_po2'], closeTo(99.73, 0.1));
    });

    test('P/F Ratio calculation', () {
      final calculator = CalculatorDefinition(
        id: 'pf_ratio',
        name: 'P/F Ratio',
        category: 'Oxygenation',
        description: '',
        formula: 'P/F = PaO2 / FiO2',
        inputs: [
          const InputField(id: 'pao2', label: 'PaO2', defaultUnit: 'mmHg'),
          const InputField(id: 'fio2', label: 'FiO2', defaultUnit: '%'),
        ],
        outputs: [
          const OutputField(id: 'pf_ratio', label: 'P/F', unit: 'mmHg'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'pao2': 80.0, 'fio2': 40.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['pf_ratio'], equals(200.0));
    });

    test('Oxygen Content calculation', () {
      final calculator = CalculatorDefinition(
        id: 'oxygen_content',
        name: 'Oxygen Content',
        category: 'Oxygenation',
        description: '',
        formula: 'CaO2 = (1.34 × Hgb × SaO2) + (0.003 × PaO2)',
        inputs: [
          const InputField(id: 'hemoglobin', label: 'Hgb', defaultUnit: 'g/dL'),
          const InputField(id: 'sao2', label: 'SaO2', defaultUnit: '%'),
          const InputField(id: 'pao2', label: 'PaO2', defaultUnit: 'mmHg'),
        ],
        outputs: [
          const OutputField(id: 'oxygen_content', label: 'CaO2', unit: 'mL O2/dL'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'hemoglobin': 15.0, 'sao2': 98.0, 'pao2': 100.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      // CaO2 = (1.34 × 15 × 0.98) + (0.003 × 100) = 19.698 + 0.3 = 19.998
      expect(result.outputs['oxygen_content'], closeTo(19.998, 0.01));
    });

    test('Oxygen Cylinder Duration calculation', () {
      final calculator = CalculatorDefinition(
        id: 'oxygen_cylinder_duration',
        name: 'O2 Cylinder Duration',
        category: 'Oxygen Equipment',
        description: '',
        formula: 'Duration = (Pressure × Factor) / Flow',
        inputs: [
          const InputField(id: 'tank_pressure', label: 'Pressure', defaultUnit: 'psi'),
          const InputField(id: 'tank_factor', label: 'Factor', defaultUnit: ''),
          const InputField(id: 'flow_rate', label: 'Flow', defaultUnit: 'L/min'),
        ],
        outputs: [
          const OutputField(id: 'duration_minutes', label: 'Duration', unit: 'minutes'),
          const OutputField(id: 'duration_hours', label: 'Duration', unit: 'hours'),
        ],
        clinicalNote: '',
      );

      // E cylinder at 2000 psi, 2 L/min flow
      final result = engine.calculate(
        calculator,
        {'tank_pressure': 2000.0, 'tank_factor': 0.28, 'flow_rate': 2.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['duration_minutes'], equals(280.0));
      expect(result.outputs['duration_hours'], closeTo(4.67, 0.1));
    });
  });

  group('Hemodynamic Calculators', () {
    test('Mean Arterial Pressure calculation', () {
      final calculator = CalculatorDefinition(
        id: 'mean_arterial_pressure',
        name: 'MAP',
        category: 'Hemodynamics',
        description: '',
        formula: 'MAP = DBP + (SBP - DBP) / 3',
        inputs: [
          const InputField(id: 'systolic', label: 'SBP', defaultUnit: 'mmHg'),
          const InputField(id: 'diastolic', label: 'DBP', defaultUnit: 'mmHg'),
        ],
        outputs: [
          const OutputField(id: 'mean_arterial_pressure', label: 'MAP', unit: 'mmHg'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'systolic': 120.0, 'diastolic': 80.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['mean_arterial_pressure'], closeTo(93.33, 0.1));
    });

    test('Cardiac Output calculation', () {
      final calculator = CalculatorDefinition(
        id: 'cardiac_output',
        name: 'Cardiac Output',
        category: 'Hemodynamics',
        description: '',
        formula: 'CO = SV × HR',
        inputs: [
          const InputField(id: 'stroke_volume', label: 'SV', defaultUnit: 'mL'),
          const InputField(id: 'heart_rate', label: 'HR', defaultUnit: 'bpm'),
        ],
        outputs: [
          const OutputField(id: 'cardiac_output', label: 'CO', unit: 'L/min'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'stroke_volume': 70.0, 'heart_rate': 80.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['cardiac_output'], equals(5.6));
    });

    test('Cardiac Index calculation', () {
      final calculator = CalculatorDefinition(
        id: 'cardiac_index',
        name: 'Cardiac Index',
        category: 'Hemodynamics',
        description: '',
        formula: 'CI = CO / BSA',
        inputs: [
          const InputField(id: 'cardiac_output', label: 'CO', defaultUnit: 'L/min'),
          const InputField(id: 'body_surface_area', label: 'BSA', defaultUnit: 'm²'),
        ],
        outputs: [
          const OutputField(id: 'cardiac_index', label: 'CI', unit: 'L/min/m²'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'cardiac_output': 5.0, 'body_surface_area': 1.8},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['cardiac_index'], closeTo(2.78, 0.01));
    });

    test('Systemic Vascular Resistance calculation', () {
      final calculator = CalculatorDefinition(
        id: 'systemic_vascular_resistance',
        name: 'SVR',
        category: 'Hemodynamics',
        description: '',
        formula: 'SVR = (MAP - CVP) / CO × 80',
        inputs: [
          const InputField(id: 'map', label: 'MAP', defaultUnit: 'mmHg'),
          const InputField(id: 'cvp', label: 'CVP', defaultUnit: 'mmHg'),
          const InputField(id: 'cardiac_output', label: 'CO', defaultUnit: 'L/min'),
        ],
        outputs: [
          const OutputField(id: 'svr', label: 'SVR', unit: 'dynes·sec/cm⁵'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'map': 90.0, 'cvp': 6.0, 'cardiac_output': 5.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['svr'], equals(1344.0));
    });
  });

  group('Body Measurement Calculators', () {
    test('Ideal Body Weight - Male', () {
      final calculator = CalculatorDefinition(
        id: 'ideal_body_weight',
        name: 'IBW',
        category: 'Body Measurements',
        description: '',
        formula: 'IBW (M) = 50 + 2.3 × (height - 60)',
        inputs: [
          const InputField(id: 'height', label: 'Height', defaultUnit: 'cm'),
          const InputField(id: 'is_male', label: 'Sex', defaultUnit: ''),
        ],
        outputs: [
          const OutputField(id: 'ideal_body_weight', label: 'IBW', unit: 'kg'),
        ],
        clinicalNote: '',
      );

      // 180 cm male (70.87 inches)
      final result = engine.calculate(
        calculator,
        {'height': 180.0, 'is_male': 1.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['ideal_body_weight'], closeTo(75.0, 1.0));
    });

    test('Body Surface Area calculation', () {
      final calculator = CalculatorDefinition(
        id: 'body_surface_area',
        name: 'BSA',
        category: 'Body Measurements',
        description: '',
        formula: 'BSA = √(height × weight / 3600)',
        inputs: [
          const InputField(id: 'height', label: 'Height', defaultUnit: 'cm'),
          const InputField(id: 'weight', label: 'Weight', defaultUnit: 'kg'),
        ],
        outputs: [
          const OutputField(id: 'body_surface_area', label: 'BSA', unit: 'm²'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'height': 180.0, 'weight': 80.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['body_surface_area'], closeTo(2.0, 0.05));
    });

    test('BMI calculation', () {
      final calculator = CalculatorDefinition(
        id: 'bmi',
        name: 'BMI',
        category: 'Body Measurements',
        description: '',
        formula: 'BMI = weight / height²',
        inputs: [
          const InputField(id: 'height', label: 'Height', defaultUnit: 'cm'),
          const InputField(id: 'weight', label: 'Weight', defaultUnit: 'kg'),
        ],
        outputs: [
          const OutputField(id: 'bmi', label: 'BMI', unit: 'kg/m²'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'height': 180.0, 'weight': 75.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['bmi'], closeTo(23.15, 0.1));
    });
  });

  group('Acid-Base Calculators', () {
    test('Anion Gap calculation', () {
      final calculator = CalculatorDefinition(
        id: 'anion_gap',
        name: 'Anion Gap',
        category: 'Acid-Base',
        description: '',
        formula: 'AG = Na - (Cl + HCO3)',
        inputs: [
          const InputField(id: 'sodium', label: 'Na', defaultUnit: 'mEq/L'),
          const InputField(id: 'chloride', label: 'Cl', defaultUnit: 'mEq/L'),
          const InputField(id: 'bicarbonate', label: 'HCO3', defaultUnit: 'mEq/L'),
        ],
        outputs: [
          const OutputField(id: 'anion_gap', label: 'AG', unit: 'mEq/L'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'sodium': 140.0, 'chloride': 100.0, 'bicarbonate': 24.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['anion_gap'], equals(16.0));
    });

    test('Winters Formula calculation', () {
      final calculator = CalculatorDefinition(
        id: 'winters_formula',
        name: 'Winters Formula',
        category: 'Acid-Base',
        description: '',
        formula: 'Expected PaCO2 = 1.5 × HCO3 + 8 ± 2',
        inputs: [
          const InputField(id: 'bicarbonate', label: 'HCO3', defaultUnit: 'mEq/L'),
        ],
        outputs: [
          const OutputField(id: 'expected_paco2', label: 'Expected PaCO2', unit: 'mmHg'),
          const OutputField(id: 'expected_paco2_low', label: 'Range Low', unit: 'mmHg'),
          const OutputField(id: 'expected_paco2_high', label: 'Range High', unit: 'mmHg'),
        ],
        clinicalNote: '',
      );

      final result = engine.calculate(
        calculator,
        {'bicarbonate': 12.0},
        {},
      );

      expect(result.isSuccessful, isTrue);
      expect(result.outputs['expected_paco2'], equals(26.0));
      expect(result.outputs['expected_paco2_low'], equals(24.0));
      expect(result.outputs['expected_paco2_high'], equals(28.0));
    });
  });

  group('Input Validation', () {
    test('validates minimum value', () {
      final field = InputField(
        id: 'test',
        label: 'Test',
        defaultUnit: 'unit',
        minValue: 10,
      );

      final result = engine.validateInput(5.0, field);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('at least 10'));
    });

    test('validates maximum value', () {
      final field = InputField(
        id: 'test',
        label: 'Test',
        defaultUnit: 'unit',
        maxValue: 100,
      );

      final result = engine.validateInput(150.0, field);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('at most 100'));
    });

    test('warns on unusually low value', () {
      final field = InputField(
        id: 'test',
        label: 'Test',
        defaultUnit: 'unit',
        warningMin: 50,
      );

      final result = engine.validateInput(30.0, field);
      expect(result.isValid, isTrue);
      expect(result.hasWarning, isTrue);
      expect(result.warningMessage, contains('unusually low'));
    });

    test('warns on unusually high value', () {
      final field = InputField(
        id: 'test',
        label: 'Test',
        defaultUnit: 'unit',
        warningMax: 100,
      );

      final result = engine.validateInput(150.0, field);
      expect(result.isValid, isTrue);
      expect(result.hasWarning, isTrue);
      expect(result.warningMessage, contains('unusually high'));
    });
  });

  group('Unit Conversion', () {
    test('converts kPa to mmHg', () {
      final field = InputField(
        id: 'pressure',
        label: 'Pressure',
        defaultUnit: 'mmHg',
        alternateUnits: [
          const UnitOption(unit: 'kPa', conversionFactor: 7.5),
        ],
      );

      final result = engine.convertToDefaultUnit(10.0, 'kPa', field);
      expect(result, equals(75.0));
    });

    test('converts L to mL', () {
      final field = InputField(
        id: 'volume',
        label: 'Volume',
        defaultUnit: 'mL',
        alternateUnits: [
          const UnitOption(unit: 'L', conversionFactor: 1000),
        ],
      );

      final result = engine.convertToDefaultUnit(0.5, 'L', field);
      expect(result, equals(500.0));
    });

    test('converts lb to kg', () {
      final field = InputField(
        id: 'weight',
        label: 'Weight',
        defaultUnit: 'kg',
        alternateUnits: [
          const UnitOption(unit: 'lb', conversionFactor: 0.4536),
        ],
      );

      final result = engine.convertToDefaultUnit(150.0, 'lb', field);
      expect(result, closeTo(68.04, 0.1));
    });
  });
}
