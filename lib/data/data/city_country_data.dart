// نفس اللي في التصميم + شوية زيادة
import 'package:azan/core/models/city_option.dart';
import 'package:azan/core/models/country_option.dart';

const kCountries = <CountryOption>[
  CountryOption(code: 'SA', nameAr: 'السعودية', nameEn: 'Saudi Arabia'),
  CountryOption(code: 'QA', nameAr: 'قطر', nameEn: 'Qatar'),
  CountryOption(code: 'AE', nameAr: 'الامارات', nameEn: 'United Arab Emirates'),
  CountryOption(code: 'LB', nameAr: 'لبنان', nameEn: 'Lebanon'),
  CountryOption(code: 'KW', nameAr: 'الكويت', nameEn: 'Kuwait'),
  CountryOption(code: 'TN', nameAr: 'تونس', nameEn: 'Tunisia'),
];
const kSaudiCities = <CityOption>[
  // المدن الرئيسية - محدثة بإحداثيات دقيقة
  CityOption(
    countryCode: 'SA',
    nameAr: 'مكة المكرمة',
    nameEn: 'Makkah',
    lat: 21.4266, // من مصادر متعددة
    lon: 39.8256,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'المدينة المنورة',
    nameEn: 'Madinah',
    lat: 24.4686, // من مصادر متعددة
    lon: 39.6142,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'الرياض',
    nameEn: 'Riyadh',
    lat: 24.7743, // من مصادر متعددة
    lon: 46.7386,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'جدة',
    nameEn: 'Jeddah',
    lat: 21.4925, // من مصادر متعددة
    lon: 39.1776,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'الدمام',
    nameEn: 'Dammam',
    lat: 26.4207, // صحيح كما ذكرت
    lon: 50.0888,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'الخبر',
    nameEn: 'Khobar',
    lat: 26.2172, // محدّث من البحث
    lon: 50.1971,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'الطائف',
    nameEn: 'Taif',
    lat: 21.4858,
    lon: 40.5210,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'أبها',
    nameEn: 'Abha',
    lat: 18.2164,
    lon: 42.5053,
  ),

  // مدن إضافية مشهورة
  CityOption(
    countryCode: 'SA',
    nameAr: 'بريدة',
    nameEn: 'Buraydah',
    lat: 26.3592, // محدّث من البحث
    lon: 43.9818,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'حائل',
    nameEn: 'Hail',
    lat: 27.5219,
    lon: 41.6907,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'تبوك',
    nameEn: 'Tabuk',
    lat: 28.3838,
    lon: 36.5770,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'جازان',
    nameEn: 'Jazan',
    lat: 16.8892,
    lon: 42.5679,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'نجران',
    nameEn: 'Najran',
    lat: 17.5449,
    lon: 44.1340,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'خميس مشيط',
    nameEn: 'Khamis Mushait',
    lat: 18.3000,
    lon: 42.7333,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'الظهران',
    nameEn: 'Dhahran',
    lat: 26.2886,
    lon: 50.1130,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'ينبع',
    nameEn: 'Yanbu',
    lat: 24.0895,
    lon: 38.0618,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'الجبيل',
    nameEn: 'Jubail',
    lat: 27.0174,
    lon: 49.5926,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'الأحساء',
    nameEn: 'Al Ahsa',
    lat: 25.4295,
    lon: 49.6179,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'القطيف',
    nameEn: 'Qatif',
    lat: 26.5208,
    lon: 50.0245,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'الباحة',
    nameEn: 'Al Bahah',
    lat: 20.0129,
    lon: 41.4677,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'عرعر',
    nameEn: 'Arar',
    lat: 30.9753,
    lon: 41.0381,
  ),
  CityOption(
    countryCode: 'SA',
    nameAr: 'سكاكا',
    nameEn: 'Sakaka',
    lat: 29.9697,
    lon: 40.2064,
  ),
];
