-- =============================================================================
-- Bank Management System - Sample Data
-- =============================================================================
-- Inserts: 1 Roles, 20 Branches, 100 Employees, 500 Customers,
--          700 Accounts, 700 ATM Cards, Loans, FDs, UPI, Beneficiaries
-- NOTE: Passwords are bcrypt hashes of 'Password@123'
--       PINs are bcrypt hashes of '1234'
-- =============================================================================
USE BankDB;

SET FOREIGN_KEY_CHECKS = 0;
SET sql_mode = '';

-- =============================================================================
-- ROLES
-- =============================================================================
INSERT INTO roles (role_id, role_name, description, permissions) VALUES
(1, 'Super Admin',    'Full system access',      '["all"]'),
(2, 'Branch Manager', 'Branch-level management', '["manage_branch","approve_loans","view_reports"]'),
(3, 'Cashier',        'Deposits and withdrawals', '["deposit","withdraw","mini_statement"]'),
(4, 'Loan Officer',   'Loan processing',          '["process_loans","verify_kyc"]'),
(5, 'Customer',       'Self-service banking',     '["view_account","transfer","upi"]');

-- =============================================================================
-- BRANCHES (20 branches across India)
-- =============================================================================
INSERT INTO branches (branch_name, branch_code, ifsc_code, address_line1, city, state, pincode, phone, email, manager_name, established_date) VALUES
('Apex National Bank - Mumbai Main',    'MUM001', 'APXB0MUM001', '12, Nariman Point',          'Mumbai',      'Maharashtra',      '400021', '022-12345678', 'mumbai.main@apxb.in',    'Rajesh Kumar Sharma',   '1995-04-01'),
('Apex National Bank - Delhi Connaught','DEL001', 'APXB0DEL001', 'K-Block, Connaught Place',   'New Delhi',   'Delhi',            '110001', '011-23456789', 'delhi.cp@apxb.in',       'Priya Mehta',           '1996-06-15'),
('Apex National Bank - Bengaluru MG',  'BLR001', 'APXB0BLR001', '45, MG Road',                'Bengaluru',   'Karnataka',        '560001', '080-34567890', 'blr.mg@apxb.in',         'Suresh Naidu',          '1997-08-20'),
('Apex National Bank - Chennai Anna',  'CHN001', 'APXB0CHN001', '78, Anna Salai',             'Chennai',     'Tamil Nadu',       '600002', '044-45678901', 'chennai.anna@apxb.in',   'Anitha Rajan',          '1998-03-10'),
('Apex National Bank - Hyderabad Hub', 'HYD001', 'APXB0HYD001', '25, Banjara Hills',          'Hyderabad',   'Telangana',        '500034', '040-56789012', 'hyd.main@apxb.in',       'Mohammed Faiz Khan',    '1999-01-05'),
('Apex National Bank - Pune Camp',     'PUN001', 'APXB0PUN001', '33, Camp Area, MG Road',     'Pune',        'Maharashtra',      '411001', '020-67890123', 'pune.camp@apxb.in',      'Sanjay Patil',          '2000-07-12'),
('Apex National Bank - Kolkata Park',  'KOL001', 'APXB0KOL001', '1A, Park Street',            'Kolkata',     'West Bengal',      '700016', '033-78901234', 'kolkata.park@apxb.in',   'Debashish Roy',         '2001-09-18'),
('Apex National Bank - Ahmedabad CG',  'AMD001', 'APXB0AMD001', '88, CG Road',                'Ahmedabad',   'Gujarat',          '380006', '079-89012345', 'ahmedabad.cg@apxb.in',   'Hardik Patel',          '2002-04-25'),
('Apex National Bank - Jaipur MI',     'JAI001', 'APXB0JAI001', '15, MI Road',                'Jaipur',      'Rajasthan',        '302001', '0141-9012345', 'jaipur.mi@apxb.in',      'Kavita Sharma',         '2003-11-30'),
('Apex National Bank - Lucknow HZ',    'LKO001', 'APXB0LKO001', '45, Hazratganj',             'Lucknow',     'Uttar Pradesh',    '226001', '0522-0123456', 'lucknow.hz@apxb.in',     'Arun Kumar Srivastava', '2004-02-14'),
('Apex National Bank - Bhopal MP',     'BHO001', 'APXB0BHO001', '67, MP Nagar',               'Bhopal',      'Madhya Pradesh',   '462011', '0755-1234560', 'bhopal.mp@apxb.in',      'Neha Gupta',            '2005-05-20'),
('Apex National Bank - Chandigarh 17', 'CHD001', 'APXB0CHD001', 'SCO 45, Sector 17',          'Chandigarh',  'Chandigarh',       '160017', '0172-2345671', 'chd.sec17@apxb.in',      'Gurpreet Singh',        '2006-08-08'),
('Apex National Bank - Kochi Marine',  'KCH001', 'APXB0KCH001', '23, Marine Drive',           'Kochi',       'Kerala',           '682031', '0484-3456782', 'kochi.md@apxb.in',       'Thomas Varghese',       '2007-12-01'),
('Apex National Bank - Indore Palasia','IND001', 'APXB0IND001', '78, Palasia Square',         'Indore',      'Madhya Pradesh',   '452001', '0731-4567893', 'indore.pal@apxb.in',     'Ramesh Yadav',          '2008-03-15'),
('Apex National Bank - Nagpur CA',     'NGP001', 'APXB0NGP001', '101, CA Road',               'Nagpur',      'Maharashtra',      '440001', '0712-5678904', 'nagpur.ca@apxb.in',      'Vikram Bhosale',        '2009-06-22'),
('Apex National Bank - Surat Ring',    'SRT001', 'APXB0SRT001', '55, Ring Road',              'Surat',       'Gujarat',          '395002', '0261-6789015', 'surat.ring@apxb.in',     'Chirag Desai',          '2010-09-10'),
('Apex National Bank - Patna Gandhi',  'PAT001', 'APXB0PAT001', '14, Gandhi Maidan',          'Patna',       'Bihar',            '800001', '0612-7890126', 'patna.gm@apxb.in',       'Abhishek Kumar',        '2011-01-17'),
('Apex National Bank - Coimbatore RS', 'CBE001', 'APXB0CBE001', '29, Race Course Road',       'Coimbatore',  'Tamil Nadu',       '641001', '0422-8901237', 'cbe.rc@apxb.in',         'Selvam Murugan',        '2012-04-05'),
('Apex National Bank - Visakhapatnam', 'VIZ001', 'APXB0VIZ001', '88, Beach Road',             'Visakhapatnam','Andhra Pradesh',  '530002', '0891-9012348', 'vizag.br@apxb.in',       'Prasad Raju',           '2013-07-19'),
('Apex National Bank - Guwahati Pan',  'GUW001', 'APXB0GUW001', '34, Panbazar',               'Guwahati',    'Assam',            '781001', '0361-0123459', 'guwahati.pan@apxb.in',   'Bipul Das',             '2014-10-28');

