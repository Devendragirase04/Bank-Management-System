import sys
import os
import logging
from database import DatabaseInitializer

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)-8s | %(message)s"
)

def setup():
    print("="*60)
    print("Bank Management System - Database Initialization")
    print("="*60)
    
    # Check if database directory exists
    sql_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "database")
    if not os.path.exists(sql_dir):
        print(f"Error: Could not find 'database' directory at {sql_dir}")
        sys.exit(1)
        
    print(f"Reading SQL scripts from: {sql_dir}")
    print("This will create the BankDB database, tables, views, procedures, and sample data.")
    print("Warning: If 'BankDB' already exists, it will be overwritten!")
    print("")
    
    confirm = input("Do you want to proceed? (y/n): ")
    if confirm.lower() != 'y':
        print("Initialization cancelled.")
        sys.exit(0)
        
    initializer = DatabaseInitializer(sql_dir)
    success = initializer.initialize_database()
    
    if success:
        print("\n" + "="*60)
        print("SUCCESS: Database initialized and seeded with sample data!")
        print("="*60)
        print("\nYou can now run the application using: python app.py")
        print("\nDefault Logins:")
        print("  Super Admin: username='superadmin', password='Admin@1234'")
        print("  Branch Mgr:  username='emp.rajesh', password='Password@123'")
        print("  Customer:    username='aarav.sharma', password='Password@123'")
    else:
        print("\n" + "="*60)
        print("ERROR: Database initialization failed. Check the logs.")
        print("="*60)

if __name__ == "__main__":
    setup()
