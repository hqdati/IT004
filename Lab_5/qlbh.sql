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

----------------------------------- Cau 13 ---------------------------------
-- Mỗi một hóa đơn phải có ít nhất một chi tiết hóa đơn. 
CREATE TRIGGER trig_CheckCTHD_insert_update
ON HOADON 
AFTER INSERT, UPDATE
AS 
BEGIN
	IF EXISTS ( -- Kiểm tra tồn tại một hóa đơn không có chi tiết hóa đơn
		SELECT 1
		FROM inserted I
		WHERE NOT EXISTS (
			SELECT 1
			FROM CTHD 
			WHERE CTHD.SOHD = I.SOHD
		)
	)
	BEGIN
		RAISERROR('Hóa đơn phải có ít nhất 1 chi tiết hóa đơn', 16, 1);
		ROLLBACK TRANSACTION;
	END
END

-------------------------------- Test Trigger ------------------------------

-- INSERT 
-- Thêm vào một bản ghi SOHD (1026) có NGHD là 22-07-2006 vào bảng HOADON
INSERT INTO HOADON(SOHD, NGHD, MAKH, MANV, TRIGIA)
VALUES (1026,'07-22-2006', 'KH11', 'NV05',5000);
----> Kết quả: Gây lỗi "Hóa đơn phải có ít nhất một chi tiết hóa đơn."

-- UPDATE
-- Sử dụng HOADON 1001 đã có trong bảng HOADON và thỏa mãn ràng buộc toàn vẹn (tồn tại trong bảng CTHD)
----> UPDATE: thay đổi SOHD thành 1026
UPDATE HOADON
SET SOHD = 1026
WHERE SOHD = 1001;
----> Kết quả: Gây ra lỗi, vì vi phạm ràng buộc toàn vẹn khóa ngoại (FK) 
--             nên sẽ kiểm tra điều kiện của khóa ngoại (FK) trước 


-----------------------------  Cau 14 -----------------------------
-- Trị giá của một hóa đơn là tổng thành tiền (số lượng*đơn giá) của các chi tiết thuộc hóa đơn đó. 

------------------------------ Lưu ý ----------------------------
-- Vì mọi thao tác thêm (INSERT), sửa (UPDATE), xóa (DELETE) đều 
-- thực hiện trên bảng CTHD, nên ta sẽ cập nhật lại TRIGIA trong bảng HOADON mỗi khi 
-- một bản ghi được thêm (INSERT), sửa (UPDATE), hoặc xóa (DELETE) trong bảng CTHD

CREATE TRIGGER trig_TriGia_insert_update_delete
ON CTHD
AFTER INSERT, UPDATE, DELETE 
AS
BEGIN
	-- Danh sách các hóa đơn bị ảnh hưởng từ inserted hoặc deleted
	DECLARE @AffectedInvoices TABLE (SOHD INT)

	-- Thêm vào bảng AffectedInvoices các hóa đơn bị ảnh hưởng
	INSERT INTO @AffectedInvoices
	SELECT I.SOHD
	FROM inserted I
	UNION
	SELECT D.SOHD
	FROM deleted D

	-- Cập nhật lại TRIGIA
	UPDATE HOADON 
	SET HOADON.TRIGIA = ( -- Cập nhật lại TRIGIA với các hóa đơn bị ảnh hưởng
		SELECT SUM(CTHD.SL * SP.GIA)
		FROM CTHD 
		JOIN SANPHAM AS SP
		ON CTHD.MASP = SP.MASP
		WHERE HOADON.SOHD = CTHD.SOHD
	)
	WHERE HOADON.SOHD IN ( -- Đảm bảo cập nhật đúng các hóa đơn bị ảnh hưởng, nằm trong 2 bảng (inserted và deleted)
		SELECT SOHD
		FROM @AffectedInvoices
	)
END

------------------------- Test Trigger ---------------------------

---------------------------- INSERT ------------------------------
SELECT * FROM HOADON WHERE SOHD = 1001; -- Ban đầu TRIGIA = 320000

-- Thêm 10 sản phẩm TV03 vào SOHD 1001
INSERT INTO CTHD (SOHD, MASP, SL) 
VALUES (1001, 'TV03', 10);

-- Sau khi thêm, TRIGIA = 350000
SELECT * FROM HOADON WHERE SOHD = 1001;

--------------------------- UPDATE -------------------------------
SELECT * FROM HOADON WHERE SOHD = 1001; -- Ban đầu TRIGIA = 350000

-- Sửa số lượng của MASP 'TV03' thành 15
UPDATE CTHD 
SET SL = 15
WHERE SOHD = 1001 AND MASP = 'TV03';

-- Sau khi sửa, TRIGIA = 365000
SELECT * FROM HOADON WHERE SOHD = 1001;

--------------------------- DELETE --------------------------------
SELECT * FROM HOADON WHERE SOHD = 1001; -- Ban đầu TRIGIA = 365000

-- Xóa bản ghi có SOHD = 1001 và MASP = 'TV03' trong bảng CTHD
DELETE FROM CTHD
WHERE SOHD = 1001 AND MASP = 'TV03';

-- Sau khi xóa, TRIGIA = 320000
SELECT * FROM HOADON WHERE SOHD = 1001;
