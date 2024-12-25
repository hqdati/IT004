USE QuanLyBanHang;

------------------------ Bai Tap 1 ----------------------------
-- Phần III bài tập QuanLyBanHang từ câu 20 đến câu 30

--------------------- Cau 20 --------------------
-- Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua? 

-- C1: Tối ưu
SELECT COUNT(HD.SOHD) AS [SoLuongHoaDon]
FROM HOADON AS HD
WHERE HD.MAKH IS NULL;

-- C2: Sử dụng Subquery
SELECT COUNT(Hd.SOHD) AS [SoLuongHoaDon]
FROM HOADON AS HD
WHERE HD.MAKH NOT IN (
	SELECT KH.MAKH
	FROM KHACHHANG AS KH
	WHERE Kh.MAKH = HD.MAKH
);

-------------------- Cau 21 ---------------------
-- Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006

-- C1: Tối ưu
SELECT COUNT(DISTINCT CTHD.MASP) AS [SoLuongSanPham]
FROM CTHD AS CTHD
JOIN HOADON AS HD
ON CTHD.SOHD = HD.SOHD
WHERE YEAR(HD.NGHD) = 2006;

-- C2: Sử dụng Subquery
SELECT COUNT(DISTINCT CTHD.MASP) AS [SoLuongSanPham]
FROM CTHD AS CTHD
WHERE EXISTS (
	SELECT *
	FROM CTHD AS CTHD2
	JOIN HOADON AS HD2
	ON CTHD2.SOHD = HD2.SOHD
	WHERE YEAR(HD2.NGHD) = 2006
		AND CTHD2.SOHD = HD2.SOHD
);

----------------------- Cau 22 ----------------------
-- Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu ? 
SELECT MAX(HD.TRIGIA) AS [TriGiaHoaDonCaoNhat],
	   MIN(HD.TRIGIA) AS [TriGiaHoaDonThapNhat]
FROM HOADON AS HD;

----------------------- Cau 23 ----------------------
-- Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu? 
SELECT AVG(HD.TRIGIA) AS [TriGiaTrungBinh]
FROM HOADON AS HD
WHERE YEAR(HD.NGHD) = 2006;

----------------------- Cau 24 ----------------------
-- Tính doanh thu bán hàng trong năm 2006. 
SELECT SUM(HD.TRIGIA) AS [DoanhThuBanHang]
FROM HOADON AS HD
WHERE YEAR(HD.NGHD) = 2006;

----------------------- Cau 25 ----------------------
-- Tìm số hóa đơn có trị giá cao nhất trong năm 2006.
SELECT HD.SOHD AS [SoHoaDon]
FROM HOADON AS HD
WHERE YEAR(HD.NGHD) = 2006 
	AND HD.TRIGIA >= ALL (
		SELECT HD2.TRIGIA
		FROM HOADON AS HD2
		WHERE YEAR(HD2.NGHD) = 2006
);

----------------------- Cau 26 ---------------------
-- Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006.
SELECT KH.HOTEN AS [HoTenKhachHang]
FROM KHACHHANG AS KH
WHERE EXISTS (
	SELECT *
	FROM HOADON AS HD
	WHERE KH.MAKH = HD.MAKH
		AND YEAR(HD.NGHD) = 2006 
		AND HD.TRIGIA >= ALL (
			SELECT HD2.TRIGIA
			FROM HOADON AS HD2
			WHERE YEAR(HD2.NGHD) = 2006
		)
);

----------------------- Cau 27 --------------------
-- In ra danh sách 3 khách hàng (MAKH, HOTEN) có doanh số cao nhất. 
SELECT TOP 3 KH.MAKH AS [MaKhachHang],
			 KH.HOTEN AS [HoTenKhachHang]
FROM KHACHHANG AS KH
ORDER BY KH.DOANHSO DESC;

----------------------- Cau 28 -------------------
-- In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất. 

