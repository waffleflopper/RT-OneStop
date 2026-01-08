import 'dart:math' as math;
import 'models/calculator_models.dart';

/// Calculator engine that computes results based on calculator definitions
class CalculatorEngine {
  /// Validate a single input value
  ValidationResult validateInput(double value, InputField field) {
    // Check hard limits
    if (field.minValue != null && value < field.minValue!) {
      return ValidationResult.error(
        '${field.label} must be at least ${field.minValue} ${field.defaultUnit}',
      );
    }
    if (field.maxValue != null && value > field.maxValue!) {
      return ValidationResult.error(
        '${field.label} must be at most ${field.maxValue} ${field.defaultUnit}',
      );
    }

    // Check warning thresholds
    if (field.warningMin != null && value < field.warningMin!) {
      return ValidationResult.warning(
        '${field.label} of $value ${field.defaultUnit} is unusually low',
      );
    }
    if (field.warningMax != null && value > field.warningMax!) {
      return ValidationResult.warning(
        '${field.label} of $value ${field.defaultUnit} is unusually high',
      );
    }

    return const ValidationResult.valid();
  }

  /// Convert value from one unit to default unit
  double convertToDefaultUnit(double value, String fromUnit, InputField field) {
    if (fromUnit == field.defaultUnit) {
      return value;
    }

    final unitOption = field.alternateUnits.firstWhere(
      (u) => u.unit == fromUnit,
      orElse: () => throw ArgumentError('Unknown unit: $fromUnit'),
    );

    // Apply conversion: (value + offset) * factor
    return (value + unitOption.offset) * unitOption.conversionFactor;
  }

  /// Convert value from default unit to another unit
  double convertFromDefaultUnit(double value, String toUnit, InputField field) {
    if (toUnit == field.defaultUnit) {
      return value;
    }

    final unitOption = field.alternateUnits.firstWhere(
      (u) => u.unit == toUnit,
      orElse: () => throw ArgumentError('Unknown unit: $toUnit'),
    );

    // Reverse conversion: value / factor - offset
    return (value / unitOption.conversionFactor) - unitOption.offset;
  }

  /// Calculate result for a given calculator definition
  CalculationResult calculate(
    CalculatorDefinition calculator,
    Map<String, double> inputValues,
    Map<String, String> inputUnits,
  ) {
    // Convert all inputs to default units and validate
    final Map<String, double> normalizedInputs = {};
    final Map<String, ValidationResult> validations = {};

    for (final field in calculator.inputs) {
      final value = inputValues[field.id];
      if (value == null) {
        return CalculationResult.error('Missing required input: ${field.label}');
      }

      // Convert to default unit if needed
      final unit = inputUnits[field.id] ?? field.defaultUnit;
      final normalizedValue = convertToDefaultUnit(value, unit, field);
      normalizedInputs[field.id] = normalizedValue;

      // Validate
      validations[field.id] = validateInput(normalizedValue, field);
      if (!validations[field.id]!.isValid) {
        return CalculationResult.error(validations[field.id]!.errorMessage!);
      }
    }

    // Perform calculation based on calculator ID
    try {
      final outputs = _computeOutputs(calculator.id, normalizedInputs);
      return CalculationResult.success(
        outputs: outputs,
        inputValidations: validations,
      );
    } catch (e) {
      return CalculationResult.error('Calculation error: $e');
    }
  }

