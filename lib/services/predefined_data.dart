import '../models/course_model.dart';
import '../models/topic_model.dart';

class PredefinedData {
  // --- Sabit Ders Tanımları ---
  static const CourseModel courseMatematik = CourseModel(
    id: 'matematik',
    name: 'Matematik',
    colorValue: 0xFF2563EB, // Blue
    iconName: 'calculate',
    targetDailyQuestions: 40,
  );

  static const CourseModel courseGeometri = CourseModel(
    id: 'geometri',
    name: 'Geometri',
    colorValue: 0xFF0284C7, // Sky Blue
    iconName: 'shapes',
    targetDailyQuestions: 25,
  );

  static const CourseModel courseTurkce = CourseModel(
    id: 'turkce',
    name: 'Türkçe',
    colorValue: 0xFFDC2626, // Red
    iconName: 'menu_book',
    targetDailyQuestions: 35,
  );

  static const CourseModel courseEdebiyat = CourseModel(
    id: 'edebiyat',
    name: 'Türk Dili ve Edebiyatı',
    colorValue: 0xFFE11D48, // Rose
    iconName: 'menu_book',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseFizik = CourseModel(
    id: 'fizik',
    name: 'Fizik',
    colorValue: 0xFF7C3AED, // Violet
    iconName: 'bolt',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseKimya = CourseModel(
    id: 'kimya',
    name: 'Kimya',
    colorValue: 0xFF059669, // Emerald
    iconName: 'science',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseBiyoloji = CourseModel(
    id: 'biyoloji',
    name: 'Biyoloji',
    colorValue: 0xFF16A34A, // Green
    iconName: 'eco',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseTarih = CourseModel(
    id: 'tarih',
    name: 'Tarih',
    colorValue: 0xFFD97706, // Amber
    iconName: 'history_edu',
    targetDailyQuestions: 25,
  );

  static const CourseModel courseCografya = CourseModel(
    id: 'cografya',
    name: 'Coğrafya',
    colorValue: 0xFF0D9488, // Teal
    iconName: 'public',
    targetDailyQuestions: 25,
  );

  static const CourseModel courseVatandaslik = CourseModel(
    id: 'vatandaslik',
    name: 'Vatandaşlık & Güncel',
    colorValue: 0xFF0891B2, // Cyan
    iconName: 'gavel',
    targetDailyQuestions: 25,
  );

  static const CourseModel courseFelsefe = CourseModel(
    id: 'felsefe',
    name: 'Felsefe & Din',
    colorValue: 0xFF9333EA, // Purple
    iconName: 'psychology',
    targetDailyQuestions: 20,
  );

  static const CourseModel courseFenBilimleri = CourseModel(
    id: 'fen_bilimleri',
    name: 'Fen Bilimleri (LGS)',
    colorValue: 0xFF059669, // Emerald
    iconName: 'science',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseInkilap = CourseModel(
    id: 'inkilap',
    name: 'T.C. İnkılap Tarihi',
    colorValue: 0xFFD97706, // Amber
    iconName: 'history_edu',
    targetDailyQuestions: 25,
  );

  static const CourseModel courseDinKulturu = CourseModel(
    id: 'din_kulturu',
    name: 'Din Kültürü',
    colorValue: 0xFF8B5CF6, // Violet
    iconName: 'auto_stories',
    targetDailyQuestions: 20,
  );

  static const CourseModel courseIngilizce = CourseModel(
    id: 'ingilizce',
    name: 'İngilizce / Yabancı Dil',
    colorValue: 0xFFEA580C, // Orange
    iconName: 'language',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseSayisalMantik = CourseModel(
    id: 'sayisal_mantik',
    name: 'Sayısal (Matematik & Mantık)',
    colorValue: 0xFF2563EB,
    iconName: 'calculate',
    targetDailyQuestions: 35,
  );

  static const CourseModel courseSozelMantik = CourseModel(
    id: 'sozel_mantik',
    name: 'Sözel (Türkçe & Mantık)',
    colorValue: 0xFFDC2626,
    iconName: 'menu_book',
    targetDailyQuestions: 35,
  );

  static const CourseModel courseHukuk = CourseModel(
    id: 'alan_hukuk',
    name: 'Hukuk',
    colorValue: 0xFF1E3A8A,
    iconName: 'gavel',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseIktisat = CourseModel(
    id: 'alan_iktisat',
    name: 'İktisat',
    colorValue: 0xFF047857,
    iconName: 'trending_up',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseMaliye = CourseModel(
    id: 'alan_maliye',
    name: 'Maliye',
    colorValue: 0xFFB45309,
    iconName: 'account_balance',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseMuhasebe = CourseModel(
    id: 'alan_muhasebe',
    name: 'Muhasebe',
    colorValue: 0xFF4338CA,
    iconName: 'receipt_long',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseKamuYonetimi = CourseModel(
    id: 'alan_kamu',
    name: 'Kamu Yönetimi',
    colorValue: 0xFF701A75,
    iconName: 'account_balance',
    targetDailyQuestions: 30,
  );

  // --- HMGS & Hukuk Dersleri ---
  static const CourseModel courseAnayasaHukuku = CourseModel(
    id: 'hmgs_anayasa',
    name: 'Anayasa Hukuku',
    colorValue: 0xFF1E3A8A,
    iconName: 'gavel',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseIdareHukuku = CourseModel(
    id: 'hmgs_idare',
    name: 'İdare Hukuku & İYUK',
    colorValue: 0xFF0369A1,
    iconName: 'account_balance',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseMedeniHukuk = CourseModel(
    id: 'hmgs_medeni',
    name: 'Medeni Hukuk',
    colorValue: 0xFF4338CA,
    iconName: 'groups',
    targetDailyQuestions: 35,
  );

  static const CourseModel courseBorclarHukuku = CourseModel(
    id: 'hmgs_borclar',
    name: 'Borçlar Hukuku',
    colorValue: 0xFF6D28D9,
    iconName: 'handshake',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseCezaHukuku = CourseModel(
    id: 'hmgs_ceza',
    name: 'Ceza & Ceza Muhakemesi',
    colorValue: 0xFFBE123C,
    iconName: 'shield',
    targetDailyQuestions: 35,
  );

  static const CourseModel courseHMK = CourseModel(
    id: 'hmgs_hmk',
    name: 'Hukuk Muhakemeleri (HMK)',
    colorValue: 0xFFB45309,
    iconName: 'balance',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseTicaretHukuku = CourseModel(
    id: 'hmgs_ticaret',
    name: 'Ticaret Hukuku',
    colorValue: 0xFF047857,
    iconName: 'store',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseIcraIflas = CourseModel(
    id: 'hmgs_icra',
    name: 'İcra ve İflas Hukuku',
    colorValue: 0xFF0F766E,
    iconName: 'gavel',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseIsHukuku = CourseModel(
    id: 'hmgs_is_sosyal',
    name: 'İş & Sosyal Güvenlik Hukuku',
    colorValue: 0xFF7C2D12,
    iconName: 'badge',
    targetDailyQuestions: 25,
  );

  static const CourseModel courseVergiHukuku = CourseModel(
    id: 'hmgs_vergi',
    name: 'Vergi Hukuku',
    colorValue: 0xFF475569,
    iconName: 'receipt_long',
    targetDailyQuestions: 25,
  );

  static const CourseModel courseAvukatlikHukuku = CourseModel(
    id: 'hmgs_avukatlik',
    name: 'Avukatlık Hukuku & Felsefesi',
    colorValue: 0xFF581C87,
    iconName: 'menu_book',
    targetDailyQuestions: 20,
  );

  // --- AGS (Milli Eğitim Akademisi Giriş Sınavı) & Eğitim Bilimleri Dersleri ---
  static const CourseModel courseEgitiminTemelleri = CourseModel(
    id: 'ags_egitim_temelleri',
    name: 'Eğitimin Temelleri',
    colorValue: 0xFF4F46E5,
    iconName: 'school',
    targetDailyQuestions: 35,
  );

  static const CourseModel courseMebMevzuat = CourseModel(
    id: 'ags_mevzuat',
    name: 'Milli Eğitim Sistemi & Mevzuat',
    colorValue: 0xFF059669,
    iconName: 'policy',
    targetDailyQuestions: 25,
  );

  static const CourseModel courseOabt = CourseModel(
    id: 'ags_oabt',
    name: 'ÖABT (Alan Bilgisi)',
    colorValue: 0xFFD97706,
    iconName: 'workspace_premium',
    targetDailyQuestions: 40,
  );

  static const CourseModel courseGelisimOgrenme = CourseModel(
    id: 'kpss_psikoloji',
    name: 'Gelişim & Öğrenme Psikolojisi',
    colorValue: 0xFF9333EA,
    iconName: 'psychology',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseOyt = CourseModel(
    id: 'kpss_oyt',
    name: 'Öğretim İlke ve Yöntemleri (ÖYT)',
    colorValue: 0xFF2563EB,
    iconName: 'auto_stories',
    targetDailyQuestions: 30,
  );

  static const CourseModel courseOlcme = CourseModel(
    id: 'kpss_olcme',
    name: 'Ölçme ve Değerlendirme',
    colorValue: 0xFF0D9488,
    iconName: 'analytics',
    targetDailyQuestions: 25,
  );

  static const CourseModel courseProgramGelistirme = CourseModel(
    id: 'kpss_program',
    name: 'Program Geliştirme & Sınıf Yönetimi',
    colorValue: 0xFFE11D48,
    iconName: 'menu_book',
    targetDailyQuestions: 25,
  );

  static const CourseModel courseRehberlik = CourseModel(
    id: 'kpss_rehberlik',
    name: 'Rehberlik ve Özel Eğitim',
    colorValue: 0xFFEA580C,
    iconName: 'support_agent',
    targetDailyQuestions: 25,
  );

  /// Tüm tanımlı derslerin eksiksiz listesi
  static List<CourseModel> getAllAvailableCourses() {
    return [
      courseTurkce,
      courseMatematik,
      courseGeometri,
      courseTarih,
      courseCografya,
      courseVatandaslik,
      courseEdebiyat,
      courseFizik,
      courseKimya,
      courseBiyoloji,
      courseFelsefe,
      courseFenBilimleri,
      courseInkilap,
      courseDinKulturu,
      courseIngilizce,
      courseSayisalMantik,
      courseSozelMantik,
      courseHukuk,
      courseIktisat,
      courseMaliye,
      courseMuhasebe,
      courseKamuYonetimi,
      courseAnayasaHukuku,
      courseIdareHukuku,
      courseMedeniHukuk,
      courseBorclarHukuku,
      courseCezaHukuku,
      courseHMK,
      courseTicaretHukuku,
      courseIcraIflas,
      courseIsHukuku,
      courseVergiHukuku,
      courseAvukatlikHukuku,
      courseEgitiminTemelleri,
      courseMebMevzuat,
      courseOabt,
      courseGelisimOgrenme,
      courseOyt,
      courseOlcme,
      courseProgramGelistirme,
      courseRehberlik,
    ];
  }

  /// Geriye uyumluluk için varsayılan dersler
  static List<CourseModel> getDefaultCourses() {
    return getAllAvailableCourses();
  }

  /// Seçilen sınava göre dersleri kısıtlayıp döndürür
  static List<CourseModel> getCoursesForExam(String examName) {
    if (examName.contains('HMGS')) {
      return [
        courseAnayasaHukuku,
        courseIdareHukuku,
        courseMedeniHukuk,
        courseBorclarHukuku,
        courseCezaHukuku,
        courseHMK,
        courseTicaretHukuku,
        courseIcraIflas,
        courseIsHukuku,
        courseVergiHukuku,
        courseAvukatlikHukuku,
      ];
    }

    if (examName.contains('AGS')) {
      return [
        courseTurkce,
        courseMatematik,
        courseTarih,
        courseCografya,
        courseEgitiminTemelleri,
        courseMebMevzuat,
      ];
    }

    if (examName.contains('İYÖS')) {
      return [
        courseAnayasaHukuku,
        courseIdareHukuku,
        courseMedeniHukuk,
        courseBorclarHukuku,
        courseHMK,
        courseCezaHukuku,
        courseVergiHukuku,
        courseIktisat,
        courseMaliye,
      ];
    }

    if (examName.contains('Eğitim Bilimleri')) {
      return [
        courseGelisimOgrenme,
        courseOyt,
        courseOlcme,
        courseProgramGelistirme,
        courseRehberlik,
      ];
    }

    if (examName.contains('ÖABT') || examName.contains('OABT')) {
      return [
        courseOabt,
      ];
    }

    if (examName.contains('EKPSS')) {
      return [
        courseTurkce,
        courseMatematik,
        courseTarih,
        courseCografya,
        courseVatandaslik,
      ];
    }

    if (examName.contains('KPSS')) {
      if (examName.contains('Alan')) {
        return [
          courseTurkce,
          courseMatematik,
          courseTarih,
          courseCografya,
          courseVatandaslik,
          courseHukuk,
          courseIktisat,
          courseMaliye,
          courseMuhasebe,
          courseKamuYonetimi,
        ];
      }
      // KPSS Genel Yetenek - Genel Kültür, Ön Lisans, Ortaöğretim (Kimya, Fizik, Biyoloji ASLA YOK!)
      return [
        courseTurkce,
        courseMatematik,
        courseGeometri,
        courseTarih,
        courseCografya,
        courseVatandaslik,
      ];
    }

    if (examName.contains('MSÜ') || examName.contains('TYT')) {
      return [
        courseTurkce,
        courseMatematik,
        courseGeometri,
        courseFizik,
        courseKimya,
        courseBiyoloji,
        courseTarih,
        courseCografya,
        courseFelsefe,
        courseDinKulturu,
      ];
    }

    if (examName.contains('YDS') || examName.contains('YÖKDİL')) {
      return [
        courseIngilizce,
      ];
    }

    if (examName.contains('LGS')) {
      return [
        courseTurkce,
        courseMatematik,
        courseFenBilimleri,
        courseInkilap,
        courseDinKulturu,
        courseIngilizce,
      ];
    }

    if (examName.contains('AYT')) {
      if (examName.contains('Eşit Ağırlık') || examName.contains('EA')) {
        return [
          courseMatematik,
          courseGeometri,
          courseEdebiyat,
          courseTarih,
          courseCografya,
        ];
      }
      if (examName.contains('Sözel')) {
        return [
          courseEdebiyat,
          courseTarih,
          courseCografya,
          courseFelsefe,
        ];
      }
      // Sayısal
      return [
        courseMatematik,
        courseGeometri,
        courseFizik,
        courseKimya,
        courseBiyoloji,
      ];
    }

    if (examName.contains('Sayısal')) {
      return [
        courseMatematik,
        courseGeometri,
        courseFizik,
        courseKimya,
        courseBiyoloji,
      ];
    }

    if (examName.contains('Eşit Ağırlık')) {
      return [
        courseMatematik,
        courseGeometri,
        courseEdebiyat,
        courseTarih,
        courseCografya,
      ];
    }

    if (examName.contains('Sözel')) {
      return [
        courseEdebiyat,
        courseTarih,
        courseCografya,
        courseFelsefe,
      ];
    }

    if (examName.contains('Dil') || examName.contains('YDT')) {
      return [
        courseIngilizce,
      ];
    }

    if (examName.contains('DGS') || examName.contains('ALES')) {
      return [
        courseSayisalMantik,
        courseGeometri,
        courseSozelMantik,
      ];
    }

    // Genel Sınav Hazırlığı
    return getAllAvailableCourses();
  }

  /// Tüm derslere ait konu listesi
  static List<TopicModel> getDefaultTopics() {
    return [
      // Matematik
      const TopicModel(id: 'mat_1', courseId: 'matematik', name: 'Temel Kavramlar & Sayı Kümeleri'),
      const TopicModel(id: 'mat_2', courseId: 'matematik', name: 'Sayı Basamakları & Bölme-Bölünebilme'),
      const TopicModel(id: 'mat_3', courseId: 'matematik', name: 'Rasyonel & Ondalık Sayılar'),
      const TopicModel(id: 'mat_4', courseId: 'matematik', name: 'Basit Eşitsizlik & Mutlak Değer'),
      const TopicModel(id: 'mat_5', courseId: 'matematik', name: 'Üslü & Köklü Sayılar'),
      const TopicModel(id: 'mat_6', courseId: 'matematik', name: 'Çarpanlara Ayırma'),
      const TopicModel(id: 'mat_7', courseId: 'matematik', name: 'Oran-Orantı & Problemler'),
      const TopicModel(id: 'mat_8', courseId: 'matematik', name: 'Kümeler & Fonksiyonlar'),
      const TopicModel(id: 'mat_9', courseId: 'matematik', name: 'Polinomlar & 2. Dereceden Denklemler'),
      const TopicModel(id: 'mat_10', courseId: 'matematik', name: 'Trigonometri'),
      const TopicModel(id: 'mat_11', courseId: 'matematik', name: 'Logaritma & Diziler'),
      const TopicModel(id: 'mat_12', courseId: 'matematik', name: 'Limit, Süreklilik & Türev'),
      const TopicModel(id: 'mat_13', courseId: 'matematik', name: 'İntegral'),
      const TopicModel(id: 'mat_14', courseId: 'matematik', name: 'Permütasyon, Kombinasyon & Olasılık'),
      const TopicModel(id: 'mat_15', courseId: 'matematik', name: 'Sayısal Mantık ve Muhakeme'),

      // Geometri
      const TopicModel(id: 'geo_1', courseId: 'geometri', name: 'Doğruda ve Üçgende Açılar'),
      const TopicModel(id: 'geo_2', courseId: 'geometri', name: 'Özel Üçgenler (Dik, İkizkenar, Eşkenar)'),
      const TopicModel(id: 'geo_3', courseId: 'geometri', name: 'Üçgende Benzerlik ve Alan'),
      const TopicModel(id: 'geo_4', courseId: 'geometri', name: 'Çokgenler ve Dörtgenler'),
      const TopicModel(id: 'geo_5', courseId: 'geometri', name: 'Çember ve Daire'),
      const TopicModel(id: 'geo_6', courseId: 'geometri', name: 'Katı Cisimler (Prizma, Piramit, Koni)'),
      const TopicModel(id: 'geo_7', courseId: 'geometri', name: 'Analitik Geometri'),

      // Türkçe
      const TopicModel(id: 'tur_1', courseId: 'turkce', name: 'Sözcükte ve Cümlede Anlam'),
      const TopicModel(id: 'tur_2', courseId: 'turkce', name: 'Paragrafta Anlam & Ana Düşünce'),
      const TopicModel(id: 'tur_3', courseId: 'turkce', name: 'Yazım Kuralları ve Noktalama'),
      const TopicModel(id: 'tur_4', courseId: 'turkce', name: 'Ses Bilgisi'),
      const TopicModel(id: 'tur_5', courseId: 'turkce', name: 'Sözcük Türleri (İsim, Sıfat, Zamir, Zarf)'),
      const TopicModel(id: 'tur_6', courseId: 'turkce', name: 'Cümlenin Ögeleri & Cümle Türleri'),
      const TopicModel(id: 'tur_7', courseId: 'turkce', name: 'Anlatım Bozuklukları'),
      const TopicModel(id: 'tur_8', courseId: 'turkce', name: 'Sözel Mantık & Çıkarım Yapma'),

      // Vatandaşlık & Güncel Bilgiler (KPSS Özel)
      const TopicModel(id: 'vat_1', courseId: 'vatandaslik', name: 'Temel Hukuk Bilgisi & Hukukun Dalları'),
      const TopicModel(id: 'vat_2', courseId: 'vatandaslik', name: 'Devlet Biçimleri ve Demokrasi'),
      const TopicModel(id: 'vat_3', courseId: 'vatandaslik', name: 'Türk Anayasa Tarihi'),
      const TopicModel(id: 'vat_4', courseId: 'vatandaslik', name: '1982 Anayasası Esasları & Temel Haklar'),
      const TopicModel(id: 'vat_5', courseId: 'vatandaslik', name: 'Yasama (TBMM Yetkileri ve Kanun Yapımı)'),
      const TopicModel(id: 'vat_6', courseId: 'vatandaslik', name: 'Yürütme (Cumhurbaşkanı ve İdare)'),
      const TopicModel(id: 'vat_7', courseId: 'vatandaslik', name: 'Yargı Organı & Yüksek Mahkemeler'),
      const TopicModel(id: 'vat_8', courseId: 'vatandaslik', name: 'İdare Hukuku ve Türkiye İdari Teşkilatı'),
      const TopicModel(id: 'vat_9', courseId: 'vatandaslik', name: 'Uluslararası Kuruluşlar ve Güncel Olaylar'),

      // Edebiyat
      const TopicModel(id: 'edb_1', courseId: 'edebiyat', name: 'Güzel Sanatlar ve Edebiyat & Metin Türleri'),
      const TopicModel(id: 'edb_2', courseId: 'edebiyat', name: 'Şiir Bilgisi & Edebi Sanatlar'),
      const TopicModel(id: 'edb_3', courseId: 'edebiyat', name: 'İslamiyet Öncesi ve Geçiş Dönemi'),
      const TopicModel(id: 'edb_4', courseId: 'edebiyat', name: 'Halk Edebiyatı'),
      const TopicModel(id: 'edb_5', courseId: 'edebiyat', name: 'Divan Edebiyatı'),
      const TopicModel(id: 'edb_6', courseId: 'edebiyat', name: 'Tanzimat & Servet-i Fünun Edebiyatı'),
      const TopicModel(id: 'edb_7', courseId: 'edebiyat', name: 'Milli Edebiyat & Cumhuriyet Dönemi'),
      const TopicModel(id: 'edb_8', courseId: 'edebiyat', name: 'Edebi Akımlar ve Dünya Edebiyatı'),

      // Tarih
      const TopicModel(id: 'tar_1', courseId: 'tarih', name: 'Tarih ve Zaman & İlk Türk Devletleri'),
      const TopicModel(id: 'tar_2', courseId: 'tarih', name: 'İslam Tarihi ve Türk-İslam Devletleri'),
      const TopicModel(id: 'tar_3', courseId: 'tarih', name: 'Osmanlı Devleti Kuruluş ve Yükselme'),
      const TopicModel(id: 'tar_4', courseId: 'tarih', name: 'Osmanlı Kültür ve Medeniyeti'),
      const TopicModel(id: 'tar_5', courseId: 'tarih', name: 'Osmanlı Dağılma Dönemi & I. Dünya Savaşı'),
      const TopicModel(id: 'tar_6', courseId: 'tarih', name: 'Kurtuluş Savaşı Hazırlık ve Cepheler'),
      const TopicModel(id: 'tar_7', courseId: 'tarih', name: 'Atatürk İlkeleri ve İnkılapları'),
      const TopicModel(id: 'tar_8', courseId: 'tarih', name: 'Çağdaş Türk ve Dünya Tarihi'),

      // Coğrafya
      const TopicModel(id: 'cog_1', courseId: 'cografya', name: 'Doğa ve İnsan & Harita Bilgisi'),
      const TopicModel(id: 'cog_2', courseId: 'cografya', name: 'Dünya’nın Şekli, Hareketleri & Konum'),
      const TopicModel(id: 'cog_3', courseId: 'cografya', name: 'İklim Bilgisi & Türkiye’nin İklimi'),
      const TopicModel(id: 'cog_4', courseId: 'cografya', name: 'Türkiye’nin Yerşekilleri & Su Varlığı'),
      const TopicModel(id: 'cog_5', courseId: 'cografya', name: 'Nüfus, Yerleşme ve Göç'),
      const TopicModel(id: 'cog_6', courseId: 'cografya', name: 'Türkiye’de Tarım ve Hayvancılık'),
      const TopicModel(id: 'cog_7', courseId: 'cografya', name: 'Madenler, Sanayi, Ulaşım ve Ticaret'),
      const TopicModel(id: 'cog_8', courseId: 'cografya', name: 'Çevre, Doğa ve Afetler'),

      // Fizik
      const TopicModel(id: 'fiz_1', courseId: 'fizik', name: 'Fizik Bilimine Giriş & Madde-Özellikleri'),
      const TopicModel(id: 'fiz_2', courseId: 'fizik', name: 'Kuvvet, Hareket ve Newton Yasaları'),
      const TopicModel(id: 'fiz_3', courseId: 'fizik', name: 'İş, Güç ve Enerji'),
      const TopicModel(id: 'fiz_4', courseId: 'fizik', name: 'Isı, Sıcaklık ve Genleşme'),
      const TopicModel(id: 'fiz_5', courseId: 'fizik', name: 'Elektrik ve Manyetizma'),
      const TopicModel(id: 'fiz_6', courseId: 'fizik', name: 'Basınç ve Kaldırma Kuvveti'),
      const TopicModel(id: 'fiz_7', courseId: 'fizik', name: 'Dalgalar & Optik'),
      const TopicModel(id: 'fiz_8', courseId: 'fizik', name: 'Çembersel & Basit Harmonik Hareket'),
      const TopicModel(id: 'fiz_9', courseId: 'fizik', name: 'Modern Fizik & Radyoaktivite'),

      // Kimya
      const TopicModel(id: 'kim_1', courseId: 'kimya', name: 'Kimya Bilimi ve Periyodik Sistem'),
      const TopicModel(id: 'kim_2', courseId: 'kimya', name: 'Kimyasal Türler Arası Etkileşimler'),
      const TopicModel(id: 'kim_3', courseId: 'kimya', name: 'Maddenin Halleri ve Gazlar'),
      const TopicModel(id: 'kim_4', courseId: 'kimya', name: 'Kimyanın Temel Kanunları & Mol'),
      const TopicModel(id: 'kim_5', courseId: 'kimya', name: 'Asitler, Bazlar ve Tuzlar'),
      const TopicModel(id: 'kim_6', courseId: 'kimya', name: 'Kimyasal Tepkimelerde Enerji ve Hız'),
      const TopicModel(id: 'kim_7', courseId: 'kimya', name: 'Kimyasal Denge & Çözünürlük Dengesi'),
      const TopicModel(id: 'kim_8', courseId: 'kimya', name: 'Organik Kimyaya Giriş & Hidrokarbonlar'),

      // Biyoloji
      const TopicModel(id: 'biy_1', courseId: 'biyoloji', name: 'Canlıların Temel Bileşenleri'),
      const TopicModel(id: 'biy_2', courseId: 'biyoloji', name: 'Hücre Yapısı ve Organeller'),
      const TopicModel(id: 'biy_3', courseId: 'biyoloji', name: 'Canlıların Sınıflandırılması'),
      const TopicModel(id: 'biy_4', courseId: 'biyoloji', name: 'Hücre Bölünmeleri & Üreme'),
      const TopicModel(id: 'biy_5', courseId: 'biyoloji', name: 'Kalıtım ve Genetik'),
      const TopicModel(id: 'biy_6', courseId: 'biyoloji', name: 'Ekosistem Ekolojisi'),
      const TopicModel(id: 'biy_7', courseId: 'biyoloji', name: 'İnsan Fizyolojisi (Organ Sistemleri)'),
      const TopicModel(id: 'biy_8', courseId: 'biyoloji', name: 'Genden Proteine & Biyoteknoloji'),

      // Felsefe & Din
      const TopicModel(id: 'fel_1', courseId: 'felsefe', name: 'Felsefenin Alanı ve Bilgi Felsefesi'),
      const TopicModel(id: 'fel_2', courseId: 'felsefe', name: 'Varlık, Ahlak ve Sanat Felsefesi'),
      const TopicModel(id: 'fel_3', courseId: 'felsefe', name: 'Siyaset ve Din Felsefesi'),
      const TopicModel(id: 'fel_4', courseId: 'felsefe', name: 'İnanç, İbadet ve Ahlak Esasları'),

      // Fen Bilimleri (LGS)
      const TopicModel(id: 'fen_1', courseId: 'fen_bilimleri', name: 'Mevsimler ve İklim'),
      const TopicModel(id: 'fen_2', courseId: 'fen_bilimleri', name: 'DNA ve Genetik Kod'),
      const TopicModel(id: 'fen_3', courseId: 'fen_bilimleri', name: 'Basınç (Katı, Sıvı, Gaz)'),
      const TopicModel(id: 'fen_4', courseId: 'fen_bilimleri', name: 'Madde ve Endüstri (Asit-Baz, Tepkimeler)'),
      const TopicModel(id: 'fen_5', courseId: 'fen_bilimleri', name: 'Basit Makineler'),
      const TopicModel(id: 'fen_6', courseId: 'fen_bilimleri', name: 'Enerji Dönüşümleri ve Çevre Bilimi'),
      const TopicModel(id: 'fen_7', courseId: 'fen_bilimleri', name: 'Elektrik Yükleri ve Elektrik Enerjisi'),

      // İnkılap Tarihi (LGS)
      const TopicModel(id: 'ink_1', courseId: 'inkilap', name: 'Bir Kahraman Doğuyor (Mustafa Kemal)'),
      const TopicModel(id: 'ink_2', courseId: 'inkilap', name: 'Milli Uyanış: Bağımsızlık Yolunda Adımlar'),
      const TopicModel(id: 'ink_3', courseId: 'inkilap', name: 'Milli Bir Destan: Ya İstiklal Ya Ölüm'),
      const TopicModel(id: 'ink_4', courseId: 'inkilap', name: 'Atatürkçülük ve Çağdaşlaşan Türkiye'),
      const TopicModel(id: 'ink_5', courseId: 'inkilap', name: 'Demokratikleşme Çabaları & Dış Politika'),

      // Din Kültürü
      const TopicModel(id: 'din_1', courseId: 'din_kulturu', name: 'Kader İnancı'),
      const TopicModel(id: 'din_2', courseId: 'din_kulturu', name: 'Zekat ve Sadaka İbadeti'),
      const TopicModel(id: 'din_3', courseId: 'din_kulturu', name: 'Din ve Hayat'),
      const TopicModel(id: 'din_4', courseId: 'din_kulturu', name: 'Hz. Muhammed’in Örnek Ahlakı'),
      const TopicModel(id: 'din_5', courseId: 'din_kulturu', name: 'Kur’an-ı Kerim ve Özellikleri'),

      // İngilizce
      const TopicModel(id: 'ing_1', courseId: 'ingilizce', name: 'Friendship & Personal Life'),
      const TopicModel(id: 'ing_2', courseId: 'ingilizce', name: 'Teen Life & Daily Routines'),
      const TopicModel(id: 'ing_3', courseId: 'ingilizce', name: 'Communication & The Internet'),
      const TopicModel(id: 'ing_4', courseId: 'ingilizce', name: 'Tourism & Adventures'),
      const TopicModel(id: 'ing_5', courseId: 'ingilizce', name: 'Science & Environment'),
      const TopicModel(id: 'ing_6', courseId: 'ingilizce', name: 'Reading Comprehension & Vocabulary'),

      // Sayısal Mantık (DGS / ALES)
      const TopicModel(id: 'say_1', courseId: 'sayisal_mantik', name: 'Temel Matematik & Sayılar'),
      const TopicModel(id: 'say_2', courseId: 'sayisal_mantik', name: 'Problemler & Denklem Kurma'),
      const TopicModel(id: 'say_3', courseId: 'sayisal_mantik', name: 'Sayısal Mantık & Örüntüler'),
      const TopicModel(id: 'say_4', courseId: 'sayisal_mantik', name: 'Tablo ve Grafik Yorumlama'),

      // Sözel Mantık (DGS / ALES)
      const TopicModel(id: 'soz_1', courseId: 'sozel_mantik', name: 'Sözcük ve Cümlede Anlam'),
      const TopicModel(id: 'soz_2', courseId: 'sozel_mantik', name: 'Paragrafta Anlam & Akıl Yürütme'),
      const TopicModel(id: 'soz_3', courseId: 'sozel_mantik', name: 'Sözel Mantık & Tablo Sıralama'),

      // KPSS Alan
      const TopicModel(id: 'huk_1', courseId: 'alan_hukuk', name: 'Anayasa ve İdare Hukuku'),
      const TopicModel(id: 'huk_2', courseId: 'alan_hukuk', name: 'Medeni Hukuk & Borçlar Hukuku'),
      const TopicModel(id: 'huk_3', courseId: 'alan_hukuk', name: 'Ceza Hukuku & Ticaret Hukuku'),

      const TopicModel(id: 'ikt_1', courseId: 'alan_iktisat', name: 'Mikro İktisat'),
      const TopicModel(id: 'ikt_2', courseId: 'alan_iktisat', name: 'Makro İktisat & Para-Banka'),
      const TopicModel(id: 'ikt_3', courseId: 'alan_iktisat', name: 'Türkiye Ekonomisi & Uluslararası İktisat'),

      const TopicModel(id: 'mal_1', courseId: 'alan_maliye', name: 'Maliye Teorisi & Kamu Harcamaları'),
      const TopicModel(id: 'mal_2', courseId: 'alan_maliye', name: 'Kamu Gelirleri & Bütçe'),
      const TopicModel(id: 'mal_3', courseId: 'alan_maliye', name: 'Vergi Hukuku & Türk Vergi Sistemi'),

      const TopicModel(id: 'muh_1', courseId: 'alan_muhasebe', name: 'Genel Muhasebe (Finansal Muhasebe)'),
      const TopicModel(id: 'muh_2', courseId: 'alan_muhasebe', name: 'Mali Tablolar Analizi & Maliyet Muhasebesi'),

      const TopicModel(id: 'kam_1', courseId: 'alan_kamu', name: 'Siyaset Bilimi & Yönetim Bilimleri'),
      const TopicModel(id: 'kam_2', courseId: 'alan_kamu', name: 'Kentleşme ve Çevre Sorunları & Türk Siyasal Hayatı'),
    ];
  }

  /// Sınav türüne ve dersine özel resmi müfredat konularını sıralı olarak getirir.
  /// KPSS çalışan öğrenciye Trigonometri/İntegral gibi sınavında olmayan konular KESİNLİKLE gösterilmez.
  static List<TopicModel> getTopicsForExam(String examName, {String? courseId}) {
    final all = getDefaultTopics();

    // 1. KPSS (Genel Yetenek - Genel Kültür) ÖZEL MÜFREDATI
    if (examName.contains('KPSS') && !examName.contains('ÖABT')) {
      if (courseId == 'matematik') {
        return const [
          TopicModel(id: 'kpss_mat_1', courseId: 'matematik', name: 'Temel Kavramlar & Sayı Kümeleri (10 Soru Grubu)'),
          TopicModel(id: 'kpss_mat_2', courseId: 'matematik', name: 'Sayı Basamakları & Bölme-Bölünebilme'),
          TopicModel(id: 'kpss_mat_3', courseId: 'matematik', name: 'Rasyonel & Ondalık Sayılar'),
          TopicModel(id: 'kpss_mat_4', courseId: 'matematik', name: 'Basit Eşitsizlik & Mutlak Değer'),
          TopicModel(id: 'kpss_mat_5', courseId: 'matematik', name: 'Üslü & Köklü Sayılar'),
          TopicModel(id: 'kpss_mat_6', courseId: 'matematik', name: 'Çarpanlara Ayırma'),
          TopicModel(id: 'kpss_mat_7', courseId: 'matematik', name: 'Oran-Orantı Temeli'),
          TopicModel(id: 'kpss_mat_8', courseId: 'matematik', name: 'Sayı ve Kesir Problemleri (12 Soru Grubu - Belirleyici)'),
          TopicModel(id: 'kpss_mat_9', courseId: 'matematik', name: 'Yaş, Yüzde, Kâr-Zarar ve Karışım Problemleri'),
          TopicModel(id: 'kpss_mat_10', courseId: 'matematik', name: 'Hareket (Hız) ve Tablo-Grafik Problemleri'),
          TopicModel(id: 'kpss_mat_11', courseId: 'matematik', name: 'Kümeler, İşlem ve Modüler Aritmetik'),
          TopicModel(id: 'kpss_mat_12', courseId: 'matematik', name: 'Fonksiyonlar ve Olasılık'),
          TopicModel(id: 'kpss_mat_13', courseId: 'matematik', name: 'Permütasyon & Kombinasyon'),
          TopicModel(id: 'kpss_mat_14', courseId: 'matematik', name: 'Sayısal Mantık, Tablo ve Muhakeme'),
        ];
      }

      if (courseId == 'geometri') {
        // KPSS'de Geometri sadece 3 sorudur
        return const [
          TopicModel(id: 'kpss_geo_1', courseId: 'geometri', name: 'Doğruda ve Üçgende Açılar'),
          TopicModel(id: 'kpss_geo_2', courseId: 'geometri', name: 'Özel Üçgenler (Dik, İkizkenar) & Üçgende Alan'),
          TopicModel(id: 'kpss_geo_3', courseId: 'geometri', name: 'Çokgenler, Dörtgenler ve Çember'),
          TopicModel(id: 'kpss_geo_4', courseId: 'geometri', name: 'Katı Cisimler ve Analitik Geometri'),
        ];
      }

      if (courseId == 'turkce') {
        return const [
          TopicModel(id: 'kpss_tur_1', courseId: 'turkce', name: 'Paragrafta Anlam ve Yapı (18 Soru Grubu - Okuma Hızı)'),
          TopicModel(id: 'kpss_tur_2', courseId: 'turkce', name: 'Sözcükte ve Cümlede Anlam'),
          TopicModel(id: 'kpss_tur_3', courseId: 'turkce', name: 'Ses Bilgisi & Yazım Kuralları (2 Soru)'),
          TopicModel(id: 'kpss_tur_4', courseId: 'turkce', name: 'Noktalama İşaretleri (2 Soru)'),
          TopicModel(id: 'kpss_tur_5', courseId: 'turkce', name: 'Sözcük Türleri (İsim, Sıfat, Zamir, Zarf)'),
          TopicModel(id: 'kpss_tur_6', courseId: 'turkce', name: 'Cümlenin Ögeleri ve Cümle Türleri'),
          TopicModel(id: 'kpss_tur_7', courseId: 'turkce', name: 'Sözel Mantık ve Muhakeme (4 Soru - Tablo Kurma)'),
        ];
      }

      if (courseId == 'tarih') {
        return const [
          TopicModel(id: 'kpss_tar_1', courseId: 'tarih', name: 'İslamiyet Öncesi Türk Tarihi & Medeniyeti (3 Soru)'),
          TopicModel(id: 'kpss_tar_2', courseId: 'tarih', name: 'İlk Türk-İslam Devletleri ve Kültürü'),
          TopicModel(id: 'kpss_tar_3', courseId: 'tarih', name: 'Osmanlı Devleti Kuruluş ve Yükselme Dönemi'),
          TopicModel(id: 'kpss_tar_4', courseId: 'tarih', name: 'Osmanlı Kültür ve Medeniyeti (6 Soru Grubu - Devlet, Hukuk, Sanat)'),
          TopicModel(id: 'kpss_tar_5', courseId: 'tarih', name: 'Osmanlı Dağılma Dönemi ve Islahatlar'),
          TopicModel(id: 'kpss_tar_6', courseId: 'tarih', name: 'Kurtuluş Savaşı Hazırlık Dönemi (Genelgeler & Kongreler - 12 Soru Grubu)'),
          TopicModel(id: 'kpss_tar_7', courseId: 'tarih', name: 'Kurtuluş Savaşı Muharebeler ve Antlaşmalar'),
          TopicModel(id: 'kpss_tar_8', courseId: 'tarih', name: 'Atatürk İlkeleri ve İnkılap Tarihi'),
          TopicModel(id: 'kpss_tar_9', courseId: 'tarih', name: 'Çağdaş Türk ve Dünya Tarihi (3 Soru)'),
        ];
      }

      if (courseId == 'cografya') {
        return const [
          TopicModel(id: 'kpss_cog_1', courseId: 'cografya', name: 'Türkiye’nin Coğrafi Konumu ve Fiziki Özellikleri (7 Soru)'),
          TopicModel(id: 'kpss_cog_2', courseId: 'cografya', name: 'Türkiye’nin Yerşekilleri, Dağları, Ovaları ve Akarsuları'),
          TopicModel(id: 'kpss_cog_3', courseId: 'cografya', name: 'Türkiye’nin İklimi ve Bitki Örtüsü'),
          TopicModel(id: 'kpss_cog_4', courseId: 'cografya', name: 'Türkiye’nin Nüfusu, Yerleşme ve Göç Özellikleri'),
          TopicModel(id: 'kpss_cog_5', courseId: 'cografya', name: 'Türkiye’de Tarım ve Hayvancılık (11 Soru Grubu - TÜİK)'),
          TopicModel(id: 'kpss_cog_6', courseId: 'cografya', name: 'Türkiye’nin Madenleri, Enerji Kaynakları ve Sanayisi'),
          TopicModel(id: 'kpss_cog_7', courseId: 'cografya', name: 'Türkiye’de Ulaşım, Ticaret ve Turizm Coğrafyası'),
        ];
      }

      if (courseId == 'vatandaslik') {
        return const [
          TopicModel(id: 'kpss_vat_1', courseId: 'vatandaslik', name: 'Temel Hukuk Bilgisi ve Hukukun Dalları'),
          TopicModel(id: 'kpss_vat_2', courseId: 'vatandaslik', name: 'Devlet Biçimleri, Hükümet Sistemleri ve Demokrasi'),
          TopicModel(id: 'kpss_vat_3', courseId: 'vatandaslik', name: 'Türk Anayasa Tarihi ve 1982 Anayasası Esasları'),
          TopicModel(id: 'kpss_vat_4', courseId: 'vatandaslik', name: 'Yasama Organı: TBMM Görev ve Yetkileri (9 Soru Grubu)'),
          TopicModel(id: 'kpss_vat_5', courseId: 'vatandaslik', name: 'Yürütme Organı: Cumhurbaşkanı ve İdari Yapı'),
          TopicModel(id: 'kpss_vat_6', courseId: 'vatandaslik', name: 'Yargı Organı ve Yüksek Mahkemeler'),
          TopicModel(id: 'kpss_vat_7', courseId: 'vatandaslik', name: 'İdare Hukuku ve Türkiye İdari Teşkilatı'),
          TopicModel(id: 'kpss_vat_8', courseId: 'vatandaslik', name: 'Güncel Olaylar, Türkiye ve Dünya Gündemi (6 Soru)'),
        ];
      }
    }

    // 2. LGS (Liselere Geçiş Sistemi) MÜFREDATI
    if (examName.contains('LGS')) {
      if (courseId == 'matematik') {
        return const [
          TopicModel(id: 'lgs_mat_1', courseId: 'matematik', name: 'Çarpanlar ve Katlar (EBOB-EKOK)'),
          TopicModel(id: 'lgs_mat_2', courseId: 'matematik', name: 'Üslü İfadeler'),
          TopicModel(id: 'lgs_mat_3', courseId: 'matematik', name: 'Kareköklü İfadeler'),
          TopicModel(id: 'lgs_mat_4', courseId: 'matematik', name: 'Veri Analizi (Grafik Yorumlama)'),
          TopicModel(id: 'lgs_mat_5', courseId: 'matematik', name: 'Basit Olayların Olma Olasılığı'),
          TopicModel(id: 'lgs_mat_6', courseId: 'matematik', name: 'Cebirsel İfadeler ve Özdeşlikler'),
          TopicModel(id: 'lgs_mat_7', courseId: 'matematik', name: 'Doğrusal Denklemler ve Eğim'),
          TopicModel(id: 'lgs_mat_8', courseId: 'matematik', name: 'Eşitsizlikler'),
          TopicModel(id: 'lgs_mat_9', courseId: 'matematik', name: 'Üçgenler (Açı-Kenar, Eşlik ve Benzerlik)'),
          TopicModel(id: 'lgs_mat_10', courseId: 'matematik', name: 'Dönüşüm Geometrisi ve Geometrik Cisimler'),
        ];
      }

      if (courseId == 'fen_bilimleri') {
        return const [
          TopicModel(id: 'lgs_fen_1', courseId: 'fen_bilimleri', name: 'Mevsimler ve İklim'),
          TopicModel(id: 'lgs_fen_2', courseId: 'fen_bilimleri', name: 'DNA ve Genetik Kod (Mutasyon, Modifikasyon)'),
          TopicModel(id: 'lgs_fen_3', courseId: 'fen_bilimleri', name: 'Basınç (Katı, Sıvı, Gaz)'),
          TopicModel(id: 'lgs_fen_4', courseId: 'fen_bilimleri', name: 'Madde ve Endüstri (Periyodik Sistem, Asit-Baz)'),
          TopicModel(id: 'lgs_fen_5', courseId: 'fen_bilimleri', name: 'Basit Makineler (Makaralar, Kaldıraç, Eğik Düzlem)'),
          TopicModel(id: 'lgs_fen_6', courseId: 'fen_bilimleri', name: 'Enerji Dönüşümleri ve Çevre Bilimi'),
          TopicModel(id: 'lgs_fen_7', courseId: 'fen_bilimleri', name: 'Elektrik Yükleri ve Elektrik Enerjisi'),
        ];
      }

      if (courseId == 'inkilap') {
        return const [
          TopicModel(id: 'lgs_ink_1', courseId: 'inkilap', name: 'Bir Kahraman Doğuyor (Atatürk’ün Hayatı)'),
          TopicModel(id: 'lgs_ink_2', courseId: 'inkilap', name: 'Milli Uyanış: Bağımsızlık Yolunda Atılan Adımlar'),
          TopicModel(id: 'lgs_ink_3', courseId: 'inkilap', name: 'Milli Bir Destan: Ya İstiklal Ya Ölüm (Cepheler)'),
          TopicModel(id: 'lgs_ink_4', courseId: 'inkilap', name: 'Atatürkçülük ve Çağdaşlaşan Türkiye (İnkılaplar)'),
          TopicModel(id: 'lgs_ink_5', courseId: 'inkilap', name: 'Demokratikleşme Çabaları & Atatürk Dönemi Dış Politika'),
        ];
      }
    }

    // 3. DGS & ALES MÜFREDATI
    if (examName.contains('DGS') || examName.contains('ALES')) {
      if (courseId == 'sayisal_mantik' || courseId == 'matematik') {
        return const [
          TopicModel(id: 'dgs_mat_1', courseId: 'sayisal_mantik', name: 'Temel Kavramlar & Sayılar (12 Soru Grubu)'),
          TopicModel(id: 'dgs_mat_2', courseId: 'sayisal_mantik', name: 'Bölme-Bölünebilme & EBOB-EKOK'),
          TopicModel(id: 'dgs_mat_3', courseId: 'sayisal_mantik', name: 'Rasyonel Sayılar, Eşitsizlik & Mutlak Değer'),
          TopicModel(id: 'dgs_mat_4', courseId: 'sayisal_mantik', name: 'Üslü ve Köklü Sayılar (8 Soru Grubu)'),
          TopicModel(id: 'dgs_mat_5', courseId: 'sayisal_mantik', name: 'Çarpanlara Ayırma & Özdeşlikler'),
          TopicModel(id: 'dgs_mat_6', courseId: 'sayisal_mantik', name: 'Sayı ve Kesir Problemleri (15 Soru Grubu)'),
          TopicModel(id: 'dgs_mat_7', courseId: 'sayisal_mantik', name: 'Yaş, Yüzde, Kâr-Zarar ve Karışım Problemleri'),
          TopicModel(id: 'dgs_mat_8', courseId: 'sayisal_mantik', name: 'Hız-Hareket ve Grafik-Tablo Problemleri'),
          TopicModel(id: 'dgs_mat_9', courseId: 'sayisal_mantik', name: 'Kümeler, Fonksiyonlar ve İşlem'),
          TopicModel(id: 'dgs_mat_10', courseId: 'sayisal_mantik', name: 'Permütasyon, Kombinasyon ve Olasılık'),
          TopicModel(id: 'dgs_mat_11', courseId: 'sayisal_mantik', name: 'Sayısal Mantık, Şekil Yeteneği & Örüntüler (8 Soru)'),
        ];
      }

      if (courseId == 'sozel_mantik' || courseId == 'turkce') {
        return const [
          TopicModel(id: 'dgs_tur_1', courseId: 'sozel_mantik', name: 'Sözcükte ve Cümlede Anlam, Kesin Yargı (12 Soru)'),
          TopicModel(id: 'dgs_tur_2', courseId: 'sozel_mantik', name: 'Paragrafta Anlam ve Ana Düşünce (30 Soru Grubu)'),
          TopicModel(id: 'dgs_tur_3', courseId: 'sozel_mantik', name: 'Paragrafta Yapı, Akışı Bozan Cümle & Çoklu Metinler'),
          TopicModel(id: 'dgs_tur_4', courseId: 'sozel_mantik', name: 'Sözel Mantık, Sıralama ve Akıl Yürütme (8 Soru - 2 Kurgu)'),
        ];
      }

      if (courseId == 'geometri') {
        return const [
          TopicModel(id: 'dgs_geo_1', courseId: 'geometri', name: 'Doğruda ve Üçgende Açılar (7-8 Soru Grubu)'),
          TopicModel(id: 'dgs_geo_2', courseId: 'geometri', name: 'Özel Üçgenler, Benzerlik ve Alan'),
          TopicModel(id: 'dgs_geo_3', courseId: 'geometri', name: 'Çokgenler, Dörtgenler ve Çember'),
          TopicModel(id: 'dgs_geo_4', courseId: 'geometri', name: 'Katı Cisimler ve Doğrunun Analitiği'),
        ];
      }
    }

    // Belirli bir ders için filtrele veya tüm ders konularını döndür
    if (courseId != null) {
      final list = all.where((t) => t.courseId == courseId).toList();
      return list.isNotEmpty ? list : [TopicModel(id: '${courseId}_genel', courseId: courseId, name: 'Genel Konu Tekrarı ve Soru Çözümü')];
    }
    return all;
  }

  /// Sınavdaki dersin ortalama soru ağırlığını (önem derecesini) döndürür
  static int getCourseQuestionWeight(String examName, String courseId) {
    // KPSS Soru Dağılımları (Toplam 120 Soru)
    if (examName.contains('KPSS') && !examName.contains('ÖABT')) {
      switch (courseId) {
        case 'turkce':
          return 30; // %25
        case 'matematik':
          return 27; // %22.5
        case 'tarih':
          return 27; // %22.5
        case 'cografya':
          return 18; // %15
        case 'vatandaslik':
          return 15; // %12.5 (Vatandaşlık 9 + Güncel 6)
        case 'geometri':
          return 3;  // SADECE 3 SORU! (%2.5) -> Haftada en fazla 1 blok olmalı!
        default:
          return 10;
      }
    }

    // YKS TYT Soru Dağılımları (120 Soru)
    if (examName.contains('TYT')) {
      switch (courseId) {
        case 'turkce':
          return 40;
        case 'matematik':
          return 30;
        case 'geometri':
          return 10;
        case 'fizik':
          return 7;
        case 'kimya':
          return 7;
        case 'biyoloji':
          return 6;
        case 'tarih':
          return 5;
        case 'cografya':
          return 5;
        case 'felsefe':
          return 5;
        case 'din_kulturu':
          return 5;
        default:
          return 10;
      }
    }

    // LGS Soru Dağılımları (90 Soru)
    if (examName.contains('LGS')) {
      switch (courseId) {
        case 'turkce':
        case 'matematik':
        case 'fen_bilimleri':
          return 20;
        case 'inkilap':
        case 'din_kulturu':
        case 'ingilizce':
          return 10;
        default:
          return 10;
      }
    }

    // DGS / ALES Soru Dağılımları (100 Soru)
    if (examName.contains('DGS') || examName.contains('ALES')) {
      switch (courseId) {
        case 'sozel_mantik':
        case 'turkce':
          return 50;
        case 'sayisal_mantik':
        case 'matematik':
          return 43;
        case 'geometri':
          return 7;
        default:
          return 20;
      }
    }

    // AGS Soru Dağılımları (80 Soru: %37,5 Eğitim, %18,75 Sözel, %18,75 Sayısal, %10 Mevzuat, %7,5 Tarih, %7,5 Coğrafya)
    if (examName.contains('AGS')) {
      switch (courseId) {
        case 'ags_egitim_temelleri':
          return 30; // 30 Soru (%37,5)
        case 'sozel_mantik':
        case 'turkce':
          return 15; // 15 Soru (%18,75)
        case 'sayisal_mantik':
        case 'matematik':
          return 15; // 15 Soru (%18,75)
        case 'ags_mevzuat':
          return 8;  // 8 Soru (%10)
        case 'tarih':
          return 6;  // 6 Soru Tarih (%7,5)
        case 'cografya':
          return 6;  // 6 Soru Coğrafya (%7,5)
        default:
          return 10;
      }
    }

    return 20; // Varsayılan ağırlık
  }

  /// Sınav türüne ve derse göre resmi maksimum soru sınırını döndürür
  static int getMaxQuestionsForCourse(String examName, String courseId) {
    final lowerExam = examName.toLowerCase();
    final lowerCourse = courseId.toLowerCase();

    // 1. EKPSS (60 Soru: GY 30 + GK 30) - KPSS'den önce kontrol edilir
    if (lowerExam.contains('ekpss')) {
      if (lowerCourse.contains('turk')) return 15;
      if (lowerCourse.contains('mat')) return 15;
      if (lowerCourse.contains('tar')) return 10;
      if (lowerCourse.contains('cog')) return 5;
      if (lowerCourse.contains('vat') || lowerCourse.contains('gunc')) return 15;
      return 15;
    }

    // 2. KPSS Eğitim Bilimleri (80 Soru)
    if (lowerExam.contains('kpss') && (lowerExam.contains('eğitim') || lowerExam.contains('egitim'))) {
      if (lowerCourse.contains('oyt')) return 21;
      if (lowerCourse.contains('olcme')) return 12;
      if (lowerCourse.contains('psikoloji') || lowerCourse.contains('gelisim') || lowerCourse.contains('ogrenme')) return 22;
      if (lowerCourse.contains('rehberlik')) return 11;
      if (lowerCourse.contains('program') || lowerCourse.contains('sinif') || lowerCourse.contains('materyal')) return 14;
      return 16;
    }

    // 3. KPSS ÖABT (75 Soru)
    if (lowerExam.contains('öabt') || lowerExam.contains('oabt')) {
      return 75;
    }

    // 4. KPSS (GY-GK: 120 Soru: GY 60 + GK 60)
    if (lowerExam.contains('kpss')) {
      if (lowerCourse.contains('turk')) return 30;
      if (lowerCourse.contains('mat')) return 27; // 27 Soru Matematik
      if (lowerCourse.contains('geo')) return 3;  // 3 Soru Geometri (27+3 = 30; Toplam GY = 60)
      if (lowerCourse.contains('tar')) return 27; // 27 Soru Tarih
      if (lowerCourse.contains('cog')) return 18; // 18 Soru Coğrafya
      if (lowerCourse.contains('vat') || lowerCourse.contains('gunc')) return 15; // 15 Soru Vatandaşlık & Güncel (Toplam GK = 60)
      if (lowerCourse.contains('hukuk')) return 30;
      if (lowerCourse.contains('iktisat')) return 30;
      if (lowerCourse.contains('maliye')) return 30;
      if (lowerCourse.contains('muhasebe')) return 30;
      if (lowerCourse.contains('kamu')) return 30;
      return 30;
    }

    // 5. YKS - TYT / MSÜ (120 Soru)
    if (lowerExam.contains('tyt') || lowerExam.contains('msü') || (lowerExam.contains('yks') && !lowerExam.contains('ayt'))) {
      if (lowerCourse.contains('turk')) return 40;
      if (lowerCourse.contains('mat')) return 30;
      if (lowerCourse.contains('geo')) return 10;
      if (lowerCourse.contains('fiz')) return 7;
      if (lowerCourse.contains('kim')) return 7;
      if (lowerCourse.contains('biyo')) return 6;
      if (lowerCourse.contains('tar')) return 5;
      if (lowerCourse.contains('cog')) return 5;
      if (lowerCourse.contains('fel')) return 5;
      if (lowerCourse.contains('din')) return 5;
      return 40;
    }

    // 6. YKS - AYT (80 Soru)
    if (lowerExam.contains('ayt')) {
      if (lowerExam.contains('sözel') || lowerExam.contains('sozel')) {
        if (lowerCourse.contains('edebiyat')) return 24;
        if (lowerCourse.contains('tar')) return 21;
        if (lowerCourse.contains('cog')) return 17;
        if (lowerCourse.contains('fel') || lowerCourse.contains('din')) return 18;
        return 20;
      }
      if (lowerExam.contains('eşit') || lowerExam.contains('esit') || lowerExam.contains('ea')) {
        if (lowerCourse.contains('mat')) return 30;
        if (lowerCourse.contains('geo')) return 10;
        if (lowerCourse.contains('edebiyat')) return 24;
        if (lowerCourse.contains('tar')) return 10;
        if (lowerCourse.contains('cog')) return 6;
        return 20;
      }
      // AYT Sayısal (30 Mat + 10 Geo + 14 Fiz + 13 Kim + 13 Biyo = 80 Soru)
      if (lowerCourse.contains('mat')) return 30;
      if (lowerCourse.contains('geo')) return 10;
      if (lowerCourse.contains('fiz')) return 14;
      if (lowerCourse.contains('kim')) return 13;
      if (lowerCourse.contains('biyo')) return 13;
      return 20;
    }

    // 7. LGS (90 Soru: Sözel 50 + Sayısal 40)
    if (lowerExam.contains('lgs')) {
      if (lowerCourse.contains('turk')) return 20;
      if (lowerCourse.contains('mat')) return 20;
      if (lowerCourse.contains('fen')) return 20;
      if (lowerCourse.contains('ink') || lowerCourse.contains('tar')) return 10;
      if (lowerCourse.contains('din')) return 10;
      if (lowerCourse.contains('ing') || lowerCourse.contains('dil')) return 10;
      return 20;
    }

    // 8. DGS & ALES (100 Soru: Sözel 50 + Sayısal 50)
    if (lowerExam.contains('dgs') || lowerExam.contains('ales')) {
      if (lowerCourse.contains('turk') || lowerCourse.contains('sozel')) return 50;
      if (lowerCourse.contains('mat') || lowerCourse.contains('sayisal')) return 43; // 43 mat + 7 geo = 50 Sayısal
      if (lowerCourse.contains('geo')) return 7;
      return 50;
    }

    // 9. AGS (Akademi Giriş Sınavı: 80 Soru: %37,5 Eğitim, %18,75 Sözel, %18,75 Sayısal, %10 Mevzuat, %7,5 Tarih, %7,5 Coğrafya)
    if (lowerExam.contains('ags')) {
      if (lowerCourse.contains('sozel') || lowerCourse.contains('turk')) return 15;
      if (lowerCourse.contains('sayisal') || lowerCourse.contains('mat')) return 15;
      if (lowerCourse.contains('tar')) return 6;  // 6 Soru Tarih (%7,5)
      if (lowerCourse.contains('cog')) return 6;  // 6 Soru Coğrafya (%7,5)
      if (lowerCourse.contains('egitim')) return 30; // 30 Soru Eğitimin Temelleri (%37,5)
      if (lowerCourse.contains('mevzuat')) return 8;  // 8 Soru Mevzuat (%10)
      return 15;
    }

    // 10. HMGS (Hukuk Mesleklerine Giriş Sınavı: 120 Soru)
    if (lowerExam.contains('hmgs')) {
      if (lowerCourse.contains('idare')) return 15;
      if (lowerCourse.contains('medeni')) return 15;
      if (lowerCourse.contains('ceza')) return 15;
      if (lowerCourse.contains('anayasa')) return 10;
      if (lowerCourse.contains('borclar')) return 10;
      if (lowerCourse.contains('hmk')) return 10;
      if (lowerCourse.contains('ticaret')) return 10;
      if (lowerCourse.contains('icra')) return 10;
      if (lowerCourse.contains('is_sosyal') || lowerCourse.contains('is_hukuku')) return 10;
      if (lowerCourse.contains('vergi')) return 10;
      if (lowerCourse.contains('avukatlik')) return 5;
      return 10;
    }

    // 11. Ehliyet (50 Soru)
    if (lowerExam.contains('ehliyet')) {
      if (lowerCourse.contains('trafik')) return 23;
      if (lowerCourse.contains('yardim')) return 12;
      if (lowerCourse.contains('motor') || lowerCourse.contains('arac')) return 9;
      if (lowerCourse.contains('adab')) return 6;
      return 25;
    }

    // 12. YDS / YÖKDİL / YDT (80 Soru)
    if (lowerExam.contains('yds') || lowerExam.contains('yökdil') || lowerExam.contains('ydt')) {
      return 80;
    }

    // 13. TUS (200 Soru) & DUS (120 Soru)
    if (lowerExam.contains('tus')) {
      if (lowerCourse.contains('temel')) return 100;
      if (lowerCourse.contains('klinik')) return 100;
      return 100;
    }
    if (lowerExam.contains('dus')) {
      if (lowerCourse.contains('temel')) return 40;
      if (lowerCourse.contains('klinik')) return 80;
      return 60;
    }

    return 40; // Varsayılan sınır
  }

  /// Sınav türüne göre toplam resmi soru sayısını döndürür
  static int getTotalQuestionsForExam(String examName) {
    final lower = examName.toLowerCase();
    if (lower.contains('ekpss')) return 60;
    if (lower.contains('kpss')) {
      if (lower.contains('eğitim') || lower.contains('egitim')) return 80;
      if (lower.contains('öabt') || lower.contains('oabt')) return 75;
      return 120; // GY-GK
    }
    if (lower.contains('tyt') || lower.contains('msü')) return 120;
    if (lower.contains('ayt')) return 80; // Sayısal, Sözel, EA
    if (lower.contains('yks')) {
      if (lower.contains('dil') || lower.contains('ydt')) return 80;
      if (lower.contains('sayısal') || lower.contains('sayisal') ||
          lower.contains('eşit') || lower.contains('esit') ||
          lower.contains('sözel') || lower.contains('sozel')) {
        return 80;
      }
      return 120; // TYT default
    }
    if (lower.contains('lgs')) return 90;
    if (lower.contains('dgs') || lower.contains('ales')) return 100;
    if (lower.contains('ags')) return 80;
    if (lower.contains('hmgs')) return 120;
    if (lower.contains('ehliyet')) return 50;
    if (lower.contains('yds') || lower.contains('yökdil') || lower.contains('ydt')) return 80;
    if (lower.contains('tus')) return 200;
    if (lower.contains('dus')) return 120;
    return 100;
  }

  static const List<String> motivationQuotes = [
    "Bugün döktüğün her damla alın teri, yarın başarı olarak karşına çıkacak.",
    "Zorluklar, başarının değerini artıran süslerdir. Asla pes etme!",
    "Başarı, her gün tekrarlanan küçük çabaların toplamıdır.",
    "Büyük hayaller kur ve başarmaya cesaret et.",
    "Gelecek, bugünden ona hazırlananlara aittir.",
    "Şampiyonlar antrenman salonlarından değil, içlerindeki tutkudan çıkar.",
    "Yorulduğunda dinlenmeyi öğren, bırakmayı değil.",
    "Bugün yapacağın bir soru fazlası, yarın binlerce kişinin önüne geçmeni sağlayabilir.",
    "Kendine inan! Sen düşündüğünden çok daha güçlüsün.",
    "Hedefe giden yol disiplinden geçer, motivasyon gelir geçer ama disiplin kazandırır.",
  ];
}
