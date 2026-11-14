import os
from PIL import Image, ImageDraw, ImageFont

out_dir = r'c:\Users\admin\Desktop\sınav çalışma takip apk sı\magaza_gorselleri'
os.makedirs(out_dir, exist_ok=True)

font_title_path = 'C:/Windows/Fonts/segoeuib.ttf'
font_regular_path = 'C:/Windows/Fonts/segoeui.ttf'

screens_data = [
    {
        'file': 'screenshot_1_soru_takip.png',
        'badge': 'AKILLI ASİSTAN',
        'title': 'Soru ve Süre Takibi',
        'desc': 'YKS, KPSS, LGS, ALES ve tüm sınavlar için günlük çalışma ve soru hedeflerini canlı tut.',
        'bg_top': '#4F46E5',
        'bg_bot': '#3730A3',
        'accent': '#818CF8',
        'card_title': 'Bugünkü Hedef',
        'card_val': '145 / 200 Soru',
        'sub1': '⏱️ 3 Saat 40 Dk Çalışma',
        'sub2': '🔥 14 Günlük Seri',
        'item1': '📐 Matematik: 65 Soru',
        'item2': '📖 Türkçe: 50 Soru',
        'item3': '⚡ Fizik: 30 Soru'
    },
    {
        'file': 'screenshot_2_deneme_analiz.png',
        'badge': 'GRAFİKSEL ANALİZ',
        'title': 'Deneme Sınavları & Netler',
        'desc': 'Doğru, yanlış ve net sayılarını kaydet; tahmini puanını ve başarı grafiğini anında gör.',
        'bg_top': '#0EA5E9',
        'bg_bot': '#0369A1',
        'accent': '#38BDF8',
        'card_title': 'Son Deneme Sonucu',
        'card_val': '92.5 Net • 428 Puan',
        'sub1': '📈 Son 5 Deneme Ortalaması: 88.4 Net',
        'sub2': '🎯 Hedef Bölüm: Tıp Fakültesi',
        'item1': '✔️ Türkçe: 34D 6Y (32.5 Net)',
        'item2': '✔️ Temel Mat: 32D 4Y (31.0 Net)',
        'item3': '✔️ Fen Bilimleri: 18D 2Y (17.5 Net)'
    },
    {
        'file': 'screenshot_3_akilli_program.png',
        'badge': 'KİŞİYE ÖZEL',
        'title': 'Akıllı Çalışma Programı',
        'desc': 'Haftalık ders programını otomatik oluştur, eksik konularına ve hedef puanına odaklan.',
        'bg_top': '#7C3AED',
        'bg_bot': '#5B21B6',
        'accent': '#A78BFA',
        'card_title': 'Pazartesi Çalışma Planı',
        'card_val': '4 Görev • 3.5 Saat',
        'sub1': '📅 Haftalık Toplam: 24 Saat Planlandı',
        'sub2': '✨ Otomatik Dinamik Dağılım',
        'item1': '09:00 - 10:30 • Paragraf & Anlam Bilgisi',
        'item2': '11:00 - 12:30 • Fonksiyonlar & Uygulamalar',
        'item3': '14:00 - 15:30 • Optik ve Dalgalar'
    },
    {
        'file': 'screenshot_4_koc_ve_rapor.png',
        'badge': 'KOÇLUK SİSTEMİ',
        'title': 'Öğretmen & PDF Karne',
        'desc': 'Koçunla eşleş, ödevlerini ve geri bildirimlerini anında al; detaylı PDF karne çıktısı al.',
        'bg_top': '#059669',
        'bg_bot': '#047857',
        'accent': '#34D399',
        'card_title': 'Öğretmen Bağlantısı',
        'card_val': 'Koç: Ali Hoca • Aktif',
        'sub1': '📝 2 Yeni Ödev Teslim Edildi',
        'sub2': '📑 Renkli PDF Başarı Raporu Hazır',
        'item1': '💬 Koç Notu: Bu hafta netlerindeki artış harika!',
        'item2': '📥 Haftalık Gelişim Raporunu İndir',
        'item3': '⭐ 3 Ay Boyunca Tüm Özellikler Ücretsiz'
    }
]

def hex_to_rgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