  /// Compute outputs based on calculator ID and inputs
  Map<String, double> _computeOutputs(
    String calculatorId,
    Map<String, double> inputs,
  ) {
    switch (calculatorId) {
      // Ventilation Calculators
      case 'minute_ventilation':
        return _minuteVentilation(inputs);
      case 'alveolar_ventilation':
        return _alveolarVentilation(inputs);
      case 'dead_space_ratio':
        return _deadSpaceRatio(inputs);
      case 'tidal_volume_ibw':
        return _tidalVolumeIbw(inputs);
      case 'rapid_shallow_breathing':
        return _rapidShallowBreathing(inputs);
      case 'static_compliance':
        return _staticCompliance(inputs);
      case 'dynamic_compliance':
        return _dynamicCompliance(inputs);
      case 'airway_resistance':
        return _airwayResistance(inputs);
      case 'time_constant':
        return _timeConstant(inputs);
      case 'ie_ratio':
        return _ieRatio(inputs);
      case 'auto_peep_estimation':
        return _autoPeepEstimation(inputs);

      // Oxygenation Calculators
      case 'aa_gradient':
        return _aaGradient(inputs);
      case 'alveolar_gas_equation':
        return _alveolarGasEquation(inputs);
      case 'pf_ratio':
        return _pfRatio(inputs);
      case 'oxygen_content':
        return _oxygenContent(inputs);
      case 'oxygen_delivery':
        return _oxygenDelivery(inputs);
      case 'oxygen_consumption':
        return _oxygenConsumption(inputs);
      case 'oxygen_extraction':
        return _oxygenExtraction(inputs);
      case 'shunt_fraction':
        return _shuntFraction(inputs);
      case 'fio2_estimation':
        return _fio2Estimation(inputs);

      // Oxygen Duration Calculators
      case 'oxygen_cylinder_duration':
        return _oxygenCylinderDuration(inputs);
      case 'liquid_o2_duration':
        return _liquidO2Duration(inputs);

      // Hemodynamic Calculators
      case 'mean_arterial_pressure':
        return _meanArterialPressure(inputs);
      case 'cerebral_perfusion_pressure':
        return _cerebralPerfusionPressure(inputs);
      case 'cardiac_output':
        return _cardiacOutput(inputs);
      case 'cardiac_index':
        return _cardiacIndex(inputs);
      case 'stroke_volume':
        return _strokeVolume(inputs);
      case 'systemic_vascular_resistance':
        return _systemicVascularResistance(inputs);
      case 'pulmonary_vascular_resistance':
        return _pulmonaryVascularResistance(inputs);
      case 'mean_pulmonary_artery_pressure':
        return _meanPulmonaryArteryPressure(inputs);

      // Body Measurement Calculators
      case 'ideal_body_weight':
        return _idealBodyWeight(inputs);
      case 'body_surface_area':
        return _bodySurfaceArea(inputs);
      case 'bmi':
        return _bmi(inputs);

      // ABG/Acid-Base Calculators
      case 'anion_gap':
        return _anionGap(inputs);
      case 'corrected_anion_gap':
        return _correctedAnionGap(inputs);
      case 'bicarbonate_deficit':
        return _bicarbonateDeficit(inputs);
      case 'winters_formula':
        return _wintersFormula(inputs);

      default:
        throw ArgumentError('Unknown calculator: $calculatorId');
    }
  }

  // ============ Ventilation Calculations ============

  Map<String, double> _minuteVentilation(Map<String, double> inputs) {
    final vt = inputs['tidal_volume']! / 1000; // Convert mL to L
    final rr = inputs['respiratory_rate']!;
    return {'minute_ventilation': vt * rr};
  }

  Map<String, double> _alveolarVentilation(Map<String, double> inputs) {
    final vt = inputs['tidal_volume']!;
    final vd = inputs['dead_space']!;
    final rr = inputs['respiratory_rate']!;
    return {'alveolar_ventilation': ((vt - vd) * rr) / 1000};
  }

  Map<String, double> _deadSpaceRatio(Map<String, double> inputs) {
    final paCO2 = inputs['paco2']!;
    final peCO2 = inputs['peco2']!;
    return {'vd_vt_ratio': (paCO2 - peCO2) / paCO2};
  }

  Map<String, double> _tidalVolumeIbw(Map<String, double> inputs) {
    final ibw = inputs['ideal_body_weight']!;
    final mlPerKg = inputs['ml_per_kg']!;
    return {'tidal_volume': ibw * mlPerKg};
  }

