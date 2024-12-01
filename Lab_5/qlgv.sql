USE QuanLyGiaoVu;

-------------------------------- Bai Tap 2 ----------------------------------
-- Phần I bài tập QuanLyGiaoVu câu 9, 10, và từ câu 15 đến câu 24

---------------------------------- Cau 9 ------------------------------------
-- Lớp trưởng của một lớp phải là học viên của lớp đó.
CREATE TRIGGER  trig_Lop_insert_delete_update
ON LOP 
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @AffectedClass TABLE (MALOP CHAR(3), TRGLOP CHAR(5))

	-- Lấy dữ liệu từ các bản ghi bị thay đổi (inserted và deleted)
	INSERT INTO @AffectedClass
	SELECT I.MALOP, I.TRGLOP
	FROM inserted I
	WHERE I.MALOP IS NOT NULL 
	UNION
	SELECT D.MALOP, D.TRGLOP
	FROM deleted D
	WHERE D.MALOP IS NOT NULL

	-- Kiểm tra xem lớp trưởng có phải là học viên của lớp đó không
	IF EXISTS (
		SELECT 1
		FROM @AffectedClass AS AC
		WHERE NOT EXISTS (
			SELECT 1
			FROM HOCVIEN AS HV
			WHERE HV.MALOP = AC.MALOP AND HV.MAHV = AC.TRGLOP
		)
	)
	BEGIN
		-- Nếu không phải học viên của lớp, báo lỗi
		RAISERROR('Lớp trưởng của một lớp phải là học viên của lớp đó', 16, 1);
		ROLLBACK TRANSACTION;
	END
END;

---------------------------------------- Cau 10 ----------------------------------------
-- Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.
CREATE TRIGGER trig_TruongKhoa_insert_update_delete
ON KHOA
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @AffectedKhoa TABLE (MAKHOA VARCHAR(4), TRGKHOA CHAR(4))

	INSERT INTO @AffectedKhoa
	SELECT I.MAKHOA, I.TRGKHOA
	FROM inserted I
	WHERE I.MAKHOA IS NOT NULL
	UNION
	SELECT D.MAKHOA, D.TRGKHOA
	FROM deleted D
	WHERE D.MAKHOA IS NOT NULL

	IF EXISTS (
		SELECT 1
		FROM @AffectedKhoa AK
		WHERE NOT EXISTS (
			SELECT 1
			FROM GIAOVIEN GV
			WHERE GV.MAKHOA = AK.MAKHOA AND 
				GV.MAGV = AK.TRGKHOA AND 
				GV.HOCVI IN ('TS', 'PTS')
		)
	)
	BEGIN
		RAISERROR('Trường khoa phải là giáo viên thuộc khoa và có học vị ("TS", "PTS")', 16, 1);
		ROLLBACK TRANSACTION;
	END
END;

------------------------------------- Cau 15 ---------------------------------
-- Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.
CREATE TRIGGER trig_canHaveTest_insert_update 
ON KETQUATHI
FOR INSERT, UPDATE
AS 
BEGIN
	-- Kiểm tra học viên có thi trước khi lớp dạy môn đó kết thúc không
	IF EXISTS (
		SELECT 1
		FROM HOCVIEN AS HV
		JOIN GIANGDAY AS GD
		ON HV.MALOP = GD.MALOP
		JOIN inserted I
		ON I.MAHV = HV.MAHV AND I.MAMH = GD.MAMH -- Đảm bảo xác định được kiểm tra đúng môn mà học viên đang học
		WHERE I.NGTHI < GD.DENNGAY
	)
	BEGIN
		RAISERROR('Lớp của học viên chưa học xong môn học này, nên học viên không được thi', 16, 1);
		ROLLBACK TRANSACTION;
	END
END;

------------------------------------ Cau 16 ----------------------------------
-- Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn. 
CREATE TRIGGER trig_numberOfSubjects_insert_update
ON GIANGDAY
FOR INSERT, UPDATE
AS
BEGIN
	-- Đảm bảo 1 lớp trong một học kì của một năm học chỉ được học tối đa 3 môn
	IF EXISTS (
		SELECT 1
		FROM GIANGDAY AS GD
		JOIN inserted I
		ON GD.MALOP = I.MALOP AND GD.NAM = I.NAM AND GD.HOCKY = I.HOCKY
		GROUP BY GD.MALOP, GD.NAM, GD.HOCKY
		HAVING COUNT(DISTINCT GD.MAMH) > 3
	)
	BEGIN
		RAISERROR('Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn', 16, 1);
		ROLLBACK TRANSACTION;
	END
END;
