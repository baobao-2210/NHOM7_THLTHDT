 USE master;
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'TCSDL02_N7')
BEGIN
    ALTER DATABASE TCSDL02_N7 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TCSDL02_N7;
END;

Create database TCSDL02_N7;
go
USE TCSDL02_N7;


-- Table: KHACHHANG
CREATE TABLE KHACHHANG (
    MAKHACHHANG	CHAR(20)	PRIMARY KEY,	-- Mã khách hàng (Primary Key)
    TENCONGTY		NVARCHAR(40)	NOT NULL,	-- Tên công ty của khách hàng
    TENGIAODICH	NVARCHAR(50)	DEFAULT'no name', -- Tên giao dịch của khách hàng
    DIACHI		NVARCHAR(40)		,	-- Địa chỉ của khách hàng
    EMAIL		VARCHAR(20)	UNIQUE,      -- Email của khách hàng
    DIENTHOAI		VARCHAR(10)	UNIQUE,	-- Số điện thoại của khách hàng
    FAX		VARCHAR(20)	UNIQUE       -- Số fax của khách hàng
);

-- Table: NHANVIEN 
CREATE TABLE NHANVIEN (
    MANHANVIEN 	VARCHAR(20)   PRIMARY KEY, -- Mã nhân viên (Primary Key)
    HO 		NVARCHAR(20)   NOT NULL,	  -- Họ của nhân viên
    TEN 		NVARCHAR(10)   NOT NULL ,   -- Tên của nhân viên
    NGAYSINH 		DATE	         NOT NULL,	  --Ngày sinh của nhân viên
    NGAYLAMVIEC 	DATE NOT NULL , 
    DIACHI 		VARCHAR(40),		-- Địa chỉ của nhân viên
    DIENTHOAI 	VARCHAR(10)    UNIQUE,	-- Số điện thoại của nhân viên
    LUONGCOBAN 	FLOAT	  CHECK (LUONGCOBAN >0),  -- Lương cơ bản của nhân viên
    PHUCAP 		FLOAT	  CHECK (PHUCAP>=0)	      -- Phụ cấp của nhân viên 
);	
-- Table: DONDATHANG 
CREATE TABLE DONDATHANG (
    SOHOADON 		VARCHAR(20) PRIMARY KEY,	-- Số hóa đơn (Primary Key)
    MAKHACHHANG 	CHAR(20),			-- Mã khách hàng (Foreign Key)
	MANHANVIEN 		VARCHAR(20),			-- Mã nhân viên (Foreign Key)
    NGAYDATHANG 	DATE,				-- Ngày đặt hàng
    NGAYGIAOHANG 	DATE,			       -- Ngày giao hàng
    NGAYCHUYENHANG 	DATE,				-- Ngày chuyển hàng
    NOIGIAOHANG 	VARCHAR(20) NOT NULL,      -- Nơi giao hàng
    FOREIGN KEY (MAKHACHHANG) REFERENCES KHACHHANG(MAKHACHHANG), -- Liên kết với bảng KHACHHANG
    FOREIGN KEY (MANHANVIEN) REFERENCES NHANVIEN(MANHANVIEN)     -- Liên kết với bảng NHANVIEN
);
-- Table: NHACUNGCAP
CREATE TABLE NHACUNGCAP (
    MACONGTY 		VARCHAR(20) PRIMARY KEY,	-- Mã công ty nhà cung cấp (Primary Key)
    TENCONGTY		NVARCHAR(50),			-- Tên công ty nhà cung cấp
    TENGIAODICH 	NVARCHAR(50),			-- Tên giao dịch của nhà cung cấp
    DIACHI 		VARCHAR(100),			-- Địa chỉ của nhà cung cấp
    DIENTHOAI 	VARCHAR(20),			-- Số điện thoại của nhà cung cấp
    FAX 		VARCHAR(20),			-- Số fax của nhà cung cấp
    EMAIL 		VARCHAR(100)			-- Email của nhà cung cấp
);
-- Table: LOAIHANG 
CREATE TABLE LOAIHANG (
	MALOAIHANG 	VARCHAR(20) PRIMARY KEY ,	-- Mã Loại Hàng
	TENLOAIHANG 	NVARCHAR(50)			-- Tên Loại Hàng 
);
-- Table: MATHANG
CREATE TABLE MATHANG (
    MAHANG 		VARCHAR(20) PRIMARY KEY,	-- Mã hàng (Primary Key)
    TENHANG 		NVARCHAR(40),			-- Tên sản phẩm
    MACONGTY 		VARCHAR(20),			-- Mã công ty nhà cung cấp (Foreign Key)
    MALOAIHANG		VARCHAR(20),			-- Mã loại hàng (Foreign Key)
    SOLUONG 		INT CHECK (SOLUONG >= 0) DEFAULT(0) , -- Số lượng hàng tồn
    DONVITINH 	VARCHAR(50),			-- Đơn vị tính của sản phẩm
    GIAHANG INT CHECK(GIAHANG > 0),		-- Giá sản phẩm
    FOREIGN KEY (MACONGTY) REFERENCES NHACUNGCAP(MACONGTY),  -- Liên kết với bảng NHACUNGCAP
    FOREIGN KEY (MALOAIHANG) REFERENCES LOAIHANG(MALOAIHANG) -- Liên kết với bảng LOAIHANG
);
-- Table: CHITIETDATHANG 
CREATE TABLE CHITIETDATHANG (	
    SOHOADON 		VARCHAR(20),	-- Số hóa đơn (Foreign Key từ bảng DONHANG)
    MAHANG 		VARCHAR(20),	-- Mã hàng (Foreign Key từ bảng MATHANG)
    GIABAN 		INT CHECK(GIABAN > 0),-- Giá bán của sản phẩm trong đơn hàng
    SOLUONG 		INT CHECK (SOLUONG >= 0)  ,-- Số lượng sản phẩm đặt trong đơn hàng
    MUCGIAMGIA 	FLOAT CHECK( MUCGIAMGIA >= 0 AND MUCGIAMGIA <= 100),-- Mức giảm giá cho sản phẩm
    PRIMARY KEY (SOHOADON, MAHANG),-- Khóa chính là kết hợp của SOHOADON và MAHANG
    FOREIGN KEY (SOHOADON) REFERENCES DONDATHANG(SOHOADON),  -- Liên kết với bảng DONDATHANG (Foreign Key)
    FOREIGN KEY (MAHANG) REFERENCES MATHANG(MAHANG)     -- Liên kết với bảng MATHANG (Foreign Key)
);

