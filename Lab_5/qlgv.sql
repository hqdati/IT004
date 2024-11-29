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
END

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
END