  Map<String, double> _rapidShallowBreathing(Map<String, double> inputs) {
    final rr = inputs['respiratory_rate']!;
    final vt = inputs['tidal_volume']! / 1000; // Convert to L
    return {'rsbi': rr / vt};
  }

  Map<String, double> _staticCompliance(Map<String, double> inputs) {
    final vt = inputs['tidal_volume']!;
    final pPlat = inputs['plateau_pressure']!;
    final peep = inputs['peep']!;
    return {'static_compliance': vt / (pPlat - peep)};
  }

  Map<String, double> _dynamicCompliance(Map<String, double> inputs) {
    final vt = inputs['tidal_volume']!;
    final pip = inputs['peak_inspiratory_pressure']!;
    final peep = inputs['peep']!;
    return {'dynamic_compliance': vt / (pip - peep)};
  }

  Map<String, double> _airwayResistance(Map<String, double> inputs) {
    final pip = inputs['peak_inspiratory_pressure']!;
    final pPlat = inputs['plateau_pressure']!;
    final flow = inputs['flow']! / 60; // Convert L/min to L/sec
    return {'airway_resistance': (pip - pPlat) / flow};
  }

  Map<String, double> _timeConstant(Map<String, double> inputs) {
    final compliance = inputs['compliance']!;
    final resistance = inputs['resistance']!;
    return {'time_constant': compliance * resistance / 1000}; // Result in seconds
  }

  Map<String, double> _ieRatio(Map<String, double> inputs) {
    final iTime = inputs['inspiratory_time']!;
    final eTime = inputs['expiratory_time']!;
    final ratio = eTime / iTime;
    return {'ie_ratio': ratio};
  }

  Map<String, double> _autoPeepEstimation(Map<String, double> inputs) {
    final ve = inputs['minute_ventilation']!;
    final expFlow = inputs['expiratory_flow']!;
    final setETime = inputs['set_expiratory_time']!;
    final timeConstant = ve / expFlow;
    // Simplified estimation
    final autoPeep = (3 * timeConstant > setETime) ? (3 * timeConstant - setETime) * 2 : 0.0;
    return {'estimated_auto_peep': autoPeep};
  }

  // ============ Oxygenation Calculations ============

  Map<String, double> _aaGradient(Map<String, double> inputs) {
    final pAO2 = inputs['alveolar_po2']!;
    final paO2 = inputs['arterial_po2']!;
    return {'aa_gradient': pAO2 - paO2};
  }

  Map<String, double> _alveolarGasEquation(Map<String, double> inputs) {
    final fio2 = inputs['fio2']! / 100; // Convert percentage to decimal
    final pB = inputs['barometric_pressure']!;
    final pH2O = inputs['water_vapor_pressure'] ?? 47.0;
    final paCO2 = inputs['paco2']!;
    final rq = inputs['respiratory_quotient'] ?? 0.8;

    final pAO2 = (fio2 * (pB - pH2O)) - (paCO2 / rq);
    return {'alveolar_po2': pAO2};
  }

  Map<String, double> _pfRatio(Map<String, double> inputs) {
    final paO2 = inputs['pao2']!;
    final fio2 = inputs['fio2']! / 100;
    return {'pf_ratio': paO2 / fio2};
  }

  Map<String, double> _oxygenContent(Map<String, double> inputs) {
    final hgb = inputs['hemoglobin']!;
    final saO2 = inputs['sao2']! / 100;
    final paO2 = inputs['pao2']!;
    // CaO2 = (1.34 × Hgb × SaO2) + (0.003 × PaO2)
    final caO2 = (1.34 * hgb * saO2) + (0.003 * paO2);
    return {'oxygen_content': caO2};
  }

  Map<String, double> _oxygenDelivery(Map<String, double> inputs) {
    final caO2 = inputs['cao2']!;
    final co = inputs['cardiac_output']!;
    // DO2 = CaO2 × CO × 10
    return {'oxygen_delivery': caO2 * co * 10};
  }

