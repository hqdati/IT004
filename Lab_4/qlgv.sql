USE QuanLyGiaoVu;

------------------------------ Bai Tap 2 ---------------------------------
-- Phần III bài tập QuanLyGiaoVu từ câu 19 đến câu 25

--------------------------- Cau 19 ---------------------------
-- Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất. 
SELECT K.MAKHOA AS [MaKhoa],
	   K.TENKHOA AS [TenKhoa],
	   K.NGTLAP AS [NgayThanhLap]
FROM KHOA AS K
WHERE K.NGTLAP <= ALL (
	SELECT K2.NGTLAP
	FROM KHOA AS K2
);

--------------------------- Cau 20 ---------------------------
-- Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.

-- C1: Sử dụng UNION
SELECT COUNT(Subquery.MAGV) AS [SoLuongGiaoVien]
FROM (
	SELECT GV.MAGV, GV.HOCHAM
	FROM GIAOVIEN AS GV
	WHERE GV.HOCHAM = 'GS'
	UNION
	SELECT GV2.MAGV, GV2.HOCHAM
	FROM GIAOVIEN AS GV2
	WHERE GV2.HOCHAM = 'PGS'
) AS Subquery;

-- C2: Sử dụng IN (Tối ưu hơn)
SELECT COUNT(GV.MAGV) AS [SoLuongGiaoVien]
FROM GIAOVIEN AS GV
WHERE GV.HOCHAM IN ('GS', 'PGS');

-------------------------- Cau 21 -------------------------
-- Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi 
-- khoa.

-- C1: Tối ưu
SELECT GV.MAKHOA AS [MaKhoa],
	   COUNT(DISTINCT GV.MAGV) AS [SoLuongGiaoVien]
FROM GIAOVIEN AS GV
WHERE GV.HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS')
GROUP BY GV.MAKHOA;

-- C2: Sử dụng EXISTS
SELECT GV.MAKHOA AS [MaKhoa],
	   COUNT(DISTINCT GV.MAGV) AS [SoLuonGiaoVien]
FROM GIAOVIEN AS GV
WHERE EXISTS (
	SELECT *
	FROM GIAOVIEN AS GV2
	WHERE GV2.HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS')
)
GROUP BY GV.MAKHOA;

----------------------------- Cau 22 ----------------------------
-- Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt). 
SELECT KQ.MAMH AS [MaMonHoc],
	   KQ.KQUA AS [KetQua],
	   COUNT(DISTINCT KQ.MAHV) AS [SoLuongHocVien]
FROM KETQUATHI AS KQ
GROUP BY KQ.MAMH, KQ.KQUA;

----------------------------- Cau 23 ----------------------------
-- Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho 
-- lớp đó ít nhất một môn học. 
SELECT GV.MAGV AS [MaGiaoVien],
	   GV.HOTEN AS [HoTen]
FROM GIAOVIEN AS GV
JOIN LOP AS L
ON L.MAGVCN = GV.MAGV
JOIN GIANGDAY AS GD
ON GD.MALOP = L.MALOP
	AND GD.MAGV = GV.MAGV -- Đảm bảo lớp đó được dạy bởi giáo viên chủ nhiệm
GROUP BY GV.MAGV, GV.HOTEN
HAVING COUNT(DISTINCT GD.MAMH) >= 1;

----------------------------- Cau 24 ---------------------------
-- Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.
SELECT (Hv.HO + ' ' + HV.TEN) AS [HoTen]
FROM HOCVIEN AS HV
JOIN LOP AS L
ON HV.MAHV = L.TRGLOP
WHERE L.SISO >= ALL (
	SELECT L2.SISO
	FROM LOP AS L2
);

------------------------------ Cau 25 ---------------------------
-- * Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả 
-- các lần thi).
SELECT (HV.HO + ' ' + HV.TEN) AS [HoTen]
FROM HOCVIEN AS HV
JOIN LOP AS L
	ON HV.MAHV = L.TRGLOP
JOIN KETQUATHI AS KQ
	ON KQ.MAHV = HV.MAHV
WHERE NOT EXISTS (
	-- Nếu lớp trưởng có bất kì lần thi nào 'Dat' thì không hiển thị
	SELECT *
	FROM KETQUATHI AS KQ2
	WHERE KQ2.MAHV = HV.MAHV -- Đảm bào đang kiểm tra lớp trưởng
		AND KQ2.KQUA = 'Dat'
)
GROUP BY HV.MAHV, (HV.HO + ' ' + HV.TEN)
HAVING COUNT(DISTINCT KQ.MAMH) <= 3;

------------------------------- Cau 26 ----------------------------
-- Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất. 
SELECT TOP 1 WITH TIES
	HV.MAHV AS [Mã học viên],
	(HV.HO + ' ' + HV.TEN) AS [Họ tên]
