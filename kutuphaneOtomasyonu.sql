DROP TABLE IF EXISTS odunc;
DROP TABLE IF EXISTS kitaplar;
DROP TABLE IF EXISTS uyeler;

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS uyeler(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	ad TEXT NOT NULL,
	yas INTEGER CHECK (yas>13),
	sehir TEXT DEFAULT 'Erzincan',
	kayit TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS kitaplar (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	ad TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS odunc (
	uye_id INTEGER,
	kitap_id INTEGER,
	gun INTEGER CHECK (gun BETWEEN 3 AND 45),
	PRIMARY KEY (uye_id, kitap_id),
	FOREIGN KEY (uye_id) REFERENCES uyeler(id) ON DELETE CASCADE,
	FOREIGN KEY (kitap_id) REFERENCES kitaplar(id)
);


INSERT INTO kitaplar (ad) VALUES
('Suç ve Ceza'),
('1984'),
('Simyacı'),
('Kürk Mantolu Madonna'),
('Sefiller');

/* 
(Tartışma): Bir kitap silinmeye çalışılırsa ne olur? kitap_id için neden ON DELETE CASCADE tercih edilmemiş olabilir?
- Cevap: Eğer silinmek istenen kitap herhangi bir üyede ödünç durumundaysa yabancı anahtar kısıtı (Foreign Key constraint failed) hatası verir ve silinmez. ON DELETE CASCADE tercih edilmemiştir çünkü bir kitap sistemden kaldırıldığında geçmişteki ödünç istatistiklerinin, logların veya raporların tamamen silinmesi / kaybolması istenmez. Üye silindiğinde ise kişisel verilerin korunması/temizliği için CASCADE mantıklıdır.
*/

INSERT INTO uyeler (ad, yas, sehir) VALUES
('Ahmet Yılmaz', 15, 'Ankara'),
('Ayşe Demir', 16, 'İstanbul'),
('Fatma Çelik', 17, 'İzmir'),
('Can Şahin', 15, 'Bursa'),
('Ali Koç', 14, 'Antalya'),
('Elif Arslan', 16, 'Trabzon'),
('İrem Öztürk', 17, 'Adana');

INSERT INTO uyeler (ad, yas) VALUES
('Mehmet Kaya', 14),
('Zeynep Aydın', 18),
('Mustafa Yıldız', 15);

/* 
Yaşı 10 olan bir üye eklemeyi deneyiniz. Hatayı açıklayınız:
INSERT INTO uyeler (ad, yas, sehir) VALUES ('Test Çocuk', 10, 'Ankara');
- Açıklama: yas INTEGER CHECK (yas > 13) kuralına aykırı olduğu için "CHECK constraint failed" hatası verir.

Olmayan bir uye_id (ör. 99) ile kayıt eklemeyi deneyiniz. Neden başarısız oldu?:
INSERT INTO odunc (uye_id, kitap_id, gun) VALUES (99, 1, 10);
- Açıklama: 'uyeler' tablosunda 99 id'li bir üye bulunmadığı için Yabancı Anahtar (Foreign Key) kısıtına takılır ve reddedilir.
*/

INSERT INTO odunc (uye_id, kitap_id, gun) VALUES
(1, 1, 15), (1, 2, 35),
(2, 2, 10), (2, 3, 20),
(3, 3, 40), (3, 4, 12),
(4, 4, 25), (4, 5, 30),
(5, 1, 14), (5, 3, 42),
(6, 2, 8),  (6, 4, 28),
(7, 3, 33), (7, 5, 18),
(8, 1, 19), (8, 4, 22),
(9, 2, 11), (9, 5, 36),
(10, 1, 29), (10, 3, 7);

-- JOIN İŞLEMLERİ

-- Üye adı, kitap adı ve gün sayısını tek tabloda gösteren sorgu:
SELECT u.ad AS uye_adi, k.ad AS kitap_adi, o.gun
FROM odunc o
JOIN uyeler u ON u.id = o.uye_id
JOIN kitaplar k ON k.id = o.kitap_id;

-- Aynı sorguya 30 günden uzun tutulan kitapları getirecek koşul eklenmiş hali:
SELECT u.ad AS uye_adi, k.ad AS kitap_adi, o.gun
FROM odunc o
JOIN uyeler u ON u.id = o.uye_id
JOIN kitaplar k ON k.id = o.kitap_id
WHERE o.gun > 30;

-- Sadece Erzincan'daki üyelerin ödünç aldığı kitapları listeleyiniz:
SELECT u.ad AS uye_adi, k.ad AS kitap_adi, o.gun, u.sehir
FROM odunc o
JOIN uyeler u ON u.id = o.uye_id
JOIN kitaplar k ON k.id = o.kitap_id
WHERE u.sehir = 'Erzincan';

-- (İleri) Hiç kitap almamış üyeleri de listede göstermek için hangi JOIN türü gerekir?
SELECT u.ad AS uye_adi, k.ad AS kitap_adi, o.gun
FROM uyeler u
LEFT JOIN odunc o ON u.id = o.uye_id
LEFT JOIN kitaplar k ON k.id = o.kitap_id;

-- GRUPLAMA VE TOPLAMA FONKSİYONLARI

-- Her üyenin ortalama tutma süresini, aldığı kitap sayısını ve en uzun tutma süresini hesaplayınız:
SELECT uye_id, AVG(gun) AS ortalama_gun, COUNT(*) AS kitap_sayisi, MAX(gun) AS en_uzun_gun
FROM odunc
GROUP BY uye_id;

-- Bu listeyi ortalaması 20 günün üzerinde olan üyelerle sınırlandırınız (WHERE yerine HAVING açıklaması):
/* 
- Açıklama: WHERE satır tabanlı filtreleme yapar; ancak AVG(gun) gibi gruplama/toplama fonksiyonları sonucunda 
oluşan türetilmiş değerler üzerinde filtreleme yapabilmek için HAVING kullanılır.
*/
SELECT uye_id, AVG(gun) AS ortalama_gun, COUNT(*) AS kitap_sayisi, MAX(gun) AS en_uzun_gun
FROM odunc
GROUP BY uye_id
HAVING AVG(gun) > 20;

-- Her kitabın kaç kez ödünç alındığını kitap adıyla gösteriniz:
SELECT k.ad AS kitap_adi, COUNT(o.uye_id) AS odunc_sayisi
FROM kitaplar k
LEFT JOIN odunc o ON k.id = o.kitap_id
GROUP BY k.id, k.ad;

-- Hangi şehirden kaç üye olduğunu çoktan aza sıralayınız:
SELECT sehir, COUNT(*) AS uye_sayisi
FROM uyeler
GROUP BY sehir
ORDER BY uye_sayisi DESC;


-- ALT SORGU

-- En az bir kitabı 30 günden uzun tutmuş üyelerin adlarını alt sorguyla listeleyiniz:
SELECT ad 
FROM uyeler 
WHERE id IN (SELECT uye_id FROM odunc WHERE gun > 30);

-- Hiç ödünç alınmamış kitapları NOT IN ile bulunuz:
SELECT ad 
FROM kitaplar 
WHERE id NOT IN (SELECT kitap_id FROM odunc);

-- Genel ortalamanın üzerinde süre tutulan tüm kayıtları listeleyiniz:
SELECT * 
FROM odunc 
WHERE gun > (SELECT AVG(gun) FROM odunc);



-- CASE

-- Her ödünç kaydı için durum üretiniz:
SELECT uye_id, kitap_id, gun,
	CASE 
		WHEN gun > 30 THEN 'Gecikmiş' 
		WHEN gun >= 15 THEN 'Uyarı' 
		ELSE 'Normal' 
	END AS durum
FROM odunc;

-- Üyeleri yaşına göre 'Genç' (≤18) veya 'Yetişkin' olarak etiketleyiniz:
SELECT ad, yas,
	CASE 
		WHEN yas <= 18 THEN 'Genç' 
		ELSE 'Yetişkin' 
	END AS yas_grubu
FROM uyeler;

-- (İleri) Her durumdan kaç kayıt olduğunu sayınız (CASE + GROUP BY):
SELECT 
	CASE 
		WHEN gun > 30 THEN 'Gecikmiş' 
		WHEN gun >= 15 THEN 'Uyarı' 
		ELSE 'Normal' 
	END AS durum,
	COUNT(*) AS kayit_sayisi
FROM odunc
GROUP BY durum;

-- INDEX

CREATE INDEX idx_uyeler_ad ON uyeler(ad);

ALTER TABLE uyeler ADD COLUMN eposta TEXT;

UPDATE uyeler SET eposta = 'test@ornek.com' WHERE id = 1;

CREATE UNIQUE INDEX idx_uyeler_eposta ON uyeler(eposta);

/* 
İki üyeye aynı e-postayı vermeyi deneyiniz. Sonucu açıklayınız:
UPDATE uyeler SET eposta = 'test@ornek.com' WHERE id = 2;
- Açıklama: eposta sütununda UNIQUE index (veya kısıt) olduğu için, aynı e-posta adresi birden fazla 
üyeye verilemez. Veritabanı "UNIQUE constraint failed" hatası vererek işlemi engeller.
*/