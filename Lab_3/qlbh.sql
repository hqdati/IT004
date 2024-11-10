USE QuanLyBanHang;

----------------------------------- Bai Tap 1 ----------------------------------
-- Phần III bài tập QuanLyBanHang câu 12 và câu 13

----------------------- Cau 12 ------------------------
-- Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm mua với số 
-- lượng từ 10 đến 20. 

SELECT SOHD AS [SoHoaDon]
FROM CTHD 
WHERE (MASP = 'BB01') AND (SL BETWEEN 10 AND 20)
UNION 
SELECT SOHD AS [SoHoaDon]
FROM CTHD 
WHERE (MASP = 'BB02') AND (SL BETWEEN 10 AND 20);

--------------------- Cau 13 ------------------------
-- Tìm các số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản phẩm mua với 
-- số lượng từ 10 đến 20. 

SELECT SOHD AS [SoHoaDon]
FROM CTHD 
WHERE (MASP = 'BB01') AND (SL BETWEEN 10 AND 20)
INTERSECT
SELECT SOHD AS [SoHoaDon]
FROM CTHD 
WHERE (MASP = 'BB02') AND (SL BETWEEN 10 AND 20);



------------------------------- Bai Tap 4 ---------------------------------
-- Phần III bài tập QuanLyBanHang từ câu 14 đến câu 19

---------------------- Cau 14 ----------------------
-- In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất hoặc các sản phẩm được 
-- bán ra trong ngày 1/1/2007.

SELECT SP.MASP AS [MaSanPham],
	   SP.TENSP AS [TenSanPham]
FROM SANPHAM AS SP
WHERE SP.NUOCSX = 'Trung Quoc'
UNION 
SELECT SP.MASP AS [MaSanPham],
	   SP.TENSP AS [TenSanPham]
FROM SANPHAM AS SP
WHERE EXISTS (
	SELECT *
	FROM HOADON AS HD
	JOIN CTHD AS CT
	ON HD.SOHD = CT.SOHD
	WHERE SP.MASP = CT.MASP AND HD.NGHD = '2007-01-01'
);

------------------------------ Cau 15 ---------------------------
-- In ra danh sách các sản phẩm (MASP,TENSP) không bán được.

SELECT SP.MASP AS [MaSanPham],
	   SP.TENSP AS [TenSanPham]
FROM SANPHAM AS SP
WHERE NOT EXISTS (
	SELECT *
	FROM CTHD AS CT
	WHERE CT.MASP = SP.MASP
);

----------------------------- Cau 16 -------------------------
-- In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006. 

SELECT SP.MASP AS [MaSanPham],
	   SP.TENSP AS [TenSanPham]
FROM SANPHAM AS SP
WHERE NOT EXISTS (
	SELECT *
	FROM CTHD AS CT 
	JOIN HOADON AS HD
	ON CT.SOHD = HD.SOHD
	WHERE SP.MASP = CT.MASP AND YEAR(HD.NGHD) = 2006
);

------------------------ Cau 17 -----------------------
-- In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán được trong 
-- năm 2006. 

SELECT SP.MASP AS [MaSanPham],
	   SP.TENSP AS [TenSanPham]
FROM SANPHAM AS SP
WHERE SP.NUOCSX = 'Trung Quoc' AND NOT EXISTS (
	SELECT *
	FROM CTHD AS CT 
	JOIN HOADON AS HD
	ON CT.SOHD = HD.SOHD
	WHERE SP.MASP = CT.MASP AND YEAR(HD.NGHD) = 2006
);

----------------------------- Cau 18 -------------------------
-- Tìm số hóa đơn đã mua tất cả các sản phẩm do Singapore sản xuất. 

SELECT HD.SOHD AS [SoHoaDon]
FROM HOADON AS HD
WHERE NOT EXISTS (
	SELECT *
	FROM SANPHAM AS SP
	WHERE SP.NUOCSX = 'Singapore' AND NOT EXISTS (
		SELECT *
		FROM CTHD AS CT
		WHERE CT.SOHD = HD.SOHD AND SP.MASP = CT.MASP
));

-------------------------- Cau 19 ----------------------
-- Tìm số hóa đơn trong năm 2006 đã mua ít nhất tất cả các sản phẩm do Singapore sản xuất.

SELECT HD.SOHD AS [SoHoaDon]
FROM HOADON AS HD
WHERE YEAR(HD.NGHD) = 2006 AND NOT EXISTS (
	SELECT *
	FROM SANPHAM AS SP
	WHERE SP.NUOCSX = 'Singapore' AND NOT EXISTS (
		SELECT *
		FROM CTHD AS CT
		WHERE CT.SOHD = HD.SOHD AND SP.MASP = CT.MASP
		AND CT.SL > 0
));

