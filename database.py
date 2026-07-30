# =============================================================================
# Bank Management System - Database Layer
# =============================================================================
# Author: Bank Management System Team
# Version: 1.0.0
# Description: Database connection manager, query executor, transaction manager,
#              and repository base class following the Repository Pattern.
# =============================================================================

import logging
import threading
from typing import Any, Dict, List, Optional, Tuple, Union
from contextlib import contextmanager
from datetime import datetime

import mysql.connector
from mysql.connector import Error, pooling
from mysql.connector.connection import MySQLConnection

from db_config import DB_CONFIG, POOL_CONFIG

logger = logging.getLogger(__name__)


# =============================================================================
# CUSTOM EXCEPTIONS
# =============================================================================

class DatabaseError(Exception):
    """Base exception for database-related errors."""
    pass


class ConnectionError(DatabaseError):
    """Raised when database connection fails."""
    pass


class QueryError(DatabaseError):
    """Raised when a SQL query fails."""
    pass


class TransactionError(DatabaseError):
    """Raised when a transaction fails."""
    pass


class RecordNotFoundError(DatabaseError):
    """Raised when an expected record is not found."""
    pass


class DuplicateRecordError(DatabaseError):
    """Raised when a unique constraint is violated."""
    pass


class InsufficientFundsError(DatabaseError):
    """Raised when account balance is insufficient."""
    pass


class AccountFrozenError(DatabaseError):
    """Raised when operation is attempted on a frozen/suspended account."""
    pass


# =============================================================================
# CONNECTION POOL MANAGER
# =============================================================================

class DatabaseConnectionPool:
    """
    Thread-safe singleton connection pool manager.
    Uses MySQL Connector's built-in pooling with additional health checks.
    """
    _instance: Optional["DatabaseConnectionPool"] = None
    _lock = threading.Lock()
    _pool: Optional[pooling.MySQLConnectionPool] = None

    def __new__(cls) -> "DatabaseConnectionPool":
        if cls._instance is None:
            with cls._lock:
                if cls._instance is None:
                    cls._instance = super().__new__(cls)
        return cls._instance

    def initialize(self) -> None:
        """Initialize the connection pool with configured parameters."""
        if self._pool is not None:
            logger.debug("Connection pool already initialized.")
            return

        try:
            pool_config = {**POOL_CONFIG, **DB_CONFIG}
            self._pool = pooling.MySQLConnectionPool(**pool_config)
            logger.info(
                f"Database connection pool initialized: "
                f"pool_name={POOL_CONFIG['pool_name']}, "
                f"pool_size={POOL_CONFIG['pool_size']}, "
                f"host={DB_CONFIG['host']}, "
                f"database={DB_CONFIG['database']}"
            )
        except Error as e:
            logger.critical(f"Failed to initialize connection pool: {e}")
            raise ConnectionError(f"Cannot connect to database: {e}") from e

    def get_connection(self) -> MySQLConnection:
        """
        Get a connection from the pool.

        Returns:
            MySQLConnection: Active database connection.

        Raises:
            ConnectionError: If connection cannot be obtained.
        """
        if self._pool is None:
            self.initialize()

        try:
            connection = self._pool.get_connection()
            connection.ping(reconnect=True, attempts=3, delay=2)
            return connection
        except Error as e:
            logger.error(f"Failed to get connection from pool: {e}")
            raise ConnectionError(f"Database connection unavailable: {e}") from e

    def close_all(self) -> None:
        """Close all connections in the pool."""
        if self._pool:
            self._pool = None
            logger.info("Connection pool closed.")


# Global pool instance
_pool_manager = DatabaseConnectionPool()


# =============================================================================
# CONTEXT MANAGER FOR CONNECTIONS
# =============================================================================

@contextmanager
def get_db_connection():
    """
    Context manager that provides a database connection from the pool.
    Automatically returns the connection to the pool on exit.

    Usage:
        with get_db_connection() as conn:
            cursor = conn.cursor(dictionary=True)
            cursor.execute(query)
    """
    connection = None
    try:
        connection = _pool_manager.get_connection()
        yield connection
    except Error as e:
        logger.error(f"Database error in connection context: {e}")
        raise QueryError(f"Database operation failed: {e}") from e
    finally:
        if connection and connection.is_connected():
            connection.close()