  Map<String, double> _oxygenConsumption(Map<String, double> inputs) {
    final caO2 = inputs['cao2']!;
    final cvO2 = inputs['cvo2']!;
    final co = inputs['cardiac_output']!;
    // VO2 = (CaO2 - CvO2) × CO × 10
    return {'oxygen_consumption': (caO2 - cvO2) * co * 10};
  }

  Map<String, double> _oxygenExtraction(Map<String, double> inputs) {
    final caO2 = inputs['cao2']!;
    final cvO2 = inputs['cvo2']!;
    // O2ER = (CaO2 - CvO2) / CaO2
    return {'oxygen_extraction_ratio': (caO2 - cvO2) / caO2};
  }

  Map<String, double> _shuntFraction(Map<String, double> inputs) {
    final ccO2 = inputs['capillary_o2_content']!;
    final caO2 = inputs['cao2']!;
    final cvO2 = inputs['cvo2']!;
    // Qs/Qt = (CcO2 - CaO2) / (CcO2 - CvO2)
    return {'shunt_fraction': (ccO2 - caO2) / (ccO2 - cvO2)};
  }

  Map<String, double> _fio2Estimation(Map<String, double> inputs) {
    final flowRate = inputs['flow_rate']!;
    // Simplified estimation: FiO2 = 20 + (4 × flow rate) for nasal cannula
    final fio2 = 20 + (4 * flowRate);
    return {'estimated_fio2': fio2.clamp(21.0, 100.0)};
  }

  // ============ Oxygen Duration Calculations ============

  Map<String, double> _oxygenCylinderDuration(Map<String, double> inputs) {
    final pressure = inputs['tank_pressure']!;
    final flowRate = inputs['flow_rate']!;
    final tankFactor = inputs['tank_factor']!;
    // Duration (min) = (Pressure × Tank Factor) / Flow Rate
    final duration = (pressure * tankFactor) / flowRate;
    return {
      'duration_minutes': duration,
      'duration_hours': duration / 60,
    };
  }

  Map<String, double> _liquidO2Duration(Map<String, double> inputs) {
    final weight = inputs['liquid_weight']!;
    final flowRate = inputs['flow_rate']!;
    // 1 lb of liquid O2 ≈ 344 L of gaseous O2
    final gasVolume = weight * 344;
    final duration = gasVolume / flowRate;
    return {
      'duration_minutes': duration,
      'duration_hours': duration / 60,
    };
  }

  // ============ Hemodynamic Calculations ============

  Map<String, double> _meanArterialPressure(Map<String, double> inputs) {
    final systolic = inputs['systolic']!;
    final diastolic = inputs['diastolic']!;
    // MAP = DBP + 1/3(SBP - DBP) or (SBP + 2×DBP) / 3
    final map = diastolic + ((systolic - diastolic) / 3);
    return {'mean_arterial_pressure': map};
  }

  Map<String, double> _cerebralPerfusionPressure(Map<String, double> inputs) {
    final map = inputs['map']!;
    final icp = inputs['icp']!;
    return {'cerebral_perfusion_pressure': map - icp};
  }

  Map<String, double> _cardiacOutput(Map<String, double> inputs) {
    final sv = inputs['stroke_volume']!;
    final hr = inputs['heart_rate']!;
    // CO = SV × HR / 1000 (convert mL to L)
    return {'cardiac_output': (sv * hr) / 1000};
  }

  Map<String, double> _cardiacIndex(Map<String, double> inputs) {
    final co = inputs['cardiac_output']!;
    final bsa = inputs['body_surface_area']!;
    return {'cardiac_index': co / bsa};
  }

  Map<String, double> _strokeVolume(Map<String, double> inputs) {
    final co = inputs['cardiac_output']!;
    final hr = inputs['heart_rate']!;
    // SV = CO / HR × 1000 (convert L to mL)
    return {'stroke_volume': (co / hr) * 1000};
  }

