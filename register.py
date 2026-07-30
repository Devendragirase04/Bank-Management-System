import tkinter as tk
import ttkbootstrap as ttk
from ttkbootstrap.constants import *
from tkinter import messagebox
from config import FONT_HEADING_2, FONT_BODY
from branch import BranchService
from customer import CustomerService
from employee import EmployeeService

class BaseRegisterView(ttk.Frame):
    def __init__(self, master, on_register_success, on_back):
        super().__init__(master)
        self.master = master
        self.on_register_success = on_register_success
        self.on_back = on_back
        self.branch_service = BranchService()
        self.branches = self.branch_service.get_all_branches()
        self.form_vars = {}
        
        self.pack(fill=BOTH, expand=YES)
        
    def create_form(self, title, fields):
        # Header
        header_frame = ttk.Frame(self)
        header_frame.pack(fill=X, pady=(0, 20))
        
        ttk.Button(header_frame, text="← Back to Login", style=LINK, command=self.on_back).pack(side=LEFT)
        ttk.Label(header_frame, text=title, font=FONT_HEADING_2).pack(side=LEFT, padx=20)

        # Form Container (using a Canvas to allow scrolling if needed, or just pack)
        # We will use a standard frame for simplicity, but it might get tall. 
        # A scrolled frame would be better if we had one, but let's pack tightly.
        
        form_frame = ttk.Frame(self)
        form_frame.pack(fill=BOTH, expand=YES)

        # Two columns
        col1 = ttk.Frame(form_frame)
        col1.pack(side=LEFT, fill=BOTH, expand=YES, padx=10)
        col2 = ttk.Frame(form_frame)
        col2.pack(side=LEFT, fill=BOTH, expand=YES, padx=10)

        for i, field in enumerate(fields):
            parent = col1 if i < len(fields) / 2 else col2
            
            label_text = field['label']
            field_name = field['name']
            field_type = field.get('type', 'text')
            
            row = ttk.Frame(parent)
            row.pack(fill=X, pady=5)
            
            ttk.Label(row, text=label_text, width=15).pack(side=LEFT)
            
            if field_type == 'combo':
                var = tk.StringVar()
                cb = ttk.Combobox(row, textvariable=var, values=field['values'], state="readonly")
                cb.pack(side=LEFT, fill=X, expand=YES)
                self.form_vars[field_name] = var
            elif field_type == 'password':
                var = tk.StringVar()
                ttk.Entry(row, textvariable=var, show="*").pack(side=LEFT, fill=X, expand=YES)
                self.form_vars[field_name] = var
            else:
                var = tk.StringVar()
                ttk.Entry(row, textvariable=var).pack(side=LEFT, fill=X, expand=YES)
                self.form_vars[field_name] = var

        # Submit button
        btn_frame = ttk.Frame(self)
        btn_frame.pack(fill=X, pady=20)
        ttk.Button(btn_frame, text="Register", style=SUCCESS, command=self.submit).pack(side=RIGHT)

    def submit(self):
        pass

    def get_form_data(self):
        data = {}
        for k, v in self.form_vars.items():
            val = v.get().strip()
            if not val:
                messagebox.showerror("Error", f"Field '{k}' is required.")
                return None
            data[k] = val
        return data

