USE QuanLyGiaoVu;

------------------------ Bai Tap 2 -----------------------
-- Phần II bài tập QuanLyGiaoVu từ câu 1 đến câu 4



-- II. Ngôn ngữ thao tác dữ liệu (Data Manipulation Language): 

------------------------- Cau 1 ----------------------------
-- Tăng hệ số lương thêm 0.2 cho những giáo viên là trưởng khoa. 

UPDATE GIAOVIEN
SET HESO = HESO + 0.2
WHERE EXISTS (
	SELECT *
	FROM KHOA AS K
	WHERE K.TRGKHOA = GIAOVIEN.MAGV
);


------------------------- Cau 2 ----------------------------
-- Cập nhật giá trị điểm trung bình tất cả các môn học  (DIEMTB) của mỗi học viên (tất cả các 
-- môn học đều có hệ số 1 và nếu học viên thi một môn nhiều lần, chỉ lấy điểm của lần thi sau 
-- cùng). 


-- C1:
UPDATE HOCVIEN
SET DIEMTB = (
	SELECT AVG(KQ.DIEM)
	FROM KETQUATHI AS KQ
	WHERE KQ.MAHV = HOCVIEN.MAHV
	AND NOT EXISTS (
		-- Tìm lần thi cuối cùng
		SELECT 1
		FROM KETQUATHI AS KQ2
		WHERE KQ2.MAHV = KQ.MAHV
		AND KQ2.MAMH = KQ.MAMH
		AND KQ2.LANTHI > KQ.LANTHI
));

-- C2:
UPDATE HOCVIEN
SET HOCVIEN.DIEMTB = (
	SELECT AVG(KQ.DIEM) 
	FROM KETQUATHI AS KQ
	WHERE KQ.MAHV = HOCVIEN.MAHV
		AND KQ.LANTHI >= ALL ( -- Tìm lần thi cuối cùng
			SELECT KQ2.LANTHI
			FROM KETQUATHI AS KQ2
			WHERE KQ2.MAHV = HOCVIEN.MAHV AND KQ.MAMH = KQ2.MAMH
		)
);

--------------------------- Cau 3 -------------------------------
-- Cập nhật giá trị cho cột GHICHU là “Cam thi” đối với trường hợp: học viên có một môn bất 
-- kỳ thi lần thứ 3 dưới 5 điểm.

UPDATE HOCVIEN 
SET GHICHU = 'Cam thi'
WHERE EXISTS (
	SELECT 1
	FROM KETQUATHI AS KQ
	WHERE KQ.MAHV = HOCVIEN.MAHV AND
		  KQ.LANTHI = 3 AND 
		  KQ.DIEM < 5
);

-------------------------- Cau 4 ------------------------------
-- Cập nhật giá trị cho cột XEPLOAI trong quan hệ HOCVIEN như sau: 
-- o Nếu DIEMTB >= 9 thì XEPLOAI = "XS"
-- o Nếu  8 <= DIEMTB < 9 thì XEPLOAI = “G” 
-- o Nếu  6.5 <= DIEMTB < 8 thì XEPLOAI = “K” 
-- o Nếu  5  <=  DIEMTB < 6.5 thì XEPLOAI = “TB” 
-- o Nếu  DIEMTB < 5 thì XEPLOAI = ”Y” 

UPDATE HOCVIEN
SET XEPLOAI = (
	CASE 
		WHEN HOCVIEN.DIEMTB >= 9 THEN 'XS'
		WHEN HOCVIEN.DIEMTB >= 8 AND HOCVIEN.DIEMTB < 9 THEN 'G'
		WHEN HOCVIEN.DIEMTB >= 6.5 AND HOCVIEN.DIEMTB < 8 THEN 'K'
		WHEN HOCVIEN.DIEMTB >= 5 AND HOCVIEN.DIEMTB < 6.5 THEN 'TB'
		ELSE 'Y'
	END
);


----------------------------- Bai Tap 3 ------------------------------
-- Phần III bài tập QuanLyGiaoVu từ câu 6 đến câu 10

------------------------------ Cau 6 ---------------------------
-- Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 2006

-- C1: Sử dụng Subquerry
SELECT MH.MAMH AS [MaMonHoc],
	   MH.TENMH AS [TenMonHoc]
