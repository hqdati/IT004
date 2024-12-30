USE QuanLyBanHang;

--------------------------- Bai Tap 1 ---------------------------
-- Phần I bài tập QuanLyBanHang từ câu 11 đến câu 14

--------------------------- Cau 11 ---------------------------
-- Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó 
-- đăng ký thành viên (NGDK). 

----------------------- Bảng tầm ảnh hưởng ----------------------------
--> Bối cảnh: HOADON, KHACHHANG
--> Bảng tầm ảnh hưởng:
--  HOADON: INSERT, UPDATE(NGHD, MAKH)
--  KHACHANG: UPDATE(NGDK)


-- HOADON: INSERT, UPDATE(NGHD, MAKH)
CREATE TRIGGER NGHD_NGDK_HOADON_INSERT_UPDATE
ON HOADON
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @NGHD SMALLDATETIME, @NGDK SMALLDATETIME, @MAKH CHAR(4)

	SELECT @NGHD = NGHD, @MAKH = MAKH 
	FROM inserted 

	SELECT @NGDK = NGDK 
	FROM KHACHHANG 
	WHERE KHACHHANG.MAKH = @MAKH

	IF (@NGHD < @NGDK)
	BEGIN
		PRINT 'KHONG THOA DIEU KIEN: NGHD >= NGDK --> INSERT/UPDATE HOA DON KHONG THANH CONG';
		ROLLBACK TRANSACTION;
	END
	ELSE 
	BEGIN
		PRINT 'THOA DIEU KIEN: NGHD >= NGDK --> INSERT/UPDATE HOA DON THANH CONG';
	END
END

-- DROP TRIGGER NGHD_NGDK_HOADON_INSERT_UPDATE;

-- Test Trigger
UPDATE HOADON
SET NGHD = '2006-06-20 00:00:00'
WHERE SOHD = 1001;

UPDATE HOADON 
SET MAKH = 'KH03'
WHERE SOHD = 1001;

INSERT INTO HOADON(SOHD, NGHD, MAKH, MANV, TRIGIA)
VALUES (1026, '2006-07-10 00:00:00', 'KH01', 'NV01', 10000000);


-- KHACHHANG: UPDATE(NGDK)
CREATE TRIGGER NGHD_NGDK_KHACHHANG_UPDATE
ON KHACHHANG
FOR UPDATE
AS
BEGIN
	DECLARE @MAKH CHAR(4), @NGDK SMALLDATETIME
	DECLARE @NGHD_TABLE TABLE (NGHD SMALLDATETIME)

	SELECT @MAKH = MAKH, @NGDK = NGDK 
	FROM inserted

	INSERT INTO @NGHD_TABLE
	SELECT HD.NGHD
	FROM HOADON AS HD
	WHERE HD.MAKH = @MAKH

	IF EXISTS (
		SELECT *
		FROM @NGHD_TABLE AS tmp
		WHERE tmp.NGHD < @NGDK
	)
	BEGIN
		PRINT 'KHONG THOA DIEU KIEN: NGHD >= NGDK --> UPDATE NGDK KHONG THANH CONG';
		ROLLBACK TRANSACTION;
	END
	ELSE
	BEGIN
		PRINT 'THOA DIEU KIEN: NGHD >= NGDK --> UPDATE NGDK THANH CONG'
	END
END

-- DROP TRIGGER [NGHD_NGDK_KHACHHANG_UPDATE];

-- Test Trigger
UPDATE KHACHHANG
SET NGDK = '2006-08-31'
WHERE MAKH = 'KH01';

------------------------------ Cau 12 -------------------------------
-- Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.

------------------------ Bảng tầm ảnh hưởng ----------------------------
--> Bối cảnh: HOADON, NHANVIEN
--> Bảng tầm ảnh hưởng:
--  HOADON: INSERT, UPDATE(MANV, NGHD)
--  NHANVIEN: UPDATE(NGVL)


-- HOADON: INSERT, UPDATE(MANV, NGHD)
CREATE TRIGGER NGHD_NGVL_HOADON_INSERT_UPDATE
ON HOADON
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MANV CHAR(4), @NGVL SMALLDATETIME, @NGHD SMALLDATETIME

	SELECT @MANV = MANV, @NGHD = NGHD
	FROM inserted

	SELECT @NGVL = NGVL 
	FROM NHANVIEN
	WHERE NHANVIEN.MANV = @MANV 

	IF (@NGVL > @NGHD)
	BEGIN
		PRINT 'KHONG THOA DIEU KIEN: NGHD >= NGVL --> UPDATE HOA DON KHONG THANH CONG'
		ROLLBACK TRANSACTION
	END
	ELSE 
	BEGIN
		PRINT 'THOA DIEU KIEN: NGHD >= NGVL --> UPDATE HOA DON THANH CONG'
	END
