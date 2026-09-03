class FareInfoCategory {
  String? image;
  String? taka;        // e.g. "৳ 50"
  String? mrtPassFare; // e.g. "৳ 45"
  String? start;
  String? des;
  int stationDistance;

  FareInfoCategory({
    this.image,
    this.taka,
    this.mrtPassFare,
    this.start,
    this.des,
    this.stationDistance = 1,
  });
}