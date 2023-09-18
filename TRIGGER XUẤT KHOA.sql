CREATE TRIGGER trigger_xuatkhoa
ON dbo.XUATKHOA_CHITIET
AFTER INSERT, UPDATE, DELETE
AS
BEGIN  
	DECLARE @thoigian CHAR(6), @sophieu CHAR(10), @mathuoc CHAR(8),@soluong numeric (10,2), @thanhtien numeric (11,0), @makhoxuat char(8)
	DECLARE XUATKHOA_inserted CURSOR FOR 

SELECT thoigian, sophieu,mathuoc, soluong
FROM inserted 
OPEN XUATKHOA_inserted 
	FETCH NEXT FROM XUATKHOA_inserted 
	INTO @thoigian, @sophieu, @makhoxuat
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		SELECT @makhoxuat=makhoxuat FROM XUATKHOA WHERE thoigian =@thoigian and sophieu=@sophieu 
		IF NOT EXISTS (SELECT * FROM TONKHO
		Where thoigian=@thoigian and makho=@makhoxuat and mathuoc =@mathuoc) 
		BEGIN 	
			INSERT INTO TONKHO(thoigian,makho,mathuoc, SLD, TTD, SLN, TTN, SLX, TTX, SLC, TTC)
			VALUES (@thoigian, @makhoxuat,@mathuoc, @soluong, @thanhtien, 0,0,0,0,0,0)
		END
		ELSE 
			BEGIN
			UPDATE TONKHO SET SLC=@soluong-SLX, TTX=TTX+@thanhtien 
			WHERE thoigian=@thoigian and makho=@makhoxuat
			END;
			FETCH NEXT FROM XUATKHOA_inserted 
			INTO @thoigian, @sophieu, @mathuoc, @soluong 
END
	CLOSE XUATKHOA_inserted 
	DEALLOCATE  XUATKHOA_inserted 
END 
