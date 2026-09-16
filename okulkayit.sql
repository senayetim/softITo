CREATE TABLE bolum (
    id SERIAL PRIMARY KEY,
    ad VARCHAR(50) NOT NULL
);

CREATE TABLE ogrenci(
    identify SERIAL PRIMARY KEY,
    ad VARCHAR(50),
    ortalama NUMERIC(4,2)
);

CREATE TABLE ders(
    id SERIAL PRIMARY KEY,
    ad VARCHAR(100) NOT NULL,
    kredi INT,
    bolum_id INT REFERENCES bolum(id)
);

CREATE TABLE kayit(
    ogrenci_id INT REFERENCES ogrenci(identify) ON DELETE CASCADE,
    ders_id INT REFERENCES ders(id) ON DELETE CASCADE,
    notu INT,
    donem VARCHAR (25),
    PRIMARY KEY (ogrenci_id, ders_id)
);

-- 1. BÖLÜM VERİLERİ
INSERT INTO bolum (id, ad) VALUES
(1, 'Bilgisayar Mühendisliği'),
(2, 'Yönetim Bilişim Sistemleri'),
(3, 'Yazılım Mühendisliği'),
(4, 'Endüstri Mühendisliği');

-- 2. ÖĞRENCİ VERİLERİ
INSERT INTO ogrenci (ad, ortalama) VALUES
('Ahmet Yılmaz', 68.30),
('Mehmet Demir', 42.10),
('Ayşe Kaya', 12.50),
('Fatma Çelik', 88.90),
('Can Şahin', 50.00),
('Emre Yıldız', 31.80),
('Zeynep Aydın', 74.20),
('Burak Öztürk', 61.70);

-- 3. DERS VERİLERİ
INSERT INTO ders (ad, kredi, bolum_id) VALUES
('Veritabanı Yönetim Sistemleri', 4, 1),
('Algoritma ve Programlama', 3, 1),
('Veri Yapıları ve Algoritmalar', 5, 2),
('Nesne Yönelimli Programlama', 2, 3),
('Yazılım Mühendisliği Temelleri', 4, 4),
('İstatistik ve Olasılık', 3, 2);

-- 4. KAYIT (NOT VE DÖNEM) VERİLERİ
INSERT INTO kayit(ogrenci_id, ders_id, notu, donem) VALUES
(1, 1, 45, '2025-Güz'),
(1, 2, 70, '2025-Güz'),
(2, 3, 90, '2025-Güz'),
(3, 4, 15, '2026-Bahar'),
(4, 5, 88, '2026-Bahar'),
(5, 1, 50, '2025-Güz'),
(6, 5, 30, '2026-Bahar'),
(7, 6, 95, '2026-Bahar'),
(8, 2, 62, '2025-Güz');

--Hangi ogrenci hangi dersi almış notu kaç

SELECT o.ad AS ogrenci , d.ad AS Ders , k.notu
FROM kayit k
JOIN ogrenci o on k.ogrenci_id= o.identify
JOIN ders d ON k.ders_id = d.id
ORDER BY o.ad, k.notu DESC

--Bölüm bazında ders ortalaması
SELECT b.ad AS bolum, d.ad AS dersi, AVG (k.notu) AS ort
FROM kayit k
JOIN ders d ON k.ders_id = d.id
JOIN bolum b ON d.bolum_id = b.id
GROUP BY b.ad, d.ad
ORDER BY ort DESC;

--Her öğrencinin aldığı toplam kredi
SELECT o.ad AS ogrenci_adi, SUM(d.kredi) AS toplam_kredi
FROM ogrenci o
JOIN kayit k ON o.identify = k.ogrenci_id
JOIN ders d ON k.ders_id = d.id
GROUP BY o.identify, o.ad
ORDER BY toplam_kredi DESC;


--Subquery Not ortalama genel ortalamanın üstünde olan öğrenciler

SELECT ad, ortalama
FROM ogrenci
WHERE ortalama > (SELECT AVG(ortalama)from ogrenci)
ORDER BY ortalama DESC;

-- En çok ders alan öğrenciler
SELECT o.ad AS ogrenci_adi, COUNT(k.ders_id) AS aldigi_ders_sayisi
FROM ogrenci o
JOIN kayit k ON o.identify = k.ogrenci_id
GROUP BY o.identify, o.ad
ORDER BY aldigi_ders_sayisi DESC;

--harf  notu öğrenelim if else case end
SELECT o.ad,
	case 
		when avg(k.notu)>= 90 then 'aa'
		when avg(k.notu)>= 80 then 'bb'
		when avg(k.notu)>= 70 then 'cc'
		else 'f'
	end as harf_notu

from ogrenci o
join kayit k on o.identify = k.ogrenci_id
group by o.identify, o.ad;


--her ogrencinin derslerde kaçıncı geldiğini göster

SELECT o.ad, d.ad as ders, k.notu,
	row_number() over (PARTITION by k.ders_id order by k.notu desc) as siralama
FROM ogrenci o
JOIN kayit k ON o.identify = k.ogrenci_id
JOIN ders d ON k.ders_id =d.id;


-- Öğrenci başına toplam kredi ve sınıfın genel kredi ortalaması
SELECT 
    o.ad AS ogrenci_adi, 
    SUM(d.kredi) AS ogrenci_toplam_kredisi,
    ROUND(AVG(SUM(d.kredi)) OVER(), 2) AS sinif_kredi_ortalamasi
FROM ogrenci o
JOIN kayit k ON o.identify = k.ogrenci_id
JOIN ders d ON k.ders_id = d.id
GROUP BY o.identify, o.ad
ORDER BY ogrenci_toplam_kredisi DESC;


-- cte with common table expression 
--önce öğrenci ortalamasını hesapla, sonra kullan

with ortalama as(
	select o.identify, o.ad, AVG(k.notu) as ort
	from ogrenci o
	join kayit k on o.identify = k.ogrenci_id
	group by o.identify, o.ad
)
SELECT * FROM ortalama where ort>80 ORDER BY ort DESC;

-- Kaç farklı derste not verilmiş
SELECT DISTINCT ders_id FROM kayit;

--- Ders başına istatistikler
SELECT d.ad,
    COUNT(k.ogrenci_id) AS ogrenci_sayisi,
    AVG(k.notu) AS ortalama,
    MIN(k.notu) AS en_dusuk,
    MAX(k.notu) AS en_yuksek,
    STDDEV(k.notu) AS standart_sapma
FROM ders d
LEFT JOIN kayit k ON d.id = k.ders_id
GROUP BY d.id, d.ad
ORDER BY ortalama DESC;
