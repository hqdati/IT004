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
