

CREATE TRIGGER xuathu_trigger
ON dbo.xuathu_chitiet
AFTER INSERT, UPDATE, DELETE
AS
BEGIN 
    DECLARE @thoigian char(6),@sophieu char(10) ,@mathuoc char(8),@soluong numeric(10,2),@makho char(8) 
	--Khai báo con trỏ cursor deleted 
    DECLARE xuathu_deleted CURSOR FOR
    SELECT thoigian,sophieu,mathuoc,soluong,thanhtien
    FROM deleted
	-- Mở con trỏ
    OPEN xuathu_deleted
	--Lấy dữ liệu dòng kế
	FETCH NEXT FROM xuathu_deleted
    INTO @thoigian,@sophieu,@mathuoc,@soluong,@thanhtien
    WHILE @@FETCH_STATUS = 0
    BEGIN
	    -- Lấy mã kho từ phiếu xuat hu
		SELECT @makho=Makhoxuat FROM xuathu WHERE thoigian=@thoigian and sophieu=@sophieu
	    IF NOT EXISTS (
		SELECT *
		FROM tonkho
		WHERE thoigian=@thoigian and @makho=makho and mathuoc=@mathuoc)
		BEGIN
		INSERT INTO TONKHO(THOIGIAN, MAKHO, MATHUOC, SLD, TTD, SLN, TTN, SLX, TTX, SLC, TTC)
		VALUES (@thoigian, @makho, @mathuoc, @soluong, @thanhtien, 0, 0, 0, 0, 0, 0)
		END
		ELSE 
			BEGIN
			UPDATE TONKHO SET SLX=SLX+@soluong, TTX=TTX+@thanhtien
			WHERE THOIGIAN=@thoigian and @makho=MAKHO and MATHUOC=@mathuoc
			END;

			FETCH NEXT FROM xuathu_inserted
			INTO @thoigian, @sophieu, @mathuoc, @soluong, @thanhtien
END;
	  CLOSE xuathu_inserted;
	  DEALLOCATE xuathu_inserted;
END;


