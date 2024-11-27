USE QuanLyBanHang;

--------------------------- Bai Tap 1 ---------------------------
-- Phần I bài tập QuanLyBanHang từ câu 11 đến câu 14

--------------------------- Cau 11 ---------------------------
-- Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó 
-- đăng ký thành viên (NGDK). 
CREATE TRIGGER trig_Validate_NGHD_insert_update
ON HOADON 
FOR INSERT, UPDATE
AS
BEGIN
	-- Kiểm tra điều kiện NGHD >= NGDK
	IF EXISTS (
		SELECT 1
		FROM inserted I
		JOIN KHACHHANG AS KH
		ON KH.MAKH = I.MAKH
		WHERE I.NGHD < KH.NGDK
	)
	BEGIN
		RAISERROR('Ngày mua hàng (NGHD) không được nhỏ hơn ngày khách hàng đó đăng ký thành viên (NGDK)', 16, 1);
		ROLLBACK TRANSACTION;
	END
END;

-------------------------- Test trigger -----------------------------

-- Tạo bản ghi KHACHHANG (KH11)
-- NGDK là 15-07-2006
INSERT INTO KHACHHANG(MAKH, HOTEN, DCHI, SODT, NGSINH, NGDK, DOANHSO)
VALUES ('KH11', 'Nguyen Van A', 'Mặt Trăng', '0123456789', '01-14-1985', '07-15-2006', 2000000);

----------------------------- INSERT -------------------------------
-- NGDK của KH11 là 15-07-2006
-- NGHD thêm vào là 10-07-2006 --> KHÔNG HỢP LỆ
INSERT INTO HOADON(SOHD, NGHD, MAKH, MANV, TRIGIA)
VALUES (1024,'07-10-2006', 'KH11', 'NV01',5000);

----------------------------- UPDATE -------------------------------
-- NGDK của KH11 là 15-07-2006
-- Thêm vào bản ghi 1024 có NGHD là 25-07-2006 vào bảng HOADON
-- --> Thực hiện UPDATE lại NGHD là 12-07-2006 --> KHÔNG HỢP LỆ
INSERT INTO HOADON(SOHD, NGHD, MAKH, MANV, TRIGIA)
VALUES (1024,'07-25-2006', 'KH11', 'NV01',5000);

-- UPDATE
UPDATE HOADON
SET NGHD = '07-12-2006'
WHERE SOHD = 1024;

------------------------------------- Cau 12 ---------------------------------
-- Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm. 
CREATE TRIGGER trig_Validate_NGHD2_insert_update
ON HOADON
FOR INSERT, UPDATE
AS
BEGIN
	-- Kiểm tra điều kiện NGHD >= NGVL của nhân viên
	IF EXISTS (
		SELECT 1
		FROM inserted I
		JOIN NHANVIEN AS NV
		ON NV.MANV = I.MANV
		WHERE I.NGHD < NV.NGVL
	)
	BEGIN
		RAISERROR('NGHD không được nhỏ hơn NGVL của nhân viên', 16, 1);
		ROLLBACK TRANSACTION;
	END
END;

----------------------------- Test Trigger ------------------------------

-- KHACHHANG (KH11)
-- NGDK: 15-07-2006

-- NHANVIEN (NV05)
-- NGVL: 20-07-2006

-------------------------------- INSERT ---------------------------------
-- NGVL của NV05 là 20-07-2006
-- NGHD được thêm vào là 18-07-2006 --> KHÔNG HỢP LỆ
INSERT INTO HOADON(SOHD, NGHD, MAKH, MANV, TRIGIA)
VALUES (1025,'07-18-2006', 'KH11', 'NV05',5000);

--------------------------------- UPDATE ---------------------------------
-- NGVL của NV05 là 20-07-2006
-- Thêm vào một bản ghi 1025 có NGHD là 22-07-2006 vào bảng HOADON
--> Thực hiện UPDATE lại bản ghi với NGHD là 18-07-2006
INSERT INTO HOADON(SOHD, NGHD, MAKH, MANV, TRIGIA)
VALUES (1025,'07-22-2006', 'KH11', 'NV05',5000);

-- UPDATE
UPDATE HOADON 
SET NGHD = '07-18-2006'
WHERE SOHD = 1025;
