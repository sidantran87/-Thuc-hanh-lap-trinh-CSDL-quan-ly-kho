CREATE TRIGGER nhap_trigger
ON NHAP_CHITIET
AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
    DECLARE @thoigian char(6), @sophieu char(10), @mathuoc char(8),
	        @soluong numeric(10,2), @makho char(8), @thanhtien numeric(11,0)

    DECLARE nhap_inserted CURSOR FOR
    SELECT thoigian, sophieu, mathuoc, soluong, thanhtien
    FROM inserted 

    OPEN nhap_inserted

    FETCH NEXT FROM nhap_inserted
    INTO @thoigian, @sophieu, @mathuoc, @soluong, @thanhtien
    WHILE @@FETCH_STATUS = 0 
    BEGIN
        SELECT @makho = Makhonhap
        FROM NHAP
        WHERE thoigian = @thoigian AND sophieu = @sophieu
        UPDATE TONKHO SET SLN = SLN + @soluong, SLC = SLC + @soluong
        WHERE THOIGIAN = @thoigian AND MAKHO = @makho AND MATHUOC = @mathuoc

        IF NOT EXISTS (SELECT * FROM TONKHO WHERE thoigian = @thoigian AND @makho = makho AND mathuoc = @mathuoc)
            INSERT INTO TONKHO(THOIGIAN, MAKHO, MATHUOC, SLD, TTD, SLN, TTN, SLX, TTX, SLC, TTC)
            VALUES (@thoigian, @makho, @mathuoc, 0, 0, @soluong, @thanhtien, 0, 0, @soluong, 0)
        ELSE
            UPDATE TONKHO SET SLN = SLN + @soluong, TTN = TTN + @thanhtien, SLC = SLC + @soluong
            WHERE THOIGIAN = @thoigian AND MAKHO = @makho AND MATHUOC = @mathuoc

        FETCH NEXT FROM nhap_inserted
        INTO @thoigian, @sophieu, @mathuoc, @soluong, @thanhtien
    END
    CLOSE nhap_inserted
    DEALLOCATE nhap_inserted

    DECLARE nhap_deleted CURSOR FOR
    SELECT thoigian, sophieu, mathuoc, soluong, thanhtien
    FROM deleted

    OPEN nhap_deleted

    FETCH NEXT FROM nhap_deleted
    INTO @thoigian, @sophieu, @mathuoc, @soluong, @thanhtien
    WHILE @@FETCH_STATUS = 0
    BEGIN

        SELECT @makho = Makhonhap
        FROM NHAP
        WHERE Thoigian = @thoigian and Sophieu = @sophieu

        UPDATE TONKHO SET SLN = SLN - @soluong, TTN = TTN - @thanhtien, SLC = SLC - @soluong
        WHERE THOIGIAN = @thoigian AND MAKHO = @makho AND MATHUOC = @mathuoc

        FETCH NEXT FROM nhap_deleted
        INTO @thoigian, @sophieu, @mathuoc, @soluong, @thanhtien
    END

    CLOSE nhap_deleted
    DEALLOCATE nhap_deleted

END