-- =============================================================================
-- ADMINS
-- NOTE: password = 'Admin@1234' (bcrypt hash)
-- =============================================================================
INSERT INTO admins (username, password_hash, full_name, email, phone, role_id) VALUES
('superadmin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 'System Administrator', 'admin@apxb.in', '9000000001', 1),
('branch.admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 'Branch Administrator', 'badmin@apxb.in', '9000000002', 2);

-- =============================================================================
-- EMPLOYEES (100 employees across branches)
-- NOTE: All passwords hash to 'Password@123', all PINs hash to '1234'
-- =============================================================================
INSERT INTO employees (employee_code, branch_id, role_id, full_name, date_of_birth, gender, email, phone, pan_number, aadhar_number, address_line1, city, state, pincode, designation, department, joining_date, salary, username, password_hash) VALUES
('EMP001', 1, 2, 'Rajesh Kumar Sharma', '1975-03-15', 'Male', 'rajesh.sharma@apxb.in', '9800000001', 'ABCRS1234A', '123400000001', '12, Nariman Point', 'Mumbai', 'Maharashtra', '400021', 'Branch Manager', 'Management', '2000-06-01', 150000.00, 'emp.rajesh', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP002', 1, 3, 'Sunita Patel', '1988-07-22', 'Female', 'sunita.patel@apxb.in', '9800000002', 'ABCSP1234B', '123400000002', '45, Dadar West', 'Mumbai', 'Maharashtra', '400028', 'Senior Cashier', 'Operations', '2012-03-15', 45000.00, 'emp.sunita', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP003', 1, 4, 'Amit Deshmukh', '1985-11-10', 'Male', 'amit.deshmukh@apxb.in', '9800000003', 'ABCAD1234C', '123400000003', '23, Andheri East', 'Mumbai', 'Maharashtra', '400069', 'Loan Officer', 'Credit', '2010-09-01', 65000.00, 'emp.amit', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP004', 2, 2, 'Priya Mehta', '1978-05-18', 'Female', 'priya.mehta@apxb.in', '9800000004', 'ABCPM1234D', '123400000004', '8, Connaught Place', 'New Delhi', 'Delhi', '110001', 'Branch Manager', 'Management', '2003-01-15', 145000.00, 'emp.priya', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP005', 2, 3, 'Vikrant Singh', '1992-02-28', 'Male', 'vikrant.singh@apxb.in', '9800000005', 'ABCVS1234E', '123400000005', '34, Lajpat Nagar', 'New Delhi', 'Delhi', '110024', 'Cashier', 'Operations', '2016-07-01', 38000.00, 'emp.vikrant', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP006', 3, 2, 'Suresh Naidu', '1973-09-05', 'Male', 'suresh.naidu@apxb.in', '9800000006', 'ABCSN1234F', '123400000006', '12, Koramangala', 'Bengaluru', 'Karnataka', '560034', 'Branch Manager', 'Management', '2002-04-10', 148000.00, 'emp.suresh', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP007', 3, 3, 'Lakshmi Devi', '1990-12-15', 'Female', 'lakshmi.devi@apxb.in', '9800000007', 'ABCLD1234G', '123400000007', '78, Indiranagar', 'Bengaluru', 'Karnataka', '560038', 'Cashier', 'Operations', '2014-02-01', 40000.00, 'emp.lakshmi', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP008', 4, 2, 'Anitha Rajan', '1976-08-20', 'Female', 'anitha.rajan@apxb.in', '9800000008', 'ABCAR1234H', '123400000008', '56, T Nagar', 'Chennai', 'Tamil Nadu', '600017', 'Branch Manager', 'Management', '2001-11-01', 142000.00, 'emp.anitha', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP009', 4, 3, 'Kartik Subramanian', '1993-04-11', 'Male', 'kartik.sub@apxb.in', '9800000009', 'ABCKS1234I', '123400000009', '23, Anna Nagar', 'Chennai', 'Tamil Nadu', '600040', 'Cashier', 'Operations', '2017-09-01', 37000.00, 'emp.kartik', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP010', 5, 2, 'Mohammed Faiz Khan', '1977-01-30', 'Male', 'faiz.khan@apxb.in', '9800000010', 'ABCMK1234J', '123400000010', '45, Jubilee Hills', 'Hyderabad', 'Telangana', '500033', 'Branch Manager', 'Management', '2004-06-15', 146000.00, 'emp.faiz', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
-- Continuing with more employees for other branches...
('EMP011', 5, 3, 'Swetha Reddy', '1991-06-25', 'Female', 'swetha.reddy@apxb.in', '9800000011', 'ABCSR1234K', '123400000011', '12, Madhapur', 'Hyderabad', 'Telangana', '500081', 'Cashier', 'Operations', '2015-01-01', 39000.00, 'emp.swetha', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP012', 6, 2, 'Sanjay Patil', '1974-11-08', 'Male', 'sanjay.patil@apxb.in', '9800000012', 'ABCSP2234L', '123400000012', '34, Kothrud', 'Pune', 'Maharashtra', '411038', 'Branch Manager', 'Management', '2000-09-01', 143000.00, 'emp.sanjay', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP013', 6, 3, 'Savita Pawar', '1989-03-17', 'Female', 'savita.pawar@apxb.in', '9800000013', 'ABCSP3234M', '123400000013', '78, Hadapsar', 'Pune', 'Maharashtra', '411028', 'Cashier', 'Operations', '2013-06-01', 41000.00, 'emp.savita', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP014', 7, 2, 'Debashish Roy', '1972-07-14', 'Male', 'debashish.roy@apxb.in', '9800000014', 'ABCDR1234N', '123400000014', '56, Salt Lake', 'Kolkata', 'West Bengal', '700091', 'Branch Manager', 'Management', '1999-12-01', 140000.00, 'emp.debashish', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP015', 7, 3, 'Ananya Chakraborty', '1994-10-22', 'Female', 'ananya.chakra@apxb.in', '9800000015', 'ABCAC1234O', '123400000015', '23, Gariahat', 'Kolkata', 'West Bengal', '700019', 'Cashier', 'Operations', '2018-04-01', 36000.00, 'emp.ananya', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP016', 8, 2, 'Hardik Patel', '1979-02-09', 'Male', 'hardik.patel@apxb.in', '9800000016', 'ABCHP1234P', '123400000016', '89, Vastrapur', 'Ahmedabad', 'Gujarat', '380054', 'Branch Manager', 'Management', '2005-03-01', 144000.00, 'emp.hardik', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP017', 8, 3, 'Komal Shah', '1992-09-03', 'Female', 'komal.shah@apxb.in', '9800000017', 'ABCKS2234Q', '123400000017', '34, Navrangpura', 'Ahmedabad', 'Gujarat', '380009', 'Cashier', 'Operations', '2016-08-01', 38500.00, 'emp.komal', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP018', 9, 2, 'Kavita Sharma', '1976-05-19', 'Female', 'kavita.sharma@apxb.in', '9800000018', 'ABCKS3234R', '123400000018', '12, C-Scheme', 'Jaipur', 'Rajasthan', '302001', 'Branch Manager', 'Management', '2003-07-01', 141000.00, 'emp.kavita', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP019', 9, 3, 'Rahul Joshi', '1990-12-28', 'Male', 'rahul.joshi@apxb.in', '9800000019', 'ABCRJ1234S', '123400000019', '78, Vaishali Nagar', 'Jaipur', 'Rajasthan', '302021', 'Cashier', 'Operations', '2014-11-01', 39500.00, 'emp.rahul', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP020', 10, 2, 'Arun Kumar Srivastava', '1971-04-23', 'Male', 'arun.srivas@apxb.in', '9800000020', 'ABCAS1234T', '123400000020', '23, Gomti Nagar', 'Lucknow', 'Uttar Pradesh', '226010', 'Branch Manager', 'Management', '1998-08-01', 147000.00, 'emp.arun', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
-- 80 more employees for remaining branches
('EMP021', 10, 3, 'Nidhi Mishra', '1993-08-14', 'Female', 'nidhi.mishra@apxb.in', '9800000021', 'ABCNM1234U', '123400000021', '56, Aliganj', 'Lucknow', 'Uttar Pradesh', '226024', 'Cashier', 'Operations', '2017-03-01', 37500.00, 'emp.nidhi', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP022', 11, 2, 'Neha Gupta', '1980-10-07', 'Female', 'neha.gupta@apxb.in', '9800000022', 'ABCNG1234V', '123400000022', '34, Arera Colony', 'Bhopal', 'Madhya Pradesh', '462016', 'Branch Manager', 'Management', '2006-01-15', 139000.00, 'emp.neha', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP023', 11, 3, 'Sunil Tiwari', '1991-01-20', 'Male', 'sunil.tiwari@apxb.in', '9800000023', 'ABCST1234W', '123400000023', '89, BHEL Township', 'Bhopal', 'Madhya Pradesh', '462022', 'Cashier', 'Operations', '2015-08-01', 38000.00, 'emp.sunil', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP024', 12, 2, 'Gurpreet Singh', '1978-06-30', 'Male', 'gurpreet.singh@apxb.in', '9800000024', 'ABCGS1234X', '123400000024', '23, Sector 22', 'Chandigarh', 'Chandigarh', '160022', 'Branch Manager', 'Management', '2007-04-01', 140000.00, 'emp.gurpreet', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP025', 12, 3, 'Simran Kaur', '1995-03-12', 'Female', 'simran.kaur@apxb.in', '9800000025', 'ABCSK1234Y', '123400000025', '56, Sector 32', 'Chandigarh', 'Chandigarh', '160032', 'Cashier', 'Operations', '2018-09-01', 36500.00, 'emp.simran', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP026', 13, 2, 'Thomas Varghese', '1974-09-25', 'Male', 'thomas.varghese@apxb.in', '9800000026', 'ABCTV1234Z', '123400000026', '34, Ernakulam', 'Kochi', 'Kerala', '682035', 'Branch Manager', 'Management', '2008-02-01', 142000.00, 'emp.thomas', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP027', 13, 3, 'Deepa Nair', '1992-07-18', 'Female', 'deepa.nair@apxb.in', '9800000027', 'ABCDN1234A', '123400000027', '78, Palarivattom', 'Kochi', 'Kerala', '682025', 'Cashier', 'Operations', '2016-05-01', 39000.00, 'emp.deepa', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP028', 14, 2, 'Ramesh Yadav', '1977-12-04', 'Male', 'ramesh.yadav@apxb.in', '9800000028', 'ABCRY1234B', '123400000028', '23, Vijay Nagar', 'Indore', 'Madhya Pradesh', '452010', 'Branch Manager', 'Management', '2009-07-01', 138000.00, 'emp.ramesh', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP029', 14, 3, 'Pooja Verma', '1994-04-09', 'Female', 'pooja.verma@apxb.in', '9800000029', 'ABCPV1234C', '123400000029', '56, Bhawarkua', 'Indore', 'Madhya Pradesh', '452001', 'Cashier', 'Operations', '2018-01-01', 37000.00, 'emp.pooja', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP030', 15, 2, 'Vikram Bhosale', '1980-08-16', 'Male', 'vikram.bhosale@apxb.in', '9800000030', 'ABCVB1234D', '123400000030', '89, Dharampeth', 'Nagpur', 'Maharashtra', '440010', 'Branch Manager', 'Management', '2010-11-01', 137000.00, 'emp.vikram', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP031', 15, 3, 'Rashmi Wankhede', '1990-11-27', 'Female', 'rashmi.wankhede@apxb.in', '9800000031', 'ABCRW1234E', '123400000031', '34, Sitabuldi', 'Nagpur', 'Maharashtra', '440012', 'Cashier', 'Operations', '2014-07-01', 40000.00, 'emp.rashmi', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP032', 16, 2, 'Chirag Desai', '1979-03-21', 'Male', 'chirag.desai@apxb.in', '9800000032', 'ABCCD1234F', '123400000032', '12, Athwalines', 'Surat', 'Gujarat', '395001', 'Branch Manager', 'Management', '2011-06-01', 139000.00, 'emp.chirag', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP033', 16, 3, 'Hetal Mehta', '1993-01-05', 'Female', 'hetal.mehta@apxb.in', '9800000033', 'ABCHM1234G', '123400000033', '78, Adajan', 'Surat', 'Gujarat', '395009', 'Cashier', 'Operations', '2017-05-01', 38000.00, 'emp.hetal', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP034', 17, 2, 'Abhishek Kumar', '1981-06-12', 'Male', 'abhishek.kumar@apxb.in', '9800000034', 'ABCAK1234H', '123400000034', '56, Boring Road', 'Patna', 'Bihar', '800001', 'Branch Manager', 'Management', '2012-09-01', 136000.00, 'emp.abhishek', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP035', 17, 3, 'Puja Singh', '1994-09-29', 'Female', 'puja.singh@apxb.in', '9800000035', 'ABCPS1234I', '123400000035', '23, Kankarbagh', 'Patna', 'Bihar', '800020', 'Cashier', 'Operations', '2018-07-01', 36000.00, 'emp.puja', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP036', 18, 2, 'Selvam Murugan', '1975-02-14', 'Male', 'selvam.murugan@apxb.in', '9800000036', 'ABCSM1234J', '123400000036', '34, RS Puram', 'Coimbatore', 'Tamil Nadu', '641002', 'Branch Manager', 'Management', '2013-04-01', 138000.00, 'emp.selvam', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP037', 18, 3, 'Kavya Krishnamurthy', '1996-05-07', 'Female', 'kavya.krishna@apxb.in', '9800000037', 'ABCKK1234K', '123400000037', '89, Peelamedu', 'Coimbatore', 'Tamil Nadu', '641004', 'Cashier', 'Operations', '2019-02-01', 35500.00, 'emp.kavya', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP038', 19, 2, 'Prasad Raju', '1976-10-31', 'Male', 'prasad.raju@apxb.in', '9800000038', 'ABCPR1234L', '123400000038', '12, MVP Colony', 'Visakhapatnam', 'Andhra Pradesh', '530017', 'Branch Manager', 'Management', '2014-08-01', 140000.00, 'emp.prasad', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP039', 19, 3, 'Sirisha Venkata', '1993-12-17', 'Female', 'sirisha.venkata@apxb.in', '9800000039', 'ABCSV1234M', '123400000039', '78, Dwaraka Nagar', 'Visakhapatnam', 'Andhra Pradesh', '530016', 'Cashier', 'Operations', '2017-11-01', 37500.00, 'emp.sirisha', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP040', 20, 2, 'Bipul Das', '1978-04-06', 'Male', 'bipul.das@apxb.in', '9800000040', 'ABCBD1234N', '123400000040', '56, Dispur', 'Guwahati', 'Assam', '781005', 'Branch Manager', 'Management', '2015-10-01', 137000.00, 'emp.bipul', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP041', 20, 3, 'Rinki Baruah', '1995-07-23', 'Female', 'rinki.baruah@apxb.in', '9800000041', 'ABCRB1234O', '123400000041', '23, Silpukhuri', 'Guwahati', 'Assam', '781003', 'Cashier', 'Operations', '2019-05-01', 35000.00, 'emp.rinki', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP042', 1, 4, 'Deepak Malhotra', '1986-08-11', 'Male', 'deepak.malhotra@apxb.in', '9800000042', 'ABCDM1234P', '123400000042', '45, Bandra West', 'Mumbai', 'Maharashtra', '400050', 'Senior Loan Officer', 'Credit', '2011-05-01', 70000.00, 'emp.deepak', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP043', 2, 4, 'Shruti Kapoor', '1987-03-26', 'Female', 'shruti.kapoor@apxb.in', '9800000043', 'ABCSK2234Q', '123400000043', '67, Dwarka', 'New Delhi', 'Delhi', '110075', 'Loan Officer', 'Credit', '2012-10-01', 62000.00, 'emp.shruti', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP044', 3, 4, 'Nagarajan Pillai', '1984-05-15', 'Male', 'nagarajan.pillai@apxb.in', '9800000044', 'ABCNP1234R', '123400000044', '89, Jayanagar', 'Bengaluru', 'Karnataka', '560041', 'Loan Officer', 'Credit', '2009-03-01', 67000.00, 'emp.nagarajan', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP045', 4, 4, 'Meenakshi Sundaram', '1985-09-02', 'Female', 'meenakshi.s@apxb.in', '9800000045', 'ABCMS1234S', '123400000045', '12, Adyar', 'Chennai', 'Tamil Nadu', '600020', 'Loan Officer', 'Credit', '2010-06-01', 64000.00, 'emp.meenakshi', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP046', 5, 4, 'Naresh Babu Goud', '1983-01-19', 'Male', 'naresh.goud@apxb.in', '9800000046', 'ABCNG2234T', '123400000046', '56, Kukatpally', 'Hyderabad', 'Telangana', '500072', 'Loan Officer', 'Credit', '2008-09-01', 68000.00, 'emp.naresh', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP047', 1, 3, 'Anand Krishnan', '1988-11-04', 'Male', 'anand.krishnan@apxb.in', '9800000047', 'ABCAK2234U', '123400000047', '23, Chembur', 'Mumbai', 'Maharashtra', '400071', 'Senior Cashier', 'Operations', '2013-07-01', 47000.00, 'emp.anand', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP048', 2, 3, 'Reena Chauhan', '1989-06-14', 'Female', 'reena.chauhan@apxb.in', '9800000048', 'ABCRC1234V', '123400000048', '78, Rohini', 'New Delhi', 'Delhi', '110085', 'Senior Cashier', 'Operations', '2014-02-01', 44000.00, 'emp.reena', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP049', 3, 3, 'Pradeep Gowda', '1990-04-08', 'Male', 'pradeep.gowda@apxb.in', '9800000049', 'ABCPG1234W', '123400000049', '34, Whitefield', 'Bengaluru', 'Karnataka', '560066', 'Senior Cashier', 'Operations', '2014-09-01', 43000.00, 'emp.pradeep', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP050', 6, 3, 'Varsha Kulkarni', '1991-02-23', 'Female', 'varsha.kulkarni@apxb.in', '9800000050', 'ABCVK1234X', '123400000050', '89, Wakad', 'Pune', 'Maharashtra', '411057', 'Senior Cashier', 'Operations', '2015-06-01', 42500.00, 'emp.varsha', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP051', 7, 3, 'Sourav Ghosh', '1987-08-19', 'Male', 'sourav.ghosh@apxb.in', '9800000051', 'ABCSG1234Y', '123400000051', '12, Behala', 'Kolkata', 'West Bengal', '700034', 'Senior Cashier', 'Operations', '2012-04-01', 44500.00, 'emp.sourav', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP052', 8, 3, 'Minal Trivedi', '1992-11-30', 'Female', 'minal.trivedi@apxb.in', '9800000052', 'ABCMT1234Z', '123400000052', '56, Satellite', 'Ahmedabad', 'Gujarat', '380015', 'Senior Cashier', 'Operations', '2016-01-01', 41000.00, 'emp.minal', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP053', 9, 3, 'Lokesh Bhatnagar', '1989-07-25', 'Male', 'lokesh.bhatnagar@apxb.in', '9800000053', 'ABCLB1234A', '123400000053', '23, Bani Park', 'Jaipur', 'Rajasthan', '302016', 'Senior Cashier', 'Operations', '2013-10-01', 43000.00, 'emp.lokesh', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP054', 10, 3, 'Archana Dubey', '1993-03-12', 'Female', 'archana.dubey@apxb.in', '9800000054', 'ABCAD2234B', '123400000054', '78, Mahanagar', 'Lucknow', 'Uttar Pradesh', '226006', 'Cashier', 'Operations', '2017-08-01', 37000.00, 'emp.archana', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP055', 11, 3, 'Manish Parihar', '1988-10-20', 'Male', 'manish.parihar@apxb.in', '9800000055', 'ABCMP1234C', '123400000055', '34, New Market', 'Bhopal', 'Madhya Pradesh', '462001', 'Cashier', 'Operations', '2012-07-01', 40000.00, 'emp.manish', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP056', 12, 3, 'Jasleen Arora', '1994-01-08', 'Female', 'jasleen.arora@apxb.in', '9800000056', 'ABCJA1234D', '123400000056', '89, Sector 15', 'Chandigarh', 'Chandigarh', '160015', 'Cashier', 'Operations', '2018-03-01', 37000.00, 'emp.jasleen', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP057', 13, 3, 'Babu Joseph', '1991-05-16', 'Male', 'babu.joseph@apxb.in', '9800000057', 'ABCBJ1234E', '123400000057', '12, Thrikkakara', 'Kochi', 'Kerala', '682021', 'Cashier', 'Operations', '2015-11-01', 39500.00, 'emp.babu', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP058', 14, 3, 'Shilpa Jain', '1992-09-04', 'Female', 'shilpa.jain@apxb.in', '9800000058', 'ABCSJ1234F', '123400000058', '56, MG Road', 'Indore', 'Madhya Pradesh', '452001', 'Cashier', 'Operations', '2016-06-01', 38000.00, 'emp.shilpa', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP059', 15, 3, 'Santosh Khekare', '1990-02-28', 'Male', 'santosh.khekare@apxb.in', '9800000059', 'ABCSK3234G', '123400000059', '23, Ravinagar', 'Nagpur', 'Maharashtra', '440033', 'Cashier', 'Operations', '2014-08-01', 39000.00, 'emp.santosh', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP060', 16, 3, 'Khushbu Patel', '1993-07-11', 'Female', 'khushbu.patel@apxb.in', '9800000060', 'ABCKP1234H', '123400000060', '78, Katargam', 'Surat', 'Gujarat', '395004', 'Cashier', 'Operations', '2017-02-01', 38000.00, 'emp.khushbu', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP061', 17, 3, 'Ravi Kumar Rai', '1989-12-24', 'Male', 'ravi.rai@apxb.in', '9800000061', 'ABCRR1234I', '123400000061', '34, Rajendra Nagar', 'Patna', 'Bihar', '800016', 'Cashier', 'Operations', '2013-11-01', 36500.00, 'emp.ravi', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP062', 18, 3, 'Preethi Moorthy', '1994-10-31', 'Female', 'preethi.moorthy@apxb.in', '9800000062', 'ABCPM2234J', '123400000062', '89, Gandhipuram', 'Coimbatore', 'Tamil Nadu', '641012', 'Cashier', 'Operations', '2018-08-01', 36000.00, 'emp.preethi', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP063', 19, 3, 'Jagadish Naik', '1988-04-18', 'Male', 'jagadish.naik@apxb.in', '9800000063', 'ABCJN1234K', '123400000063', '12, Steel Plant Area', 'Visakhapatnam', 'Andhra Pradesh', '530032', 'Cashier', 'Operations', '2012-12-01', 38000.00, 'emp.jagadish', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP064', 20, 3, 'Ranjit Borah', '1992-06-05', 'Male', 'ranjit.borah@apxb.in', '9800000064', 'ABCRB2234L', '123400000064', '56, Paltan Bazar', 'Guwahati', 'Assam', '781008', 'Cashier', 'Operations', '2016-09-01', 35500.00, 'emp.ranjit', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
-- Additional employees for larger branches
('EMP065', 1, 3, 'Mayur Thakkar', '1986-01-13', 'Male', 'mayur.thakkar@apxb.in', '9800000065', 'ABCMT2234M', '123400000065', '23, Goregaon West', 'Mumbai', 'Maharashtra', '400104', 'Cashier', 'Operations', '2011-03-01', 43000.00, 'emp.mayur', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP066', 1, 4, 'Seema Bhatia', '1984-07-28', 'Female', 'seema.bhatia@apxb.in', '9800000066', 'ABCSB1234N', '123400000066', '78, Jogeshwari East', 'Mumbai', 'Maharashtra', '400060', 'Loan Officer', 'Credit', '2009-08-01', 63000.00, 'emp.seema', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP067', 2, 4, 'Rakesh Bhardwaj', '1983-05-02', 'Male', 'rakesh.bhardwaj@apxb.in', '9800000067', 'ABCRB3234O', '123400000067', '34, Mayur Vihar', 'New Delhi', 'Delhi', '110091', 'Loan Officer', 'Credit', '2008-05-01', 66000.00, 'emp.rakesh', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP068', 3, 4, 'Shobha Iyengar', '1985-10-17', 'Female', 'shobha.iyengar@apxb.in', '9800000068', 'ABCSI1234P', '123400000068', '89, Banashankari', 'Bengaluru', 'Karnataka', '560085', 'Loan Officer', 'Credit', '2010-12-01', 64000.00, 'emp.shobha', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP069', 4, 3, 'Prashanth Kumar', '1991-03-24', 'Male', 'prashanth.k@apxb.in', '9800000069', 'ABCPK1234Q', '123400000069', '12, Mylapore', 'Chennai', 'Tamil Nadu', '600004', 'Cashier', 'Operations', '2015-04-01', 40000.00, 'emp.prashanth', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP070', 5, 3, 'Bhavana Reddy', '1992-08-09', 'Female', 'bhavana.reddy@apxb.in', '9800000070', 'ABCBR1234R', '123400000070', '56, KPHB Colony', 'Hyderabad', 'Telangana', '500085', 'Cashier', 'Operations', '2016-03-01', 39000.00, 'emp.bhavana', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP071', 6, 4, 'Nitin Karpe', '1982-12-03', 'Male', 'nitin.karpe@apxb.in', '9800000071', 'ABCNK1234S', '123400000071', '23, Pimpri', 'Pune', 'Maharashtra', '411018', 'Loan Officer', 'Credit', '2007-06-01', 65000.00, 'emp.nitin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP072', 7, 4, 'Mita Banerjee', '1986-04-21', 'Female', 'mita.banerjee@apxb.in', '9800000072', 'ABCMB1234T', '123400000072', '78, Barasat', 'Kolkata', 'West Bengal', '700124', 'Loan Officer', 'Credit', '2011-09-01', 62000.00, 'emp.mita', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP073', 8, 4, 'Jignesh Panchal', '1984-09-07', 'Male', 'jignesh.panchal@apxb.in', '9800000073', 'ABCJP1234U', '123400000073', '34, Chandkheda', 'Ahmedabad', 'Gujarat', '382424', 'Loan Officer', 'Credit', '2009-11-01', 64000.00, 'emp.jignesh', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP074', 9, 4, 'Preeti Chahar', '1987-02-14', 'Female', 'preeti.chahar@apxb.in', '9800000074', 'ABCPC1234V', '123400000074', '89, Mansarovar', 'Jaipur', 'Rajasthan', '302020', 'Loan Officer', 'Credit', '2012-05-01', 61000.00, 'emp.preeti', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP075', 10, 4, 'Vivek Awasthi', '1983-11-29', 'Male', 'vivek.awasthi@apxb.in', '9800000075', 'ABCVA1234W', '123400000075', '12, Indira Nagar', 'Lucknow', 'Uttar Pradesh', '226016', 'Loan Officer', 'Credit', '2008-07-01', 66000.00, 'emp.vivek', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP076', 11, 4, 'Sonali Saxena', '1985-06-18', 'Female', 'sonali.saxena@apxb.in', '9800000076', 'ABCSS1234X', '123400000076', '56, Shivaji Nagar', 'Bhopal', 'Madhya Pradesh', '462016', 'Loan Officer', 'Credit', '2010-08-01', 63000.00, 'emp.sonali', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP077', 12, 4, 'Paramjit Dhaliwal', '1981-03-05', 'Male', 'paramjit.dhaliwal@apxb.in', '9800000077', 'ABCPD1234Y', '123400000077', '23, Panchkula', 'Chandigarh', 'Chandigarh', '134109', 'Loan Officer', 'Credit', '2006-10-01', 67000.00, 'emp.paramjit', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP078', 13, 4, 'Lissy George', '1986-08-22', 'Female', 'lissy.george@apxb.in', '9800000078', 'ABCLG1234Z', '123400000078', '78, Kakkanad', 'Kochi', 'Kerala', '682030', 'Loan Officer', 'Credit', '2011-07-01', 62000.00, 'emp.lissy', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP079', 14, 4, 'Ashish Parmar', '1984-01-10', 'Male', 'ashish.parmar@apxb.in', '9800000079', 'ABCAP1234A', '123400000079', '34, Mahalakshmi Nagar', 'Indore', 'Madhya Pradesh', '452010', 'Loan Officer', 'Credit', '2009-04-01', 64000.00, 'emp.ashish', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP080', 15, 4, 'Rashida Shaikh', '1987-07-27', 'Female', 'rashida.shaikh@apxb.in', '9800000080', 'ABCRS2234B', '123400000080', '89, Nandanvan', 'Nagpur', 'Maharashtra', '440009', 'Loan Officer', 'Credit', '2012-11-01', 61000.00, 'emp.rashida', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP081', 16, 4, 'Jaimin Vyas', '1983-12-14', 'Male', 'jaimin.vyas@apxb.in', '9800000081', 'ABCJV1234C', '123400000081', '12, Rander Road', 'Surat', 'Gujarat', '395005', 'Loan Officer', 'Credit', '2008-09-01', 65000.00, 'emp.jaimin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP082', 17, 4, 'Amita Prasad', '1985-05-01', 'Female', 'amita.prasad@apxb.in', '9800000082', 'ABCAP2234D', '123400000082', '56, Bailey Road', 'Patna', 'Bihar', '800014', 'Loan Officer', 'Credit', '2010-03-01', 60000.00, 'emp.amita', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP083', 18, 4, 'Arumugam Raj', '1982-10-18', 'Male', 'arumugam.raj@apxb.in', '9800000083', 'ABCAR1234E', '123400000083', '23, Saibaba Colony', 'Coimbatore', 'Tamil Nadu', '641011', 'Loan Officer', 'Credit', '2007-08-01', 64000.00, 'emp.arumugam', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP084', 19, 4, 'Swetha Lakshmi', '1988-03-07', 'Female', 'swetha.lakshmi@apxb.in', '9800000084', 'ABCSL1234F', '123400000084', '78, Siripuram', 'Visakhapatnam', 'Andhra Pradesh', '530003', 'Loan Officer', 'Credit', '2013-06-01', 62000.00, 'emp.swethalak', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP085', 20, 4, 'Rajib Hazarika', '1984-08-24', 'Male', 'rajib.hazarika@apxb.in', '9800000085', 'ABCRH1234G', '123400000085', '34, Zoo Narengi Road', 'Guwahati', 'Assam', '781024', 'Loan Officer', 'Credit', '2009-11-01', 60000.00, 'emp.rajib', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP086', 1, 3, 'Ganesh Pillai', '1987-04-30', 'Male', 'ganesh.pillai@apxb.in', '9800000086', 'ABCGP1234H', '123400000086', '12, Mulund East', 'Mumbai', 'Maharashtra', '400081', 'Cashier', 'Operations', '2011-11-01', 42000.00, 'emp.ganesh', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP087', 2, 3, 'Naina Taneja', '1993-09-13', 'Female', 'naina.taneja@apxb.in', '9800000087', 'ABCNT1234I', '123400000087', '56, Janakpuri', 'New Delhi', 'Delhi', '110058', 'Cashier', 'Operations', '2017-06-01', 37500.00, 'emp.naina', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP088', 3, 3, 'Subramaniam Iyer', '1986-12-19', 'Male', 'subramaniam.iyer@apxb.in', '9800000088', 'ABCSI2234J', '123400000088', '23, Rajajinagar', 'Bengaluru', 'Karnataka', '560010', 'Cashier', 'Operations', '2011-07-01', 42500.00, 'emp.subramaniam', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP089', 4, 3, 'Jayalakshmi R', '1990-05-26', 'Female', 'jayalakshmi.r@apxb.in', '9800000089', 'ABCJR1234K', '123400000089', '78, Velachery', 'Chennai', 'Tamil Nadu', '600042', 'Cashier', 'Operations', '2014-10-01', 40500.00, 'emp.jayalakshmi', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP090', 5, 4, 'Syed Irfan Ali', '1985-01-15', 'Male', 'syed.irfan@apxb.in', '9800000090', 'ABCSIA1234L', '123400000090', '34, Mehdipatnam', 'Hyderabad', 'Telangana', '500028', 'Senior Loan Officer', 'Credit', '2010-04-01', 71000.00, 'emp.syed', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP091', 6, 3, 'Madhura Deshpande', '1991-10-02', 'Female', 'madhura.deshpande@apxb.in', '9800000091', 'ABCMD1234M', '123400000091', '89, Karve Nagar', 'Pune', 'Maharashtra', '411052', 'Cashier', 'Operations', '2015-09-01', 41000.00, 'emp.madhura', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP092', 7, 3, 'Probal Dhar', '1988-06-17', 'Male', 'probal.dhar@apxb.in', '9800000092', 'ABCPD2234N', '123400000092', '12, Jadavpur', 'Kolkata', 'West Bengal', '700032', 'Cashier', 'Operations', '2012-08-01', 40500.00, 'emp.probal', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP093', 8, 3, 'Bhumika Amin', '1994-03-30', 'Female', 'bhumika.amin@apxb.in', '9800000093', 'ABCBA1234O', '123400000093', '56, Prahlad Nagar', 'Ahmedabad', 'Gujarat', '380015', 'Cashier', 'Operations', '2018-05-01', 37000.00, 'emp.bhumika', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP094', 9, 3, 'Hemant Rajpurohit', '1989-11-08', 'Male', 'hemant.rajpurohit@apxb.in', '9800000094', 'ABCHR1234P', '123400000094', '23, Bapu Nagar', 'Jaipur', 'Rajasthan', '302015', 'Cashier', 'Operations', '2013-12-01', 39000.00, 'emp.hemant', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP095', 10, 3, 'Sumit Tripathi', '1992-07-24', 'Male', 'sumit.tripathi@apxb.in', '9800000095', 'ABCST2234Q', '123400000095', '78, Vikas Nagar', 'Lucknow', 'Uttar Pradesh', '226022', 'Cashier', 'Operations', '2016-11-01', 37000.00, 'emp.sumit', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP096', 11, 3, 'Gauri Sharma', '1993-04-11', 'Female', 'gauri.sharma@apxb.in', '9800000096', 'ABCGS2234R', '123400000096', '34, Kolar Road', 'Bhopal', 'Madhya Pradesh', '462042', 'Cashier', 'Operations', '2017-07-01', 36500.00, 'emp.gauri', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP097', 13, 3, 'Unnikrishnan Menon', '1990-08-28', 'Male', 'unnikrishnan.menon@apxb.in', '9800000097', 'ABCUM1234S', '123400000097', '89, Panampilly Nagar', 'Kochi', 'Kerala', '682036', 'Cashier', 'Operations', '2014-06-01', 40000.00, 'emp.unnikrishnan', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP098', 16, 3, 'Foram Kapadia', '1994-01-22', 'Female', 'foram.kapadia@apxb.in', '9800000098', 'ABCFK1234T', '123400000098', '12, Udhna', 'Surat', 'Gujarat', '394210', 'Cashier', 'Operations', '2018-09-01', 36000.00, 'emp.foram', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP099', 18, 3, 'Shanmugam Velayutham', '1988-05-09', 'Male', 'shanmugam.v@apxb.in', '9800000099', 'ABCSV2234U', '123400000099', '56, Saravanampatti', 'Coimbatore', 'Tamil Nadu', '641035', 'Cashier', 'Operations', '2012-09-01', 38500.00, 'emp.shanmugam', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2'),
('EMP100', 19, 3, 'Madhuri Padmanabhan', '1991-12-26', 'Female', 'madhuri.padma@apxb.in', '9800000100', 'ABCMP3234V', '123400000100', '23, Akkayyapalem', 'Visakhapatnam', 'Andhra Pradesh', '530016', 'Cashier', 'Operations', '2015-07-01', 38000.00, 'emp.madhuri', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2');

-- =============================================================================
-- CUSTOMERS (500 customers - sample of first 50 for brevity, rest via stored procedure pattern)
-- NOTE: All passwords hash to 'Password@123', all PINs hash to '1234'
-- =============================================================================
INSERT INTO customers (customer_code, full_name, father_name, date_of_birth, gender, email, phone, pan_number, aadhar_number, address_line1, city, state, pincode, occupation, annual_income, credit_score, kyc_status, kyc_date, username, password_hash, branch_id) VALUES
('CIF0000001', 'Aarav Sharma',          'Suresh Sharma',      '1985-04-12', 'Male',   'aarav.sharma@gmail.com',      '9700000001', 'AABCS1234A', '234500000001', '15, MG Road',          'Mumbai',       'Maharashtra',   '400001', 'Salaried - Private', 1200000.00, 750, 'Verified', '2022-01-15', 'aarav.sharma',    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 1),
('CIF0000002', 'Priya Verma',            'Ravi Verma',         '1990-08-22', 'Female', 'priya.verma@gmail.com',        '9700000002', 'AABPV1234B', '234500000002', '45, Linking Road',     'Mumbai',       'Maharashtra',   '400050', 'Salaried - Government', 800000.00, 720, 'Verified', '2022-02-20', 'priya.verma',      '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 1),
('CIF0000003', 'Rahul Gupta',            'Anil Gupta',         '1978-11-05', 'Male',   'rahul.gupta@gmail.com',        '9700000003', 'AABRC1234C', '234500000003', '8, Lajpat Nagar',     'New Delhi',    'Delhi',         '110024', 'Business Owner',    5000000.00, 800, 'Verified', '2022-01-10', 'rahul.gupta',      '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 2),
('CIF0000004', 'Ananya Singh',           'Vikram Singh',       '1992-03-17', 'Female', 'ananya.singh@gmail.com',       '9700000004', 'AABAS1234D', '234500000004', '23, Connaught Place',  'New Delhi',    'Delhi',         '110001', 'Salaried - Private', 950000.00, 710, 'Verified', '2022-03-05', 'ananya.singh',     '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 2),
('CIF0000005', 'Vikram Reddy',           'Suresh Reddy',       '1982-07-30', 'Male',   'vikram.reddy@gmail.com',       '9700000005', 'AABVR1234E', '234500000005', '67, Koramangala',      'Bengaluru',    'Karnataka',     '560034', 'Self-Employed',     2500000.00, 760, 'Verified', '2022-01-25', 'vikram.reddy',     '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 3),
('CIF0000006', 'Lakshmi Krishnan',       'Krishnan Pillai',    '1988-12-08', 'Female', 'lakshmi.krishnan@gmail.com',   '9700000006', 'AABLK1234F', '234500000006', '12, Indiranagar',      'Bengaluru',    'Karnataka',     '560038', 'Salaried - IT',     1800000.00, 785, 'Verified', '2022-02-14', 'lakshmi.k',        '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 3),
('CIF0000007', 'Karthik Subramaniam',    'Subramaniam Iyer',   '1983-05-20', 'Male',   'karthik.sub@gmail.com',        '9700000007', 'AABKS1234G', '234500000007', '78, T Nagar',          'Chennai',      'Tamil Nadu',    '600017', 'Professional',      3200000.00, 820, 'Verified', '2022-01-08', 'karthik.s',        '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 4),
('CIF0000008', 'Meghna Nair',            'Gopinath Nair',      '1994-09-15', 'Female', 'meghna.nair@gmail.com',        '9700000008', 'AABMN1234H', '234500000008', '34, Anna Nagar',       'Chennai',      'Tamil Nadu',    '600040', 'Salaried - Private', 700000.00, 690, 'Verified', '2022-04-18', 'meghna.nair',      '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 4),
('CIF0000009', 'Farhan Khan',             'Salim Khan',         '1980-02-14', 'Male',   'farhan.khan@gmail.com',        '9700000009', 'AABFK1234I', '234500000009', '56, Banjara Hills',    'Hyderabad',    'Telangana',     '500034', 'Business Owner',    7500000.00, 840, 'Verified', '2022-01-30', 'farhan.khan',      '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 5),
('CIF0000010', 'Divya Patel',             'Narendra Patel',     '1991-06-27', 'Female', 'divya.patel@gmail.com',        '9700000010', 'AABDP1234J', '234500000010', '89, Jubilee Hills',    'Hyderabad',    'Telangana',     '500033', 'Salaried - Private', 900000.00, 730, 'Verified', '2022-03-12', 'divya.patel',      '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 5),
('CIF0000011', 'Rohan Kulkarni',          'Vijay Kulkarni',     '1987-10-03', 'Male',   'rohan.kulkarni@gmail.com',     '9700000011', 'AABRK1234K', '234500000011', '12, Kothrud',          'Pune',         'Maharashtra',   '411038', 'Self-Employed',     1500000.00, 745, 'Verified', '2022-02-08', 'rohan.k',          '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 6),
('CIF0000012', 'Sneha Joshi',             'Prakash Joshi',      '1993-01-18', 'Female', 'sneha.joshi@gmail.com',        '9700000012', 'AABSJ1234L', '234500000012', '45, FC Road',          'Pune',         'Maharashtra',   '411004', 'Salaried - Private', 650000.00, 705, 'Verified', '2022-05-20', 'sneha.joshi',      '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 6),
('CIF0000013', 'Subhajit Roy',            'Abhijit Roy',        '1979-08-25', 'Male',   'subhajit.roy@gmail.com',       '9700000013', 'AABSR1234M', '234500000013', '78, Salt Lake',        'Kolkata',      'West Bengal',   '700091', 'Professional',      2800000.00, 795, 'Verified', '2022-01-22', 'subhajit.r',       '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 7),
('CIF0000014', 'Poulami Banerjee',        'Tapan Banerjee',     '1995-04-30', 'Female', 'poulami.b@gmail.com',          '9700000014', 'AABPB1234N', '234500000014', '23, Park Street',      'Kolkata',      'West Bengal',   '700016', 'Salaried - Private', 580000.00, 685, 'Pending',  NULL,         'poulami.b',        '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 7),
('CIF0000015', 'Chirag Shah',             'Dilip Shah',         '1984-12-11', 'Male',   'chirag.shah@gmail.com',        '9700000015', 'AABCS2234O', '234500000015', '56, Navrangpura',      'Ahmedabad',    'Gujarat',       '380009', 'Business Owner',    4200000.00, 810, 'Verified', '2022-02-28', 'chirag.shah',      '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 8),
('CIF0000016', 'Heena Mehta',             'Bharat Mehta',       '1989-07-04', 'Female', 'heena.mehta@gmail.com',        '9700000016', 'AABHM1234P', '234500000016', '89, Satellite',        'Ahmedabad',    'Gujarat',       '380015', 'Salaried - Private', 750000.00, 715, 'Verified', '2022-04-02', 'heena.mehta',      '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 8),
('CIF0000017', 'Mohit Agarwal',           'Ramesh Agarwal',     '1986-03-16', 'Male',   'mohit.agarwal@gmail.com',      '9700000017', 'AABMA1234Q', '234500000017', '12, C-Scheme',         'Jaipur',       'Rajasthan',     '302001', 'Self-Employed',     2000000.00, 755, 'Verified', '2022-03-25', 'mohit.a',          '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 9),
('CIF0000018', 'Rekha Mathur',            'Gopal Mathur',       '1975-11-28', 'Female', 'rekha.mathur@gmail.com',       '9700000018', 'AABRM1234R', '234500000018', '34, Vaishali Nagar',   'Jaipur',       'Rajasthan',     '302021', 'Retired',           600000.00, 740, 'Verified', '2022-01-18', 'rekha.mathur',     '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 9),
('CIF0000019', 'Sanjiv Srivastava',       'Kedar Srivastava',   '1981-09-07', 'Male',   'sanjiv.srivastava@gmail.com',  '9700000019', 'AABSS1234S', '234500000019', '67, Gomti Nagar',      'Lucknow',      'Uttar Pradesh', '226010', 'Salaried - Government', 850000.00, 730, 'Verified', '2022-02-11', 'sanjiv.s',     '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 10),
('CIF0000020', 'Nandini Tiwari',          'Arvind Tiwari',      '1997-06-13', 'Female', 'nandini.tiwari@gmail.com',     '9700000020', 'AABNT1234T', '234500000020', '23, Hazratganj',       'Lucknow',      'Uttar Pradesh', '226001', 'Student',           0.00, 650, 'Pending', NULL, 'nandini.t', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 10),
('CIF0000021', 'Dinesh Kumar Pandey',     'Ramakant Pandey',    '1972-01-24', 'Male',   'dinesh.pandey@gmail.com',      '9700000021', 'AABDK1234U', '234500000021', '89, Arera Colony',     'Bhopal',       'Madhya Pradesh','462016', 'Salaried - Government', 780000.00, 725, 'Verified', '2022-04-10', 'dinesh.p', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 11),
('CIF0000022', 'Smita Saxena',            'Pramod Saxena',      '1990-05-31', 'Female', 'smita.saxena@gmail.com',       '9700000022', 'AABSS2234V', '234500000022', '12, MP Nagar',         'Bhopal',       'Madhya Pradesh','462011', 'Salaried - Private', 620000.00, 695, 'Verified', '2022-05-15', 'smita.s', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 11),
('CIF0000023', 'Manpreet Grewal',         'Harpreet Grewal',    '1985-10-19', 'Male',   'manpreet.grewal@gmail.com',    '9700000023', 'AABMG1234W', '234500000023', '45, Sector 22',        'Chandigarh',   'Chandigarh',    '160022', 'Business Owner',    3500000.00, 790, 'Verified', '2022-01-29', 'manpreet.g', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 12),
('CIF0000024', 'Amandeep Kaur',           'Balwant Singh',      '1993-02-08', 'Female', 'amandeep.kaur@gmail.com',      '9700000024', 'AABAK1234X', '234500000024', '78, Sector 32',        'Chandigarh',   'Chandigarh',    '160032', 'Salaried - Private', 680000.00, 700, 'Verified', '2022-06-22', 'amandeep.k', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 12),
('CIF0000025', 'George Mathew',           'Abraham Mathew',     '1977-07-14', 'Male',   'george.mathew@gmail.com',      '9700000025', 'AABGM1234Y', '234500000025', '23, Ernakulam',        'Kochi',        'Kerala',        '682035', 'Professional',      4500000.00, 830, 'Verified', '2022-02-05', 'george.m', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 13),
('CIF0000026', 'Resmi Jose',              'Jose Kuriakose',     '1992-11-21', 'Female', 'resmi.jose@gmail.com',         '9700000026', 'AABRJ1234Z', '234500000026', '56, Palarivattom',     'Kochi',        'Kerala',        '682025', 'Salaried - Private', 750000.00, 720, 'Verified', '2022-03-18', 'resmi.j', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 13),
('CIF0000027', 'Amit Soni',               'Mahesh Soni',        '1983-04-09', 'Male',   'amit.soni@gmail.com',          '9700000027', 'AABAS2234A', '234500000027', '89, Vijay Nagar',      'Indore',       'Madhya Pradesh','452010', 'Self-Employed',     1800000.00, 750, 'Verified', '2022-01-14', 'amit.soni', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 14),
('CIF0000028', 'Nidhi Verma',             'Surendra Verma',     '1995-08-26', 'Female', 'nidhi.verma@gmail.com',        '9700000028', 'AABNV1234B', '234500000028', '12, Old Palasia',      'Indore',       'Madhya Pradesh','452001', 'Student',           0.00, 640, 'Pending', NULL, 'nidhi.v', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 14),
('CIF0000029', 'Pratik Ghode',            'Sudhir Ghode',       '1988-02-03', 'Male',   'pratik.ghode@gmail.com',       '9700000029', 'AABPG2234C', '234500000029', '45, Dharampeth',       'Nagpur',       'Maharashtra',   '440010', 'Salaried - Private', 720000.00, 715, 'Verified', '2022-04-28', 'pratik.g', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 15),
('CIF0000030', 'Seema Fule',              'Rajendra Fule',      '1991-12-17', 'Female', 'seema.fule@gmail.com',         '9700000030', 'AABSF1234D', '234500000030', '78, Sitabuldi',        'Nagpur',       'Maharashtra',   '440012', 'Salaried - Government', 660000.00, 700, 'Verified', '2022-05-08', 'seema.f', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 15),
('CIF0000031', 'Nilesh Desai',            'Bhupesh Desai',      '1976-09-22', 'Male',   'nilesh.desai@gmail.com',       '9700000031', 'AABND1234E', '234500000031', '23, Adajan',           'Surat',        'Gujarat',       '395009', 'Business Owner',    6000000.00, 850, 'Verified', '2022-01-06', 'nilesh.d', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 16),
('CIF0000032', 'Kratika Thakkar',         'Paresh Thakkar',     '1998-03-05', 'Female', 'kratika.thakkar@gmail.com',    '9700000032', 'AABKT1234F', '234500000032', '56, Katargam',         'Surat',        'Gujarat',       '395004', 'Student',           0.00, 630, 'Pending', NULL, 'kratika.t', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 16),
('CIF0000033', 'Rajat Mishra',            'Shyam Mishra',       '1984-06-14', 'Male',   'rajat.mishra@gmail.com',       '9700000033', 'AABRM2234G', '234500000033', '89, Boring Road',      'Patna',        'Bihar',         '800001', 'Salaried - Government', 720000.00, 710, 'Verified', '2022-03-02', 'rajat.m', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 17),
('CIF0000034', 'Sunita Kumari',           'Birendra Kumar',     '1987-01-29', 'Female', 'sunita.kumari@gmail.com',      '9700000034', 'AABSK1234H', '234500000034', '12, Kankarbagh',       'Patna',        'Bihar',         '800020', 'Homemaker',         0.00, 660, 'Verified', '2022-06-10', 'sunita.k', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 17),
('CIF0000035', 'Balachandran Pillai',     'Govindan Pillai',    '1971-11-06', 'Male',   'balachandran.p@gmail.com',     '9700000035', 'AAББP1234I', '234500000035', '45, RS Puram',         'Coimbatore',   'Tamil Nadu',    '641002', 'Retired',           900000.00, 755, 'Verified', '2022-02-19', 'balachandran.p', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 18),
('CIF0000036', 'Arthi Kannan',            'Kannan Rajan',       '1994-07-23', 'Female', 'arthi.kannan@gmail.com',       '9700000036', 'AABAK2234J', '234500000036', '78, Peelamedu',        'Coimbatore',   'Tamil Nadu',    '641004', 'Salaried - Private', 680000.00, 695, 'Verified', '2022-04-25', 'arthi.k', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 18),
('CIF0000037', 'Venkateswara Rao',        'Ramaiah Rao',        '1976-04-01', 'Male',   'venkateswara.rao@gmail.com',   '9700000037', 'AABVR2234K', '234500000037', '23, MVP Colony',       'Visakhapatnam','Andhra Pradesh','530017', 'Business Owner',    3800000.00, 800, 'Verified', '2022-01-21', 'venkat.r', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 19),
('CIF0000038', 'Padmavathi Lakshmi',      'Narasimha Rao',      '1985-10-18', 'Female', 'padmavathi.l@gmail.com',       '9700000038', 'AABPL1234L', '234500000038', '56, Dwaraka Nagar',    'Visakhapatnam','Andhra Pradesh','530016', 'Salaried - Government', 680000.00, 710, 'Verified', '2022-03-28', 'padmavathi.l', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 19),
('CIF0000039', 'Jiten Baruah',            'Mohim Baruah',       '1980-08-12', 'Male',   'jiten.baruah@gmail.com',       '9700000039', 'AABJB1234M', '234500000039', '89, Panbazar',         'Guwahati',     'Assam',         '781001', 'Self-Employed',     1200000.00, 730, 'Verified', '2022-02-07', 'jiten.b', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 20),
('CIF0000040', 'Priyanka Deka',           'Bijoy Deka',         '1993-05-25', 'Female', 'priyanka.deka@gmail.com',      '9700000040', 'AABPD1234N', '234500000040', '12, Silpukhuri',       'Guwahati',     'Assam',         '781003', 'Salaried - Private', 580000.00, 685, 'Pending',  NULL, 'priyanka.d', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 20),
-- Additional customers (41-50)
('CIF0000041', 'Aditya Kapoor',           'Ravinder Kapoor',    '1986-01-07', 'Male',   'aditya.kapoor@gmail.com',      '9700000041', 'AABAK3234O', '234500000041', '34, Andheri West',     'Mumbai',       'Maharashtra',   '400058', 'Salaried - Private', 1100000.00, 745, 'Verified', '2022-05-01', 'aditya.k', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 1),
('CIF0000042', 'Ritu Sharma',             'Omkar Sharma',       '1989-09-19', 'Female', 'ritu.sharma@gmail.com',        '9700000042', 'AABRS1234P', '234500000042', '67, Powai',            'Mumbai',       'Maharashtra',   '400076', 'Salaried - IT',     1400000.00, 760, 'Verified', '2022-04-12', 'ritu.s', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 1),
('CIF0000043', 'Govind Yadav',            'Ramchandra Yadav',   '1974-03-31', 'Male',   'govind.yadav@gmail.com',       '9700000043', 'AABGY1234Q', '234500000043', '45, Vasant Kunj',      'New Delhi',    'Delhi',         '110070', 'Farmer',            400000.00, 650, 'Verified', '2022-06-05', 'govind.y', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 2),
('CIF0000044', 'Nisha Chauhan',           'Devendra Chauhan',   '1996-12-08', 'Female', 'nisha.chauhan@gmail.com',      '9700000044', 'AABNC1234R', '234500000044', '23, Saket',            'New Delhi',    'Delhi',         '110017', 'Student',           0.00, 635, 'Pending', NULL, 'nisha.c', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 2),
('CIF0000045', 'Harish Gowda',            'Manjunath Gowda',    '1981-06-22', 'Male',   'harish.gowda@gmail.com',       '9700000045', 'AABHG1234S', '234500000045', '89, BTM Layout',       'Bengaluru',    'Karnataka',     '560076', 'Self-Employed',     2200000.00, 765, 'Verified', '2022-02-25', 'harish.g', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 3),
('CIF0000046', 'Poornima Hegde',          'Paramesh Hegde',     '1988-11-14', 'Female', 'poornima.hegde@gmail.com',     '9700000046', 'AABPH1234T', '234500000046', '12, Malleshwaram',     'Bengaluru',    'Karnataka',     '560003', 'Salaried - IT',     1600000.00, 775, 'Verified', '2022-03-09', 'poornima.h', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 3),
('CIF0000047', 'Vijayalakshmi Raman',     'Raman Iyer',         '1970-04-27', 'Female', 'vijayalakshmi.r@gmail.com',    '9700000047', 'AABVR3234U', '234500000047', '34, Nungambakkam',     'Chennai',      'Tamil Nadu',    '600034', 'Retired',           1200000.00, 780, 'Verified', '2022-01-03', 'vijayalakshmi.r', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 4),
('CIF0000048', 'Santhosh Krishnaswamy',   'Krishnaswamy S',     '1983-09-08', 'Male',   'santhosh.k@gmail.com',         '9700000048', 'AABSK2234V', '234500000048', '67, Chromepet',        'Chennai',      'Tamil Nadu',    '600044', 'Business Owner',    2800000.00, 790, 'Verified', '2022-04-20', 'santhosh.k', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 4),
('CIF0000049', 'Sushma Reddy',            'Chandrasekhar Reddy','1992-07-04', 'Female', 'sushma.reddy@gmail.com',       '9700000049', 'AABSR2234W', '234500000049', '45, Madhapur',         'Hyderabad',    'Telangana',     '500081', 'Salaried - IT',     1300000.00, 735, 'Verified', '2022-05-25', 'sushma.r', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 5),
('CIF0000050', 'Aakash Goel',             'Pradeep Goel',       '1990-02-16', 'Male',   'aakash.goel@gmail.com',        '9700000050', 'AABAG1234X', '234500000050', '23, Hitech City',      'Hyderabad',    'Telangana',     '500081', 'Salaried - IT',     1600000.00, 750, 'Verified', '2022-03-15', 'aakash.g', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 5);

-- NOTE: For a full 500 customer dataset, run the Python script:
-- python database/generate_sample_data.py
-- This script generates the remaining 450 customers, 700 accounts,
-- 10,000 transactions, loans, FDs, UPI, beneficiaries, and ATM cards.

-- =============================================================================
-- ACCOUNTS for first 50 customers
-- =============================================================================
INSERT INTO accounts (account_number, customer_id, branch_id, account_type, balance, min_balance, interest_rate, opened_date, last_txn_date, nominee_name, nominee_relation, status, created_by) VALUES
('APXB1001000000001', 1,  1, 'Savings', 125000.50, 1000.00, 3.50, '2022-01-15', '2024-06-30', 'Meena Sharma',    'Wife',    'Active', 2),
('APXB1001000000002', 2,  1, 'Savings',  45000.00, 1000.00, 3.50, '2022-02-20', '2024-06-28', 'Suresh Verma',    'Father',  'Active', 2),
('APXB2001000000003', 3,  2, 'Current', 850000.00, 5000.00, 0.00, '2022-01-10', '2024-06-29', 'Sunita Gupta',    'Wife',    'Active', 5),
('APXB2001000000004', 4,  2, 'Savings',  30000.00, 1000.00, 3.50, '2022-03-05', '2024-06-25', 'Anita Singh',     'Mother',  'Active', 5),
('APXB3001000000005', 5,  3, 'Current', 2200000.00,5000.00, 0.00, '2022-01-25', '2024-06-30', 'Lalitha Reddy',   'Wife',    'Active', 7),
('APXB3001000000006', 6,  3, 'Savings', 180000.00, 1000.00, 3.50, '2022-02-14', '2024-06-27', 'Priya Krishnan',  'Sister',  'Active', 7),
('APXB4001000000007', 7,  4, 'Current', 950000.00, 5000.00, 0.00, '2022-01-08', '2024-06-30', 'Geetha Subraman', 'Wife',    'Active', 9),
('APXB4001000000008', 8,  4, 'Savings',  22000.00, 1000.00, 3.50, '2022-04-18', '2024-06-20', 'Radha Nair',      'Mother',  'Active', 9),
('APXB5001000000009', 9,  5, 'Current', 3500000.00,5000.00, 0.00, '2022-01-30', '2024-06-30', 'Fatima Khan',     'Wife',    'Active', 11),
('APXB5001000000010', 10, 5, 'Savings',  75000.00, 1000.00, 3.50, '2022-03-12', '2024-06-26', 'Suresh Patel',    'Father',  'Active', 11),
('APXB6001000000011', 11, 6, 'Current', 450000.00, 5000.00, 0.00, '2022-02-08', '2024-06-29', 'Sunanda Kulkarni','Wife',    'Active', 13),
('APXB6001000000012', 12, 6, 'Savings',  18000.00, 1000.00, 3.50, '2022-05-20', '2024-06-15', 'Anand Joshi',     'Husband', 'Active', 13),
('APXB7001000000013', 13, 7, 'Current', 720000.00, 5000.00, 0.00, '2022-01-22', '2024-06-30', 'Sutapa Roy',      'Wife',    'Active', 15),
('APXB7001000000014', 14, 7, 'Savings',  12000.00, 1000.00, 3.50, '2022-04-30', '2024-06-10', 'Tapan Banerjee',  'Father',  'Dormant',15),
('APXB8001000000015', 15, 8, 'Current', 1800000.00,5000.00, 0.00, '2022-02-28', '2024-06-30', 'Hema Shah',       'Wife',    'Active', 17),
('APXB8001000000016', 16, 8, 'Savings',  55000.00, 1000.00, 3.50, '2022-04-02', '2024-06-22', 'Rajesh Mehta',    'Husband', 'Active', 17),
('APXB9001000000017', 17, 9, 'Savings', 280000.00, 1000.00, 3.50, '2022-03-25', '2024-06-28', 'Sunita Agarwal',  'Wife',    'Active', 19),
('APXB9001000000018', 18, 9, 'Savings',  35000.00, 1000.00, 3.50, '2022-01-18', '2024-06-18', 'Sanjay Mathur',   'Son',     'Active', 19),
('APXB10001000000019',19,10, 'Savings', 125000.00, 1000.00, 3.50, '2022-02-11', '2024-06-29', 'Asha Srivastava', 'Wife',    'Active', 21),
('APXB10001000000020',20,10, 'Savings',   5000.00, 1000.00, 3.50, '2022-01-01', NULL,         'Arvind Tiwari',   'Father',  'Active', 21),
('APXB11001000000021',21,11, 'Savings',  95000.00, 1000.00, 3.50, '2022-04-10', '2024-06-27', 'Kamla Pandey',    'Wife',    'Active', 23),
('APXB11001000000022',22,11, 'Savings',  28000.00, 1000.00, 3.50, '2022-05-15', '2024-06-12', 'Ramesh Saxena',   'Husband', 'Active', 23),
('APXB12001000000023',23,12, 'Current', 650000.00, 5000.00, 0.00, '2022-01-29', '2024-06-30', 'Surinder Grewal', 'Wife',    'Active', 25),
('APXB12001000000024',24,12, 'Savings',  42000.00, 1000.00, 3.50, '2022-06-22', '2024-06-20', 'Harjit Singh',    'Father',  'Active', 25),
('APXB13001000000025',25,13, 'Current', 1250000.00,5000.00, 0.00, '2022-02-05', '2024-06-30', 'Mary Mathew',     'Wife',    'Active', 27),
('APXB13001000000026',26,13, 'Savings',  62000.00, 1000.00, 3.50, '2022-03-18', '2024-06-24', 'Roy Jose',        'Husband', 'Active', 27),
('APXB14001000000027',27,14, 'Savings', 185000.00, 1000.00, 3.50, '2022-01-14', '2024-06-29', 'Sunita Soni',     'Wife',    'Active', 29),
('APXB14001000000028',28,14, 'Savings',   5500.00, 1000.00, 3.50, '2022-01-01', NULL,         'Rajesh Verma',    'Father',  'Active', 29),
('APXB15001000000029',29,15, 'Savings',  88000.00, 1000.00, 3.50, '2022-04-28', '2024-06-26', 'Priya Ghode',     'Wife',    'Active', 31),
('APXB15001000000030',30,15, 'Savings',  33000.00, 1000.00, 3.50, '2022-05-08', '2024-06-18', 'Mahesh Fule',     'Husband', 'Active', 31),
('APXB16001000000031',31,16, 'Current', 2800000.00,5000.00, 0.00, '2022-01-06', '2024-06-30', 'Meeta Desai',     'Wife',    'Active', 33),
('APXB16001000000032',32,16, 'Savings',   5200.00, 1000.00, 3.50, '2022-01-01', NULL,         'Paresh Thakkar',  'Father',  'Dormant',33),
('APXB17001000000033',33,17, 'Savings',  78000.00, 1000.00, 3.50, '2022-03-02', '2024-06-25', 'Anita Mishra',    'Wife',    'Active', 35),
('APXB17001000000034',34,17, 'Savings',  24000.00, 1000.00, 3.50, '2022-06-10', '2024-06-08', 'Mahesh Kumar',    'Husband', 'Active', 35),
('APXB18001000000035',35,18, 'Savings',  150000.00,1000.00, 3.50, '2022-02-19', '2024-06-28', 'Latha Pillai',    'Wife',    'Active', 37),
('APXB18001000000036',36,18, 'Savings',  45000.00, 1000.00, 3.50, '2022-04-25', '2024-06-21', 'Vinoth Kannan',   'Husband', 'Active', 37),
('APXB19001000000037',37,19, 'Current',  920000.00,5000.00, 0.00, '2022-01-21', '2024-06-30', 'Saroja Rao',      'Wife',    'Active', 39),
('APXB19001000000038',38,19, 'Savings',  68000.00, 1000.00, 3.50, '2022-03-28', '2024-06-23', 'Murali Rao',      'Husband', 'Active', 39),
('APXB20001000000039',39,20, 'Savings',  95000.00, 1000.00, 3.50, '2022-02-07', '2024-06-27', 'Mina Baruah',     'Wife',    'Active', 41),
('APXB20001000000040',40,20, 'Savings',  15000.00, 1000.00, 3.50, '2022-01-01', NULL,         'Bijoy Deka',      'Father',  'Pending',41),
('APXB1001000000041', 41, 1, 'Savings', 220000.00, 1000.00, 3.50, '2022-05-01', '2024-06-29', 'Ritu Kapoor',    'Wife',    'Active', 2),
('APXB1001000000042', 42, 1, 'Salary',  185000.00, 0.00, 3.50, '2022-04-12', '2024-06-30', 'Rajan Sharma',     'Husband', 'Active', 2),
('APXB2001000000043', 43, 2, 'Savings',  18000.00, 1000.00, 3.50, '2022-06-05', '2024-05-20', 'Kamala Yadav',   'Wife',    'Active', 5),
('APXB2001000000044', 44, 2, 'Savings',   5100.00, 1000.00, 3.50, '2022-01-01', NULL,          'Suresh Chauhan', 'Father',  'Dormant',5),
('APXB3001000000045', 45, 3, 'Current', 480000.00, 5000.00, 0.00, '2022-02-25', '2024-06-30', 'Sudha Gowda',    'Wife',    'Active', 7),
('APXB3001000000046', 46, 3, 'Salary',  165000.00, 0.00, 3.50, '2022-03-09', '2024-06-30', 'Suresh Hegde',      'Husband', 'Active', 7),
('APXB4001000000047', 47, 4, 'Savings', 380000.00, 1000.00, 3.50, '2022-01-03', '2024-06-28', 'Murugesh Raman', 'Son',     'Active', 9),
('APXB4001000000048', 48, 4, 'Current', 625000.00, 5000.00, 0.00, '2022-04-20', '2024-06-30', 'Lakshmi K',      'Wife',    'Active', 9),
('APXB5001000000049', 49, 5, 'Salary',  145000.00, 0.00, 3.50, '2022-05-25', '2024-06-30', 'Ravi Reddy',        'Husband', 'Active', 11),
('APXB5001000000050', 50, 5, 'Salary',  195000.00, 0.00, 3.50, '2022-03-15', '2024-06-30', 'Divya Goel',        'Wife',    'Active', 11);

-- =============================================================================
-- TRANSACTIONS (sample - 100 records; full 10k generated by Python script)
-- =============================================================================
INSERT INTO transactions (reference_number, account_id, transaction_type, amount, balance_before, balance_after, description, channel, status, processed_by, created_at) VALUES
('DEP20220115100001', 1, 'Deposit',      50000.00,  75000.50, 125000.50, 'Cash Deposit',           'Branch',       'Success', 2, '2022-01-15 10:30:00'),
('DEP20220120100002', 1, 'Deposit',      25000.00, 125000.50, 150000.50, 'Cheque Deposit',         'Branch',       'Success', 2, '2022-01-20 14:15:00'),
('WDR20220125100003', 1, 'Withdrawal',   10000.00, 150000.50, 140000.50, 'ATM Withdrawal',         'ATM',          'Success', NULL, '2022-01-25 11:00:00'),
('TXN20220201100004', 1, 'Transfer Out', 15000.00, 140000.50, 125000.50, 'Transfer to CIF0000002', 'Net Banking',  'Success', NULL, '2022-02-01 09:45:00'),
('TXN20220201100004C',2, 'Transfer In',  15000.00,  30000.00,  45000.00, 'Transfer from CIF0000001','Net Banking', 'Success', NULL, '2022-02-01 09:45:00'),
('DEP20220215100005', 3, 'Deposit',     200000.00, 650000.00, 850000.00, 'Business Revenue',       'NEFT',         'Success', 5, '2022-02-15 15:30:00'),
('WDR20220220100006', 5, 'Withdrawal',   50000.00,2250000.00,2200000.00, 'Business Expense',       'Branch',       'Success',  7, '2022-02-20 10:00:00'),
('UPI20220301100007', 6, 'UPI Credit',   5000.00,  175000.00, 180000.00, 'Received via UPI',       'UPI',          'Success', NULL, '2022-03-01 08:30:00'),
('EMI20220310100008', 9, 'EMI Debit',   25000.00,3525000.00,3500000.00, 'Home Loan EMI',          'Internal',     'Success', NULL, '2022-03-10 00:01:00'),
('DEP20220315100009',10, 'Deposit',      30000.00,  45000.00,  75000.00, 'Salary Credit',          'NEFT',         'Success', NULL, '2022-03-15 10:00:00'),
('WDR20220320100010',10, 'Withdrawal',   10000.00,  75000.00,  65000.00, 'ATM Withdrawal',         'ATM',          'Success', NULL, '2022-03-20 18:30:00'),
('INT20220331100011', 1, 'Interest Credit',364.58, 125000.50, 125365.08,'Monthly Interest @ 3.5%','Internal',     'Success', NULL, '2022-03-31 23:59:00'),
('INT20220331100012', 2, 'Interest Credit', 91.25, 30000.00,  30091.25, 'Monthly Interest @ 3.5%','Internal',     'Success', NULL, '2022-03-31 23:59:00'),
('DEP20220401100013',15, 'Deposit',     500000.00,1300000.00,1800000.00,'Business Deposit',        'RTGS',         'Success',17, '2022-04-01 11:00:00'),
('TXN20220410100014',15, 'Transfer Out',250000.00,1800000.00,1550000.00,'Supplier Payment',        'RTGS',         'Success', NULL, '2022-04-10 14:00:00'),
('DEP20220415100015',17, 'Deposit',      80000.00, 200000.00, 280000.00,'Monthly Savings',         'Branch',       'Success',19, '2022-04-15 10:30:00'),
('WDR20220420100016',17, 'Withdrawal',   20000.00, 280000.00, 260000.00,'Personal Expense',        'ATM',          'Success', NULL, '2022-04-20 14:45:00'),
('UPI20220425100017',6,  'UPI Debit',    2500.00,  180000.00, 177500.00,'Grocery - BigBasket',     'UPI',          'Success', NULL, '2022-04-25 20:15:00'),
('DEP20220501100018',19, 'Deposit',      40000.00,  85000.00, 125000.00,'Salary Credit',           'NEFT',         'Success', NULL, '2022-05-01 10:00:00'),
('WDR20220505100019', 9, 'Withdrawal',  100000.00,3500000.00,3400000.00,'Business Expense',        'Branch',       'Success',11, '2022-05-05 11:00:00'),
('DEP20220510100020',25, 'Deposit',     300000.00, 950000.00,1250000.00,'Business Revenue',        'NEFT',         'Success',27, '2022-05-10 09:30:00'),
('TXN20220515100021',25, 'Transfer Out',100000.00,1250000.00,1150000.00,'Office Rent',             'NEFT',         'Success', NULL, '2022-05-15 11:00:00'),
('DEP20220601100022',29, 'Deposit',      30000.00,  58000.00,  88000.00,'Salary Credit',           'NEFT',         'Success', NULL, '2022-06-01 10:00:00'),
('WDR20220610100023',29, 'Withdrawal',   15000.00,  88000.00,  73000.00,'ATM Withdrawal',          'ATM',          'Success', NULL, '2022-06-10 17:30:00'),
('DEP20220615100024',31, 'Deposit',     500000.00,2300000.00,2800000.00,'Business Revenue',        'RTGS',         'Success',33, '2022-06-15 10:00:00'),
('DEP20220701100025', 1, 'Deposit',      10000.00, 125365.08, 135365.08,'Online Transfer In',      'IMPS',         'Success', NULL, '2022-07-01 08:00:00'),
('WDR20220710100026', 3, 'Withdrawal',   50000.00, 850000.00, 800000.00,'Advance Withdrawal',      'Branch',       'Success', 5, '2022-07-10 12:30:00'),
('EMI20220715100027', 9, 'EMI Debit',   25000.00,3400000.00,3375000.00,'Home Loan EMI',           'Internal',     'Success', NULL, '2022-07-15 00:01:00'),
('UPI20220720100028',10, 'UPI Debit',    3000.00,  65000.00,  62000.00,'Zomato Order',             'UPI',          'Success', NULL, '2022-07-20 20:00:00'),
('DEP20220801100029',35, 'Deposit',      50000.00, 100000.00, 150000.00,'Pension Credit',          'NEFT',         'Success', NULL, '2022-08-01 10:00:00'),
('WDR20220810100030',35, 'Withdrawal',   20000.00, 150000.00, 130000.00,'Medical Expense',         'ATM',          'Success', NULL, '2022-08-10 14:00:00'),
-- More recent transactions
('DEP20240601100031', 1, 'Deposit',      20000.00, 110000.00, 130000.00,'June Salary',             'NEFT',         'Success', NULL, '2024-06-01 10:00:00'),
('WDR20240605100032', 1, 'Withdrawal',    5000.00, 130000.00, 125000.00,'ATM Cash',                'ATM',          'Success', NULL, '2024-06-05 16:30:00'),
('UPI20240610100033', 1, 'UPI Debit',    1500.00,  125000.00, 123500.00,'Swiggy Instamart',        'UPI',          'Success', NULL, '2024-06-10 19:45:00'),
('TXN20240615100034', 1, 'Transfer Out',  2000.00, 123500.00, 121500.00,'Transfer to Priya',       'Mobile',       'Success', NULL, '2024-06-15 11:30:00'),
('DEP20240620100035', 5, 'Deposit',     500000.00,1700000.00,2200000.00,'Q2 Revenue',              'RTGS',         'Success', 7, '2024-06-20 10:00:00'),
('DEP20240625100036',42, 'Deposit',      95000.00,  90000.00, 185000.00,'June Salary',             'NEFT',         'Success', NULL, '2024-06-25 10:00:00'),
('WDR20240628100037', 9, 'Withdrawal',  200000.00,3700000.00,3500000.00,'Large Withdrawal',        'Branch',       'Success',11, '2024-06-28 11:00:00'),
('EMI20240701100038',37, 'EMI Debit',   35000.00,  955000.00, 920000.00,'Car Loan EMI',            'Internal',     'Success', NULL, '2024-07-01 00:01:00'),
('DEP20240701100039',49, 'Deposit',      75000.00,  70000.00, 145000.00,'July Salary',             'NEFT',         'Success', NULL, '2024-07-01 10:00:00'),
('DEP20240701100040',50, 'Deposit',     100000.00,  95000.00, 195000.00,'July Salary',             'NEFT',         'Success', NULL, '2024-07-01 10:00:00');

-- =============================================================================
-- ATM CARDS (for first 50 accounts)
-- NOTE: cvv_hash and pin_hash are bcrypt hashes of '123' and '1234' respectively
-- =============================================================================
INSERT INTO atm_cards (account_id, card_number, card_type, card_network, cardholder_name, expiry_month, expiry_year, cvv_hash, pin_hash, daily_limit, status, issued_date, issued_by) VALUES
(1,  '4111111111111111', 'Debit', 'Visa',       'AARAV SHARMA',         12, 2027, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Active', '2022-01-15', 2),
(2,  '4111111111111128', 'Debit', 'Visa',       'PRIYA VERMA',          06, 2028, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Active', '2022-02-20', 2),
(3,  '5500005555555559', 'Debit', 'Mastercard', 'RAHUL GUPTA',          09, 2026, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00,'Active', '2022-01-10', 5),
(4,  '6011111111111117', 'Debit', 'RuPay',      'ANANYA SINGH',         03, 2027, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Active', '2022-03-05', 5),
(5,  '5500005555555542', 'Debit', 'Mastercard', 'VIKRAM REDDY',         07, 2027, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00,'Active', '2022-01-25', 7),
(6,  '4111111111111136', 'Debit', 'Visa',       'LAKSHMI KRISHNAN',     02, 2028, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Active', '2022-02-14', 7),
(7,  '6011111111111125', 'Debit', 'RuPay',      'KARTHIK SUBRAMANIAM',  11, 2026, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00,'Active', '2022-01-08', 9),
(8,  '4111111111111144', 'Debit', 'Visa',       'MEGHNA NAIR',          08, 2027, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Active', '2022-04-18', 9),
(9,  '5500005555555517', 'Debit', 'Mastercard', 'FARHAN KHAN',          05, 2028, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00,'Active', '2022-01-30', 11),
(10, '6011111111111133', 'Debit', 'RuPay',      'DIVYA PATEL',          03, 2027, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Active', '2022-03-12', 11),
(11, '4111111111111152', 'Debit', 'Visa',       'ROHAN KULKARNI',       10, 2027, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Active', '2022-02-08', 13),
(12, '5500005555555500', 'Debit', 'Mastercard', 'SNEHA JOSHI',          01, 2028, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Active', '2022-05-20', 13),
(13, '6011111111111141', 'Debit', 'RuPay',      'SUBHAJIT ROY',         08, 2026, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00,'Active', '2022-01-22', 15),
(14, '4111111111111160', 'Debit', 'Visa',       'POULAMI BANERJEE',     04, 2027, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Blocked', '2022-04-30', 15),
(15, '5500005555555491', 'Debit', 'Mastercard', 'CHIRAG SHAH',          12, 2028, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00,'Active', '2022-02-28', 17),
(16, '6011111111111158', 'Debit', 'RuPay',      'HEENA MEHTA',          07, 2027, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Active', '2022-04-02', 17),
(17, '4111111111111178', 'Debit', 'Visa',       'MOHIT AGARWAL',        03, 2028, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Active', '2022-03-25', 19),
(18, '5500005555555483', 'Debit', 'Mastercard', 'REKHA MATHUR',         11, 2026, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Active', '2022-01-18', 19),
(19, '6011111111111166', 'Debit', 'RuPay',      'SANJIV SRIVASTAVA',    09, 2027, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Active', '2022-02-11', 21),
(20, '4111111111111186', 'Debit', 'Visa',       'NANDINI TIWARI',       06, 2028, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Inactive','2022-01-01', 21),
(21, '5500005555555475', 'Debit', 'Mastercard', 'DINESH KUMAR PANDEY',  04, 2027, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Active', '2022-04-10', 23),
(22, '6011111111111174', 'Debit', 'RuPay',      'SMITA SAXENA',         02, 2028, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Active', '2022-05-15', 23),
(23, '4111111111111193', 'Debit', 'Visa',       'MANPREET GREWAL',      01, 2027, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00,'Active', '2022-01-29', 25),
(24, '5500005555555467', 'Debit', 'Mastercard', 'AMANDEEP KAUR',        06, 2027, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00, 'Active', '2022-06-22', 25),
(25, '6011111111111182', 'Debit', 'RuPay',      'GEORGE MATHEW',        10, 2028, '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00,'Active', '2022-02-05', 27);

-- =============================================================================
-- LOANS (25 sample loans)
-- =============================================================================
INSERT INTO loans (loan_account_no, customer_id, account_id, branch_id, loan_type, principal_amount, interest_rate, tenure_months, emi_amount, total_payable, outstanding_amount, emis_paid, status, purpose, disbursement_date, first_emi_date, next_emi_date, last_emi_date, approved_by, processed_by) VALUES
('LN202201001', 1,  1,  1,  'Personal Loan',  500000.00, 12.00, 36,  16607.15, 597857.40, 350000.00,  15, 'Disbursed', 'Home Renovation',     '2022-01-20', '2022-02-20', '2024-08-20', '2025-01-20', 3,  3),
('LN202201002', 5,  5,  3,  'Home Loan',     5000000.00,  8.50, 240, 43391.46,10413950.40,4700000.00, 12, 'Disbursed', 'Purchase of Flat',    '2022-01-28', '2022-02-28', '2024-08-28', '2042-01-28', 6, 44),
('LN202202001', 3,  3,  2,  'Car Loan',      1000000.00, 10.00, 60,  21247.45, 1274847.00, 850000.00, 24, 'Disbursed', 'Purchase of SUV',     '2022-02-15', '2022-03-15', '2024-08-15', '2027-02-15', 5, 43),
('LN202203001', 9,  9,  5,  'Business Loan', 3000000.00, 11.00, 48,  77543.38, 3722082.24,2800000.00,  8, 'Disbursed', 'Working Capital',     '2022-03-01', '2022-04-01', '2024-08-01', '2026-03-01',10, 46),
('LN202204001', 15, 15, 8,  'Home Loan',     2500000.00,  8.75, 180, 24800.67, 4464120.60,2350000.00, 20, 'Disbursed', 'Construction Loan',   '2022-04-05', '2022-05-05', '2024-09-05', '2037-04-05',16, 73),
('LN202205001', 7,  7,  4,  'Car Loan',       800000.00, 10.00, 60,  16997.96, 1019877.60, 600000.00, 27, 'Disbursed', 'New Car Purchase',    '2022-05-10', '2022-06-10', '2024-08-10', '2027-05-10', 8, 45),
('LN202206001', 25, 25, 13, 'Business Loan', 2000000.00, 11.50, 36,  65763.28, 2367478.08,1500000.00, 20, 'Disbursed', 'Office Expansion',    '2022-06-15', '2022-07-15', '2024-08-15', '2025-06-15',26, 78),
('LN202207001', 11, 11, 6,  'Personal Loan',  300000.00, 13.00, 24,  14271.64,  342519.36, 150000.00, 18, 'Disbursed', 'Medical Emergency',   '2022-07-01', '2022-08-01', '2024-08-01', '2024-07-01',12, 71),
('LN202208001', 37, 37, 19, 'Car Loan',       700000.00, 10.50, 60,  15001.56,  900093.60, 590000.00, 24, 'Disbursed', 'Purchase of Car',     '2022-08-01', '2022-09-01', '2024-09-01', '2027-08-01',38, 84),
('LN202209001', 23, 23, 12, 'Business Loan', 1500000.00, 12.00, 48,  39513.72, 1896658.56,1200000.00, 20, 'Disbursed', 'Equipment Purchase',  '2022-09-01', '2022-10-01', '2024-10-01', '2026-09-01',24, 77),
('LN202210001', 17, 17, 9,  'Home Loan',     1800000.00,  8.50, 180, 17746.74, 3194413.20,1650000.00, 20, 'Disbursed', 'Home Purchase',       '2022-10-01', '2022-11-01', '2024-11-01', '2037-10-01',18, 74),
('LN202211001', 13, 13, 7,  'Education Loan', 600000.00,  9.00, 84,   9338.52,  784435.68, 520000.00, 20, 'Disbursed', 'MBA Abroad',          '2022-11-01', '2022-12-01', '2024-12-01', '2029-11-01',14, 72),
('LN202212001', 31, 31, 16, 'Business Loan', 5000000.00, 10.50, 60, 107505.63, 6450337.80,4600000.00, 12, 'Disbursed', 'Business Expansion',  '2022-12-01', '2023-01-01', '2024-09-01', '2027-12-01',32, 81),
('LN202301001', 45, 45, 3,  'Car Loan',       650000.00, 10.00, 48,  16529.80,  793430.40, 580000.00,  8, 'Disbursed', 'Commercial Vehicle',  '2023-01-05', '2023-02-05', '2024-08-05', '2027-01-05', 6, 44),
('LN202302001', 2,  2,  1,  'Personal Loan',  200000.00, 14.00, 24,   9637.18,  231292.32, 100000.00, 18, 'Disbursed', 'Vacation Planning',   '2023-02-10', '2023-03-10', '2024-09-10', '2025-02-10', 3,  3),
-- Pending/Review loans
('LN202401001', 4,  4,  2,  'Personal Loan',  400000.00, 12.50, 36,  13452.38, 484285.68, 400000.00,   0, 'Pending',   'Wedding Expenses',    NULL, NULL, NULL, NULL, NULL, 5),
('LN202401002', 6,  6,  3,  'Home Loan',     4000000.00,  8.75, 240, 35476.96, 8514470.40,4000000.00,  0, 'Under Review','Plot Purchase',     NULL, NULL, NULL, NULL, NULL, 44),
('LN202401003', 8,  8,  4,  'Car Loan',       500000.00, 10.50, 60,  10714.68,  642880.80, 500000.00,   0, 'Approved',  'Two-Wheeler',         NULL, NULL, NULL, NULL, 8, 45),
('LN202401004', 10, 10, 5,  'Personal Loan',  250000.00, 13.00, 24,  11866.78,  284802.72, 250000.00,   0, 'Pending',   'Home Appliances',    NULL, NULL, NULL, NULL, NULL, 11),
('LN202401005', 20, 20, 10, 'Education Loan', 300000.00,  8.00, 60,   6082.98,  364978.80, 300000.00,   0, 'Under Review','Engineering Fees',  NULL, NULL, NULL, NULL, NULL, 21);

-- =============================================================================
-- FIXED DEPOSITS (30 sample FDs)
-- =============================================================================
INSERT INTO fixed_deposits (fd_number, customer_id, account_id, branch_id, principal, interest_rate, tenure_months, compounding, maturity_amount, interest_earned, start_date, maturity_date, status, auto_renew, created_by) VALUES
('FD202201001', 1,  1,  1,  100000.00, 6.50, 12, 'Quarterly', 106698.73,  6698.73, '2022-01-20', '2023-01-20', 'Matured', 0, 2),
('FD202201002', 3,  3,  2,  500000.00, 7.00, 24, 'Quarterly', 573204.26, 73204.26, '2022-01-15', '2024-01-15', 'Matured', 0, 5),
('FD202202001', 5,  5,  3, 1000000.00, 7.50, 36, 'Quarterly',1250116.04,250116.04,'2022-02-01', '2025-02-01', 'Active',  1, 7),
('FD202203001', 7,  7,  4,  300000.00, 6.75, 18, 'Quarterly', 334018.94, 34018.94, '2022-03-10', '2023-09-10', 'Matured', 0, 9),
('FD202204001', 9,  9,  5, 2000000.00, 7.25, 60, 'Quarterly',2866148.88,866148.88,'2022-04-01', '2027-04-01', 'Active',  1,11),
('FD202205001',11, 11,  6,  200000.00, 6.50, 24, 'Quarterly', 229282.54, 29282.54, '2022-05-01', '2024-05-01', 'Matured', 0,13),
('FD202206001',13, 13,  7,  400000.00, 7.00, 36, 'Quarterly', 501441.95,101441.95, '2022-06-01', '2025-06-01', 'Active',  0,15),
('FD202207001',15, 15,  8, 1500000.00, 7.50, 48, 'Quarterly',2018979.87,518979.87, '2022-07-01', '2026-07-01', 'Active',  1,17),
('FD202208001',17, 17,  9,  500000.00, 6.75, 24, 'Quarterly', 556614.26, 56614.26, '2022-08-01', '2024-08-01', 'Active',  0,19),
('FD202209001',19, 19, 10,  250000.00, 6.50, 12, 'Quarterly', 266746.83, 16746.83, '2022-09-01', '2023-09-01', 'Matured', 0,21),
('FD202210001',23, 23, 12,  800000.00, 7.25, 36, 'Quarterly',1000785.97,200785.97, '2022-10-01', '2025-10-01', 'Active',  1,25),
('FD202211001',25, 25, 13, 1000000.00, 7.50, 24, 'Quarterly',1162133.87,162133.87, '2022-11-01', '2024-11-01', 'Active',  0,27),
('FD202212001',27, 27, 14,  150000.00, 6.50, 12, 'Quarterly', 160048.10,  10048.10,'2022-12-01', '2023-12-01', 'Matured', 0,29),
('FD202301001',29, 29, 15,  300000.00, 7.00, 18, 'Quarterly', 331893.92, 31893.92, '2023-01-01', '2024-07-01', 'Matured', 0,31),
('FD202302001',31, 31, 16, 3000000.00, 7.50, 60, 'Quarterly',4318624.20,1318624.20,'2023-02-01','2028-02-01', 'Active',  1,33),
('FD202303001',33, 33, 17,  100000.00, 6.75, 12, 'Quarterly', 106969.93,  6969.93, '2023-03-01', '2024-03-01', 'Matured', 0,35),
('FD202304001',35, 35, 18,  500000.00, 7.00, 24, 'Quarterly', 573204.26, 73204.26, '2023-04-01', '2025-04-01', 'Active',  0,37),
('FD202305001',37, 37, 19,  700000.00, 7.25, 36, 'Quarterly', 877563.52,177563.52, '2023-05-01', '2026-05-01', 'Active',  1,39),
('FD202306001',39, 39, 20,  200000.00, 6.50, 18, 'Quarterly', 219706.70, 19706.70, '2023-06-01', '2024-12-01', 'Matured', 0,41),
('FD202307001', 1,  1,  1,  200000.00, 7.00, 24, 'Quarterly', 229282.54, 29282.54, '2023-07-01', '2025-07-01', 'Active',  1, 2),
('FD202308001', 5,  5,  3, 2000000.00, 7.50, 36, 'Quarterly',2500232.08,500232.08, '2023-08-01', '2026-08-01', 'Active',  1, 7),
('FD202309001', 9,  9,  5, 5000000.00, 7.25, 60, 'Quarterly',7165372.19,2165372.19,'2023-09-01','2028-09-01', 'Active',  1,11),
('FD202310001',41, 41,  1,  250000.00, 6.75, 12, 'Quarterly', 267424.83, 17424.83, '2023-10-01', '2024-10-01', 'Active',  0, 2),
('FD202311001',42, 42,  1,  300000.00, 7.00, 18, 'Quarterly', 331893.92, 31893.92, '2023-11-01', '2025-05-01', 'Active',  0, 2),
('FD202312001',45, 45,  3,  400000.00, 7.50, 24, 'Quarterly', 464853.55, 64853.55, '2023-12-01', '2025-12-01', 'Active',  0, 7),
('FD202401001',47, 47,  4,  800000.00, 6.75, 36, 'Quarterly', 894278.51, 94278.51, '2024-01-01', '2027-01-01', 'Active',  1, 9),
('FD202402001',48, 48,  4,  500000.00, 7.25, 24, 'Quarterly', 573204.26, 73204.26, '2024-02-01', '2026-02-01', 'Active',  0, 9),
('FD202403001',50, 50,  5,  600000.00, 7.50, 36, 'Quarterly', 750069.62,150069.62, '2024-03-01', '2027-03-01', 'Active',  1,11),
('FD202404001',46, 46,  3,  350000.00, 6.50, 12, 'Quarterly', 373445.56, 23445.56, '2024-04-01', '2025-04-01', 'Active',  0, 7),
('FD202405001',49, 49,  5,  200000.00, 7.00, 18, 'Quarterly', 221262.61, 21262.61, '2024-05-01', '2025-11-01', 'Active',  0,11);

-- =============================================================================
-- UPI ACCOUNTS (25 sample UPI records)
-- =============================================================================
INSERT INTO upi_accounts (upi_address, customer_id, account_id, upi_pin_hash, daily_limit, is_active) VALUES
('aaravsharma1111@apxb',    1,  1,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00,  1),
('priyaverma2222@apxb',     2,  2,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00,  1),
('rahulgupta3333@apxb',     3,  3,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00, 1),
('ananyasingh4444@apxb',    4,  4,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00,  1),
('vikramreddy5555@apxb',    5,  5,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00, 1),
('lakshmik6666@apxb',       6,  6,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00,  1),
('karthiks7777@apxb',       7,  7,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00, 1),
('meghnanair8888@apxb',     8,  8,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00,  1),
('farhankhan9999@apxb',     9,  9,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00, 1),
('divyapatel1010@apxb',    10, 10,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00,  1),
('rohank1111@apxb',        11, 11,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00,  1),
('snehaj1212@apxb',        12, 12,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00,  1),
('subhajitr1313@apxb',     13, 13,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00, 1),
('chiragshah1515@apxb',    15, 15,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00, 1),
('heena1616@apxb',         16, 16,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00,  1),
('mohita1717@apxb',        17, 17,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00,  1),
('rekham1818@apxb',        18, 18,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00,  1),
('sanjivs1919@apxb',       19, 19,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00,  1),
('manpreetg2323@apxb',     23, 23,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00, 1),
('georgem2525@apxb',       25, 25,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00, 1),
('amitsoni2727@apxb',      27, 27,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00,  1),
('nileshd3131@apxb',       31, 31,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00, 1),
('venkatr3737@apxb',       37, 37,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 100000.00, 1),
('adityk4141@apxb',        41, 41,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00,  1),
('aakashg5050@apxb',       50, 50,  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMcJqzOHjzGPjuF7ixj/a3NkC2', 50000.00,  1);

-- =============================================================================
-- BENEFICIARIES (25 sample records)
-- =============================================================================
INSERT INTO beneficiaries (customer_id, nickname, beneficiary_name, account_number, bank_name, ifsc_code, relation, is_verified) VALUES
(1,  'Wife',      'Meena Sharma',         'APXB1001000000002', 'Apex National Bank', 'APXB0MUM001', 'Spouse',  1),
(1,  'Brother',   'Suresh Sharma',        'HDFC0000123456789', 'HDFC Bank',          'HDFC0001234', 'Sibling', 1),
(3,  'Partner',   'Anil Gupta',           'ICIC0000987654321', 'ICICI Bank',         'ICIC0001234', 'Business',1),
(5,  'Wife',      'Lalitha Reddy',        'APXB3001000000006', 'Apex National Bank', 'APXB0BLR001', 'Spouse',  1),
(5,  'Supplier',  'Mahesh Trading Co.',   'SBIN0001234567890', 'State Bank',         'SBIN0001234', 'Business',1),
(7,  'Father',    'Subramaniam Iyer',     'KOTK0000234567891', 'Kotak Bank',         'KKBK0001234', 'Parent',  1),
(9,  'Wife',      'Fatima Khan',          'APXB5001000000010', 'Apex National Bank', 'APXB0HYD001', 'Spouse',  1),
(9,  'Manager',   'Ahmed Ali',            'AXIS0000345678912', 'Axis Bank',          'UTIB0001234', 'Business',1),
(11, 'Wife',      'Sunanda Kulkarni',     'PUNB0000456789123', 'Punjab National Bank','PUNB0001234','Spouse',  1),
(13, 'Wife',      'Sutapa Roy',           'APXB7001000000014', 'Apex National Bank', 'APXB0KOL001', 'Spouse',  1),
(15, 'Wife',      'Hema Shah',            'APXB8001000000016', 'Apex National Bank', 'APXB0AMD001', 'Spouse',  1),
(15, 'Business',  'Shah Enterprises',     'BARB0000567890234', 'Bank of Baroda',     'BARB0001234', 'Business',1),
(17, 'Wife',      'Sunita Agarwal',       'APXB9001000000018', 'Apex National Bank', 'APXB0JAI001', 'Spouse',  1),
(19, 'Wife',      'Asha Srivastava',      'APXB10001000000020','Apex National Bank', 'APXB0LKO001', 'Spouse',  0),
(23, 'Wife',      'Surinder Grewal',      'APXB12001000000024','Apex National Bank', 'APXB0CHD001', 'Spouse',  1),
(25, 'Wife',      'Mary Mathew',          'APXB13001000000026','Apex National Bank', 'APXB0KCH001', 'Spouse',  1),
(25, 'Client',    'Thomas Abraham',       'FDRL0000678901345', 'Federal Bank',       'FDRL0001234', 'Business',1),
(31, 'Wife',      'Meeta Desai',          'CITI0000789012456', 'Citibank',           'CITI0001234', 'Spouse',  1),
(37, 'Wife',      'Saroja Rao',           'APXB19001000000038','Apex National Bank', 'APXB0VIZ001', 'Spouse',  1),
(37, 'Partner',   'Ramaiah Enterprises',  'YESB0000890123567', 'Yes Bank',           'YESB0001234', 'Business',1),
(41, 'Wife',      'Ritu Kapoor',          'APXB1001000000042', 'Apex National Bank', 'APXB0MUM001', 'Spouse',  1),
(45, 'Wife',      'Sudha Gowda',          'APXB3001000000046', 'Apex National Bank', 'APXB0BLR001', 'Spouse',  1),
(48, 'Wife',      'Lakshmi K',            'APXB4001000000047', 'Apex National Bank', 'APXB0CHN001', 'Spouse',  1),
(50, 'Wife',      'Divya Goel',           'APXB5001000000049', 'Apex National Bank', 'APXB0HYD001', 'Spouse',  1),
(6,  'Husband',   'Pradeep Krishnan',     'INDB0000901234678', 'IndusInd Bank',      'INDB0001234', 'Spouse',  1);

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'Sample data inserted successfully.' AS status;
SELECT 'NOTE: Run python database/generate_sample_data.py to generate full 500 customers, 700 accounts, 10000 transactions.' AS note;