FROM (
	SELECT KQ.MAHV,
		   COUNT(DISTINCT KQ.MAMH) AS [Số lượng điểm 9 và 10]
	FROM KETQUATHI AS KQ
	WHERE KQ.DIEM IN (9, 10)
	GROUP BY KQ.MAHV
) AS Subquery
JOIN HOCVIEN AS HV
	ON HV.MAHV = Subquery.MAHV
ORDER BY Subquery.[Số lượng điểm 9 và 10] DESC;

------------------------------- Cau 27 -----------------------------
-- Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất. 
SELECT L.MALOP AS [Mã Lớp],
	   HV.MAHV AS [Mã Học Viên],
	   (HV.HO + ' ' + HV.TEN) AS [Họ tên],
	   COUNT(DISTINCT KQ.MAMH) AS [Số lượng điểm 9, 10]
FROM KETQUATHI AS KQ
JOIN HOCVIEN AS HV
	ON KQ.MAHV = HV.MAHV
JOIN LOP AS L
	ON L.MALOP = HV.MALOP
WHERE KQ.DIEM IN (9,10)
GROUP BY L.MALOP, HV.MAHV, (HV.HO + ' ' + HV.TEN)
HAVING COUNT(DISTINCT KQ.MAMH) >= ALL (
	SELECT COUNT(DISTINCT KQ.MAMH)
	FROM KETQUATHI AS KQ2
	JOIN HOCVIEN AS HV2
		ON KQ2.MAHV = HV2.MAHV
	JOIN LOP AS L2
		ON L2.MALOP = HV2.MALOP
	WHERE KQ2.DIEM IN (9,10)
		AND L.MALOP = L2.MALOP -- Đảm bảo kiểm tra trong cùng 1 lớp 
							   -- --> Tìm ra học viên có số lượng điểm 9, 10 nhiều nhất trong 1 lớp
	GROUP BY HV2.MAHV
);

----------------------------- Cau 28 ---------------------------
-- Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao 
-- nhiêu lớp. 
SELECT GD.NAM AS [Năm],
	   GD.HOCKY AS [Học Kỳ],
	   GD.MAGV AS [Mã Giáo Viên],
	   COUNT(DISTINCT GD.MAMH) AS [Số lượng môn học],
	   COUNT(DISTINCT GD.MALOP) AS [Số lượng lớp] 
FROM GIANGDAY AS GD
GROUP BY GD.NAM, GD.HOCKY, GD.MAGV;

----------------------------- Cau 29 ---------------------------
-- Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất. 
SELECT GD.NAM AS [Nam],
	   GD.HOCKY AS [HocKy],
	   GV.MAGV AS [MaGiaoVien],
	   GV.HOTEN AS [HoTen],
	   COUNT(DISTINCT GD.MALOP) AS [SoLuongLop]
FROM GIANGDAY AS GD 
JOIN GIAOVIEN AS GV
ON GD.MAGV = GV.MAGV
GROUP BY GD.NAM, GD.HOCKY, GV.MAGV, GV.HOTEN
HAVING COUNT(DISTINCT GD.MALOP) = (
	SELECT MAX(Subquery.SoLuong)
	FROM (
		SELECT COUNT(DISTINCT GD2.MALOP) AS [SoLuong]
		FROM GIANGDAY AS GD2
		WHERE GD2.NAM = GD.NAM			-- Đảm bảo cùng 1 năm
			AND GD2.HOCKY = GD.HOCKY	-- Đảm bảo cùng 1 học kỳ
		GROUP BY GD2.MAGV
	) AS Subquery
);

---------------------------- Cau 30 --------------------------
-- Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) 
-- nhất.

/* Subquery tìm số lượng học viên thi không đạt ở lân 1 ở từng mỗi môn học
	
	SELECT MH.MAMH AS [MaMonHoc],
		   MH.TENMH AS [TenMonHoc],
		   COUNT(KQ.MAHV) AS [SoLuongHocVien]
	FROM MONHOC AS MH
	JOIN KETQUATHI AS KQ
	ON MH.MAMH = KQ.MAMH
	WHERE KQ.KQUA = 'Khong dat'
		AND KQ.LANTHI = 1
	GROUP BY MH.MAMH, MH.TENMH

*/

SELECT TOP 1 WITH TIES Subquery.MaMonHoc, Subquery.TenMonHoc
FROM (
	SELECT MH.MAMH AS [MaMonHoc],
		   MH.TENMH AS [TenMonHoc],
	       COUNT(KQ.MAHV) AS [SoLuongHocVien]
	FROM MONHOC AS MH
	JOIN KETQUATHI AS KQ
	ON MH.MAMH = KQ.MAMH
	WHERE KQ.KQUA = 'Khong dat'
		AND KQ.LANTHI = 1
	GROUP BY MH.MAMH, MH.TENMH
) Subquery
ORDER BY Subquery.SoLuongHocVien DESC;