  Map<String, double> _systemicVascularResistance(Map<String, double> inputs) {
    final map = inputs['map']!;
    final cvp = inputs['cvp']!;
    final co = inputs['cardiac_output']!;
    // SVR = (MAP - CVP) / CO × 80
    return {'svr': ((map - cvp) / co) * 80};
  }

  Map<String, double> _pulmonaryVascularResistance(Map<String, double> inputs) {
    final mpap = inputs['mpap']!;
    final pcwp = inputs['pcwp']!;
    final co = inputs['cardiac_output']!;
    // PVR = (MPAP - PCWP) / CO × 80
    return {'pvr': ((mpap - pcwp) / co) * 80};
  }

  Map<String, double> _meanPulmonaryArteryPressure(Map<String, double> inputs) {
    final systolic = inputs['pa_systolic']!;
    final diastolic = inputs['pa_diastolic']!;
    return {'mpap': diastolic + ((systolic - diastolic) / 3)};
  }

  // ============ Body Measurement Calculations ============

  Map<String, double> _idealBodyWeight(Map<String, double> inputs) {
    final heightCm = inputs['height']!;
    final isMale = inputs['is_male']! == 1;

    // Devine formula
    // Males: IBW = 50 + 2.3 × (height in inches - 60)
    // Females: IBW = 45.5 + 2.3 × (height in inches - 60)
    final heightInches = heightCm / 2.54;
    final ibw = isMale
        ? 50 + 2.3 * (heightInches - 60)
        : 45.5 + 2.3 * (heightInches - 60);
    return {'ideal_body_weight': ibw};
  }

  Map<String, double> _bodySurfaceArea(Map<String, double> inputs) {
    final height = inputs['height']!;
    final weight = inputs['weight']!;
    // Mosteller formula: BSA = √((height × weight) / 3600)
    final bsa = math.sqrt((height * weight) / 3600);
    return {'body_surface_area': bsa};
  }

  Map<String, double> _bmi(Map<String, double> inputs) {
    final heightM = inputs['height']! / 100; // Convert cm to m
    final weight = inputs['weight']!;
    return {'bmi': weight / (heightM * heightM)};
  }

  // ============ ABG/Acid-Base Calculations ============

  Map<String, double> _anionGap(Map<String, double> inputs) {
    final na = inputs['sodium']!;
    final cl = inputs['chloride']!;
    final hco3 = inputs['bicarbonate']!;
    // AG = Na - (Cl + HCO3)
    return {'anion_gap': na - (cl + hco3)};
  }

  Map<String, double> _correctedAnionGap(Map<String, double> inputs) {
    final ag = inputs['anion_gap']!;
    final albumin = inputs['albumin']!;
    // Corrected AG = AG + 2.5 × (4 - albumin)
    return {'corrected_anion_gap': ag + 2.5 * (4 - albumin)};
  }

  Map<String, double> _bicarbonateDeficit(Map<String, double> inputs) {
    final weight = inputs['weight']!;
    final currentHCO3 = inputs['current_hco3']!;
    final targetHCO3 = inputs['target_hco3'] ?? 24.0;
    // Deficit = 0.5 × weight × (target HCO3 - current HCO3)
    return {'bicarbonate_deficit': 0.5 * weight * (targetHCO3 - currentHCO3)};
  }

  Map<String, double> _wintersFormula(Map<String, double> inputs) {
    final hco3 = inputs['bicarbonate']!;
    // Expected PaCO2 = 1.5 × HCO3 + 8 ± 2
    final expectedPaCO2 = 1.5 * hco3 + 8;
    return {
      'expected_paco2': expectedPaCO2,
      'expected_paco2_low': expectedPaCO2 - 2,
      'expected_paco2_high': expectedPaCO2 + 2,
    };
  }
}