--Bổ sung cho bảng DONDATHANG ràng buộc kiểm tra ngày giao hàng và ngày chuyển hàng phải sau hoặc bằng với ngày đặt hàng
ALTER TABLE DONDATHANG
	ADD CONSTRAINT CK_NGAYGIAOHANG CHECK (NGAYGIAOHANG>=NGAYDATHANG),
		CONSTRAINT CK_NGAYCHUYENHANG CHECK (NGAYCHUYENHANG>=NGAYDATHANG)

--Bổ sung ràng buộc cho bảng NHANVIEN để đảm bảo rằng một nhân viên chỉ có thể làm việc trong công ty khi đủ 18 tuổi và không quá 60 tuổi.
ALTER TABLE NHANVIEN
    ADD CONSTRAINT CK_NGAYSINH CHECK (
        DATEDIFF(YEAR, NGAYSINH, NGAYLAMVIEC) >= 18 
        AND DATEDIFF(YEAR, NGAYSINH, GETDATE()) <= 60
    );
--Bổ sung ràng buộc thiết lập giá trị mặc định bằng 1 cho cột SOLUONG  và bằng 0 cho cột MUCGIAMGIA trong bảng CHITIETDATHANG
ALTER TABLE CHITIETDATHANG
	ADD CONSTRAINT DF_SOLUONG DEFAULT 1 FOR SOLUONG,
		CONSTRAINT DF_MUCGIAMGIA DEFAULT 0 FOR MUCGIAMGIA