class CustomerRegisterView(BaseRegisterView):
    def __init__(self, master, on_register_success, on_back):
        super().__init__(master, on_register_success, on_back)
        self.customer_service = CustomerService()
        self.create_ui()

    def create_ui(self):
        branch_names = [f"{b['branch_name']} ({b['ifsc_code']})" for b in self.branches]
        
        fields = [
            {'label': 'Full Name', 'name': 'full_name'},
            {'label': 'Date of Birth (YYYY-MM-DD)', 'name': 'date_of_birth'},
            {'label': 'Gender', 'name': 'gender', 'type': 'combo', 'values': ['Male', 'Female', 'Other']},
            {'label': 'Email', 'name': 'email'},
            {'label': 'Phone', 'name': 'phone'},
            {'label': 'PAN Number', 'name': 'pan_number'},
            {'label': 'Aadhar Number', 'name': 'aadhar_number'},
            {'label': 'Address', 'name': 'address_line1'},
            {'label': 'City', 'name': 'city'},
            {'label': 'State', 'name': 'state'},
            {'label': 'Pincode', 'name': 'pincode'},
            {'label': 'Branch', 'name': 'branch_id', 'type': 'combo', 'values': branch_names},
            {'label': 'Username', 'name': 'username'},
            {'label': 'Password', 'name': 'password_hash', 'type': 'password'},
        ]
        self.create_form("Customer Registration", fields)

    def submit(self):
        data = self.get_form_data()
        if not data:
            return
            
        # Get branch_id from the combo string
        branch_str = data['branch_id']
        branch = next((b for b in self.branches if f"{b['branch_name']} ({b['ifsc_code']})" == branch_str), None)
        if not branch:
            messagebox.showerror("Error", "Invalid branch selected.")
            return
            
        data['branch_id'] = branch['branch_id']
        
        if self.customer_service.register_customer(data):
            messagebox.showinfo("Success", "Registration successful. You can now login.")
            self.on_register_success()
        else:
            messagebox.showerror("Error", "Registration failed. Username might already exist.")

class EmployeeRegisterView(BaseRegisterView):
    def __init__(self, master, on_register_success, on_back):
        super().__init__(master, on_register_success, on_back)
        self.employee_service = EmployeeService()
        self.create_ui()

    def create_ui(self):
        branch_names = [f"{b['branch_name']} ({b['ifsc_code']})" for b in self.branches]
        
        # Hardcoding roles for now, ideally fetch from DB.
        # ID 2: Branch Manager, 3: Cashier, 4: Loan Officer
        roles = ["Branch Manager (ID: 2)", "Cashier (ID: 3)", "Loan Officer (ID: 4)"]
        
        fields = [
            {'label': 'Full Name', 'name': 'full_name'},
            {'label': 'Date of Birth (YYYY-MM-DD)', 'name': 'date_of_birth'},
            {'label': 'Gender', 'name': 'gender', 'type': 'combo', 'values': ['Male', 'Female', 'Other']},
            {'label': 'Email', 'name': 'email'},
            {'label': 'Phone', 'name': 'phone'},
            {'label': 'PAN Number', 'name': 'pan_number'},
            {'label': 'Aadhar Number', 'name': 'aadhar_number'},
            {'label': 'Address', 'name': 'address_line1'},
            {'label': 'City', 'name': 'city'},
            {'label': 'State', 'name': 'state'},
            {'label': 'Pincode', 'name': 'pincode'},
            {'label': 'Branch', 'name': 'branch_id', 'type': 'combo', 'values': branch_names},
            {'label': 'Role', 'name': 'role_id', 'type': 'combo', 'values': roles},
            {'label': 'Username', 'name': 'username'},
            {'label': 'Password', 'name': 'password_hash', 'type': 'password'},
        ]
        self.create_form("Employee Registration", fields)

    def submit(self):
        data = self.get_form_data()
        if not data:
            return
            
        # Get branch_id
        branch_str = data['branch_id']
        branch = next((b for b in self.branches if f"{b['branch_name']} ({b['ifsc_code']})" == branch_str), None)
        if not branch:
            messagebox.showerror("Error", "Invalid branch selected.")
            return
        data['branch_id'] = branch['branch_id']
        
        # Get role_id
        role_str = data['role_id']
        if "2" in role_str: data['role_id'] = 2
        elif "3" in role_str: data['role_id'] = 3
        elif "4" in role_str: data['role_id'] = 4
        
        if self.employee_service.register_employee(data):
            messagebox.showinfo("Success", "Registration successful. You can now login.")
            self.on_register_success()
        else:
            messagebox.showerror("Error", "Registration failed. Username might already exist.")