for sc in screens_data:
    w, h = 1080, 1920
    img = Image.new('RGB', (w, h), hex_to_rgb(sc['bg_top']))
    draw = ImageDraw.Draw(img)

    # Vertical gradient
    c1 = hex_to_rgb(sc['bg_top'])
    c2 = hex_to_rgb(sc['bg_bot'])
    for y in range(h):
        r = int(c1[0] + (c2[0] - c1[0]) * (y / h))
        g = int(c1[1] + (c2[1] - c1[1]) * (y / h))
        b = int(c1[2] + (c2[2] - c1[2]) * (y / h))
        draw.line([(0, y), (w, y)], fill=(r, g, b))

    font_badge = ImageFont.truetype(font_title_path, 32)
    font_h1 = ImageFont.truetype(font_title_path, 64)
    font_desc = ImageFont.truetype(font_regular_path, 36)
    font_card_head = ImageFont.truetype(font_title_path, 38)
    font_card_val = ImageFont.truetype(font_title_path, 54)
    font_card_sub = ImageFont.truetype(font_regular_path, 34)
    font_card_item = ImageFont.truetype(font_regular_path, 36)

    # Badge pill
    badge_text = sc['badge']
    bw = draw.textlength(badge_text, font=font_badge)
    pill_w = bw + 60
    pill_x = (w - pill_w) / 2
    pill_y = 100
    draw.rounded_rectangle([pill_x, pill_y, pill_x + pill_w, pill_y + 60], radius=30, fill=hex_to_rgb(sc['accent']))
    draw.text((pill_x + 30, pill_y + 12), badge_text, fill=(255, 255, 255), font=font_badge)

    # Title
    t = sc['title']
    tw = draw.textlength(t, font=font_h1)
    draw.text(((w - tw) / 2, 190), t, fill=(255, 255, 255), font=font_h1)

    # Description (wrap if needed)
    d = sc['desc']
    dw = draw.textlength(d, font=font_desc)
    if dw > 900:
        words = d.split(' ')
        mid = len(words) // 2
        line1 = ' '.join(words[:mid])
        line2 = ' '.join(words[mid:])
        l1w = draw.textlength(line1, font=font_desc)
        l2w = draw.textlength(line2, font=font_desc)
        draw.text(((w - l1w) / 2, 280), line1, fill=(220, 230, 250), font=font_desc)
        draw.text(((w - l2w) / 2, 330), line2, fill=(220, 230, 250), font=font_desc)
    else:
        draw.text(((w - dw) / 2, 290), d, fill=(220, 230, 250), font=font_desc)

    # Main mockup frame (representing mobile app)
    frame_x1, frame_y1 = 80, 430
    frame_x2, frame_y2 = 1000, 1820
    draw.rounded_rectangle([frame_x1, frame_y1, frame_x2, frame_y2], radius=48, fill=(248, 250, 252))

    # Inner mobile header bar
    draw.rounded_rectangle([frame_x1, frame_y1, frame_x2, frame_y1 + 140], radius=48, fill=(255, 255, 255))
    draw.rectangle([frame_x1, frame_y1 + 90, frame_x2, frame_y1 + 140], fill=(255, 255, 255))
    font_appbar = ImageFont.truetype(font_title_path, 42)
    draw.text((frame_x1 + 60, frame_y1 + 45), 'Sınav Koçum 🎓', fill=(15, 23, 42), font=font_appbar)

    # Hero Card inside mockup
    card1_y1 = frame_y1 + 180
    card1_y2 = card1_y1 + 280
    draw.rounded_rectangle([frame_x1 + 40, card1_y1, frame_x2 - 40, card1_y2], radius=32, fill=(255, 255, 255))
    draw.text((frame_x1 + 80, card1_y1 + 35), sc['card_title'], fill=(100, 116, 139), font=font_card_head)
    draw.text((frame_x1 + 80, card1_y1 + 95), sc['card_val'], fill=hex_to_rgb(sc['bg_top']), font=font_card_val)
    draw.text((frame_x1 + 80, card1_y1 + 185), sc['sub1'], fill=(30, 41, 59), font=font_card_sub)
    draw.text((frame_x1 + 80, card1_y1 + 230), sc['sub2'], fill=(16, 185, 129), font=font_card_sub)

    # 3 Content List Cards
    list_items = [sc['item1'], sc['item2'], sc['item3']]
    y_start = card1_y2 + 40
    for it in list_items:
        draw.rounded_rectangle([frame_x1 + 40, y_start, frame_x2 - 40, y_start + 140], radius=24, fill=(255, 255, 255))
        draw.text((frame_x1 + 80, y_start + 45), it, fill=(15, 23, 42), font=font_card_item)
        y_start += 170

    # Bottom action button
    btn_y1 = y_start + 50
    draw.rounded_rectangle([frame_x1 + 60, btn_y1, frame_x2 - 60, btn_y1 + 120], radius=28, fill=hex_to_rgb(sc['bg_top']))
    btn_font = ImageFont.truetype(font_title_path, 40)
    btn_text = 'Hemen Başla ve Netlerini Yükselt 🚀'
    btn_w = draw.textlength(btn_text, font=btn_font)
    draw.text(((w - btn_w) / 2, btn_y1 + 35), btn_text, fill=(255, 255, 255), font=btn_font)

    target_path = os.path.join(out_dir, sc['file'])
    img.save(target_path, 'PNG', quality=95)
    print('Generated:', sc['file'])

print('All 4 Google Play screenshots created successfully!')
