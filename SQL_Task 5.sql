-- Đặt tên cho trigger là "xuathu_trigger"
-- Trigger này chạy sau INSERT, UPDATE, hoặc DELETE trên bảng XUATKHOA_CHITIET
CREATE TRIGGER xuathu_trigger
ON XUATHU_CHITIET
AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
    -- Khai báo các biến để lưu trữ thông tin từ bảng XUATHU_CHITIET
    DECLARE @thoigian char(6), @sophieu char(10), @mathuoc char(8),
	        @soluong numeric(10,2), @makhoxuat char(8), @makhonhap char(8), @thanhtien numeric(11,0)

    -- Khai báo con trỏ cursor cho dữ liệu được chèn (INSERT)
    DECLARE xuathu_inserted CURSOR FOR
    SELECT thoigian, sophieu, mathuoc, soluong, thanhtien
    FROM inserted 

    -- Mở con trỏ
    OPEN xuathu_inserted

    -- Duyệt qua từng dòng được chèn
    FETCH NEXT FROM xuathu_inserted
    INTO @thoigian, @sophieu, @mathuoc, @soluong, @thanhtien
    WHILE @@FETCH_STATUS = 0 
    BEGIN
        -- Lấy mã kho từ phiếu xuất khoa, với thoigian va sophieu là của dòng mới được inserted
        SELECT @makhoxuat = Makhoxuat, @makhonhap = Makhoanhap
        FROM XUATKHOA
        WHERE thoigian = @thoigian AND sophieu = @sophieu

        -- Cập nhật dữ liệu trong bảng TONKHO cho dòng được chèn
        UPDATE TONKHO SET SLX = SLX + @soluong, SLC = SLC - @soluong
        WHERE THOIGIAN = @thoigian AND MAKHO = @makhoxuat AND MATHUOC = @mathuoc

        -- Kiểm tra nếu thuốc chưa tồn tại trong kho nhập
        IF NOT EXISTS (SELECT * FROM TONKHO WHERE thoigian = @thoigian AND @makhonhap = makho AND mathuoc = @mathuoc)
            INSERT INTO TONKHO(THOIGIAN, MAKHO, MATHUOC, SLD, TTD, SLN, TTN, SLX, TTX, SLC, TTC)
            VALUES (@thoigian, @makho, @mathuoc,0,0,0,0,@soluong,@thanhtien,0,0)
        -- Nếu thuốc đã tồn tại
        ELSE
            UPDATE TONKHO SET slx=slx+@soluong, TTX = ISNULL(((TTD + TTN)/( SLD+SLN))*SLX,0), SLC=SLD+SLN-SLX, TTC= ISNULL(((TTD + TTN)/( SLD+SLN))*SLC,0)
            WHERE THOIGIAN = @thoigian AND MAKHO = @makhonhap AND MATHUOC = @mathuoc

        FETCH NEXT FROM xuathu_inserted
        INTO @thoigian, @sophieu, @mathuoc, @soluong, @thanhtien
    END

    -- Đóng con trỏ
    CLOSE xuathu_inserted
    DEALLOCATE xuathu_inserted

    -- Khai báo con trỏ cursor cho dữ liệu bị xóa (DELETE)
    DECLARE xuathu_deleted CURSOR FOR
    SELECT thoigian, sophieu, mathuoc, soluong, thanhtien
    FROM deleted

    -- Mở con trỏ
    OPEN xuathu_deleted

    -- Duyệt qua từng dòng bị xóa
    FETCH NEXT FROM xuathu_deleted
    INTO @thoigian, @sophieu, @mathuoc, @soluong, @thanhtien
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Lấy mã kho từ phiếu nhập trả
        SELECT @makhonhap = Makhonhap, @makhoxuat = Makhoxuat
        FROM NHAPTRA
        WHERE Thoigian = @thoigian and Sophieu = @sophieu

        -- Cập nhật dữ liệu trong bảng TONKHO cho dòng bị xóa
        UPDATE TONKHO SET SLX = SLX - @soluong, SLC = SLC + @soluong
        WHERE THOIGIAN = @thoigian AND MAKHO = @makhoxuat AND MATHUOC = @mathuoc

        -- Cập nhật dữ liệu trong bảng TONKHO cho kho nhập
        UPDATE TONKHO SET SLN = SLN - @soluong, TTN = TTN - @thanhtien, SLC = SLC - @soluong
        WHERE THOIGIAN = @thoigian AND MAKHO = @makhonhap AND MATHUOC = @mathuoc

        FETCH NEXT FROM xuathu_deleted
        INTO @thoigian, @sophieu, @mathuoc, @soluong, @thanhtien
    END

    -- Đóng con trỏ
    CLOSE xuathu_deleted
    DEALLOCATE xuathu_deleted

END