END

-- Test Trigger
UPDATE HOADON 
SET NGHD = '2006-07-18 00:00:00'
WHERE SOHD = 1025;

UPDATE HOADON 
SET MANV = 'NV06'
WHERE SOHD = 1024;

INSERT INTO HOADON (SOHD, NGHD, MANV, TRIGIA)
VALUES (1026, '2006-04-10 00:00:00', 'NV02', 100000);

-- UPDATE: NHANVIEN
CREATE TRIGGER NGHD_NGVL_NHANVIEN_UPDATE
ON NHANVIEN
FOR UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT *
		FROM inserted
		JOIN HOADON
		ON inserted.MANV = HOADON.MANV
		WHERE inserted.NGVL > HOADON.NGHD
	)
	BEGIN
		PRINT 'KHONG THOA DIEU KIEN: NGHD >= NGVL --> UPDATE NGVL CUA NHAN VIEN KHONG THANH CONG'
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		PRINT 'THOA DIEU KIEN: NGHD >= NGVL --> UPDATE NGVL CUA NHAN VIEN THANH CONG'
	END
END

-- Test Trigger
UPDATE NHANVIEN 
SET NGVL = '2006-07-19 00:00:00'
WHERE MANV = 'NV05';

UPDATE NHANVIEN 
SET NGVL = '2006-07-25 00:00:00'
WHERE MANV = 'NV05';

----------------------------- Cau 13 ------------------------------
-- Mỗi một hóa đơn phải có ít nhất một chi tiết hóa đơn. 


------------------------ Bảng tầm ảnh hưởng ----------------------------
--> Bối cảnh: CTHD, HOADON
--> Bảng tầm ảnh hưởng:
--  CTHD: DELETE, INSERT

-- INSERT
CREATE TRIGGER CTHD_INSERT
ON CTHD
AFTER INSERT, DELETE
AS
BEGIN
	-- INSERT
	IF EXISTS (
		SELECT *
		FROM HOADON AS HD
		WHERE NOT EXISTS (
			SELECT *
			FROM inserted
			WHERE inserted.SOHD = HD.SOHD
		)
	)
	BEGIN
		PRINT 'KHONG THOA DIEU KIEN: HOA DON PHAI CO IT NHAT MOT CTHD --> INSERT CTHD KHONG THANH CONG'
		ROLLBACK TRANSACTION
	END
	ELSE 
		PRINT 'THOA DIEU KIEN: HOA DON PHAI CO IT NHAT MOT CTHD --> INSERT CTHD THANH CONG'
END

-- DELETE
CREATE TRIGGER CTHD_DELETE
ON CTHD
FOR DELETE
AS
BEGIN
	-- DELETE
	IF EXISTS (
		SELECT *
		FROM HOADON AS HD
		WHERE NOT EXISTS (
			SELECT *
			FROM deleted
			WHERE deleted.SOHD = HD.SOHD
		)
	)
	BEGIN
		PRINT 'KHONG THOA DIEU KIEN: HOA DON PHAI CO IT NHAT MOT CTHD --> XOA CTHD KHONG THANH CONG'
		ROLLBACK TRANSACTION
	END
	ELSE 
		PRINT 'THOA DIEU KIEN: HOA DON PHAI CO IT NHAT MOT CTHD --> XOA CTHD THANH CONG'
END

-- Test Trigger
DELETE FROM CTHD
WHERE SOHD = 1021 AND MASP = 'ST08'; --> XOA THANH CONG

DELETE FROM CTHD 
WHERE SOHD = 1024 AND MASP = 'TV02'; --> XOA KHONG THANH CONG


----------------------------- Cau 14 -----------------------------
-- Trị giá của một hóa đơn là tổng thành tiền (số lượng*đơn giá) của các chi tiết thuộc hóa đơn đó.

------------------------ Bảng tầm ảnh hưởng ----------------------------
--> Bối cảnh: CTHD, HOADON, SANPHAM
--> Bảng tầm ảnh hưởng:
--  HOADON: UPDATE(TRIGIA)
--  CTHD: INSERT, DELETE, UPDATE(SL)