Set Dateformat dmy;
 
INSERT INTO NhanVien
	VALUES
		('MNV001',N'Nguyễn Tấn',N'Bảo ','10-9-2001','12-5-2024',N'2 Lê Lợi','0912345678',2000000,50000),
		('MNV002',N'Lê Văn',N'Mạnh','2-5-1997','11-01-2023',N'15 Nguyễn Thế Lữ','0912344678',3000000,75000),
		('MNV003',N'Nguyễn Quốc',N'Hùng','22-03-2002','19-05-2022',N'Ngô Quyền 83','0932345678',4000000,50000),
		('MNV004',N'Trần Xuân', N'Trường','22-04-2003','24-08-2023', N'Đống Đa 32','0965127121',3500000,70000),
		('MNV005',N'Nguyễn Văn', N'A','27-06-2005','24-08-2023', N'28 Trần Cao Vân','0965127122',3000000,70000);
  
INSERT INTO KHACHHANG
	VALUES 
		('MKH001',N'Thế Giới Di Động',N'Thiết bị công nghệ',N'48 Cao Thắng','tgdd@gmail.com','0999999999','1'),
		('MKH002',N'Điện Máy Xanh',N'Đồ điện máy',N'20 Hoàng Diệu','dmx@gmail.com','0888888888','2'),
		('MKH003',N'CellPhoneS',N'Điện thoại và phụ kiện',N'44 Điện Biên Phủ','cellphones@gmail.com','093745832','3'),
		('MKH004',N'FPT Shop',N'Máy tính và phụ kiện',N'99 CMT8','fptshop@gmai.com','034854756','4'),
		('MKH005',N'XT Store',N'Phụ kiện điện thoại',N'22 Nguyễn Công Trứ','xtstore@gmai.com','034857345','5');
	
INSERT INTO NHACUNGCAP 
	VALUES 
		('NCC001','APPLE',N'Điện thoại và phụ kiện',N'44 Đà Sơn','0393177153','1', 'apple@gmail.com'),
		('NCC002','SAMSUNG',N'Đa dạng hàng hóa',N'39 Xô Viết Nghệ Tĩnh','0934284738','2', 'samsung@gmail.com'),
		('NCC003','OPPO',N'Bán hàng',N'47 Hoàng Minh Thảo','0384759388','3', 'oppo@gmail.com'),
		('NCC004','LENOVO',N'Bán hàng',N'324 Nguyễn Lương Bằng','0393784774','3', 'lenovo@gmail.com'),
		('NCC005','PANASONIC',N'Bán hàng',N'34 Nguyễn Tất Thành','0389475664','3', 'panasonic@gmail.com');

INSERT INTO LOAIHANG 
	VALUES 
		('MLH001',N'Điện Thoại'),
		('MLH002',N'Máy Tính'),
		('MLH003',N'Ti Vi'),
		('MLH004',N'Tủ Lạnh'),
		('MLH005',N'Phụ Kiện');

insert into MATHANG 
	Values 
		('MMH001',N'IPHONE 15','NCC001','MLH001','50','Hộp','29000000'),
		('MMH002',N'Tai nghe không dây','NCC001','MLH005','120','Hộp','299000'),
		('MMH003',N'LENOVO LEGION 5','NCC004','MLH002','100','Hộp','250000000'),
		('MMH004',N'Tủ Lạnh Panasonic Inverter','NCC005','MLH004','40','Cái','7000000'),
		('MMH005',N'OPPO A3','NCC003','MLH001','60','Hộp','5000000');

INSERT into DONDATHANG
	values
		('MHD001','MKH001','MNV001','18-12-2004','18-12-2018','18-12-2020',N'48 Cao Thắng'),
		('MHD002','MKH002','MNV002','17-2-2004','18-12-2018','18-12-2020',N'12 Ông Ích Khiêm'),
		('MHD003','MKH003','MNV003','1-8-2004','18-12-2018','18-12-2020',N'32 Quang Trung'),
		('MHD004','MKH004','MNV004','1-11-2004','18-12-2018','18-12-2020',N'167 Nguyễn Sinh Sắc'),
		('MHD005','MKH003','MNV004','6-7-2004','18-12-2018','18-12-2020',N'71 Hai Bà Trưng');

