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
    NOIGIAOHANG 	NVARCHAR(40) NOT NULL,      -- Nơi giao hàng
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
    DONVITINH 	NVARCHAR(50),			-- Đơn vị tính của sản phẩm
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
		('NCC003','OPPO',N'OPPO',N'47 Hoàng Minh Thảo','0384759388','3', 'oppo@gmail.com'),
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
		('MMH001',N'IPHONE 15','NCC001','MLH001','50',N'Hộp','29000000'),
		('MMH002',N'Tai nghe không dây','NCC001','MLH005','120',N'Hộp','299000'),
		('MMH003',N'LENOVO LEGION 5','NCC004','MLH002','100',N'Hộp','250000000'),
		('MMH004',N'Tủ Lạnh Panasonic Inverter','NCC005','MLH004','40',N'Cái','7000000'),
		('MMH005',N'OPPO A3','NCC003','MLH001','60',N'Hộp','5000000');

INSERT into DONDATHANG
	values
	('MHD001','MKH001','MNV001','18-12-2022','18-12-2022','18-12-2022',N'48 Cao Thắng'),
		('MHD002','MKH002','MNV002','17-2-2022','18-12-2022','18-12-2022',N'12 Ông Ích Khiêm'),
		('MHD003','MKH003','MNV003','1-8-2022','18-12-2022','18-12-2022',N'48 Cao Thắng'),
		('MHD004','MKH004','MNV004','1-11-2022','18-12-2022','18-12-2022',N'167 Nguyễn Sinh Sắc'),
		('MHD005','MKH003','MNV004','6-7-2022','18-12-2022','18-12-2022',N'71 Hai Bà Trưng');

INSERT into CHITIETDATHANG
	values	
	('MHD001','MMH001',32000000,3,8),
		('MHD002','MMH001',399000,1,10),
		('MHD003','MMH003',300000000,1,''),
		('MHD004','MMH004',10000000,4,26),
		('MHD005','MMH005',5500000,2,10),
		('MHD001','MMH005',5500000,3,8),
		('MHD002','MMH004',10000000,1,''),
		('MHD003','MMH001',32000000,2,''),
		('MHD004','MMH001',399000,4,15),
		('MHD005','MMH001',32000000,3,40);


	--Cập nhật lại giá trị trường NGAYCHUYENHANG của những bản ghi có NGAYCHUYENHANG chưa xác định (NULL) trong bảng DONDATHANG bằng với giá trị của trường NGAYDATHANG.
UPDATE DonDatHang 
SET NGAYCHUYENHANG = NGAYDATHANG 
WHERE NGAYCHUYENHANG IS NULL;
select * from DONDATHANG;

--Tăng số lượng hàng của những mặt hàng do công ty APPLE cung cấp lên gấp đôi.
select * from MATHANG ;
UPDATE MATHANG
SET SOLUONG = SOLUONG * 2
WHERE MACONGTY in (select MACONGTY
					From NHACUNGCAP
					Where TENCONGTY = 'APPLE');
					select * from MATHANG;
    ----Cập nhật giá trị của trường NOIGIAOHANG trong bảng DONDATHANG bằng địa chỉ của khách hàng đối với những đơn đặt hàng chưa xác định được nơi giao hàng
UPDATE DONDATHANG
SET NOIGIAOHANG = KHACHHANG.DIACHI
FROM DONDATHANG
JOIN KHACHHANG ON DONDATHANG.MAKHACHHANG = KHACHHANG.MAKHACHHANG
WHERE DONDATHANG.NOIGIAOHANG IS NULL;
select * from DONDATHANG;
select * from KHACHHANG;
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
	select * from KHACHHANG ;
	select * from NHACUNGCAP;


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
---- tuần 9 ---------------------------
--1/ Mã hàng, tên hàng và số lượng của các mặt hàng có trong công ty.
SELECT TENLOAIHANG, SOLUONG, MAHANG
FROM MATHANG
JOIN LOAIHANG ON MATHANG.MALOAIHANG = LOAIHANG.MALOAIHANG​
--2/Cho biết mỗi mặt hàng trong công ty do ai cung cấp
SELECT MH.MAHANG,MH.TENHANG,NCC.TENCONGTY
FROM MATHANG MH
JOIN NHACUNGCAP NCC
ON MH.MACONGTY=NCC.MACONGTY
--3/Hãy cho biết số tiền lương mà công ty phải trả cho mỗi nhân viên là bao nhiêu (lương = lương cơ bản + phụ cấp).
SELECT NV.MANHANVIEN,NV.HO,NV.TEN,sum(LUONGCOBAN+PHUCAP) as LUONG
FROM NHANVIEN NV
GROUP BY NV.MANHANVIEN,NV.HO,NV.TEN
 --6/Hãy cho biết tổng số tiền lời mà công ty thu được từ mỗi mặt hàng trong năm 2022