-- CTHD: INSERT
CREATE TRIGGER TRIGIA_CTHD_INSERT
ON CTHD
FOR INSERT
AS
BEGIN
    -- Khởi tạo các biến
    DECLARE @SOHD INT, @TRIGIA MONEY

    -- Lấy giá trị SOHD từ bản ghi mới thêm vào
    SELECT @SOHD = SOHD FROM inserted

    -- Tính trị giá tổng của hóa đơn mới bằng cách cộng tất cả trị giá của từng sản phẩm
    SELECT @TRIGIA = SUM(SL * GIA)
    FROM CTHD C
    JOIN SANPHAM S ON C.MASP = S.MASP
    WHERE C.SOHD = @SOHD

    -- Cập nhật lại trị giá hóa đơn
    UPDATE HOADON
    SET TRIGIA = @TRIGIA
    WHERE SOHD = @SOHD
END

DROP TRIGGER TRIGIA_CTHD_INSERT

-- Test Trigger
INSERT INTO CTHD (SOHD, MASP, SL)
VALUES (1001, 'ST03', 5);

-- Ban đầu trị giá là 45000
-- Sau khi thêm, trị giá thành 300000, với MASP(ST03) có giá là 51000
SELECT * FROM HOADON WHERE SOHD = 1001;

-- CTHD: DELETE
CREATE TRIGGER TRIGIA_CTHD_DELETE
ON CTHD
FOR DELETE
AS 
BEGIN
	-- Khởi tạo các biến
	DECLARE @SOHD INT, @TRIGIA MONEY

	-- Gán giá trị của hóa đơn
	SELECT @SOHD = SOHD
	FROM deleted

	-- Tính trị giá mới sau khi xóa chi tiết
	SELECT @TRIGIA = SUM(SL * GIA)
	FROM CTHD c
	JOIN SANPHAM s ON c.MASP = s.MASP
	WHERE c.SOHD = @SOHD

	-- Cập nhật trị giá mới cho hóa đơn
	UPDATE HOADON
	SET TRIGIA = @TRIGIA
	WHERE SOHD = @SOHD
END

DROP TRIGGER TRIGIA_CTHD_DELETE

-- Test Trigger
INSERT INTO CTHD (SOHD, MASP, SL)
VALUES (1001, 'BB01', 5);

SELECT * FROM HOADON WHERE SOHD = 1001;

DELETE FROM CTHD
WHERE SOHD = 1001 AND MASP = 'BB01';

SELECT * FROM HOADON WHERE SOHD = 1001;

-- CTHD: UPDATE(SL)
CREATE TRIGGER TRIGIA_CTHD_UPDATE
ON CTHD
FOR UPDATE
AS
BEGIN
	-- Khởi tạo 
	DECLARE @TRIGIA MONEY, @SOHD INT

	-- Lấy hóa đơn thay đổi
	SELECT @SOHD = SOHD
	FROM inserted

	-- Thực hiện tính toán lại trị giá
	SELECT @TRIGIA = SUM(SL * GIA)
	FROM CTHD c
	JOIN SANPHAM sp ON c.MASP = sp.MASP
	WHERE c.SOHD = @SOHD

	-- Update lại trị giá của hóa đơn
	UPDATE HOADON 
	SET TRIGIA = @TRIGIA
	WHERE SOHD = @SOHD
END

-- Test trigger
SELECT * FROM CTHD WHERE SOHD = 1001;
SELECT * FROM HOADON WHERE SOHD = 1001;

UPDATE CTHD 
SET SL = 10
WHERE SOHD = 1001 AND MASP = 'ST03';

SELECT * FROM CTHD WHERE SOHD = 1001;
SELECT * FROM HOADON WHERE SOHD = 1001;

-- HOADON: UPDATE(TRIGIA)
CREATE TRIGGER TRIGIA_HOADON_UPDATE
ON HOADON
FOR UPDATE
AS 
BEGIN
	-- Khởi tạo
	DECLARE @TRIGIA_BANDAU MONEY
	DECLARE @TRIGIA MONEY, @SOHD INT

	-- Lấy trị giá sau khi thay đổi
	SELECT @TRIGIA = TRIGIA
	FROM inserted

	-- Lấy số hóa đơn thay đổi
	SELECT @SOHD = SOHD 
	FROM inserted

	-- Tính toán lại trị giá ban đầu
	--> So sánh với trị giá thay đổi
	--> Khác --> In thông báo lỗi
	--> Giống --> Không in gì cả
	SELECT @TRIGIA_BANDAU = TRIGIA 
	FROM deleted
	WHERE deleted.SOHD = @SOHD

	-- Tiến hành so sánh
	IF(@TRIGIA <> @TRIGIA_BANDAU)
	BEGIN
		PRINT 'KHONG DUOC PHEP THAY DOI TRI GIA CUA HOA DON';
		ROLLBACK TRANSACTION;
	END
END

DROP TRIGGER TRIGIA_HOADON_UPDATE;

-- Test Trigger
UPDATE HOADON 
SET TRIGIA = 500000
WHERE SOHD = 1001;
