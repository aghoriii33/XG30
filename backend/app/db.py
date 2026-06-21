import sqlite3
import os

DB_PATH = os.environ.get("DATABASE_PATH", os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "app.db"))

def get_db_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db_connection()
    cursor = conn.cursor()
    # Create user_keys table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS user_keys (
            user_id TEXT PRIMARY KEY,
            openai_key TEXT,
            gemini_key TEXT
        )
    """)
    # Create chat_history table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS chat_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            session_id TEXT,
            role TEXT,
            content TEXT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    conn.close()

def save_user_keys(user_id: str, openai_key: str, gemini_key: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO user_keys (user_id, openai_key, gemini_key)
        VALUES (?, ?, ?)
        ON CONFLICT(user_id) DO UPDATE SET
            openai_key=excluded.openai_key,
            gemini_key=excluded.gemini_key
    """, (user_id, openai_key, gemini_key))
    conn.commit()
    conn.close()

def get_user_keys(user_id: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT openai_key, gemini_key FROM user_keys WHERE user_id = ?", (user_id,))
    row = cursor.fetchone()
    conn.close()
    if row:
        return dict(row)
    return {"openai_key": None, "gemini_key": None}

def save_chat_message(user_id: str, session_id: str, role: str, content: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO chat_history (user_id, session_id, role, content)
        VALUES (?, ?, ?, ?)
    """, (user_id, session_id, role, content))
    conn.commit()
    conn.close()

def get_chat_history(user_id: str, session_id: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT role, content, timestamp FROM chat_history 
        WHERE user_id = ? AND session_id = ? 
        ORDER BY timestamp ASC
    """, (user_id, session_id))
    rows = cursor.fetchall()
    conn.close()
    return [dict(row) for row in rows]