FROM MONHOC AS MH
WHERE EXISTS (
	SELECT *
	FROM GIAOVIEN AS GV
	JOIN GIANGDAY AS GD
	ON GV.MAGV = GD.MAGV
	WHERE GV.HOTEN = 'Tran Tam Thanh' 
		AND GD.HOCKY = 1 
		AND GD.NAM = 2006
		AND MH.MAMH = GD.MAMH
);

-- C2: Tối ưu hơn
SELECT DISTINCT MH.MAMH AS [MaMonHoc],
				MH.TENMH AS [TenMonHoc]
FROM MONHOC AS MH
JOIN GIANGDAY AS GD
ON MH.MAMH = GD.MAMH
JOIN GIAOVIEN AS GV
ON GV.MAGV = GD.MAGV
WHERE GV.HOTEN = 'Tran Tam Thanh' 
	AND GD.HOCKY = 1 
	AND GD.NAM = 2006;

-------------------------- Cau 7 ----------------------------
-- Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy 
-- trong học kỳ 1 năm 2006. 

-- C1: Sử dụng Subquery
SELECT MH.MAMH AS [MaMonHoc],
	   MH.TENMH AS [TenMonHoc]
FROM MONHOC AS MH
WHERE EXISTS (
	SELECT *
	FROM LOP AS L
	JOIN GIANGDAY AS GD
	ON L.MAGVCN = GD.MAGV
	WHERE L.MALOP = 'K11' 
		AND GD.NAM = 2006 
		AND GD.HOCKY = 1
		AND GD.MAMH = MH.MAMH
);

-- C2: Cách tối ưu hơn
SELECT DISTINCT MH.MAMH AS [MaMonHoc],
				MH.TENMH AS [TenMonHoc]
FROM MONHOC AS MH
JOIN GIANGDAY AS GD
ON GD.MAMH = MH.MAMH
JOIN LOP AS L
ON L.MAGVCN = GD.MAGV
WHERE L.MALOP = 'K11' 
	AND GD.NAM = 2006
	AND GD.HOCKY = 1;

----------------------------- Cau 8 ------------------------
-- Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So 
-- Du Lieu”. 

-- C1:
SELECT (HV.HO + ' ' + HV.TEN) AS [HoTen]
FROM HOCVIEN AS HV
WHERE HV.MAHV IN (
	SELECT L.TRGLOP
	FROM LOP AS L
	WHERE L.MALOP IN (
		SELECT DISTINCT GD.MALOP
		FROM GIANGDAY AS GD
		WHERE GD.MAGV IN (
			SELECT GV.MAGV
			FROM GIAOVIEN AS GV
			WHERE GV.HOTEN = 'Nguyen To Lan'
		) AND GD.MAMH IN (
			SELECT MH.MAMH
			FROM MONHOC AS MH
			WHERE MH.TENMH = 'Co So Du Lieu'
		)
	)
);

-- C2:
SELECT (HV.HO + ' ' + HV.TEN) AS [HoTenLopTruong]
FROM LOP AS L
JOIN HOCVIEN AS HV
ON L.TRGLOP = HV.MAHV
WHERE EXISTS (
	SELECT *
	FROM GIANGDAY AS GD
	JOIN GIAOVIEN AS GV
	ON GD.MAGV = GV.MAGV
	JOIN MONHOC AS MH
	ON MH.MAMH = GD.MAMH
	WHERE GV.HOTEN = 'Nguyen To Lan'
		AND MH.TENMH = 'Co So Du Lieu'
		AND L.MALOP = GD.MALOP
);

--------------------------- Cau 9 --------------------------
-- In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So 
-- Du Lieu”.

SELECT MH.MAMH AS [MaMonHoc],
	   MH.TENMH AS [TenMonHoc]
FROM MONHOC AS MH
WHERE MH.MAMH IN (
	SELECT DK.MAMH_TRUOC
	FROM DIEUKIEN AS DK
	WHERE DK.MAMH IN (
		SELECT MH2.MAMH
		FROM MONHOC AS MH2
		WHERE MH2.TENMH = 'Co So Du Lieu'
	)
);