select TENHANG ,TENCONGTY, SUM((GIABAN - GIAHANG)*CHITIETDATHANG.SOLUONG) as TONGTIENLOI

from MATHANG, CHITIETDATHANG, DONDATHANG, NHACUNGCAP
where NHACUNGCAP.MACONGTY = MATHANG.MACONGTY and MATHANG.MAHANG = CHITIETDATHANG.MAHANG and CHITIETDATHANG.SOHOADON = DONDATHANG.SOHOADON and YEAR(NGAYDATHANG) = 2022
group by MATHANG.MAHANG, TENHANG, TENCONGTY
--Những mặt hàng nào chưa từng đượic khách mua
SELECT MAHANG, TENHANG, TENCONGTY
FROM MATHANG JOIN NHACUNGCAP 
	on MATHANG.MACONGTY = NHACUNGCAP.MACONGTY
WHERE MATHANG.MAHANG not in (select MAHANG  from CHITIETDATHANG)

--Hãy cho biết mỗi khách hàng đã phải bỏ ra bao nhiêu tiền để đặt mua hàng công ty
SELECT KH.TENCONGTY AS KHACHHANG, NCC.TENCONGTY AS CONGTY, SUM(GIABAN*CH.SOLUONG*(1-MUCGIAMGIA/100)) AS TONGTIEN
FROM KHACHHANG KH, DONDATHANG DH, CHITIETDATHANG CH, MATHANG MH, NHACUNGCAP NCC
Where KH.MAKHACHHANG = DH.MAKHACHHANG and DH.SOHOADON=CH.SOHOADON and CH.MAHANG = MH.MAHANG and MH.MACONGTY = NCC.MACONGTY
Group by KH.MAKHACHHANG, KH.TENCONGTY, NCC.MACONGTY, NCC.TENCONGTY​
---tuần 10----------
--1/ Cho biết danh sách các đối tác  cung cấp hàng cho công ty
SELECT  NCC.MACONGTY,NCC.TENCONGTY AS ĐỐITÁC
FROM NHACUNGCAP NCC

---2/ mã hàng tên hàng số lượng của các mặt hàng có trong công ty 
select MH.MAHANG,MH.TENHANG,MH.SOLUONG
 FROM MATHANG MH
--3/Họ và tên ,địa chỉ, năm bắt đầu làm việc của các nhân viên trong công ty
SELECT NV.HO,NV.TEN,NV.DIACHI,NV.NGAYLAMVIEC AS NAMLAMVIEC
FROM NHANVIEN NV
--4/Sử dụng câu lệnh Select hiển thị địa chỉ và số điện thoại của nhà cung cấp  có tên giao dịch là VINAMILK
 update NHACUNGCAP
set TENGIAODICH = 'VINAMILK'
where TENGIAODICH = N'OPPO';
select DIACHI, DIENTHOAI
from NHACUNGCAP
where TENGIAODICH = 'VINAMILK';

