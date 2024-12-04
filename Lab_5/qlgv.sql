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

----------------------------------- Cau 17 ------------------------------------
-- Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó. 

-- Tạo trigger đảm bảo sỉ số của lớp khi thêm hoặc xóa bằng số lượng học viên
CREATE TRIGGER trig_ClassAttendants_insert_update
ON LOP
FOR INSERT, UPDATE
AS 
BEGIN
	IF EXISTS (
		SELECT 1
		FROM inserted I
		WHERE I.SISO <> (
			SELECT COUNT(DISTINCT MAHV)
			FROM HOCVIEN AS HV
			WHERE I.MALOP = HV.MALOP
		)
	)
	BEGIN
		RAISERROR('Sỉ số của một lớp phải bằng số lượng học viên thuộc lớp đó', 16, 1);
		ROLLBACK TRANSACTION;
	END
END;

-- Tạo trigger đảm bảo khi học viên đó chuyển lớp, hoặc nghỉ học, hoặc mới nhập học
-- thì sĩ số của lớp vẫn được đảm bảo
CREATE TRIGGER trg_updateAttendants_HOCVIEN_insert_udpate_delete
ON HOCVIEN
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @AffectedNumberOfAttendants TABLE (MALOP CHAR(3));

	-- Lấy các lớp bị ảnh hưởng khi thêm, xóa, và sửa học viên
	INSERT INTO @AffectedNumberOfAttendants
	SELECT i.MALOP
	FROM inserted AS i
	UNION
	SELECT d.MALOP
	FROM deleted AS d

	-- Cập nhật lại các lớp bị ảnh hưởng
	UPDATE LOP
	SET LOP.SISO = (
		SELECT COUNT(DISTINCT HV.MAHV)
		FROM HOCVIEN AS HV
		WHERE HV.MALOP = LOP.MALOP
	)
	WHERE LOP.MALOP IN (
		SELECT MALOP
		FROM @AffectedNumberOfAttendants
	)
END;

-------------------------------- Cau 18 ---------------------------

-------------------------------- Cau 19 ---------------------------
-- Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau.
CREATE TRIGGER trig_TeacherWage_insert_update
ON GIAOVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        -- Kiểm tra xem có giáo viên nào có cùng học vị, học hàm, và hệ số lương nhưng mức lương khác nhau
        SELECT 1
        FROM inserted AS I
        JOIN GIAOVIEN AS GV
        ON GV.HOCHAM = I.HOCHAM 
		   AND GV.HOCVI = I.HOCVI 
		   AND GV.HESO = I.HESO
		   -- AND GV.MAGV = I.MAGV 
		   ----> Nếu thêm dòng này thì chỉ kiểm tra với các giáo viên mới (MAGV) mới được thêm vào, cập nhật
		   ----> Không kiểm tra với các bản ghi đã có sẵn trong bảng GIAOVIEN

        WHERE GV.MUCLUONG <> I.MUCLUONG -- Kiểm tra mức lương khác nhau
        AND GV.MAGV <> I.MAGV -- Đảm bảo không so sánh với chính bản thân giáo viên vừa cập nhật
    )
    BEGIN
        RAISERROR('Giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương phải bằng nhau', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;


-------------------------------- Cau 20 ---------------------------------
-- Học viên chỉ được thi lại (lần thi > 1) khi điểm của lần thi trước đó dưới 5.
CREATE TRIGGER trig_canHaveTestAgain_HOCVIEN_insert_update_delete
ON KETQUATHI
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @AffectedStudent TABLE (MAHV CHAR(5), LANTHI TINYINT, MAMH VARCHAR(10));

	INSERT INTO @AffectedStudent
	SELECT I.MAHV, I.LANTHI, I.MAMH
	FROM inserted AS I
	UNION 
	SELECT D.MAHV, D.LANTHI, D.MAMH
	FROM deleted AS D;

	IF EXISTS (
		SELECT 1
		FROM KETQUATHI AS KQ
		JOIN @AffectedStudent AS affected
		ON affected.MAHV = KQ.MAHV AND affected.MAMH = KQ.MAMH
		WHERE affected.LANTHI > 1 -- LANTHI > 1 (thi lại)
			  AND EXISTS (
				-- Kiểm tra lần thi trước đó của học viên
				SELECT 1
				FROM KETQUATHI AS prev_KQ
				WHERE prev_KQ.MAHV = KQ.MAHV
				  AND prev_KQ.MAMH = KQ.MAMH
				  AND prev_KQ.LANTHI = affected.LANTHI - 1 -- Kiểm tra lần thi trước
				  AND prev_KQ.DIEM >= 5 -- Điểm lần thi trước >= 5
			  )
	)
	BEGIN
		RAISERROR('Học viên chỉ được thi lại (lần thi > 1) khi điểm lần thi trước đó dưới 5', 16, 1);
		ROLLBACK TRANSACTION;
	END 
END;

------------------------------- Cau 21 -------------------------------
-- Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn 
-- học).
CREATE TRIGGER trig_ngayThiLanTiepTheo_insert_update_delete
ON KETQUATHI
FOR INSERT, UPDATE, DELETE
AS 
BEGIN
	DECLARE @AffectedStudent TABLE (MAHV CHAR(5), MAMH VARCHAR(10), LANTHI TINYINT)

	INSERT INTO @AffectedStudent
	SELECT I.MAHV, I.MAMH, I.LANTHI
	FROM inserted I
	UNION
	SELECT D.MAHV, D.MAMH, D.LANTHI
	FROM deleted D

	IF EXISTS (
		SELECT 1
		FROM KETQUATHI AS KQ
		JOIN @AffectedStudent AS affected
		ON KQ.MAHV = affected.MAHV AND KQ.MAMH = affected.MAMH
		WHERE KQ.LANTHI > 1 
			AND EXISTS (
				SELECT 1
				FROM KETQUATHI AS prev_KQ
				WHERE KQ.MAHV = prev_KQ.MAHV
					AND KQ.MAMH = prev_KQ.MAMH
					AND KQ.LANTHI - 1 = prev_KQ.LANTHI
					AND KQ.NGTHI <= prev_KQ.NGTHI
			)
	)
	BEGIN
		RAISERROR('Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước', 16, 1);
		ROLLBACK TRANSACTION;
	END