/* Truy vấn tìm kiếm 3 mức giá cao nhất khác nhau

SELECT TOP 3 Subquery.GiaSanPham AS [Gia]
	FROM (
		SELECT DISTINCT SP.GIA AS [GiaSanPham]
		FROM SANPHAM AS SP
	) Subquery
ORDER BY Subquery.GiaSanPham DESC;

*/

SELECT SP.MASP AS [MaSanPham],
	   SP.TENSP AS [TenSanPham]
FROM SANPHAM AS SP
WHERE SP.GIA IN (
	SELECT TOP 3 Subquery.GiaSanPham
	FROM (
		SELECT DISTINCT SP2.GIA AS [GiaSanPham]
		FROM SANPHAM AS SP2
	) Subquery
	ORDER BY Subquery.GiaSanPham DESC
);

---------------------------- Cau 29 ------------------------
-- In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 trong 3 mức 
-- giá cao nhất (của tất cả các sản phẩm). 
SELECT SP.MASP AS [MaSanPham],
	   SP.TENSP AS [TenSanPham]
FROM SANPHAM AS SP
WHERE SP.NUOCSX = 'Thai Lan'
	AND SP.GIA IN (
		SELECT TOP 3 Subquery.GiaSanPham
		FROM (
			SELECT DISTINCT SP2.GIA AS [GiaSanPham]
			FROM SANPHAM AS SP2
		) Subquery
		ORDER BY Subquery.GiaSanPham DESC
);

--------------------------- Cau 30 --------------------------
-- In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 trong 3 mức 
-- giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất).
SELECT SP.MASP AS [MaSanPham],
	   SP.TENSP AS [TenSanPham]
FROM SANPHAM AS SP
WHERE SP.NUOCSX = 'Trung Quoc'
	AND SP.GIA IN (
		SELECT TOP 3 Subquery.GiaSanPham
		FROM (
			SELECT DISTINCT SP2.GIA AS [GiaSanPham]
			FROM SANPHAM AS SP2
			WHERE SP2.NUOCSX = 'Trung Quoc'
		) Subquery
		ORDER BY Subquery.GiaSanPham DESC
);

----------------------------- Bai Tap 3 -----------------------------
-- Phần III bài tập QuanLyBanHang từ câu 31 đến câu 45

---------------------------- Cau 31 ---------------------------
-- * In ra danh sách 3 khách hàng có doanh số cao nhất (sắp xếp theo kiểu xếp hạng). 

-- Sử dụng ROW_NUMBER()
SELECT TOP 3 
    ROW_NUMBER() OVER (ORDER BY KH.DOANHSO DESC) AS Rank,
	KH.MAKH AS [MaKhachHang],
	KH.HOTEN AS [HoTenKhachHang]
FROM KHACHHANG AS KH;

---------------------------- Cau 32 ---------------------------
-- Tính tổng số sản phẩm do “Trung Quoc” sản xuất. 
SELECT COUNT(DISTINCT SP.MASP) AS [TongSoSanPham]
FROM SANPHAM AS SP
WHERE SP.NUOCSX = 'Trung Quoc';

---------------------------- Cau 33 --------------------------
-- Tính tổng số sản phẩm của từng nước sản xuất
SELECT SP.NUOCSX AS [NuocSanXuat],
	   COUNT(DISTINCT SP.MASP) AS [SoLuongSanPham]
FROM SANPHAM AS SP
GROUP BY SP.NUOCSX;

---------------------------- Cau 34 --------------------------
-- Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm. 
SELECT SP.NUOCSX AS [NuocSanXuat],
	   MAX(SP.GIA) AS [GiaBanCaoNhat],
	   MIN(SP.GIA) AS [GiaBanThapNhat],
	   AVG(SP.GIA) AS [GiaBanTrungBinh]
FROM SANPHAM AS SP
GROUP BY SP.NUOCSX;

--------------------------- Cau 35 ----------------------------
-- Tính doanh thu bán hàng mỗi ngày.
SELECT HD.NGHD AS [NgayHoaDon],
	   SUM(HD.TRIGIA) AS [DoanhThu]