INSERT into CHITIETDATHANG
	values
		('MHD001','MMH001',32000000,3,8),
		('MHD002','MMH002',399000,1,10),
		('MHD003','MMH003',300000000,1,''),
		('MHD004','MMH004',10000000,4,26),
		('MHD005','MMH005',5500000,2,10),
		('MHD001','MMH005',5500000,3,8),
		('MHD002','MMH004',10000000,1,''),
		('MHD003','MMH001',32000000,2,''),
		('MHD004','MMH002',399000,4,15),
		('MHD005','MMH001',32000000,3,40);


	--Cập nhật lại giá trị trường NGAYCHUYENHANG của những bản ghi có NGAYCHUYENHANG chưa xác định (NULL) trong bảng DONDATHANG bằng với giá trị của trường NGAYDATHANG.
UPDATE DonDatHang 
SET NGAYCHUYENHANG = NGAYDATHANG 
WHERE NGAYCHUYENHANG IS NULL;
--Tăng số lượng hàng của những mặt hàng do công ty iphone cung cấp lên gấp đôi.
UPDATE MATHANG
SET SOLUONG = SOLUONG * 2
WHERE MACONGTY = 'iphone';
    ----Cập nhật giá trị của trường NOIGIAOHANG trong bảng DONDATHANG bằng địa chỉ của khách hàng đối với những đơn đặt hàng chưa xác định được nơi giao hàng
UPDATE DONDATHANG
SET NOIGIAOHANG = KHACHHANG.DIACHI
FROM DONDATHANG
JOIN KHACHHANG ON DONDATHANG.MAKHACHHANG = KHACHHANG.MAKHACHHANG
WHERE DONDATHANG.NOIGIAOHANG IS NULL;

--Cập nhật lại dữ liệu trong bảng KHACHHANG sao cho nếu tên công ty và tên giao dịch của khách hàng trùng với tên công ty và tên giao dịch của một nhà cung cấp nào đó thì địa chỉ, điện thoại, fax và e-mail phải giống nhau.
UPDATE KHACHHANG
SET 
    DIACHI = NC.DIACHI,
    DIENTHOAI = NC.DIENTHOAI,
    FAX = NC.FAX,
    EMAIL = NC.EMAIL
FROM 
    KHACHHANG KH
JOIN 
    NHACUNGCAP NC
ON 
    KH.TENCONGTY = NC.TENCONGTY
    AND KH.TENGIAODICH = NC.TENGIAODICH;
	-- Tăng lương lên gấp đôi cho những nhân viên bán được hơn 100 đơn hàng trong năm 2022
UPDATE NHANVIEN
SET LUONGCOBAN = LUONGCOBAN * 2
WHERE MANHANVIEN IN (
    SELECT MANHANVIEN
    FROM DONDATHANG
    WHERE YEAR(NGAYDATHANG) = 2022
    GROUP BY MANHANVIEN
    HAVING COUNT(*) > '100'
);
-- Tăng phụ cấp lên 50% cho những nhân viên bán được nhiều nhất
   UPDATE NHANVIEN
SET PHUCAP = PHUCAP * 1.5
WHERE MANHANVIEN IN (
    SELECT TOP 1 MANHANVIEN
    FROM DONDATHANG
    GROUP BY MANHANVIEN
    ORDER BY COUNT(*) DESC
);
  --Giảm 25% lương của những nhân viên trong năm 2023 không lập được bất kỳ đơn đặt hàng nào
  UPDATE NHANVIEN
SET LUONGCOBAN = LUONGCOBAN * 0.75
WHERE MANHANVIEN NOT IN (
    SELECT MANHANVIEN
    FROM DONDATHANG
    WHERE YEAR(NGAYDATHANG) = 2023
);
