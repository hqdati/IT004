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


-- HOADON: INSERT
CREATE TRIGGER NGHD_NGDK_HOADON_INSERT
ON HOADON
FOR INSERT
AS
BEGIN
	DECLARE @NGHD SMALLDATETIME, @NGDK SMALLDATETIME

	SELECT @NGHD = NGHD
	FROM inserted

	SELECT @NGDK = NGDK
	FROM inserted 
	JOIN KHACHHANG ON inserted.MAKH = KHACHHANG.MAKH

	IF(@NGHD < @NGDK)
	BEGIN
		PRINT 'NGAY HOA DON KHONG HOP LE'
		ROLLBACK TRANSACTION
	END
	ELSE 
	BEGIN
		PRINT 'THEM HOA DON THANH CONG'
	END
END

-- Test Trigger
INSERT INTO HOADON(SOHD, NGHD, MAKH, MANV, TRIGIA)
VALUES (1026, '2006-07-10 00:00:00', 'KH01', 'NV01', 10000000);


--- HOADON: UPDATE(NGHD, MAKH)
CREATE TRIGGER NGHD_NGDK_HOADON_UPDATE
ON HOADON
FOR UPDATE
AS 
BEGIN
	DECLARE @NGHD SMALLDATETIME, @NGDK SMALLDATETIME

	SELECT @NGHD = NGHD
	FROM inserted

	SELECT @NGDK = NGDK
	FROM KHACHHANG
	JOIN inserted ON inserted.MAKH = KHACHHANG.MAKH

	IF(@NGHD < @NGDK)
	BEGIN
		PRINT 'UPDATE HOA DON KHONG THANH CONG'
		ROLLBACK TRANSACTION
	END
	ELSE 
	BEGIN
		PRINT 'UPDATE HOA DON THANH CONG'
	END
END

-- Test Trigger
UPDATE HOADON
SET NGHD = '2006-07-20 00:00:00'
WHERE SOHD = 1001;


-- KHACHHANG: UPDATE(NGDK)
CREATE TRIGGER NGHD_NGDK_KHACHHANG_UPDATE
ON KHACHHANG
FOR UPDATE
AS 
BEGIN
	DECLARE @NGDK SMALLDATETIME
	DECLARE @NGHD_TABLE TABLE (NGHD SMALLDATETIME)

	SELECT @NGDK = NGDK -- biến lưu trữ ngày hóa đơn thay đổi
	FROM inserted -- dữ liệu thay đổi lưu trong inserted

	INSERT INTO @NGHD_TABLE -- Vì có nhiều giá trị NGHD, nên cần lưu vào TABLE
	SELECT HOADON.NGHD
	FROM HOADON
	JOIN inserted ON inserted.MAKH = HOADON.MAKH

	IF EXISTS (
		SELECT *
		FROM @NGHD_TABLE AS nghd
		WHERE nghd.NGHD < @NGDK
	)
	BEGIN
		PRINT 'UPDATE NGDK KHONG THANH CONG'
		ROLLBACK TRANSACTION
	END
	ELSE 
	BEGIN
		PRINT 'UPDATE NGDK THANH CONG'
	END
END

DROP TRIGGER [NGHD_NGDK_KHACHHANG_UPDATE];

-- Test Trigger
UPDATE KHACHHANG
SET NGDK = '2006-07-31'
WHERE MAKH = 'KH01';

------------------------------ Cau 12 -------------------------------
-- Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.