FROM HOADON AS HD
GROUP BY HD.NGHD;

--------------------------- Cau 36 ----------------------------
-- Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.
SELECT CTHD.MASP AS [MaSanPham],
	   SUM(CTHD.SL) AS [TongSoLuong] 
FROM HOADON AS HD
JOIN CTHD AS CTHD
ON HD.SOHD = CTHD.SOHD
WHERE MONTH(HD.NGHD) = 10
	AND YEAR(HD.NGHD) = 2006
GROUP BY CTHD.MASP;

-------------------------- Cau 37 ----------------------------
-- Tính doanh thu bán hàng của từng tháng trong năm 2006. 
SELECT MONTH(HD.NGHD) AS [Thang],
	   SUM(HD.TRIGIA) AS [DoanhThu]
FROM HOADON AS HD
WHERE YEAR(HD.NGHD) = 2006
GROUP BY MONTH(HD.NGHD);

--------------------------- Cau 38 --------------------------
-- Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau.
SELECT HD.SOHD AS [SoHoaDon],
	   COUNT(DISTINCT CTHD.MASP) AS [SoLuongSanPham]
FROM HOADON AS HD
JOIN CTHD AS CTHD
ON HD.SOHD = CTHD.SOHD
GROUP BY HD.SOHD
HAVING COUNT(DISTINCT CTHD.MASP) >= 4;

---------------------------- Cau 39 ------------------------
-- Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau). 
SELECT CTHD.SOHD AS [SoHoaDon]
FROM CTHD AS CTHD
JOIN SANPHAM AS SP
ON CTHD.MASP = SP.MASP
WHERE SP.NUOCSX = 'Viet Nam'
GROUP BY CTHD.SOHD
HAVING COUNT(DISTINCT CTHD.MASP) = 3;

----------------------------  Cau 40 -------------------------
-- Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất. 
SELECT KH.MAKH AS [MaKH],
	   KH.HOTEN AS [HoTen],
	   COUNT(HD.SOHD) AS [SoLanMuaHang]
FROM KHACHHANG AS KH
JOIN HOADON AS HD
ON KH.MAKH = HD.MAKH
GROUP BY KH.MAKH, KH.HOTEN
HAVING COUNT(HD.SOHD) >= ALL (
	SELECT COUNT(HD2.SOHD)
	FROM HOADON AS HD2
	GROUP BY HD2.MAKH
);

------------------------------ Cau 41 -------------------------
-- Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ? 

-- C1: Sử dụng Subquery
SELECT MONTH(HD.NGHD) AS [ThangCoDoanhSoCaoNhat]
FROM HOADON AS HD
WHERE YEAR(HD.NGHD) = 2006
GROUP BY MONTH(HD.NGHD)
HAVING SUM(HD.TRIGIA) >= ALL (
	SELECT SUM(HD2.TRIGIA)
	FROM HOADON AS HD2
	WHERE YEAR(HD2.NGHD) = 2006
	GROUP BY MONTH(HD2.NGHD)
);

-- C2: Tối ưu hơn
SELECT TOP 1 MONTH(HD.NGHD) AS [ThangCoDoanhSoCaoNhat]
FROM HOADON AS HD
WHERE YEAR(HD.NGHD) = 2006
GROUP BY MONTH(HD.NGHD)
ORDER BY SUM(HD.TRIGIA) DESC;

------------------------------ Cau 42 --------------------------
-- Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.

-- C1: Sử dụng Subquery
SELECT SP.MASP AS [MaSanPham],
	   SP.TENSP AS [TenSanPham]
FROM SANPHAM AS SP
JOIN CTHD AS CTHD
ON SP.MASP = CTHD.MASP
JOIN HOADON AS HD
ON HD.SOHD = CTHD.SOHD
WHERE YEAR(HD.NGHD) = 2006
GROUP BY SP.MASP, SP.TENSP
HAVING SUM(CTHD.SL) <= ALL (
	SELECT SUM(CTHD2.SL)
	FROM CTHD AS CTHD2
	JOIN HOADON AS HD2
	ON HD2.SOHD = CTHD2.SOHD
	WHERE YEAR(HD2.NGHD) = 2006
	GROUP BY CTHD2.MASP
);

