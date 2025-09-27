class Packs {
  final int packs30; // 套餐个数
  const Packs(this.packs30);

  int get totalMinutes => packs30 * 30;

  Packs copyWith({int? packs30}) => Packs(packs30 ?? this.packs30);
}