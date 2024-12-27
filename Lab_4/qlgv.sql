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
		AND GV2.MAGV = GV.MAGV
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

-- C1:
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

-- C2: hay hơn :>
SELECT GV.MAGV AS [Mã giáo viên],
	   GV.HOTEN AS [Họ tên]
FROM GIAOVIEN AS GV
WHERE EXISTS (
	SELECT *
	FROM LOP AS L
	WHERE L.MAGVCN = GV.MAGV
		AND EXISTS (
			SELECT *
			FROM GIANGDAY AS GD
			WHERE GD.MAGV = GV.MAGV
				AND GD.MALOP = L.MALOP
		)
);

----------------------------- Cau 24 ---------------------------
-- Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.

-- C1:
SELECT (Hv.HO + ' ' + HV.TEN) AS [HoTen]
FROM HOCVIEN AS HV
JOIN LOP AS L
ON HV.MAHV = L.TRGLOP
WHERE L.SISO >= ALL (
	SELECT L2.SISO
	FROM LOP AS L2
);

-- C2: hay hơn :>
SELECT (HV.HO + ' ' + HV.TEN) AS [Họ tên lớp trưởng]
FROM HOCVIEN AS HV
WHERE EXISTS (
	SELECT *
	FROM LOP AS L
	WHERE L.TRGLOP = HV.MAHV
		AND L.SISO >= ALL (
			SELECT L2.SISO
			FROM LOP AS L2
		)
);

------------------------------ Cau 25 ---------------------------
-- * Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả 
-- các lần thi).

-- C1:
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
HAVING COUNT(DISTINCT KQ.MAMH) > 3;

-- C2: Vận dụng EXISTS, NOT EXISTS (khá hay) :>
SELECT (HV.HO + ' ' + HV.TEN) AS [Họ tên lớp trưởng]
FROM HOCVIEN AS HV
WHERE EXISTS (
	SELECT *
	FROM LOP AS L
	WHERE L.TRGLOP = HV.MAHV
) AND EXISTS (
	SELECT KQ.MAHV
	FROM KETQUATHI AS KQ
	WHERE KQ.MAHV = HV.MAHV
		AND NOT EXISTS (
			SELECT *
			FROM KETQUATHI AS KQ2
			WHERE KQ2.MAMH = KQ.MAMH
				AND KQ2.MAHV = KQ.MAHV
				AND KQ.KQUA = 'Dat'
		)
	GROUP BY KQ.MAHV 
	HAVING COUNT(DISTINCT KQ.MAMH) > 3
);


------------------------------- Cau 26 ----------------------------
-- Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất. 

-- C1:
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

-- C2:
SELECT HV.MAHV AS [Mã học viên],
	   (HV.HO + ' ' + HV.TEN) AS [Họ tên]
FROM HOCVIEN AS HV
JOIN KETQUATHI AS KQ
ON HV.MAHV = KQ.MAHV
WHERE KQ.DIEM IN (9, 10)
GROUP BY HV.MAHV, (HV.HO + ' ' + HV.TEN)
HAVING COUNT(DISTINCT KQ.MAMH) >= ALL (
	SELECT COUNT(DISTINCT KQ2.MAMH)
	FROM KETQUATHI AS KQ2
	WHERE KQ2.DIEM IN (9, 10)
	GROUP BY KQ2.MAHV
);

------------------------------- Cau 27 -----------------------------
-- Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất. 
SELECT HV.MALOP AS [Mã lớp],
	   HV.MAHV AS [Mã học viên],
	   (HV.HO + ' ' + HV.TEN) AS [Họ tên],
	   COUNT(DISTINCT KQ.MAMH) AS [Số lượng điểm 9, 10]