@contextmanager
def get_transaction():
    """
    Context manager that provides a transactional database connection.
    Automatically commits on success and rolls back on any exception.

    Usage:
        with get_transaction() as conn:
            cursor = conn.cursor(dictionary=True)
            cursor.execute(update_query)
            # Commits automatically on exit
    """
    connection = None
    try:
        connection = _pool_manager.get_connection()
        connection.start_transaction()
        yield connection
        connection.commit()
        logger.debug("Transaction committed successfully.")
    except Error as e:
        if connection:
            connection.rollback()
            logger.warning(f"Transaction rolled back due to error: {e}")
        raise TransactionError(f"Transaction failed: {e}") from e
    except Exception as e:
        if connection:
            connection.rollback()
            logger.warning(f"Transaction rolled back due to application error: {e}")
        raise
    finally:
        if connection and connection.is_connected():
            connection.close()


# =============================================================================
# QUERY EXECUTOR
# =============================================================================

class QueryExecutor:
    """
    Centralized SQL query executor with:
    - Parameterized queries (SQL injection prevention)
    - Comprehensive logging
    - Error mapping to custom exceptions
    - Dictionary-cursor support
    """

    @staticmethod
    def execute_query(
        query: str,
        params: Optional[Tuple] = None,
        fetch_one: bool = False,
        fetch_all: bool = False,
        dictionary: bool = True,
        connection: Optional[MySQLConnection] = None
    ) -> Union[Dict, List[Dict], int, None]:
        """
        Execute a parameterized SQL query.

        Args:
            query: SQL query string with %s placeholders.
            params: Tuple of parameter values (prevents SQL injection).
            fetch_one: If True, returns a single row dict.
            fetch_all: If True, returns list of row dicts.
            dictionary: If True, returns results as dictionaries.
            connection: Optional existing connection (for transactions).

        Returns:
            Single row dict, list of row dicts, lastrowid, or None.

        Raises:
            QueryError: On SQL execution errors.
            DuplicateRecordError: On unique constraint violation.
            RecordNotFoundError: When fetch_one returns None unexpectedly.
        """
        use_external_conn = connection is not None
        conn = connection

        try:
            if not use_external_conn:
                conn = _pool_manager.get_connection()

            cursor = conn.cursor(dictionary=dictionary, buffered=True)

            # Log query (mask sensitive data in production)
            logger.debug(
                f"Executing query: {query[:200]}... "
                f"| params: {str(params)[:100] if params else 'None'}"
            )

            cursor.execute(query, params or ())

            if fetch_one:
                result = cursor.fetchone()
                cursor.close()
                return result

            if fetch_all:
                result = cursor.fetchall()
                cursor.close()
                return result if result else []

            # For INSERT/UPDATE/DELETE - commit if no external transaction
            if not use_external_conn:
                conn.commit()

            last_id = cursor.lastrowid
            rows_affected = cursor.rowcount
            cursor.close()

            logger.debug(f"Query executed: lastrowid={last_id}, rows_affected={rows_affected}")
            return last_id if last_id else rows_affected

        except Error as e:
            if not use_external_conn and conn:
                conn.rollback()

            error_code = e.errno if hasattr(e, 'errno') else None

            if error_code == 1062:  # Duplicate entry
                raise DuplicateRecordError(
                    f"Record already exists: {e.msg if hasattr(e, 'msg') else str(e)}"
                ) from e
            elif error_code == 1452:  # Foreign key constraint
                raise QueryError(
                    f"Foreign key constraint violation: {e.msg if hasattr(e, 'msg') else str(e)}"
                ) from e
            elif error_code in (1054, 1064):  # Unknown column / SQL syntax
                raise QueryError(f"SQL error: {e}") from e
            else:
                logger.error(f"Database query error [{error_code}]: {e} | Query: {query[:200]}")
                raise QueryError(f"Query execution failed: {e}") from e

        finally:
            if not use_external_conn and conn and conn.is_connected():
                conn.close()

    @staticmethod
    def execute_many(
        query: str,
        params_list: List[Tuple],
        connection: Optional[MySQLConnection] = None
    ) -> int:
        """
        Execute a parameterized query for multiple rows (bulk operations).

        Args:
            query: SQL query string.
            params_list: List of parameter tuples.
            connection: Optional existing connection.

        Returns:
            Number of rows affected.
        """
        use_external_conn = connection is not None
        conn = connection

        try:
            if not use_external_conn:
                conn = _pool_manager.get_connection()

            cursor = conn.cursor()
            cursor.executemany(query, params_list)

            if not use_external_conn:
                conn.commit()

            rows = cursor.rowcount
            cursor.close()
            logger.debug(f"Bulk query executed: {rows} rows affected.")
            return rows

        except Error as e:
            if not use_external_conn and conn:
                conn.rollback()
            logger.error(f"Bulk query error: {e}")
            raise QueryError(f"Bulk operation failed: {e}") from e

        finally:
            if not use_external_conn and conn and conn.is_connected():
                conn.close()

    @staticmethod
    def call_procedure(
        procedure_name: str,
        args: Optional[Tuple] = None,
        connection: Optional[MySQLConnection] = None
    ) -> List[Dict]:
        """
        Call a stored procedure and return all result sets.

        Args:
            procedure_name: Name of the stored procedure.
            args: Tuple of input arguments.
            connection: Optional existing connection.

        Returns:
            List of result dictionaries.
        """
        use_external_conn = connection is not None
        conn = connection
        results = []

        try:
            if not use_external_conn:
                conn = _pool_manager.get_connection()

            cursor = conn.cursor(dictionary=True)
            cursor.callproc(procedure_name, args or ())

            for result_set in cursor.stored_results():
                results.extend(result_set.fetchall())

            cursor.close()

            if not use_external_conn:
                conn.commit()

            logger.debug(
                f"Stored procedure '{procedure_name}' called, "
                f"returned {len(results)} rows."
            )
            return results

        except Error as e:
            if not use_external_conn and conn:
                conn.rollback()
            logger.error(f"Stored procedure '{procedure_name}' error: {e}")
            raise QueryError(f"Stored procedure failed: {e}") from e

        finally:
            if not use_external_conn and conn and conn.is_connected():
                conn.close()