--------------------- Cau 10 -----------------------
-- Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, 
-- tên môn học) nào.

SELECT MH.MAMH AS [MaMonHoc],
	   MH.TENMH AS [TenMonHoc]
FROM MONHOC AS MH
WHERE MH.MAMH IN (
	SELECT DK.MAMH 
	FROM DIEUKIEN AS DK
	WHERE DK.MAMH_TRUOC IN (
		SELECT MH2.MAMH
		FROM MONHOC AS MH2
		WHERE MH2.TENMH = 'Cau Truc Roi Rac'
	)
);


------------------------------ Bai Tap 5 ------------------------------
-- Phần III bài tập QuanLyGiaoVu từ câu 11 đến câu 18

---------------------- Cau 11 --------------------------
-- Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 
-- năm 2006.

-- C1: Sử dụng INTERSECT
SELECT GV.HOTEN AS [HoTenGiaoVien]
FROM GIAOVIEN AS GV
JOIN GIANGDAY AS GD
ON GV.MAGV = GD.MAGV
WHERE GD.MAMH = 'CTRR' 
	AND GD.MALOP = 'K11'
	AND GD.HOCKY = 1
	AND GD.NAM = 2006
INTERSECT
SELECT GV.HOTEN AS [HoTenGiaoVien]
FROM GIAOVIEN AS GV
JOIN GIANGDAY AS GD 
ON GV.MAGV = GD.MAGV
WHERE GD.MAMH = 'CTRR'
	AND GD.MALOP = 'K12'
	AND GD.HOCKY = 1
	AND GD.NAM = 2006;

-- C2: Sử dụng Subquery
SELECT GV.HOTEN AS [HoTenGiaoVien]
FROM GIAOVIEN AS GV
WHERE EXISTS (
	SELECT *
	FROM GIANGDAY AS GD
	WHERE GD.MAMH = 'CTRR'
		AND GD.HOCKY = 1
		AND GD.NAM = 2006
		AND GD.MAGV = GV.MAGV
		AND GD.MALOP = 'K11'
) AND EXISTS (
	SELECT *
	FROM GIANGDAY AS GD
	WHERE GD.MAMH = 'CTRR'
		AND GD.HOCKY = 1
		AND GD.NAM = 2006
		AND GD.MAGV = GV.MAGV
		AND GD.MALOP = 'K12'
);

----------------------- Cau 12 ------------------------
-- Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng 
-- chưa thi lại môn này. 

-- C1:
SELECT HV.MAHV AS [MaHocVien],
	   (HV.Ho + ' ' + HV.TEN) AS [HoTenHocVien]
FROM HOCVIEN AS HV
WHERE EXISTS (
	SELECT *
	FROM KETQUATHI AS KQ
	WHERE KQ.MAMH = 'CSDL'
		AND KQ.LANTHI = 1
		AND KQ.KQUA = 'Khong dat'
		AND KQ.MAHV = HV.MAHV
		AND NOT EXISTS (
			SELECT *
			FROM KETQUATHI AS KQ2
			WHERE KQ2.MAHV = KQ.MAHV
				AND KQ2.MAHV = HV.MAHV
				AND KQ2.MAMH = 'CSDL'
				AND KQ2.LANTHI > 1
		)
);

-- C2:
SELECT HV.MAHV AS [MaHocVien],
	   (HV.HO + ' ' + HV.TEN) AS [HoTen]
FROM HOCVIEN AS HV
WHERE EXISTS (
	SELECT *
	FROM KETQUATHI AS KQ
	WHERE KQ.MAHV = HV.MAHV
		AND KQ.MAMH = 'CSDL'
		AND KQ.KQUA = 'Khong dat'
		AND KQ.LANTHI = 1
		AND KQ.LANTHI >= ALL (
			SELECT KQ2.LANTHI
			FROM KETQUATHI AS KQ2
			WHERE KQ2.MAHV = KQ.MAHV
				AND KQ2.MAMH = KQ.MAMH
		)
);
--------------------------- Cau 13 --------------------------
-- Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào. 
SELECT GV.MAGV AS [MaGiaoVien],
	   GV.HOTEN AS [HoTenGiaoVien]
