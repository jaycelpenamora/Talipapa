import 'package:flutter/material.dart';

const kGreen = Color(0xFFD1EE64);
const kBlue = Color(0xFF042F80);
const kPink = Color(0xFFF18496);
const kLightGray = Color(0xFFF9F9F9);
const kAltGray = Color(0xFFF7F7F7);
const kDivider = Color(0xFFEDEDED);

//darkmode
const kDarkAltGray = Color.fromARGB(255, 42, 54, 77);

// Commodity Types and Items
const COMMODITY_TYPES = {
  'Kadiwa Rice-for-all': ['Well milled'],
  'Imported Commercial Rice': [
    'Special',
    'Premium',
    'Well milled',
    'Regular milled'
  ],
  'Local Commercial Rice': [
    'Special',
    'Premium',
    'Well milled',
    'Regular milled'
  ],
  'Corn': [
    'Corn (White)',
    'Corn (Yellow)',
    'Corn Grits (White, Food Grade)',
    'Corn Grits (Yellow, Food Grade)',
    'Corn Cracked (Yellow, Feed Grade)',
    'Corn Grits (Feed Grade)'
  ],
  'Fish': [
    'Bangus | Specification: Large',
    'Bangus | Specification: Medium(3-4pcs/kg)',
    'Tilapia',
    'Galunggong (Local)',
    'Galunggong (Imported)',
    'Alumahan',
    'Bonito',
    'Salmon Head',
    'Sardines (Tamban)',
    'Squid (Pusit Bisaya)',
    'Yellow-Fin Tuna (Tambakal)'
  ],
  'Livestock & Poultry Products': [
    'Beef Rump',
    'Beef Brisket',
    'Pork Ham',
    'Pork Belly',
    'Frozen Kasim',
    'Frozen Liempo',
    'Whole Chicken',
    'Chicken Egg (White, Pewee)',
    'Chicken Egg (White, Extra Small)',
    'Chicken Egg (White, Small)',
    'Chicken Egg (White, Medium)',
    'Chicken Egg (White, Large)',
    'Chicken Egg (White, Extra Large)',
    'Chicken Egg (White, Jumbo)',
    'Chicken Egg (Brown, Medium)',
    'Chicken Egg (Brown, Large)',
    'Chicken Egg (Brown, Extra Large)'
  ],
  'Lowland Vegetables': [
    'Ampalaya',
    'Sitao',
    'Pechay (Native)',
    'Squash',
    'Eggplant',
    'Tomato'
  ],
  'Highland Vegetables': [
    'Bell Pepper (Green)',
    'Bell Pepper (Red)',
    'Broccoli',
    'Cabbage (Rare Ball)',
    'Cabbage (Scorpio)',
    'Cabbage (Wonder Ball)',
    'Carrots',
    'Habi chuelas (Baguio Beans)',
    'White Potato',
    'Pechay (Baguio)',
    'Chayote',
    'Cauliflower',
    'Celery',
    'Lettuce (Green Ice)',
    'Lettuce (Iceberg)',
    'Lettuce (Romaine)'
  ],
  'Spices': [
    'Red Onion',
    'Red Onion (Imported)',
    'White Onion',
    'White Onion (Imported)',
    'Garlic (Imported)',
    'Garlic (Native)',
    'Ginger',
    'Chili (Red)'
  ],
  'Fruits': [
    'Calamansi',
    'Banana (Lakatan)',
    'Banana (Latundan)',
    'Banana (Saba)',
    'Papaya',
    'Mango (Carabao)',
    'Avocado',
    'Melon',
    'Pomelo',
    'Watermelon'
  ],
  'Other Basic Commodities': [
    'Sugar (Refined)',
    'Sugar (Washed)',
    'Sugar (Brown)',
    'Cooking Oil (Palm) | Spec: 350 ml/bottle',
    'Cooking Oil (Palm) | Spec: 1 liter/bottle',
    'Cooking Oil (Coconut)'
  ],
};

// Helper function to get all commodities as a flat list
List<String> getAllCommodities() {
  List<String> all = [];
  COMMODITY_TYPES.forEach((type, items) {
    all.addAll(items);
  });
  return all;
}