# =============================================================================
# BASE REPOSITORY
# =============================================================================

class BaseRepository:
    """
    Abstract base class for all repository classes.
    Provides common CRUD operations and query helpers.
    All SQL uses parameterized queries to prevent injection.
    """

    def __init__(self, table_name: str):
        self.table_name = table_name
        self.executor = QueryExecutor()
        self.logger = logging.getLogger(self.__class__.__name__)

    def find_by_id(self, record_id: int, id_column: str = "id") -> Optional[Dict]:
        """Find a single record by primary key."""
        query = f"SELECT * FROM `{self.table_name}` WHERE `{id_column}` = %s"
        result = self.executor.execute_query(query, (record_id,), fetch_one=True)
        return result

    def find_all(
        self,
        where_clause: str = "",
        params: Optional[Tuple] = None,
        order_by: str = "",
        limit: Optional[int] = None,
        offset: Optional[int] = None
    ) -> List[Dict]:
        """
        Generic find-all with optional WHERE, ORDER BY, LIMIT, OFFSET.
        All filtering is parameterized.
        """
        query = f"SELECT * FROM `{self.table_name}`"

        if where_clause:
            query += f" WHERE {where_clause}"
        if order_by:
            query += f" ORDER BY {order_by}"
        if limit is not None:
            query += f" LIMIT {int(limit)}"
            if offset is not None:
                query += f" OFFSET {int(offset)}"

        return self.executor.execute_query(
            query, params, fetch_all=True
        )

    def count(
        self,
        where_clause: str = "",
        params: Optional[Tuple] = None
    ) -> int:
        """Count records with optional filtering."""
        query = f"SELECT COUNT(*) AS cnt FROM `{self.table_name}`"
        if where_clause:
            query += f" WHERE {where_clause}"

        result = self.executor.execute_query(query, params, fetch_one=True)
        return result["cnt"] if result else 0

    def insert(self, data: Dict[str, Any]) -> int:
        """
        Insert a record and return the new primary key.
        All values are parameterized.
        """
        columns = ", ".join(f"`{k}`" for k in data.keys())
        placeholders = ", ".join("%s" for _ in data)
        query = f"INSERT INTO `{self.table_name}` ({columns}) VALUES ({placeholders})"
        last_id = self.executor.execute_query(query, tuple(data.values()))
        self.logger.debug(f"Inserted into {self.table_name}: id={last_id}")
        return last_id

    def update(
        self,
        data: Dict[str, Any],
        where_clause: str,
        where_params: Tuple
    ) -> int:
        """
        Update records matching the where clause.
        All values and conditions are parameterized.
        """
        set_clause = ", ".join(f"`{k}` = %s" for k in data.keys())
        query = f"UPDATE `{self.table_name}` SET {set_clause} WHERE {where_clause}"
        rows = self.executor.execute_query(
            query, tuple(data.values()) + where_params
        )
        self.logger.debug(f"Updated {rows} rows in {self.table_name}")
        return rows

    def delete(self, where_clause: str, params: Tuple) -> int:
        """Delete records matching the where clause."""
        query = f"DELETE FROM `{self.table_name}` WHERE {where_clause}"
        rows = self.executor.execute_query(query, params)
        self.logger.debug(f"Deleted {rows} rows from {self.table_name}")
        return rows

    def exists(self, where_clause: str, params: Tuple) -> bool:
        """Check if a record exists."""
        return self.count(where_clause, params) > 0

    def search(
        self,
        search_columns: List[str],
        search_term: str,
        extra_where: str = "",
        extra_params: Optional[Tuple] = None,
        order_by: str = "",
        limit: int = 50
    ) -> List[Dict]:
        """
        Full-text style search across multiple columns.
        Uses LIKE with parameterized pattern (not raw string concat).
        """
        like_clauses = " OR ".join(
            f"`{col}` LIKE %s" for col in search_columns
        )
        params = tuple(f"%{search_term}%" for _ in search_columns)

        where = f"({like_clauses})"
        if extra_where:
            where += f" AND ({extra_where})"
            params = params + (extra_params or ())

        query = f"SELECT * FROM `{self.table_name}` WHERE {where}"
        if order_by:
            query += f" ORDER BY {order_by}"
        query += f" LIMIT {int(limit)}"

        return self.executor.execute_query(query, params, fetch_all=True)


