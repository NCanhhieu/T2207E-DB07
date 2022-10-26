create table Asm6_Categorys(
Id int primary key identity(1,1),
Name nvarchar(255) not null unique,
);
create table  Asm6_Authors(
Id int primary key  identity(1,1),
Name nvarchar(255) not null,
);
create table  Asm6_Publishers(
Id int primary key identity(1,1),
Name nvarchar(255) not null ,
Address nvarchar(255) not null,
);

create table  Asm6_Books(
Code varchar(20) primary key,
Name nvarchar(255) not null,
Descrip ntext ,
CategoryID int foreign key references  Asm6_Categorys(Id) not null,
);

create table  Asm6_AuthorBooks(
AuthorID int foreign key references  Asm6_Authors(Id) not null,
BookCode nvarchar(20) foreign key references  Asm6_Books(Code) not null,
);
declare @x int;
set @x= ( select convert(int,year(getdate())) );

create table  Asm6_BookPublishs(
Publishyear int not null check(Publishyear <= @x ),
NumberofPublish int not null check(NumberofPublish > 0) default 1,
Price Decimal(12,4) not null check(Price >= 0) default 0,
Qty int not null check(Qty >= 0) default 0,
PublisherID int foreign key references  Asm6_Publishers(Id) not null,
BookID varchar(20) foreign key references  Asm6_Books(code) not null
);

--2. Viết lệnh SQL chèn vào các bảng của CSDL các dữ liệu mẫu


insert into Asm6_Categorys(Name)
values(N'Khoa học xã hội')(N'Toán học'),(N'Tin học');

insert into Asm6_Authors(Name)
values(N'Eran Katz');

insert into  Asm6_Publishers(Name,Address)
values(N'Tri Thức', N'Nhà xuất bản 53 Nguyễn Du, Hai Bà Trưng, Hà Nội');

