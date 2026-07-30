class EnergyPoint {
  const EnergyPoint(this.label, this.kwh, this.power);

  final String label;
  final double kwh;
  final int power;
}

enum Period { day, week, month }