# =============================================================================
# DATABASE INITIALIZER
# =============================================================================

class DatabaseInitializer:
    """
    Handles database schema creation and initial setup.
    Reads and executes SQL scripts from the database/ directory.
    """

    def __init__(self, sql_dir: str):
        self.sql_dir = sql_dir
        self.logger = logging.getLogger(self.__class__.__name__)

    def run_sql_file(self, filename: str, connection: MySQLConnection) -> None:
        """
        Read and execute a SQL script file.
        Handles multi-statement scripts with DELIMITER changes.
        """
        import os
        filepath = os.path.join(self.sql_dir, filename)

        if not os.path.exists(filepath):
            self.logger.warning(f"SQL file not found: {filepath}")
            return

        with open(filepath, "r", encoding="utf-8") as f:
            sql_content = f.read()

        cursor = connection.cursor()

        try:
            statements = self._split_sql_statements(sql_content)
            for stmt in statements:
                stmt = stmt.strip()
                if stmt:
                    cursor.execute(stmt)
                    # Consume any result sets to avoid "Unread result found" errors
                    if cursor.with_rows:
                        cursor.fetchall()

            connection.commit()
            self.logger.info(f"Successfully executed SQL file: {filename}")

        except Error as e:
            connection.rollback()
            self.logger.error(f"Error executing {filename}: {e}")
            raise QueryError(f"SQL file execution failed ({filename}): {e}") from e
        finally:
            cursor.close()

    def _split_sql_statements(self, sql_content: str) -> list:
        """
        Split a SQL script into individual statements.
        Handles DELIMITER changes used in stored procedures and triggers.
        Strips comments and blank lines.
        """
        import re
        statements = []
        delimiter = ";"
        current = []

        for line in sql_content.splitlines():
            stripped = line.strip()

            # Skip pure comment lines and empty lines
            if not stripped or stripped.startswith("--") or stripped.startswith("#"):
                continue

            # Handle DELIMITER changes (e.g. DELIMITER //)
            delim_match = re.match(r"^DELIMITER\s+(\S+)", stripped, re.IGNORECASE)
            if delim_match:
                # Flush anything accumulated before this
                accumulated = "\n".join(current).strip()
                if accumulated:
                    statements.append(accumulated)
                current = []
                delimiter = delim_match.group(1)
                continue

            current.append(line)

            # Check if this line ends with the current delimiter
            if stripped.endswith(delimiter):
                accumulated = "\n".join(current).strip()
                # Remove trailing delimiter
                if accumulated.endswith(delimiter):
                    accumulated = accumulated[: -len(delimiter)].strip()
                if accumulated:
                    statements.append(accumulated)
                current = []

        # Flush any remaining content
        remaining = "\n".join(current).strip()
        if remaining:
            statements.append(remaining)

        return statements

    def initialize_database(self) -> bool:
        """
        Run all database setup scripts in order.
        Returns True on success, False on failure.
        """
        script_order = [
            "create_database.sql",
            "create_tables.sql",
            "constraints.sql",
            "indexes.sql",
            "views.sql",
            "functions.sql",
            "triggers.sql",
            "stored_procedures.sql",
            "sample_data.sql",
        ]

        try:
            # Use raw connection without database for initial setup
            init_config = {k: v for k, v in DB_CONFIG.items()
                           if k not in ("database", "raise_on_warnings")}
            connection = mysql.connector.connect(use_pure=True, **init_config)

            for script in script_order:
                self.logger.info(f"Running: {script}")
                self.run_sql_file(script, connection)

            connection.close()
            self.logger.info("Database initialization complete.")
            return True

        except Exception as e:
            self.logger.critical(f"Database initialization failed: {e}")
            return False