--5/CHo biết mã vầ tên của các loại mặt hàng có giá >100000 và số lượng hiện  tại ít hơn 50
SELECT MH.MAHANG,MH.TENHANG
FROM MATHANG MH
WHERE MH.GIAHANG>100000 AND MH.SOLUONG<50
--6/Mỗi mặt hàng trong công ty do ai cung cấp--
select MH.MAHANG, MH.TENHANG,NCC.TENCONGTY
from MATHANG MH ,NHACUNGCAP NCC
where MH.MACONGTY=NCC.MACONGTY
--7/Công ty "Việt Tiến" đã cung cấp những mặt hàng nào--------
update NHACUNGCAP
set TENCONGTY='Việt Tiến'
where TENCONGTY=N'APPLE'
SELECT MH.MAHANG, MH.TENHANG, MH.SOLUONG, MH.GIAHANG, LH.TENLOAIHANG
FROM MATHANG MH
JOIN NHACUNGCAP NCC ON MH.MACONGTY = NCC.MACONGTY
JOIN LOAIHANG LH ON MH.MALOAIHANG = LH.MALOAIHANG
WHERE NCC.TENCONGTY = 'Việt Tiến';

--8/Loại hàng thực phẩm do những công ty nào cung cấp và địa chỉ của các công ty đó là gì?

select distinct TENLOAIHANG, TENCONGTY, DIACHI

from LOAIHANG LH, NHACUNGCAP NCC, MATHANG MH
where LH.MALOAIHANG = MH.MALOAIHANG and NCC.MACONGTY = MH.MACONGTY
--9/Những khách hàng nào (tên giao dịch) đã đặt mua mặt hàng Sữa hộp XYZ của công ty?
update MATHANG
set TENHANG = N'Sữa hộp XYZ'
where TENHANG = 'OPPO A3'
SELECT distinct  KH.TENGIAODICH
 FROM KHACHHANG KH
JOIN DONDATHANG DDH ON KH.MAKHACHHANG = DDH.MAKHACHHANG
JOIN CHITIETDATHANG CTDH ON DDH.SOHOADON = CTDH.SOHOADON
JOIN MATHANG MH ON CTDH.MAHANG = MH.MAHANG
WHERE MH.TENHANG = N'Sữa hộp XYZ';
--10/Đơn đặt hàng số 1 do ai đặt và do nhân viên nào lập, thời gian và địa điểm giao hàng:

SELECT 
    DDH.SOHOADON,
    KH.TENCONGTY AS TenKhachHang,
    NV.HO + ' ' + NV.TEN AS TenNhanVien,
    DDH.NGAYDATHANG,
    DDH.NGAYGIAOHANG,
    DDH.NOIGIAOHANG
FROM DONDATHANG DDH
JOIN KHACHHANG KH ON DDH.MAKHACHHANG = KH.MAKHACHHANG
JOIN NHANVIEN NV ON DDH.MANHANVIEN = NV.MANHANVIEN
WHERE DDH.SOHOADON = 'MHD001';
--11/Số tiền lương mà công ty phải trả cho mỗi nhân viên (lương = lương cơ bản + phụ cấp):
SELECT NV.MANHANVIEN,NV.HO,NV.TEN,sum(LUONGCOBAN+PHUCAP) as LUONG
FROM NHANVIEN NV
GROUP BY NV.MANHANVIEN,NV.HO,NV.TEN
--12/Khách hàng nào là đối tác cung cấp hàng của công ty (có cùng tên giao dịch):
select  KH.MAKHACHHANG AS MaKhachHang,
    KH.TENCONGTY AS TenCongTyKhachHang,
    KH.TENGIAODICH AS TenGiaoDich,
    KH.DIACHI AS DiaChi,
    KH.EMAIL AS Email
from  KHACHHANG KH
join NHACUNGCAP NCC ON KH.TENGIAODICH=NCC.TENGIAODICH
--13/Nhân viên nào trong công ty có cùng ngày sinh:
update NHANVIEN
set NGAYSINH='10-9-2001'
where NGAYSINH='22-04-2003'
SELECT NV.NGAYSINH, 
    STRING_AGG(HO + ' ' + TEN, ', ') AS DanhSachNhanVien
FROM NHANVIEN NV
GROUP BY NGAYSINH
HAVING COUNT(*) > 1;
--14--Những đơn đặt hàng yêu cầu giao hàng ngay tại công ty đặt hàng và của công ty nào:
SELECT DH.SOHOADON,KH.TENCONGTY
FROM DONDATHANG DH
JOIN KHACHHANG KH
ON DH.MAKHACHHANG=KH.MAKHACHHANG
WHERE DH.NOIGIAOHANG NOT IN( 
SELECT  KH.DIACHI
FROM KHACHHANG KH
)

