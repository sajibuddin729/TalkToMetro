import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mrts/modules/other_info/model/other_info_category_model.dart';

class OtherInfoController extends GetxController implements GetxService {
  final searchQuery = ''.obs;
  final selectedCategory = 'All'.obs;

  List<OtherInfoCategory> _allCategories = [];
  final filteredCategories = <OtherInfoCategory>[].obs;

  final categoriesList = [
    'All',
    'Schedule',
    'Rules',
    'Contact',
    'Passes',
    'Accessibility'
  ];

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  Future<void> getData() async {
    _allCategories = const [
      OtherInfoCategory(
        id: 'INFO-01',
        title: 'Metro Line 6 Service Hours',
        subtitle: 'Official operating timings & daily frequencies',
        categoryTag: 'Schedule',
        icon: Icons.access_time_filled,
        description:
            'Dhaka Metro Rail Line 6 operates between Uttara North and Motijheel according to the following weekly schedule:',
        bulletPoints: [
          'Weekdays (Sun – Thu): 06:30 AM – 10:10 PM',
          'Friday Service: 03:00 PM – 09:40 PM',
          'Saturday Service: 06:30 AM – 09:40 PM',
          'Peak Hours Frequency: ~6 minutes interval',
          'Off-Peak Hours Frequency: ~8 to 10 minutes interval',
          'Evening / Night Service: ~12 to 15 minutes interval',
        ],
      ),
      OtherInfoCategory(
        id: 'INFO-02',
        title: 'DMTCL Hotline & Customer Care',
        subtitle: '24/7 Helpline, Head Office & Official Contact',
        categoryTag: 'Contact',
        icon: Icons.headset_mic,
        description:
            'For inquiries, emergency support, complaints, or lost card assistance, reach out to Talk2Metro (DMTCL) official channels:',
        bulletPoints: [
          'DMTCL Helpline: 16108 (Toll-free 24/7)',
          'Head Office: DMTCL Building, Diabari, Uttara, Dhaka-1230',
          'Official Website: www.dmtcl.gov.bd',
          'Customer Support Email: info@dmtcl.gov.bd',
        ],
        actionLabel: 'Call 16108 Helpline Now',
        actionType: 'tel',
        actionPayload: '16108',
      ),
      OtherInfoCategory(
        id: 'INFO-03',
        title: 'MRT Pass & Rapid Pass Rules',
        subtitle: 'Card registration, 10% discount & recharges',
        categoryTag: 'Passes',
        icon: Icons.credit_card,
        description:
            'MRT Pass & Rapid Pass provide seamless contactless travel across all Dhaka Metro stations with exclusive benefits:',
        bulletPoints: [
          'Automatic 10% discount on every journey fare',
          'Initial Card Cost: ৳ 500 (৳ 200 initial balance + ৳ 300 refundable deposit)',
          'Maximum Balance Limit: ৳ 10,000 | Validity: 10 Years',
          'Top-up available at ticket vending machines (TVM) or digital wallet',
          'Lost card replacement available at station customer service desks',
        ],
      ),
      OtherInfoCategory(
        id: 'INFO-04',
        title: 'Metro Rail Code of Conduct & Rules',
        subtitle: 'Safety guidelines, prohibited items & penalties',
        categoryTag: 'Rules',
        icon: Icons.gavel,
        description:
            'Passengers must strictly adhere to the Metro Rail Act 2015 for safe, clean, and comfortable mass transit:',
        bulletPoints: [
          'Strictly No Smoking, chewing betel leaf (paan), or spitting (Fine up to ৳ 10,000)',
          'Luggage size limit: Max weight 10 kg | Size limit 60 × 40 × 25 cm',
          'Flammable liquids, explosives, weapons, and pets are strictly prohibited',
          'No eating or drinking inside metro trains or paid station concourses',
          'Offer priority seats to elderly, pregnant women, and passengers with infants',
        ],
      ),
      OtherInfoCategory(
        id: 'INFO-05',
        title: 'Lost & Found Station Service',
        subtitle: 'Reporting lost belongings at customer desks',
        categoryTag: 'Contact',
        icon: Icons.find_in_page,
        description:
            'Lost items found inside metro train coaches or station platforms are collected and cataloged at station desks:',
        bulletPoints: [
          'Report lost items immediately at any station Customer Service Counter',
          'Found items are stored for 30 days at the respective station office',
          'Unclaimed items are transferred to DMTCL Central Archive at Uttara North',
          'Proof of ownership (NID / Purchase Receipt / Pass ID) required for claim',
        ],
        actionLabel: 'Call Lost & Found Center',
        actionType: 'tel',
        actionPayload: '16108',
      ),
      OtherInfoCategory(
        id: 'INFO-06',
        title: 'Accessibility & Special Facilities',
        subtitle: 'Dedicated women coach, wheelchair ramps & elevators',
        categoryTag: 'Accessibility',
        icon: Icons.accessible_forward,
        description:
            'Dhaka Metro Rail is fully universal-accessible designed for all passengers:',
        bulletPoints: [
          'Dedicated Women-Only Coach (Coach #1 in direction of travel)',
          'Tactile yellow guide tiles on platforms for visually impaired commuters',
          'Elevators & wide automated gates at every station for wheelchair access',
          'Designated wheelchair parking spots & priority seats inside every train coach',
          'Audio announcements in English & clear LED visual displays',
        ],
      ),
      OtherInfoCategory(
        id: 'INFO-07',
        title: 'Single Journey Ticket (SJT) Tokens',
        subtitle: 'Token purchase, usage & turnstile exit rules',
        categoryTag: 'Passes',
        icon: Icons.confirmation_number,
        description:
            'Single Journey Tickets (RFID Tokens) are ideal for occasional passengers:',
        bulletPoints: [
          'Purchase tokens from Ticket Vending Machines (TVM) or Manual Counters',
          'Valid only on date of purchase for selected origin-destination stations',
          'Tap token at turnstile gate upon entry; drop token into gate slot upon exit',
          'Over-travel beyond purchased station requires paying fare difference at exit',
        ],
      ),
    ];

    applyFilter();
  }

  void filterSearch(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    applyFilter();
  }

  void applyFilter() {
    final q = searchQuery.value.trim().toLowerCase();
    final cat = selectedCategory.value;

    filteredCategories.assignAll(
      _allCategories.where((item) {
        final matchesCat = cat == 'All' || item.categoryTag == cat;
        final matchesQuery = q.isEmpty ||
            item.title.toLowerCase().contains(q) ||
            item.subtitle.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q) ||
            (item.bulletPoints?.any((b) => b.toLowerCase().contains(q)) ??
                false);
        return matchesCat && matchesQuery;
      }).toList(),
    );
  }

  Future<void> executeAction(OtherInfoCategory item) async {
    if (item.actionType == 'tel' && item.actionPayload != null) {
      final uri = Uri.parse('tel:${item.actionPayload}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }
}
