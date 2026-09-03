class Images{
  static get menu => 'menu'.png;
  static get homelogo => 'homelogo'.png;
  static get home => 'home'.png;
  static get notification => 'notification'.png;
  static get clock => 'Frame'.png;
  static get location => 'location'.png;
  static get rectangle => 'rectangle'.png;
  static get currency => 'currency'.png;
  static get vector => 'Vector'.png;
  static get route => 'route'.png;
  static get map => 'map'.png;
  static get train => 'train'.png;
  static get wallet => 'wallet'.png;
  static get flat_settings => 'flat_settings'.png;
  static get settings => 'settings'.png;
  static get mastercard => 'mastercard'.png;
  static get bkash => 'bkash'.png;
  static get move => 'move'.png;
  static get visa => 'visacard'.png;
}
extension on String {
  String get png => 'images/$this.png';
}