-- C2: Tối ưu hơn
SELECT TOP 1 SP.MASP AS [MaSanPham],
		     SP.TENSP AS [TenSanPham]
FROM SANPHAM AS SP
JOIN CTHD AS CTHD
ON SP.MASP = CTHD.MASP
JOIN HOADON AS HD
ON HD.SOHD = CTHD.SOHD
WHERE YEAR(HD.NGHD) = 2006
GROUP BY SP.MASP, SP.TENSP
ORDER BY SUM(CTHD.SL) ASC;

------------------------------- Cau 43 ---------------------------
-- *Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất. 

/* Query sắp xếp theo Ranking giá bán cao nhất cho mỗi nước

SELECT SP.MASP, SP.TENSP, SP.NUOCSX, SP.GIA,
		ROW_NUMBER() OVER(PARTITION BY SP.NUOCSX ORDER BY SP.GIA DESC) AS Rank
FROM SANPHAM AS SP
	
*/

-- Sử dụng ROW_NUMBER()
SELECT Subquery.MASP AS [MaSanPham],
	   Subquery.TENSP AS [TenSanPham],
	   Subquery.NUOCSX AS [NuocSanXuat],
	   Subquery.GIA AS [Gia]
FROM (
	SELECT SP.MASP, SP.TENSP, SP.NUOCSX, SP.GIA,
		ROW_NUMBER() OVER(PARTITION BY SP.NUOCSX ORDER BY SP.GIA DESC) AS Rank
	FROM SANPHAM AS SP
) Subquery
WHERE Subquery.Rank = 1;

-- Sử dụng so sánh bình thường
SELECT SP.NUOCSX, SP.MASP, SP.TENSP, SP.GIA
FROM SANPHAM AS SP
WHERE SP.GIA = (
	SELECT MAX(SP2.GIA)
	FROM SANPHAM AS SP2
	WHERE SP2.NUOCSX = SP.NUOCSX
	GROUP BY SP2.NUOCSX
);

------------------------------- Cau 44 ---------------------------
-- Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau. 

-- C1: Sử dụng Subquery
SELECT SP.NUOCSX AS [NuocSanXuat]
FROM SANPHAM AS SP
GROUP BY SP.NUOCSX
HAVING EXISTS (
	SELECT *
	FROM SANPHAM AS SP2
	WHERE SP2.NUOCSX = SP.NUOCSX -- Bỏ phần này là sai vì thực hiện truy vấn với mọi nước
	GROUP BY SP2.NUOCSX
	HAVING COUNT(DISTINCT SP2.MASP) >= 3
		AND COUNT(DISTINCT SP2.GIA) >= 3
);

-- C2: Tối ưu hơn
SELECT SP.NUOCSX AS [NuocSanXuat]
FROM SANPHAM AS SP
GROUP BY SP.NUOCSX
HAVING COUNT(DISTINCT SP.MASP) >= 3
   AND COUNT(DISTINCT SP.GIA) >= 3;

-------------------------------- Cau 45 ----------------------------
-- *Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất. 

SELECT TOP 1 KH.MAKH AS [MaKhachHang],
			 KH.HOTEN AS [HoTen],
			 KH.DOANHSO AS [DoanhSo],
			 COUNT(HD.SOHD) AS [SoLanMuaHang]
FROM KHACHHANG AS KH
JOIN HOADON AS HD
ON HD.MAKH = KH.MAKH
WHERE KH.MAKH IN (
	SELECT TOP 10 KH2.MAKH
	FROM KHACHHANG AS KH2
	ORDER BY KH2.DOANHSO DESC
)
GROUP BY KH.MAKH, KH.HOTEN, KH.DOANHSO
ORDER BY COUNT(HD.SOHD) DESC;