--15/Tên công ty, tên giao dịch, địa chỉ và điện thoại của khách hàng và nhà cung cấp:
SELECT 
    'Khách hàng' 
    TENCONGTY,
    TENGIAODICH,
    DIACHI,
    DIENTHOAI
FROM KHACHHANG

UNION ALL

SELECT 
    'Nhà cung cấp' 
    TENCONGTY,
    TENGIAODICH,
    DIACHI,
    DIENTHOAI
FROM NHACUNGCAP;
--16Những mặt hàng nào chưa từng được khách hàng đặt mua
SELECT MH.MAHANG,MH.TENHANG
FROM MATHANG MH
LEFT JOIN CHITIETDATHANG CTDH
ON MH.MAHANG=CTDH.MAHANG
WHERE CTDH.MAHANG IS NULL
--17Những nhân viên nào của công ty chua từng lập bất kỳ hóa đơn đặt hàng nào
SELECT NV.MANHANVIEN,NV.HO,NV.TEN
FROM NHANVIEN NV
LEFT JOIN DONDATHANG DDH
ON NV.MANHANVIEN=DDH.MANHANVIEN
WHERE DDH.MANHANVIEN IS NULL
--18 Những nhân viên nào có lương cơ bản cao nhất 
SELECT TOP 1 NV.MANHANVIEN,NV.HO,NV.TEN,NV.LUONGCOBAN
FROM NHANVIEN NV
ORDER BY NV.LUONGCOBAN DESC
----Tuan 11----
--1) Tạo thủ tục lưu trữ để thông qua thủ tục này có thể bổ sung thêm một bản ghi mới cho bảng MATHANG 
--(thủ tục phải thực hiện kiểm tra tính hợp lệ của dữ liệu cần bổ sung: không trùng khoá chính và đảm bảo toàn vẹn tham chiếu)
GO
CREATE PROC prThemMatHang
    @MAHANG VARCHAR(20),
    @TENHANG NVARCHAR(40),
    @MACONGTY VARCHAR(20),
    @MALOAIHANG VARCHAR(20),
    @SOLUONG INT,
    @DONVITINH NVARCHAR(50),
    @GIAHANG INT
AS
BEGIN 
        INSERT INTO MATHANG (MAHANG, TENHANG, MACONGTY, MALOAIHANG, SOLUONG, DONVITINH, GIAHANG)
        VALUES (@MAHANG, @TENHANG, @MACONGTY, @MALOAIHANG, @SOLUONG, @DONVITINH, @GIAHANG);
END;
EXEC prThemMatHang 
    @MAHANG = 'MMH006',
    @TENHANG = N'Laptop Dell XPS 13',
    @MACONGTY = 'NCC004',
    @MALOAIHANG = 'MLH002',
    @SOLUONG = 20,
    @DONVITINH = N'Cái',
    @GIAHANG = 25000000;
--xóa proc để test thử
DROP PROCEDURE prThemMatHang
--select bảng  MATHANG để check kết quả 
SELECT *FROM MATHANG
----- 2/ Tạo thủ tục có chức năng thống kê tổng số lượng hàng bán được của một mặt hàng có mã bất kì ( tham số thống kê là mã mặt hàng )----
CREATE PROCEDURE sp_ThongKeSoLuongHangBan_V2
    @MaHang VARCHAR(20)
AS
BEGIN
    SELECT 
        MH.MAHANG, 
        MH.TENHANG,
        SUM(CTDH.SOLUONG) AS TongSoLuongBan
    FROM 
        MATHANG MH
    INNER JOIN CHITIETDATHANG CTDH ON MH.MAHANG = CTDH.MAHANG
    INNER JOIN DONDATHANG DDH ON CTDH.SOHOADON = DDH.SOHOADON
    WHERE 
        MH.MAHANG = @MaHang
    GROUP BY 
        MH.MAHANG, MH.TENHANG;