# =============================================================================
# AUDIT LOG HELPER
# =============================================================================

class AuditLogger:
    """
    Records all significant user actions in the audit_logs table.
    Called by service layers to maintain a complete audit trail.
    """

    @staticmethod
    def log(
        user_id: int,
        user_type: str,
        action: str,
        details: str = "",
        ip_address: str = "127.0.0.1",
        status: str = "Success"
    ) -> None:
        """
        Insert an audit log entry.

        Args:
            user_id: ID of the actor (admin, employee, or customer ID).
            user_type: 'Admin', 'Employee', or 'Customer'.
            action: Short action label, e.g., 'TRANSFER', 'LOGIN'.
            details: Additional context / description.
            ip_address: Client IP address.
            status: 'Success' or 'Failed'.
        """
        query = """
            INSERT INTO audit_logs
                (user_id, user_type, action, details, ip_address, status, created_at)
            VALUES (%s, %s, %s, %s, %s, %s, NOW())
        """
        try:
            QueryExecutor.execute_query(
                query,
                (user_id, user_type, action, details[:1000], ip_address, status)
            )
        except Exception as e:
            # Audit logging should never crash the main application
            logging.getLogger(__name__).error(f"Audit log failed: {e}")


# =============================================================================
# HEALTH CHECK
# =============================================================================

def check_database_connection() -> Tuple[bool, str]:
    """
    Verify database connectivity.

    Returns:
        Tuple of (success: bool, message: str)
    """
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT VERSION()")
            version = cursor.fetchone()
            cursor.close()
            return True, f"Connected | MySQL {version[0]}"
    except Exception as e:
        return False, f"Connection failed: {e}"


# =============================================================================
# MODULE INITIALIZATION
# =============================================================================

def initialize_pool() -> None:
    """Initialize the connection pool. Call once at application startup."""
    _pool_manager.initialize()
    logger.info("Database layer initialized.")
