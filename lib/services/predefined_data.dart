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
    ];
  }

  /// Geriye uyumluluk için varsayılan dersler
  static List<CourseModel> getDefaultCourses() {
    return getAllAvailableCourses();
  }

  /// Seçilen sınava göre dersleri kısıtlayıp döndürür
  static List<CourseModel> getCoursesForExam(String examName) {
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
      // KPSS Genel Yetenek - Genel Kültür (Kimya, Fizik, Biyoloji ASLA YOK!)
      return [
        courseTurkce,
        courseMatematik,
        courseGeometri,
        courseTarih,
        courseCografya,
        courseVatandaslik,
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

    if (examName.contains('Sayısal')) {
      return [
        courseMatematik,
        courseGeometri,
        courseFizik,
        courseKimya,
        courseBiyoloji,
        courseTurkce,
        courseTarih,
        courseCografya,
        courseFelsefe,
      ];
    }

    if (examName.contains('Eşit Ağırlık')) {
      return [
        courseTurkce,
        courseEdebiyat,
        courseMatematik,
        courseGeometri,
        courseTarih,
        courseCografya,
        courseFelsefe,
      ];
    }

    if (examName.contains('Sözel')) {
      return [
        courseTurkce,
        courseEdebiyat,
        courseTarih,
        courseCografya,
        courseFelsefe,
        courseDinKulturu,
        courseMatematik,
      ];
    }

    if (examName.contains('Dil')) {
      return [
        courseIngilizce,
        courseTurkce,
        courseMatematik,
        courseTarih,
        courseCografya,
        courseFelsefe,
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