END;

------------------------------ Cau 22 ---------------------------
-- Học viên chỉ được thi những môn mà lớp của học viên đó đã học xong. 
CREATE TRIGGER trig_CanHaveTest_insert_update
ON KETQUATHI
AFTER INSERT, UPDATE
AS 
BEGIN
	IF EXISTS (
		SELECT 1
		FROM inserted AS I
		JOIN HOCVIEN AS HV
			ON HV.MAHV = I.MAHV
		JOIN GIANGDAY AS GD
			ON GD.MALOP = HV.MALOP AND 
			   GD.MAMH = I.MAMH
		WHERE I.NGTHI < GD.DENNGAY
	)
	BEGIN
		RAISERROR('Học viên chỉ được thi những môn mà lớp của học viên đó đã học xong', 16, 1);
		ROLLBACK TRANSACTION;
	END
END;

------------------------------ Cau 23 -----------------------------
-- Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau 
-- khi học xong những môn học phải học trước mới được học những môn liền sau). 
CREATE TRIGGER trig_GiangDay_insert_update
ON GIANGDAY 
FOR INSERT, UPDATE
AS 
BEGIN
	IF NOT EXISTS (
		SELECT 1
		FROM inserted AS I
		JOIN DIEUKIEN AS DK
		ON I.MAMH = DK.MAMH
		WHERE DK.MAMH_TRUOC IN (
			SELECT GD.MAMH
			FROM GIANGDAY AS GD
			WHERE GD.MALOP = I.MALOP AND I.MAMH <> GD.MAMH
		) AND DK.MAMH_TRUOC IS NOT NULL
	)
	BEGIN
		RAISERROR('Môn học tiên quyết chưa được học xong!', 16, 1);
		ROLLBACK TRANSACTION;
	END 
END;

-------------------------- Cau 24 ------------------------------
-- Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách. 
CREATE TRIGGER trig_phanCongGiangDay_insert_update
ON GIANGDAY
FOR INSERT, UPDATE
AS
BEGIN
	IF NOT EXISTS (
		SELECT 1
		FROM inserted AS I
		WHERE I.MAGV IN (
			SELECT GV.MAGV
			FROM GIAOVIEN AS GV
			JOIN MONHOC AS MH
			ON GV.MAKHOA = MH.MAKHOA
				AND GV.MAGV = I.MAGV
		) AND I.MAMH IN (
			SELECT MH.MAMH
			FROM GIAOVIEN AS GV
			JOIN MONHOC AS MH
			ON GV.MAKHOA = MH.MAKHOA
				AND GV.MAGV = I.MAGV
		)
	)	
	BEGIN
		RAISERROR('Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách', 16, 1);
		ROLLBACK TRANSACTION;
	END
END;
