import '../models/target_department_model.dart';

class TargetDepartmentsData {
  static final List<TargetDepartmentModel> allDepartments = [
    // --- YKS SAYISAL BÖLÜMLERİ ---
    const TargetDepartmentModel(
      id: 'yks_say_tip',
      name: 'Tıp Fakültesi',
      examType: 'YKS (Sayısal)',
      baseScore: 505.0,
      targetNet: 106.0,
      recommendedHours: 6,
      category: 'Sağlık & Tıp',
      description: 'Devlet tıp fakülteleri için yüksek matematik ve fen başarısı gerektirir (İlk 20.000 hedefi).',
      targetCourseNets: {'matematik': 36.0, 'fizik': 12.0, 'kimya': 12.0, 'biyoloji': 12.0, 'turkce': 34.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_say_ceng',
      name: 'Bilgisayar Mühendisliği (ODTÜ / İTÜ / Boğaziçi)',
      examType: 'YKS (Sayısal)',
      baseScore: 515.0,
      targetNet: 108.0,
      recommendedHours: 6,
      category: 'Mühendislik',
      description: 'Türkiye geneli ilk 5.000 hedefi, fulle yakın matematik ve ileri fizik-kimya seviyesi.',
      targetCourseNets: {'matematik': 38.0, 'fizik': 13.0, 'kimya': 12.0, 'biyoloji': 11.0, 'turkce': 34.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_say_ceng_devlet',
      name: 'Bilgisayar / Yazılım Mühendisliği (Devlet)',
      examType: 'YKS (Sayısal)',
      baseScore: 465.0,
      targetNet: 92.0,
      recommendedHours: 5,
      category: 'Mühendislik',
      description: 'Köklü devlet üniversiteleri için 50.000-80.000 başarı sıralaması hedeflenir.',
      targetCourseNets: {'matematik': 32.0, 'fizik': 10.0, 'kimya': 10.0, 'biyoloji': 9.0, 'turkce': 31.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_say_dis',
      name: 'Diş Hekimliği',
      examType: 'YKS (Sayısal)',
      baseScore: 475.0,
      targetNet: 95.0,
      recommendedHours: 5,
      category: 'Sağlık & Tıp',
      description: 'Devlet diş hekimliği fakülteleri için ilk 40.000 dilimi hedeflenir.',
      targetCourseNets: {'matematik': 33.0, 'fizik': 11.0, 'kimya': 11.0, 'biyoloji': 11.0, 'turkce': 29.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_say_ee',
      name: 'Elektrik-Elektronik Mühendisliği',
      examType: 'YKS (Sayısal)',
      baseScore: 470.0,
      targetNet: 94.0,
      recommendedHours: 5,
      category: 'Mühendislik',
      description: 'Matematik ve Fizik ağırlıklı yoğun çalışma temposu gerektirir.',
      targetCourseNets: {'matematik': 34.0, 'fizik': 12.0, 'kimya': 9.0, 'biyoloji': 9.0, 'turkce': 30.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_say_eczacilik',
      name: 'Eczacılık Fakültesi',
      examType: 'YKS (Sayısal)',
      baseScore: 445.0,
      targetNet: 86.0,
      recommendedHours: 4,
      category: 'Sağlık & Tıp',
      description: 'Kimya ve biyoloji derslerinde yüksek net başarısı hedeflenir (İlk 60.000).',
      targetCourseNets: {'matematik': 29.0, 'kimya': 12.0, 'biyoloji': 11.0, 'fizik': 8.0, 'turkce': 26.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_say_makine',
      name: 'Makine / Endüstri Mühendisliği',
      examType: 'YKS (Sayısal)',
      baseScore: 440.0,
      targetNet: 85.0,
      recommendedHours: 4,
      category: 'Mühendislik',
      description: 'Analitik düşünme, geometri ve fizik temeli yüksek bölümler.',
      targetCourseNets: {'matematik': 30.0, 'fizik': 10.0, 'kimya': 9.0, 'biyoloji': 8.0, 'turkce': 28.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_say_mimarlik',
      name: 'Mimarlık',
      examType: 'YKS (Sayısal)',
      baseScore: 410.0,
      targetNet: 75.0,
      recommendedHours: 4,
      category: 'Tasarım & Mimarlık',
      description: 'Geometri ve matematik ağırlıklı çalışma planı gerektirir.',
      targetCourseNets: {'matematik': 26.0, 'geometri': 9.0, 'fizik': 8.0, 'turkce': 28.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_say_ilkogretim_mat',
      name: 'İlköğretim Matematik Öğretmenliği',
      examType: 'YKS (Sayısal)',
      baseScore: 420.0,
      targetNet: 78.0,
      recommendedHours: 4,
      category: 'Eğitim',
      description: 'Temel matematik ve Türkçe netlerinin dengeli yüksekliği hedeflenir.',
      targetCourseNets: {'matematik': 30.0, 'turkce': 32.0, 'fen': 16.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_say_hemsirelik',
      name: 'Hemşirelik / Fizyoterapi (FTR)',
      examType: 'YKS (Sayısal)',
      baseScore: 385.0,
      targetNet: 68.0,
      recommendedHours: 3,
      category: 'Sağlık & Tıp',
      description: 'Temel sayısal netleri ile istikrarlı bir çalışma programı yeterlidir.',
      targetCourseNets: {'matematik': 22.0, 'biyoloji': 9.0, 'kimya': 8.0, 'turkce': 29.0},
    ),

    // --- YKS EŞİT AĞIRLIK BÖLÜMLERİ ---
    const TargetDepartmentModel(
      id: 'yks_ea_hukuk_top',
      name: 'Hukuk Fakültesi (Ankara / İstanbul / GSÜ)',
      examType: 'YKS (Eşit Ağırlık)',
      baseScore: 450.0,
      targetNet: 94.0,
      recommendedHours: 6,
      category: 'Hukuk & Adalet',
      description: 'Türkiye geneli ilk 10.000 hedefi, yüksek matematik ve edebiyat/tarih başarısı.',
      targetCourseNets: {'turkce': 35.0, 'edebiyat': 22.0, 'matematik': 32.0, 'tarih': 8.0, 'cografya': 5.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_ea_hukuk_devlet',
      name: 'Hukuk Fakültesi (Devlet)',
      examType: 'YKS (Eşit Ağırlık)',
      baseScore: 420.0,
      targetNet: 84.0,
      recommendedHours: 5,
      category: 'Hukuk & Adalet',
      description: 'Devlet üniversiteleri hukuk fakülteleri için ilk 40.000 dilimi hedeflenir.',
      targetCourseNets: {'turkce': 32.0, 'edebiyat': 20.0, 'matematik': 26.0, 'tarih': 7.0, 'cografya': 4.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_ea_psikoloji',
      name: 'Psikoloji (Devlet)',
      examType: 'YKS (Eşit Ağırlık)',
      baseScore: 415.0,
      targetNet: 82.0,
      recommendedHours: 5,
      category: 'Sosyal Bilimler',
      description: 'Edebiyat ve matematik netlerinde dengeli başarı gerektirir.',
      targetCourseNets: {'turkce': 33.0, 'edebiyat': 19.0, 'matematik': 24.0, 'tarih': 7.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_ea_ybs',
      name: 'Yönetim Bilişim Sistemleri (YBS)',
      examType: 'YKS (Eşit Ağırlık)',
      baseScore: 430.0,
      targetNet: 88.0,
      recommendedHours: 5,
      category: 'Bilişim & Yönetim',
      description: 'Son yılların en popüler EA bölümü, matematik neti belirleyicidir.',
      targetCourseNets: {'matematik': 30.0, 'turkce': 33.0, 'edebiyat': 18.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_ea_sinif_ogretmenligi',
      name: 'Sınıf Öğretmenliği',
      examType: 'YKS (Eşit Ağırlık)',
      baseScore: 390.0,
      targetNet: 72.0,
      recommendedHours: 4,
      category: 'Eğitim',
      description: 'Türkçe, Edebiyat ve temel matematik netleri ön plandadır.',
      targetCourseNets: {'turkce': 32.0, 'edebiyat': 18.0, 'matematik': 18.0, 'tarih': 6.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_ea_pdr',
      name: 'Rehberlik ve Psikolojik Danışmanlık (PDR)',
      examType: 'YKS (Eşit Ağırlık)',
      baseScore: 385.0,
      targetNet: 70.0,
      recommendedHours: 4,
      category: 'Eğitim',
      description: 'Düzenli paragraf ve matematik soru pratiği hedeflenir.',
      targetCourseNets: {'turkce': 31.0, 'edebiyat': 17.0, 'matematik': 17.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_ea_isletme_iktisat',
      name: 'İşletme / İktisat (İngilizce)',
      examType: 'YKS (Eşit Ağırlık)',
      baseScore: 435.0,
      targetNet: 88.0,
      recommendedHours: 5,
      category: 'İktisadi Bilimler',
      description: 'Boğaziçi, ODTÜ ve İTÜ gibi üniversiteler için yüksek matematik başarısı.',
      targetCourseNets: {'matematik': 32.0, 'turkce': 34.0, 'edebiyat': 18.0},
    ),

    // --- YKS SÖZEL BÖLÜMLERİ ---
    const TargetDepartmentModel(
      id: 'yks_soz_ozel_egitim',
      name: 'Özel Eğitim Öğretmenliği',
      examType: 'YKS (Sözel)',
      baseScore: 425.0,
      targetNet: 88.0,
      recommendedHours: 5,
      category: 'Eğitim',
      description: 'Sözel puan türünün en yüksek taban puanlı ve ataması güçlü bölümü.',
      targetCourseNets: {'turkce': 36.0, 'edebiyat': 22.0, 'tarih': 16.0, 'cografya': 10.0, 'felsefe': 10.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_soz_turkce_ogr',
      name: 'Türkçe Öğretmenliği',
      examType: 'YKS (Sözel)',
      baseScore: 410.0,
      targetNet: 82.0,
      recommendedHours: 4,
      category: 'Eğitim',
      description: 'Edebiyat ve dil bilgisi odaklı yüksek net hedefi gerektirir.',
      targetCourseNets: {'turkce': 35.0, 'edebiyat': 21.0, 'tarih': 14.0, 'cografya': 8.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_soz_tarih_cografya',
      name: 'Tarih / Coğrafya Öğretmenliği',
      examType: 'YKS (Sözel)',
      baseScore: 385.0,
      targetNet: 72.0,
      recommendedHours: 4,
      category: 'Eğitim',
      description: 'Sosyal-1 ve Sosyal-2 testlerinde derin konu hakimiyeti.',
      targetCourseNets: {'turkce': 32.0, 'edebiyat': 18.0, 'tarih': 15.0, 'cografya': 9.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_soz_ilahiyat',
      name: 'İlahiyat / İslami İlimler',
      examType: 'YKS (Sözel)',
      baseScore: 375.0,
      targetNet: 68.0,
      recommendedHours: 3,
      category: 'Sosyal Bilimler',
      description: 'Temel Türkçe ve sosyal bilimler netleriyle rahatlıkla kazanılabilir.',
      targetCourseNets: {'turkce': 30.0, 'edebiyat': 17.0, 'tarih': 12.0, 'felsefe': 8.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_soz_rts',
      name: 'Radyo, Sinema, TV & İletişim',
      examType: 'YKS (Sözel)',
      baseScore: 365.0,
      targetNet: 65.0,
      recommendedHours: 3,
      category: 'İletişim & Medya',
      description: 'Güncel olaylar ve sözel paragraf pratiği ağırlıklı program.',
      targetCourseNets: {'turkce': 30.0, 'edebiyat': 16.0, 'tarih': 11.0},
    ),

    // --- YKS DİL BÖLÜMLERİ ---
    const TargetDepartmentModel(
      id: 'yks_dil_ing_ogr',
      name: 'İngilizce Öğretmenliği (Devlet)',
      examType: 'YKS (Dil)',
      baseScore: 445.0,
      targetNet: 92.0,
      recommendedHours: 5,
      category: 'Dil & Eğitim',
      description: 'TYT Türkçe-Matematik ve YDT İngilizce testinde 75+ net hedeflenir.',
      targetCourseNets: {'turkce': 34.0, 'matematik': 20.0, 'ingilizce': 75.0},
    ),
    const TargetDepartmentModel(
      id: 'yks_dil_mutercim',
      name: 'Mütercim ve Tercümanlık',
      examType: 'YKS (Dil)',
      baseScore: 435.0,
      targetNet: 88.0,
      recommendedHours: 4,
      category: 'Dil & Çeviri',
      description: 'YDT testinde yüksek kelime bilgisi ve okuma-anlama kabiliyeti.',
      targetCourseNets: {'turkce': 33.0, 'matematik': 18.0, 'ingilizce': 73.0},
    ),

    // --- LGS (LİSE GİRİŞ SINAVI) ---
    const TargetDepartmentModel(
      id: 'lgs_galatasaray_kabatas',
      name: 'Galatasaray / Kabataş / İstanbul Erkek Lisesi (%0.1 Dilim)',
      examType: 'LGS (Lise Giriş)',
      baseScore: 495.0,
      targetNet: 88.5,
      recommendedHours: 5,
      category: 'Nitelikli Liseler',
      description: '90 soruda maksimum 1-2 yanlış toleransı olan Türkiye zirvesi hedefi.',
      targetCourseNets: {'turkce': 20.0, 'matematik': 19.0, 'fen': 20.0, 'inkilap': 10.0, 'din': 10.0, 'ingilizce': 10.0},
    ),
    const TargetDepartmentModel(
      id: 'lgs_fen_lisesi',
      name: 'Merkezi Fen Liseleri (%1-2 Dilim)',
      examType: 'LGS (Lise Giriş)',
      baseScore: 470.0,
      targetNet: 82.0,
      recommendedHours: 4,
      category: 'Fen Liseleri',
      description: 'Yeni nesil matematik ve fen bilimleri sorularında hız ve muhakeme.',
      targetCourseNets: {'turkce': 19.0, 'matematik': 17.0, 'fen': 19.0, 'inkilap': 9.0, 'din': 9.0, 'ingilizce': 9.0},
    ),
    const TargetDepartmentModel(
      id: 'lgs_anadolu_lisesi',
      name: 'Nitelikli Anadolu Liseleri (%3-7 Dilim)',
      examType: 'LGS (Lise Giriş)',
      baseScore: 440.0,
      targetNet: 74.0,
      recommendedHours: 3,
      category: 'Anadolu Liseleri',
      description: 'Dengeli konu tekrarı ve günlük düzenli soru çözümü gerektirir.',
      targetCourseNets: {'turkce': 18.0, 'matematik': 14.0, 'fen': 17.0, 'inkilap': 9.0, 'din': 9.0, 'ingilizce': 8.0},
    ),

    // --- KPSS GENEL YETENEK & GENEL KÜLTÜR ---
    const TargetDepartmentModel(
      id: 'kpss_90_ustu',
      name: 'KPSS B Grubu 90+ Puan (Merkezi Atama Garantisi)',
      examType: 'KPSS (Genel Yetenek - Kültür)',
      baseScore: 92.0,
      targetNet: 98.0,
      recommendedHours: 6,
      category: 'Devlet Memurluğu',
      description: 'DHMİ, Bakanlıklar, Kit Kadroları için 120 soruda 95+ net başarısı.',
      targetCourseNets: {'turkce': 27.0, 'matematik': 26.0, 'tarih': 24.0, 'cografya': 16.0, 'vatandaslik': 12.0},
    ),
    const TargetDepartmentModel(
      id: 'kpss_ogretmenlik_85',
      name: 'KPSS Öğretmenlik / Sağlık Ataması (82-88 Puan)',
      examType: 'KPSS (Genel Yetenek - Kültür)',
      baseScore: 84.0,
      targetNet: 86.0,
      recommendedHours: 5,
      category: 'Eğitim & Sağlık',
      description: 'Tarih, Coğrafya ve Vatandaşlık ezberlerinin tam oturması hedeflenir.',
      targetCourseNets: {'turkce': 26.0, 'matematik': 20.0, 'tarih': 21.0, 'cografya': 15.0, 'vatandaslik': 10.0},
    ),
    const TargetDepartmentModel(
      id: 'kpss_memurluk_75',
      name: 'KPSS Düz Memurluk / Zabıta / İnfaz Koruma (75-80 Puan)',
      examType: 'KPSS (Genel Yetenek - Kültür)',
      baseScore: 78.0,
      targetNet: 75.0,
      recommendedHours: 4,
      category: 'Devlet Memurluğu',
      description: 'Türkçe paragraf ve sözel derslerdeki netlerle rahatlıkla ulaşılabilir.',
      targetCourseNets: {'turkce': 24.0, 'matematik': 15.0, 'tarih': 18.0, 'cografya': 14.0, 'vatandaslik': 9.0},
    ),

    // --- KPSS ALAN BİLGİSİ (A GRUBU) ---
    const TargetDepartmentModel(
      id: 'kpss_a_mufettis',
      name: 'Müfettişlik & Uzman Yardımcılığı (A Grubu Kadrolar)',
      examType: 'KPSS (Alan Bilgisi)',
      baseScore: 88.0,
      targetNet: 92.0,
      recommendedHours: 6,
      category: 'Kariyer Meslekler',
      description: 'Hukuk, İktisat, Maliye ve Muhasebe alanlarında yüksek akademik bilgi.',
    ),
    const TargetDepartmentModel(
      id: 'kpss_a_kaymakamlik',
      name: 'Kaymakamlık & İdari Yargı Hakimliği',
      examType: 'KPSS (Alan Bilgisi)',
      baseScore: 86.0,
      targetNet: 90.0,
      recommendedHours: 6,
      category: 'Kariyer Meslekler',
      description: 'Anayasa, İdare ve Ceza Hukuku ile iktisadi konularda uzmanlaşma.',
    ),

    // --- DGS (DİKEY GEÇİŞ SINAVI) ---
    const TargetDepartmentModel(
      id: 'dgs_muhendislik',
      name: 'DGS Bilgisayar / Yazılım Mühendisliği',
      examType: 'DGS (Dikey Geçiş)',
      baseScore: 310.0,
      targetNet: 78.0,
      recommendedHours: 5,
      category: 'Mühendislik',
      description: '100 soruda yüksek Sayısal mantık ve geometri neti gerektirir.',
    ),
    const TargetDepartmentModel(
      id: 'dgs_hukuk',
      name: 'DGS Hukuk Fakültesi',
      examType: 'DGS (Dikey Geçiş)',
      baseScore: 305.0,
      targetNet: 74.0,
      recommendedHours: 5,
      category: 'Hukuk',
      description: 'Türkçe ve Matematik netlerinin dengeli ve 35+ olması gerekir.',
    ),
    const TargetDepartmentModel(
      id: 'dgs_hemsirelik',
      name: 'DGS Hemşirelik & Sağlık Bilimleri',
      examType: 'DGS (Dikey Geçiş)',
      baseScore: 285.0,
      targetNet: 62.0,
      recommendedHours: 3,
      category: 'Sağlık',
      description: 'Düzenli konu tekrarı ve çıkmış soru çözümleriyle ulaşılabilir.',
    ),

    // --- ALES ---
    const TargetDepartmentModel(
      id: 'ales_sayisal_85',
      name: 'ALES Sayısal 85+ (Akademik Kadro & Doktora)',
      examType: 'ALES',
      baseScore: 88.0,
      targetNet: 82.0,
      recommendedHours: 4,
      category: 'Akademi',
      description: 'Sayısal 1-2 testlerinde hız ve süre yönetimi odaklı çalışma.',
    ),
    const TargetDepartmentModel(
      id: 'ales_ea_80',
      name: 'ALES Eşit Ağırlık 80+ (Yüksek Lisans)',
      examType: 'ALES',
      baseScore: 82.0,
      targetNet: 74.0,
      recommendedHours: 3,
      category: 'Akademi',
      description: 'Türkçe sözel mantık ve temel matematik sorularında hız kazanımı.',
    ),

    // --- TUS ---
    const TargetDepartmentModel(
      id: 'tus_klinik_derece',
      name: 'TUS Klinik Derece (Dermatoloji / Radyoloji / Göz)',
      examType: 'TUS',
      baseScore: 72.0,
      targetNet: 178.0,
      recommendedHours: 8,
      category: 'Uzmanlık',
      description: 'Temel ve Klinik Tıp Bilimlerinde yoğun soru kampı ve vaka çözümleri.',
    ),

    // --- GENEL SINAV HAZIRLIĞI ---
    const TargetDepartmentModel(
      id: 'genel_yuksek_derece',
      name: 'Yüksek Başarı & Derece Hedefi',
      examType: 'Genel Sınav Hazırlığı',
      baseScore: 90.0,
      targetNet: 88.0,
      recommendedHours: 5,
      category: 'Genel',
      description: 'Sınavın en üst %5 dilimine girmeyi amaçlayan disiplinli program.',
    ),
    const TargetDepartmentModel(
      id: 'genel_standart',
      name: 'Standart Başarı & Kazanma Hedefi',
      examType: 'Genel Sınav Hazırlığı',
      baseScore: 75.0,
      targetNet: 70.0,
      recommendedHours: 3,
      category: 'Genel',
      description: 'Konu eksiklerini kapatarak hedefe istikrarlı adımlarla ilerleme.',
    ),
  ];

  /// Belirli bir sınav türüne ait bölümleri döndürür
  static List<TargetDepartmentModel> getDepartmentsForExam(String examType) {
    final list = allDepartments.where((d) => d.examType == examType).toList();
    if (list.isNotEmpty) return list;

    // Kısmi eşleşme kontrolü (örn. KPSS lisans / GK-GY)
    final lowerExam = examType.toLowerCase();
    final partial = allDepartments.where((d) {
      final dExam = d.examType.toLowerCase();
      if (lowerExam.contains('kpss') && dExam.contains('kpss')) return true;
      if (lowerExam.contains('yks') && dExam.contains('yks')) return true;
      if (lowerExam.contains('lgs') && dExam.contains('lgs')) return true;
      return false;
    }).toList();

    return partial.isNotEmpty ? partial : allDepartments;
  }

  /// Varsayılan / İlk bölümü getir
  static TargetDepartmentModel getDefaultDepartmentForExam(String examType) {
    final list = getDepartmentsForExam(examType);
    return list.isNotEmpty ? list.first : allDepartments.first;
  }

  /// Bölüm adından arama veya eşleştirme
  static TargetDepartmentModel? findDepartmentByName(String name) {
    final clean = name.trim().toLowerCase();
    for (final d in allDepartments) {
      if (d.name.toLowerCase() == clean) return d;
    }
    return null;
  }
}
