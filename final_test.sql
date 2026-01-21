create database insurance_system;
use insurance_system;

create table customers(
	Customer_ID char(10) primary key ,
	Full_Name varchar(100) not null,
	Phone_Number varchar (15) unique,
	Email varchar(50) unique,
	Join_Date datetime default current_timestamp
);

create table Insurance_Packages(
	Package_ID char(10) primary key,
	Package_Name varchar(100) not null,
	Max_Limit decimal(10,2) check (Max_Limit>0),
	Base_Premium decimal (10,2)
);

create table policies(
	Policy_ID char(10) primary key,
	Customer_ID char(10) not null,
	Package_ID char(10)  not null,
	Start_Date date,
	End_Date date, 
    status enum('Active', 'Expired', 'Cancelled'),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    FOREIGN KEY (Package_ID) REFERENCES Insurance_Packages(Package_ID)
);

create table claims(
	Claim_ID char(10) primary key,
	Policy_ID char(10) not null,
	Claim_Date date,
	Claim_Amount decimal(10,2) check (Claim_Amount>0),
    status enum ('Pending', 'Approved', 'Rejected'),
    FOREIGN KEY (Policy_ID) REFERENCES Policies(Policy_ID)
);

create table Claim_Processing_Log(
	Log_ID char(10) primary key,
	Claim_ID char(10) not null,
	Action_Detail text not null,
	Recorded_At datetime default current_timestamp,
    Processor varchar(50) not null,
    FOREIGN KEY (Claim_ID) REFERENCES Claims(Claim_ID)
);

insert into customers(Customer_ID,Full_Name,Phone_Number,Email,Join_Date) values 
	('C001','Nguyen Hoang Long','0901112223','long.nh@gmail.com','2024-01-15'),
	('C002','Tran Thi Kim Anh','0988877766','anh.tk@yahoo.com','2024-03-10'),
	('C003','Le Hoang Nam','0903334445','nam.lh@outlook.com','2025-05-20'),
	('C004','Pham Minh Duc','0355556667','duc.pm@gmail.com','2025-08-12'),
	('C005','Hoang Thu Thao','0779998881','thao.ht@gmail.com','2026-01-01');

insert into Insurance_Packages(Package_ID,Package_Name,Max_Limit,Base_Premium) values
	('PKG01','Bảo hiểm Sức khỏe Gold',500000000.00,5000000.00),
	('PKG02','Bảo hiểm Ô tô Liberty',1000000000.00,15000000.00),
	('PKG03','Bảo hiểm Nhân thọ An Bình',2000000000.00,25000000.00),
	('PKG04', 'Bảo hiểm Du lịch Quốc tế',100000000.00,1000000.00),
    ('PKG05','Bảo hiểm Tai nạn 24/7',200000000.00,2500000.00);
insert into policies(Policy_ID,Customer_ID,Package_ID,Start_Date,End_Date,status) values
	('POL101','C001','PKG01','2024-01-15','2025-01-15','Expired'),
	('POL102','C002','PKG02','2024-03-10','2026-03-10','Active'),
	('POL103','C003','PKG03','2025-05-20','2035-05-20','Active'),
	('POL104','C004','PKG04','2025-08-12','2025-09-12','Expired'),
	('POL105','C005','PKG01','2026-01-01','2027-01-01','Active');
insert into claims(Claim_ID,Policy_ID,Claim_Date,Claim_Amount,status) values
	('CLM901','POL102','2024-06-15',12000000,'Approved'),
	('CLM902','POL103','2025-10-20',50000000,'Pending'),
	('CLM903','POL101','2024-11-05',5500000,'Approved'),
	('CLM904','POL105','2026-01-15',2000000,'Rejected'),
    ('CLM905','POL102','2025-02-10',120000000,'Approved');
insert into Claim_Processing_Log(Log_ID,Claim_ID,Action_Detail,Recorded_At,Processor) values
	('L001','CLM901','Đã nhận hồ sơ hiện trường','2024-06-15 09:00','Admin_01'),
    ('L002','CLM901','Chấp nhận bồi thường xe tai nạn','2024-06-20 14:30','Admin_01'),
    ('L003','CLM902','Đang thẩm định hồ sơ bệnh án','2025-10-21 10:00','Admin_02'),
	('L004','CLM904','Từ chối do lỗi cố ý của khách hàng','2026-01-16 16:00','Admin_03'),
    ('L005','CLM905','Đã thanh toán qua chuyển khoản','2025-02-15 08:30','Accountant_01');

-- PHẦN 2: TRUY VẤN DỮ LIỆU CƠ BẢN
--   - Câu 1: Liệt kê thông tin các hợp đồng có trạng thái 'Active' và có ngày kết thúc trong năm 2026.
select * from policies
where status = 'Active' and End_Date between '2026-01-01' and '2026-12-31';

--   - Câu 2: Lấy thông tin khách hàng (Họ tên, Email) có tên chứa chữ 'Hoàng' và tham gia bảo hiểm từ năm 2025 trở lại đây.
select Full_Name,Email from customers
where Full_Name like '%Hoàng%' and Join_Date >= '2025-01-01';