FROM HOCVIEN AS HV
JOIN KETQUATHI AS KQ
ON HV.MAHV = KQ.MAHV
WHERE KQ.DIEM IN (9, 10)
GROUP BY HV.MALOP, HV.MAHV, (HV.HO + ' ' + HV.TEN)
HAVING COUNT(DISTINCT KQ.MAMH) >= ALL (
	SELECT COUNT(DISTINCT KQ2.MAMH)
	FROM KETQUATHI AS KQ2
	JOIN HOCVIEN AS HV2
	ON KQ2.MAHV = HV2.MAHV
	WHERE KQ2.DIEM IN (9, 10)
		AND HV2.MALOP = HV.MALOP -- Đảm bảo kiểm tra cho từng lớp
	GROUP BY KQ2.MAHV
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
SELECT GD.NAM AS [Năm],
	   GD.HOCKY AS [Học kỳ],
	   GD.MAGV AS [Mã giáo viên],
	   COUNT(DISTINCT GD.MALOP) AS [Số lớp]
FROM GIANGDAY AS GD
GROUP BY GD.NAM, GD.HOCKY, GD.MAGV
HAVING COUNT(DISTINCT GD.MALOP) >= ALL (
	SELECT COUNT(DISTINCT GD2.MALOP)
	FROM GIANGDAY AS GD2
	WHERE GD2.NAM = GD.NAM -- Đảm bảo cùng 1 năm
		AND GD2.HOCKY = GD.HOCKY -- Đảm bảo cùng 1 học kỳ
	GROUP BY GD2.NAM, GD2.HOCKY, GD2.MAGV
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

-- C1:
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

-- C2:
SELECT MH.MAMH AS [Mã môn học],
	   MH.TENMH AS [Tên môn học]
FROM MONHOC AS MH
JOIN KETQUATHI AS KQ
ON KQ.MAMH = MH.MAMH
WHERE KQ.KQUA = 'Khong dat'	
	AND KQ.LANTHI = 1
GROUP BY MH.MAMH, MH.TENMH
HAVING COUNT(DISTINCT KQ.MAHV) >= ALL (
	SELECT COUNT(DISTINCT KQ2.MAHV)
	FROM KETQUATHI AS KQ2
	WHERE KQ2.KQUA = 'Khong dat'
		AND KQ2.LANTHI = 1
	GROUP BY KQ2.MAMH
);

--------------------------- Cau 31 ------------------------
-- Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1).

/* Subquery truy vấn học viên thi không đạt ở lần thi 1

SELECT *  
FROM KETQUATHI AS KQ
WHERE KQ.LANTHI = 1
	AND KQ.KQUA = 'Khong dat'

*/

-- Sử dụng NOT EXISTS
SELECT HV.MAHV AS [Mã học viên],
	   (HV.HO + ' ' + HV.TEN) AS [Họ tên]
FROM HOCVIEN AS HV
JOIN KETQUATHI AS KQ
ON KQ.MAHV = HV.MAHV
WHERE KQ.LANTHI = 1
	AND NOT EXISTS (
		SELECT *
		FROM KETQUATHI AS KQ2
		WHERE KQ2.MAHV = KQ.MAHV -- Đảm bảo  cùng học viên
			AND KQ2.LANTHI = 1
			AND KQ2.MAMH = KQ.MAMH -- Đảm bảo cùng môn học
			AND KQ2.KQUA = 'Khong dat'
	)
GROUP BY HV.MAHV, (HV.HO + ' ' + HV.TEN);

------------------------------- Cau 32 -------------------------------
-- * Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng). 

-- Lưu ý: Thi môn nào cũng đạt nghĩa là những môn mà học viên đó thi, 
-- ==> Những môn đó đề đạt ở lần thi cuối cùng

SELECT HV.MAHV AS [Mã học viên],
	   (HV.HO + ' ' + HV.TEN) AS [Họ tên]
FROM HOCVIEN AS HV
JOIN KETQUATHI AS KQ
ON KQ.MAHV = HV.MAHV
WHERE NOT EXISTS (
	SELECT *
	FROM KETQUATHI AS KQ2
	WHERE KQ2.MAHV = KQ.MAHV
		AND KQ2.KQUA = 'Khong dat'
		AND KQ2.LANTHI >= ALL ( -- Truy vấn lần thi sau cùng
			SELECT KQ3.LANTHI
			FROM KETQUATHI AS KQ3
			WHERE KQ3.MAHV = KQ2.MAHV
				AND KQ3.MAMH = KQ2.MAMH
		)
)
GROUP BY HV.MAHV, (HV.HO + ' ' + HV.TEN); 

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
GROUP BY KQ.MAMH, HV.MAHV, (HV.HO + ' ' + HV.TEN)
ORDER BY KQ.MAMH;