FROM GIAOVIEN AS GV
WHERE NOT EXISTS (
	SELECT *
	FROM GIANGDAY AS GD
	WHERE GD.MAGV = GV.MAGV
		AND GD.MAMH IS NOT NULL
);

------------------------- Cau 14 ----------------------------
-- Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào 
-- thuộc khoa giáo viên đó phụ trách. 
SELECT GV.MAGV AS [MaGiaoVien],
	   GV.HOTEN AS [HoTenGiaoVien]
FROM GIAOVIEN AS GV
JOIN KHOA AS K
ON K.MAKHOA = GV.MAKHOA
WHERE NOT EXISTS (
	SELECT *
	FROM GIANGDAY AS GD
	JOIN MONHOC AS MH
	ON GD.MAMH = MH.MAMH
	WHERE K.MAKHOA = MH.MAKHOA
		AND GD.MAGV = GV.MAGV
);

-------------------------- Cau 15 ---------------------------
-- Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat” 
-- hoặc thi lần thứ 2 môn CTRR được 5 điểm. 
SELECT (HV.HO + ' ' + HV.TEN) AS [HoTenHocVien]
FROM HOCVIEN AS HV
WHERE HV.MALOP = 'K11' 
	AND (
		EXISTS (
	SELECT *
	FROM KETQUATHI AS KQ1
	WHERE KQ1.MAHV = HV.MAHV
		AND KQ1.LANTHI > 3 
		AND KQ1.KQUA = 'Khong dat'
	)
	OR EXISTS (
	SELECT *
	FROM KETQUATHI AS KQ2
	WHERE KQ2.MAHV = HV.MAHV
		AND KQ2.LANTHI = 2
		AND KQ2.MAMH = 'CTRR'
		AND KQ2.DIEM = 5
	)
);

--------------------------- Cau 16 -----------------------------
-- Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm 
-- học.

-- C1: Sử dụng Subquery
SELECT GV.HOTEN AS [HoTenGiaoVien]
FROM GIAOVIEN AS GV
WHERE EXISTS (
	SELECT GD.MAGV
	FROM GIANGDAY AS GD
	WHERE GD.MAGV = GV.MAGV
		AND GD.MAMH = 'CTRR'
	GROUP BY GD.NAM, GD.HOCKY, GD.MAGV
	HAVING COUNT(DISTINCT GD.MALOP) >= 2
);

-- C2: Tối ưu hơn
SELECT GV.HOTEN AS [HoTenGiaoVien]
FROM GIAOVIEN AS GV
JOIN GIANGDAY AS GD 
ON GV.MAGV = GD.MAGV
WHERE GD.MAMH = 'CTRR'
GROUP BY GD.NAM, GD.HOCKY, GV.MAGV, GV.HOTEN
HAVING COUNT(DISTINCT GD.MALOP) >= 2;

--------------------------- Cau 17 ---------------------------
-- Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng).
SELECT HV.MAHV AS [MaHocVien],
	   (HV.HO + ' ' + HV.TEN) AS [HoTenHocVien],
	   KQ.DIEM AS [KetQuaThi_CSDL]
FROM HOCVIEN AS HV
JOIN KETQUATHI AS KQ
ON HV.MAHV = KQ.MAHV
WHERE KQ.MAMH = 'CSDL'
	AND KQ.LANTHI >= ALL (
		SELECT KQ2.LANTHI
		FROM KETQUATHI AS KQ2
		WHERE KQ2.MAMH = KQ.MAMH
			AND KQ2.MAHV = KQ.MAHV
);

--------------------------- Cau 18 ------------------------------
-- Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần 
-- thi).

SELECT HV.MAHV AS [MaHocVien],
	   (HV.HO + ' ' + HV.TEN) AS [HoTenHocVien],
	   KQ.DIEM AS [KetQuaThi_CSDL]
FROM HOCVIEN AS HV
JOIN KETQUATHI AS KQ
ON HV.MAHV = KQ.MAHV
WHERE KQ.MAMH = 'CSDL' 
	AND KQ.DIEM >= ALL (
		SELECT KQ2.DIEM
		FROM KETQUATHI AS KQ2
		WHERE KQ2.MAMH = KQ.MAMH
			AND KQ2.MAHV = HV.MAHV
);