--------------------------- Cau 31 ------------------------
-- Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1).

/* Subquery truy vấn học viên thi không đạt ở lần thi 1

SELECT *  
FROM KETQUATHI AS KQ
WHERE KQ.LANTHI = 1
	AND KQ.KQUA = 'Khong dat'

*/

-- Sử dụng NOT EXISTS
SELECT HV.MAHV AS [MaHocVien],
	   (Hv.HO + ' ' + HV.TEN) AS [HoTen]
FROM HOCVIEN AS HV
WHERE NOT EXISTS (
	SELECT *  
	FROM KETQUATHI AS KQ
	WHERE KQ.LANTHI = 1
		AND KQ.KQUA = 'Khong dat'
		AND HV.MAHV = KQ.MAHV -- Đảm bảo học viên đang xét không có môn nào không đạt ở lần 1
);

------------------------------- Cau 32 -------------------------------
-- * Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng). 
SELECT HV.MAHV AS [MaHocVien],
	   (HV.HO + ' ' + HV.TEN) AS [HoTen]
FROM HOCVIEN AS HV
WHERE NOT EXISTS (
	SELECT *
	FROM MONHOC AS MH
	WHERE NOT EXISTS (
		SELECT *
		FROM KETQUATHI AS KQ
		WHERE KQ.MAHV = HV.MAHV
			AND KQ.MAMH = MH.MAMH
			AND KQ.KQUA = 'Dat'
			AND KQ.LANTHI = (			-- Truy vấn lần thi sau cùng
				SELECT MAX(KQ2.LANTHI)
				FROM KETQUATHI AS KQ2
				WHERE KQ2.MAHV = KQ.MAHV
					AND KQ2.MAMH = KQ.MAMH
			)
	)
);

---------------------------- Cau 33 --------------------------
-- * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt (chỉ xét lần thi thứ 1). 
SELECT HV.MAHV AS [MaHocVien],
       (HV.HO + ' ' + HV.TEN) AS [HoTen]
FROM HOCVIEN AS HV
WHERE NOT EXISTS (
	SELECT *
	FROM MONHOC AS MH
	WHERE NOT EXISTS (
		SELECT *
		FROM KETQUATHI AS KQ
		WHERE KQ.KQUA = 'Dat'
			AND KQ.LANTHI = 1		-- Đảm bảo thi 'Dat' ở lần thi thứ 1
			AND KQ.MAHV = HV.MAHV
			AND KQ.MAMH = MH.MAMH
	)
);

----------------------------- Cau 34 ------------------------
-- * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt  (chỉ xét lần thi sau cùng). 
SELECT HV.MAHV AS [MaHocVien],
	   (HV.HO + ' ' + HV.TEN) AS [HoTen]
FROM HOCVIEN AS HV
WHERE NOT EXISTS (
	SELECT *
	FROM MONHOC AS MH
	WHERE NOT EXISTS (
		SELECT *
		FROM KETQUATHI AS KQ
		WHERE KQ.MAHV = HV.MAHV
			AND KQ.MAMH = MH.MAMH
			AND KQ.KQUA = 'Dat'
			AND KQ.LANTHI = (			-- Truy vấn lần thi sau cùng
				SELECT MAX(KQ2.LANTHI)
				FROM KETQUATHI AS KQ2
				WHERE KQ2.MAHV = KQ.MAHV
					AND KQ2.MAMH = KQ.MAMH
			)
	)
);

-------------------------------- Cau 35 --------------------------------
-- ** Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần 
-- thi sau cùng). 
SELECT KQ.MAMH AS [MaMonHoc],
	   HV.MAHV AS [MaHocVien],
	   (HV.HO + ' ' + HV.TEN) AS [HoTen]
FROM HOCVIEN AS HV
JOIN KETQUATHI AS KQ
ON KQ.MAHV = HV.MAHV
WHERE KQ.DIEM >= ALL ( -- Tìm điểm cao nhất
	SELECT KQ2.DIEM
	FROM KETQUATHI AS KQ2
	WHERE KQ2.MAMH = KQ.MAMH
) AND KQ.LANTHI = ( -- Tìm kiếm điểm cao nhất lần thi sau cùng
	SELECT MAX(KQ3.LANTHI)
	FROM KETQUATHI AS KQ3
	WHERE KQ3.MAMH = KQ.MAMH
		AND KQ3.MAHV = KQ.MAHV
)
GROUP BY KQ.MAMH, HV.MAHV, (HV.HO + ' ' + HV.TEN);
