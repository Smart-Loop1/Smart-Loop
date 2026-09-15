abstract final class SaudiResidentialWaterTariff {
  static const _slabs = <_TariffSlab>[
    _TariffSlab(limitInCubicMeters: 15, ratePerCubicMeter: 0.10),
    _TariffSlab(limitInCubicMeters: 15, ratePerCubicMeter: 1.00),
    _TariffSlab(limitInCubicMeters: 15, ratePerCubicMeter: 3.00),
    _TariffSlab(limitInCubicMeters: 15, ratePerCubicMeter: 4.00),
    _TariffSlab(ratePerCubicMeter: 6.00),
  ];

  /// Estimates the progressive residential water charge only.
  ///
  /// Wastewater service, VAT, meter fees, and other bill adjustments are not
  /// included. Tariff reference: https://www.spa.gov.sa/1493570
  static double estimateWaterCost(double liters) {
    var remainingCubicMeters = liters <= 0 ? 0.0 : liters / 1000.0;
    var cost = 0.0;

    for (final slab in _slabs) {
      if (remainingCubicMeters <= 0) break;
      final limit = slab.limitInCubicMeters;
      final chargedCubicMeters = limit == null || remainingCubicMeters < limit
          ? remainingCubicMeters
          : limit;
      cost += chargedCubicMeters * slab.ratePerCubicMeter;
      remainingCubicMeters -= chargedCubicMeters;
    }

    return cost;
  }
}

class _TariffSlab {
  const _TariffSlab({this.limitInCubicMeters, required this.ratePerCubicMeter});

  final double? limitInCubicMeters;
  final double ratePerCubicMeter;
}
