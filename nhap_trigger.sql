CREATE TRIGGER [dbo].[nhap_trigger]
ON	[dbo].[nhap_chitiet]
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
DECLARE @thoigian char(6),@sophieu char(10) ,@mathuoc char(8),
	@soluong numeric(10,2),@makho char(8)

--Khai báo con trỏ cursor deleted 
DECLARE nhap_deleted CURSOR FOR
SELECT thoigian,sophieu,mathuoc,soluong
FROM deleted
-- Mở con trỏ
OPEN nhap_deleted
--Lấy dữ liệu dòng kế
FETCH NEXT FROM nhap_deleted
INTO @thoigian,@sophieu,@mathuoc,@soluong
WHILE @@FETCH_STATUS = 0
BEGIN
	-- Lấy mã kho từ phiếu nhập 1
	SELECT @makho=makho FROM nhap WHERE thoigian=@thoigian and sophieu=@sophieu
	UPDATE TONKHO SET sln=sln-@soluong
	WHERE thoigian=@thoigian and @makho=makho and mathuoc=@mathuoc
	FETCH NEXT FROM pn2_deleted
	INTO @thoigian,@sophieu,@mathuoc,@soluong
END
CLOSE nhap_deleted
DEALLOCATE nhap_deleted

--Khai báo con trỏ cursor inserted 
DECLARE nhap_inserted CURSOR FOR
SELECT thoigian,sophieu,mathuoc,soluong
FROM inserted
-- Mở con trỏ
OPEN nhap_inserted
--Lấy dữ liệu dòng hiện thời
FETCH NEXT FROM nhap_inserted
INTO @thoigian,@sophieu,@mathuoc,@soluong
WHILE @@FETCH_STATUS = 0
BEGIN
	-- Lấy mã kho từ phiếu nhập
	SELECT @makho=makhonhap FROM nhap WHERE thoigian=@thoigian and sophieu=@sophieu

	IF NOT EXISTS(SELECT * FROM tonkho 
					WHERE thoigian=@thoigian and @makho=makho and mathuoc=@mathuoc)
		-- Chưa có dòng dữ liệu trong tồn kho
		INSERT INTO tonkho (thoigian,makho,mathuoc,sld,sln,slx,slc)
		VALUES (@thoigian,@makho,@mathuoc,0,@soluong,0,0)
	ELSE
		UPDATE TONKHO SET sln=sln+@soluong
		WHERE thoigian=@thoigian and @makho=makho and mathuoc=@mathuoc

	FETCH NEXT FROM nhap_inserted
	INTO @thoigian,@sophieu,@mathuoc,@soluong
END
CLOSE nhap_inserted
DEALLOCATE nhap_inserted
END