--   - Câu 3: Hiển thị top 3 yêu cầu bồi thường (Claims) có số tiền được yêu cầu cao nhất, bỏ qua yêu cầu cao nhất (lấy từ vị trí số 2 đến số 4).
select * from claims
order by Claim_Amount desc
limit 3 offset 1;

-- PHẦN 3: TRUY VẤN DỮ LIỆU NÂNG CAO
--   - Câu 1: Sử dụng JOIN để hiển thị: Tên khách hàng, Tên gói bảo hiểm, Ngày bắt đầu hợp đồng và Số tiền bồi thường (nếu có).
select c.Full_Name 'Tên khách hang', ip.Package_Name 'Tên gói bảo hiểm', p.Start_Date 'Ngày bắt đầu', cl.Claim_Amount 'Số tiền bồi thường'
from policies p
join customers c on p.Customer_ID = c.Customer_ID
join insurance_packages ip on p.Package_ID = ip.Package_ID
left join claims cl on p.Policy_ID = cl.Policy_ID;

--   - Câu 2: Thống kê tổng số tiền bồi thường đã chi trả ('Approved') cho từng khách hàng. Chỉ hiện những người có tổng chi trả > 50.000.000 VNĐ.
select c.Full_Name as 'Tên khách hang',sum(cl.Claim_Amount) as 'Tổng tiền bồi thường'
from customers c
join policies p on c.Customer_ID = p.Customer_ID
join claims cl on p.Policy_ID = cl.Policy_ID
where cl.status = 'Approved'
group by c.Customer_ID
having sum(cl.Claim_Amount) > 50000000;


--   - Câu 3: Tìm gói bảo hiểm có số lượng khách hàng đăng ký nhiều nhất.
select ip.Package_Name 'Tên gói bảo hiểm', count(*) as so_luong
from policies p
join insurance_packages ip on p.Package_ID = ip.Package_ID
group by p.Package_ID
order by so_luong desc
limit 1;


-- PHẦN 4: INDEX VÀ VIEW
--   - Câu 1: Tạo Composite Index tên idx_policy_status_date trên bảng Policies cho hai cột: status và start_date.
create index idx_policy_status_date
on policies (status, Start_Date);

--   - Câu 2: Tạo một View tên vw_customer_summary hiển thị: Tên khách hàng, Số lượng hợp đồng đang sở hữu, và Tổng phí bảo hiểm định kỳ họ phải trả.
create view vw_customer_summary as
select c.Full_Name as 'Tên khách hàng',count(p.Policy_ID) as 'Số lượng hợp đồng',sum(ip.Base_Premium) as 'Tổng phí bảo hiểm định kỳ'
from customers c
left join policies p 
on c.Customer_ID = p.Customer_ID and p.status = 'Active'
left join Insurance_Packages ip 
on p.Package_ID = ip.Package_ID
group by c.Customer_ID, c.Full_Name;


-- PHẦN 5: TRIGGER
--   - Câu 1: Viết Trigger trg_after_claim_approved. Khi một yêu cầu bồi thường chuyển trạng thái sang 'Approved', tự động thêm một dòng vào Claim_Processing_Log với nội dung 'Payment processed to customer'.
delimiter //
create trigger trg_after_claim_approved
after update on claims
for each row
begin
    if old.status <> 'Approved' and new.status = 'Approved' then
        insert into Claim_Processing_Log(Log_ID, Claim_ID, Action_Detail, Processor)values (
            concat('LOG', unix_timestamp()),
            new.Claim_ID,
            'Payment processed to customer',
            'Admin1'
        );
    end if;
end //
delimiter ;

--  - Câu 2: Viết Trigger ngăn chặn việc xóa hợp đồng nếu trạng thái của hợp đồng đó đang là 'Active'.
delimiter //
create trigger trg_before_deletePolicy
before delete on policies
for each row
begin
	if old.status = 'Active' then
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi : Không thể xóa hợp đồng đang hoạt động';
	end if;
end //
delimiter ;

-- PHẦN 6: STORED PROCEDURE
--   - Câu 1: Viết Procedure sp_check_claim_limit nhận vào Mã yêu cầu bồi thường. Trả về tham số OUT message:
delimiter //
create procedure sp_check_claim_limit (in p_Claim_ID char(10),out message varchar(20))
begin
    declare v_claim_amount decimal(15,2);
    declare v_max_limit decimal(15,2);
    select cl.Claim_Amount,ip.Max_Limit into v_claim_amount,v_max_limit
    from claims cl
    join policies p on cl.Policy_ID = p.Policy_ID
    join insurance_packages ip on p.Package_ID = ip.Package_ID
    where cl.Claim_ID = p_Claim_ID;
    if v_claim_amount > v_max_limit then
        set message = 'Exceeded';
    else
        set message = 'Valid';
    end if;
end //
delimiter ;

call sp_check_claim_limit('CLM905', @result);
select @result;