END
DROP PROCEDURE sp_ThongKeSoLuongHangBan_V2
EXEC sp_ThongKeSoLuongHangBan_V2 'MMH001';
-- 3/ Viết hàm trả về 1 bảng cho biết tổng số lượng hàng bán được của mỗi mặt hàng. Sử dụng hàm để thống kê xem tổng số lượng (hiện có và đã bán) của mỗi mặt hàng
CREATE FUNCTION dbo.fn_TongSoLuongHangBan(@MaHang VARCHAR(20))
RETURNS INT
AS
BEGIN
    DECLARE @TongSoLuongBan INT;

    SELECT @TongSoLuongBan = SUM(CTDH.SOLUONG)
    FROM CHITIETDATHANG CTDH
    WHERE CTDH.MAHANG = @MaHang;

    RETURN @TongSoLuongBan;
END;
select* From MATHANG;
SELECT 
    MH.MAHANG, 
    MH.TENHANG,
    MH.SOLUONG AS SoLuongHienCo,
    dbo.fn_TongSoLuongHangBan(MH.MAHANG) AS TongSoLuongBan,
    (MH.SOLUONG + dbo.fn_TongSoLuongHangBan(MH.MAHANG)) AS TongSoLuong
FROM 
    MATHANG MH;
----4) Viết trigger cho bảng CHITIETDATHANG theo yêu cầu sau: 
----a/Khi một bản ghi mới được bổ sung vào bảng này thì giảm số lượng hàng hiện có nếu số lượng hàng hiện có lớn hơn hoặc bằng số lượng hàng được bán ra. Ngược lại thì huỷ bỏ thao tác bổ sung. 
---	b/Khi cập nhật lại số lượng hàng được bán, kiểm tra số lượng hàng được cập nhật lại có phù hợp hay không (số lượng hàng bán ra không được vượt quá số lượng hàng hiện có và không được nhỏ hơn 1). Nếu dữ liệu hợp lệ thì giảm (hoặc tăng) số lượng hàng hiện có trong công ty, ngược lại thì huỷ bỏ thao tác cập nhật. 



go
CREATE TRIGGER tg_CTDH_Insert
ON CHITIETDATHANG
AFTER INSERT
AS
BEGIN
    -- Kiểm tra nếu số lượng hàng đặt vượt quá số lượng hiện có
    IF EXISTS (
        SELECT *
        FROM inserted AS i
        JOIN MATHANG AS h ON i.MAHANG = h.MAHANG
        WHERE i.SOLUONG > h.SOLUONG
    )
    BEGIN
        PRINT N'Không đủ hàng để bán';
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        -- Cập nhật số lượng hàng hóa trong bảng MATHANG
        UPDATE h
        SET h.SOLUONG = h.SOLUONG - i.SOLUONG
        FROM MATHANG AS h
        JOIN inserted AS i ON h.MAHANG = i.MAHANG;
    END
END;

GO
CREATE TRIGGER tg_CTDH_Update
ON CHITIETDATHANG
AFTER UPDATE
AS
BEGIN
    -- Kiểm tra nếu số lượng hàng bán không hợp lệ
    IF EXISTS (
        SELECT *
        FROM inserted AS i
        JOIN deleted AS d ON i.MaHang = d.MaHang
        JOIN MATHANG AS h ON i.MaHang = h.MaHang
        WHERE i.SoLuong > h.SoLuong -- Số lượng bán lớn hơn số lượng hiện có
          OR i.SoLuong < 1          -- Số lượng bán nhỏ hơn 1
    )
    BEGIN
        PRINT N'Số lượng hàng không hợp lệ. Hủy bỏ thao tác cập nhật.';
        ROLLBACK TRANSACTION; -- Hủy giao dịch
    END
    ELSE
    BEGIN
        -- Điều chỉnh lại số lượng hàng trong MATHANG
        UPDATE MATHANG
        SET MATHANG.SoLuong = MATHANG.SoLuong - (i.SoLuong - d.SoLuong)
        FROM MATHANG
        JOIN inserted AS i ON MATHANG.MaHang = i.MaHang
        JOIN deleted AS d ON MATHANG.MaHang = d.MaHang;
    END
END;
GO
