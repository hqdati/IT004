CREATE DATABASE QuanLyBanHang;

USE QuanLyBanHang;

--------------------- Cau 1 -----------------------------
-- Tạo các quan hệ và khai báo các khóa chính, khóa ngoại của quan hệ. 

--------------------- Khach Hang ----------------------
CREATE TABLE KHACHHANG 
(
	MAKH CHAR(4) NOT NULL PRIMARY KEY,
	HOTEN VARCHAR(40),
	DCHI VARCHAR(50),
	SODT VARCHAR(20),
	NGSINH SMALLDATETIME,
	NGDK SMALLDATETIME,
	DOANHSO MONEY
);

--------------------------- NHAN VIEN ----------------------------
CREATE TABLE NHANVIEN (
	MANV CHAR(4) NOT NULL PRIMARY KEY,
	HOTEN VARCHAR(40),
	SODT VARCHAR(20),
	NGVL SMALLDATETIME
);

-------------------------- SAN PHAM -----------------------------
CREATE TABLE SANPHAM (
	MASP CHAR(4),
	TENSP VARCHAR(40),
	DVT VARCHAR(20),
	NUOCSX VARCHAR(40),
	GIA MONEY
);

ALTER TABLE SANPHAM 
ALTER COLUMN MASP CHAR(4) NOT NULL;

ALTER TABLE SANPHAM 
ADD CONSTRAINT PK_SANPHAM PRIMARY KEY (MASP);

---------------------------- HOA DON ----------------------------
CREATE TABLE HOADON (
	SOHD INT,
	NGHD SMALLDATETIME,
	MAKH CHAR(4),
	MANV CHAR(4) FOREIGN KEY REFERENCES NHANVIEN (MANV),
	TRIGIA MONEY
);

ALTER TABLE HOADON 
ALTER COLUMN SOHD INT NOT NULL;

ALTER TABLE HOADON
ADD CONSTRAINT PK_HOADON PRIMARY KEY (SOHD);

ALTER TABLE HOADON 
ADD CONSTRAINT FK_HOADON_MAKH FOREIGN KEY (MAKH)
REFERENCES KHACHHANG (MAKH);

-------------------------- CTHD -----------------------------
CREATE TABLE CTHD (
	SOHD INT,
	MASP CHAR(4),
	SL INT,
);

ALTER TABLE CTHD
ALTER COLUMN SOHD INT NOT NULL;

ALTER TABLE CTHD
ALTER COLUMN MASP CHAR(4) NOT NULL;

ALTER TABLE CTHD
ADD CONSTRAINT PK_CTHD PRIMARY KEY (SOHD, MASP);

ALTER TABLE CTHD 
ADD CONSTRAINT FK_CTHD_SOHD FOREIGN KEY (SOHD)
REFERENCES HOADON (SOHD);

ALTER TABLE CTHD
ADD CONSTRAINT FK_CTHD_MASP FOREIGN KEY (MASP)
REFERENCES SANPHAM (MASP);

---------------------------- Cau 2 ------------------------
-- Thêm vào thuộc tính GHICHU có kiểu dữ liệu varchar(20) cho quan hệ SANPHAM.
ALTER TABLE SANPHAM 
ADD GHICHU VARCHAR(20);

---------------------------- Cau 3 ------------------------
-- Thêm vào thuộc tính LOAIKH có kiểu dữ liệu là tinyint cho quan hệ KHACHHANG.
ALTER TABLE KHACHHANG 
ADD LOAIKH TINYINT;

---------------------------- Cau 4 ------------------------
-- Sửa kiểu dữ liệu của thuộc tính GHICHU trong quan hệ SANPHAM thành varchar(100).
ALTER TABLE SANPHAM
ALTER COLUMN GHICHU VARCHAR(100);

---------------------------- Cau 5 ------------------------
-- Xóa thuộc tính GHICHU trong quan hệ SANPHAM
ALTER TABLE SANPHAM
DROP COLUMN GHICHU;

---------------------------- Cau 6 ------------------------
-- Làm thế nào để thuộc tính LOAIKH trong quan hệ KHACHHANG có thể lưu các giá trị là: “Vang 
-- lai”, “Thuong xuyen”, “Vip”, …
ALTER TABLE KHACHHANG
ALTER COLUMN LOAIKH VARCHAR(50);

---------------------------- Cau 7 ------------------------
-- Đơn vị tính của sản phẩm chỉ có thể là (“cay”,”hop”,”cai”,”quyen”,”chuc”)
ALTER TABLE SANPHAM
ADD CONSTRAINT DTVT_CHECK 
CHECK(DVT IN ('cay', 'hop', 'cai', 'quyen', 'chuc'));

---------------------------- Cau 8 ------------------------
-- Giá bán của sản phẩm từ 500 đồng trở lên.
ALTER TABLE SANPHAM
ADD CONSTRAINT GIA_CHECK CHECK (GIA >= 500);

---------------------------- Cau 9 ------------------------
-- Mỗi lần mua hàng, khách hàng phải mua ít nhất 1 sản phẩm.
ALTER TABLE CTHD 
ADD CONSTRAINT SL_CHECK CHECK (SL >= 1);

---------------------------- Cau 10 -----------------------
-- Ngày khách hàng đăng ký là khách hàng thành viên phải lớn hơn ngày sinh của người đó. 
ALTER TABLE KHACHHANG
ADD CONSTRAINT NGDK_CHECK CHECK (NGDK > NGSINH);