insert into Asm6_Books(Code,Name,Descrip,CategoryID)
values('B001',N'Trí tuệ Do Thái',N'Bạn có muốn biết: Người Do Thái sáng tạo ra cái gì và nguồn gốc
trí tuệ của họ xuất phát từ đâu không? Cuốn sách này sẽ dần hé lộ
những bí ẩn về sự thông thái của người Do Thái, của một dân tộc
thông tuệ với những phương pháp và kỹ thuật phát triển tầng lớp trí
thức đã được giữ kín hàng nghìn năm như một bí ẩn mật mang tính
văn hóa.', 1);

insert into  Asm6_AuthorBooks(AuthorID,BookCode)
values (1,'B001');

insert into   Asm6_BookPublishs(Publishyear,NumberofPublish,Price,Qty,PublisherID,BookID)
values (2010,1,79000,100,1,'B001');


--3. Liệt kê các cuốn sách có năm xuất bản từ 2008 đến nay
select * from Asm6_Books where  Code in 
(select BookID from Asm6_BookPublishs where Publishyear >= 2008);
--4. Liệt kê 10 cuốn sách có giá bán cao nhất
select  * from Asm6_Books where Code in 
(select TOP(10) BookID from Asm6_BookPublishs Order by Price desc )
--5. Tìm những cuốn sách có tiêu đề chứa từ “tin học”
select * from Asm6_Books where Name like N'%tin học%'  
--6. Liệt kê các cuốn sách có tên bắt đầu với chữ “T” theo thứ tự giá giảm dần
select * from Asm6_Books where Name like N'T%'  Code in 
(select  BookID from Asm6_BookPublishs Order by Price desc )
--7. Liệt kê các cuốn sách của nhà xuất bản Tri thức
select * from Asm6_Books where Name like N'T%'  Code in 
(select  BookID from Asm6_BookPublishs where PublisherID in
 (select Id from Asm6_Publishers where Name like 'Tri Thức' ))
--8. Lấy thông tin chi tiết về nhà xuất bản xuất bản cuốn sách “Trí tuệ Do Thái”
select * from Asm6_Publishers where Id in
 (select PublisherID from Asm6_BookPublishs where BookID in 
   (select Code from Asm6_Books where Name like 'Trí tuệ Do Thái'))
--9. Hiển thị các thông tin sau về các cuốn sách: Mã sách, Tên sách, Năm xuất bản, Nhà xuất bản,Loại sách
select A.Code, A.Name, B.Publishyear, C.Name, D.Name  from Asm6_Books A
  inner join Asm6_BookPublishs B on A.Code = B.BookID
  inner join Asm6_Publishers C on B.PublisherID = C.Id
  inner join Asm6_Categorys D on A.CategoryID = D.Id
--10. Tìm cuốn sách có giá bán đắt nhất
select  * from Asm6_Books where Code in 
(select TOP(1) BookID from Asm6_BookPublishs Order by Price desc )
--11. Tìm cuốn sách có số lượng lớn nhất trong kho
select  * from Asm6_Books where Code in 
(select TOP(1) BookID from Asm6_BookPublishs Order by Qty desc )
--12. Tìm các cuốn sách của tác giả “Eran Katz”
select * from Asm6_Books where   Code in 
(select  BookID from Asm6_AuthorBooks where AuthorID in 
 (select Id from Asm6_Authors where Name like 'Eran Katz'))

--13. Giảm giá bán 10% các cuốn sách xuất bản từ năm 2008 trở về trước
update Asm6_BookPublishs set Price = Price*(90.0/100) where Publishyear  <= 2008 ;
--14. Thống kê số đầu sách của mỗi nhà xuất bản
select   PublisherID,Count(BookID) as So_dau_sach from Asm6_BookPublishs Group by PublisherID
--15. Thống kê số đầu sách của mỗi loại sách
select CategoryID, Count(Name) from Asm6_Books group by CategoryID 
--16. Đặt chỉ mục (Index) cho trường tên sách
create index Book_name on Asm6_Books(Name)
--17. Viết view lấy thông tin gồm: Mã sách, tên sách, tác giả, nhà xb và giá bán
create view Book_Data as
select A.Code, A.Name, E.Name , C.Name, B.Price  from Asm6_Books A
  inner join Asm6_BookPublishs B on A.Code = B.BookID
  left join Asm6_Publishers C on B.PublisherID = C.Id
  left join Asm6_AuthorBooks D on A.Code = D.BookCode
  left join Asm6_Authors E on D.AuthorID = E.Id

--18. Viết Store Procedure:
--SP_Them_Sach: thêm mới một cuốn sách
create procedure SP_Them_Sach @Code varchar(20), @Name nvarchar(255),@Descrip ntext ,@CategoryID int as
insert into Asm6_Books(Code,Name,Descrip,CategoryID)
values(@Code,@Name,@Descrip,@CategoryID)
--SP_Tim_Sach: Tìm các cuốn sách theo từ khóa
create procedure SP_Tim_Sach @Name nvarchar(255) as
select * from Asm6_Books where Name like @Name;
--SP_Sach_ChuyenMuc: Liệt kê các cuốn sách theo mã chuyên mục
create procedure SP_Sach_ChuyenMuc @CategoryID int as
select * from Asm6_Books where CategoryID = @CategoryID
--19. Viết trigger không cho phép xóa các cuốn sách vẫn còn trong kho (số lượng > 0)
create trigger ko_xoa_san_pham
on Asm6_Books
after Delete 
as 
begin 
if exists (select * from deleted where Code in (select BookID from Asm6_BookPublishs where Qty > 0))
 rollback transaction;
end;
--20. Viết trigger chỉ cho phép xóa một danh mục sách khi không còn cuốn sách nào thuộc chuyênmục này.create trigger ko_xoa_san_pham
on Asm6_Categorys
after Delete 
as 
begin 
if exists (select * from deleted where Id in (select CategoryID from Asm6_Books))
 rollback transaction;
end;