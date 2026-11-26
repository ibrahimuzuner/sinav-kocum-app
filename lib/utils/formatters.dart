class Formatters {
  static String formatSecondsToTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  static String formatMinutesToDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes dk';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours sa';
    }
    return '$hours sa $remainingMinutes dk';
  }

  static String formatDateTurkish(DateTime date) {
    const months = [
      '',
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  static String formatDayOfWeek(int day) {
    switch (day) {
      case 1:
        return 'Pazartesi';
      case 2:
        return 'Salı';
      case 3:
        return 'Çarşamba';
      case 4:
        return 'Perşembe';
      case 5:
        return 'Cuma';
      case 6:
        return 'Cumartesi';
      case 7:
        return 'Pazar';
      default:
        return '';
    }
  }

  static String formatDayOfWeekShort(int day) {
    switch (day) {
      case 1:
        return 'Pzt';
      case 2:
        return 'Sal';
      case 3:
        return 'Çar';
      case 4:
        return 'Per';
      case 5:
        return 'Cum';
      case 6:
        return 'Cmt';
      case 7:
        return 'Paz';
      default:
        return '';
    }
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Sınav kurallarına uygun net formatlama (Örn: YKS/KPSS 0.25, 0.5, 0.75 veya LGS 0.33, 0.67).
  /// Tek basamağa yuvarlanmasını (.toStringAsFixed(1)) önleyerek 0.75'in 0.8 veya -0.25'in -0.3
  /// şeklinde yanlış/LGS gibi görünmesini engeller.
  static String formatNet(double net) {
    if (net == 0 || net.abs() < 0.001) return '0';
    final s = net.toStringAsFixed(2);
    if (s.endsWith('.00')) {
      return s.substring(0, s.length - 3);
    }
    if (s.endsWith('0')) {
      return s.substring(0, s.length - 1);
    }
    return s;
  }
}
