CREATE TABLE IF NOT EXISTS oyuncaklar (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    isim TEXT NOT NULL,
    cesit TEXT,
    fiyat INTEGER CHECK (fiyat > 0),
    renk TEXT DEFAULT 'kırmızı'
);

INSERT INTO oyuncaklar (isim, cesit, fiyat) VALUES ('Şimşek', 'araba', 50);
INSERT INTO oyuncaklar (isim, cesit, fiyat, renk) VALUES 
('Ayıcık', 'peluş', 80, 'kahverengi'),
('Kale Seti', 'lego', 150, 'gri'),
('Zıpzıp', 'top', 20, 'sarı'),
('Barbie', 'bebek', 90, 'pembe');


SELECT * FROM oyuncaklar;

SELECT isim, fiyat FROM oyuncaklar WHERE fiyat >= 80;

SELECT * FROM oyuncaklar ORDER BY fiyat DESC LIMIT 2;

SELECT * FROM oyuncaklar WHERE isim LIKE 'Z%';

SELECT * FROM oyuncaklar WHERE cesit IN ('araba', 'top');

SELECT * FROM oyuncaklar WHERE fiyat BETWEEN 20 AND 60;


UPDATE oyuncaklar SET renk = 'mavi' WHERE isim = 'Şimşek';

DELETE FROM oyuncaklar WHERE isim = 'Zıpzıp';


ALTER TABLE oyuncaklar ADD COLUMN kimin TEXT;

UPDATE oyuncaklar SET kimin = 'Ali' WHERE isim = 'Kale Seti';

ALTER TABLE oyuncaklar RENAME COLUMN cesit TO tur;


