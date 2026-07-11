import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconUtils {
  static FaIconData getIconData(int codePoint) {
    switch (codePoint) {
      // Category Icons
      case 0xe532:
        return FontAwesomeIcons.gasPump;
      case 0xe6e3:
        return FontAwesomeIcons.utensils;
      case 0xe8cc:
        return FontAwesomeIcons.cartShopping;
      case 0xe8f0:
        return FontAwesomeIcons.wallet;
      case 0xe332:
        return FontAwesomeIcons.hospital;
      case 0xe0b0:
        return FontAwesomeIcons.phone;
      case 0xe54c:
        return FontAwesomeIcons.film;
      case 0xeb3f:
        return FontAwesomeIcons.plane;
      case 0xe84f:
        return FontAwesomeIcons.dollarSign;
      case 0xe619:
        return FontAwesomeIcons.bus;
      case 0xe406:
        return FontAwesomeIcons.graduationCap;
      case 0xeb48:
        return FontAwesomeIcons.bed;
      case 0xe88e:
        return FontAwesomeIcons.circleInfo;

      // Payment Method Icons
      case 0xeacc:
        return FontAwesomeIcons.buildingColumns;
      case 0xe870:
        return FontAwesomeIcons.creditCard;
      case 0xe3f7:
        return FontAwesomeIcons.moneyBill1;
      case 0xe1b1:
        return FontAwesomeIcons.house;
      case 0xe19f:
        return FontAwesomeIcons.briefcase;

      // Saver Icons (Legacy support if any)
      case 0xe838:
        return FontAwesomeIcons.star;

      // Income Category Icons
      case 0xe30a:
        return FontAwesomeIcons.laptop;
      case 0xe8f6:
        return FontAwesomeIcons.gift;
      case 0xe8e5:
        return FontAwesomeIcons.arrowTrendUp;
      case 0xe8d0:
        return FontAwesomeIcons.store;

      // Fallback
      default:
        return FontAwesomeIcons.circleInfo;
    }
  }
}
