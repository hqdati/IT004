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
