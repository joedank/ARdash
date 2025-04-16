#!/usr/bin/env python3
"""
Migration script to transfer data from SQLite to PostgreSQL.
This script extracts data from a SQLite database and imports it into PostgreSQL.
"""

import sqlite3
import psycopg2
import uuid
import os
from datetime import datetime

# Database connection parameters
SQLITE_DB_PATH = '/Volumes/4TB/Users/josephmcmyne/myProjects/management/database.sqlite'
PG_HOST = 'localhost'
PG_PORT = '5432'
PG_DB = 'management_db'
PG_USER = 'postgres'
PG_PASSWORD = 'postgres'  # Change this if your password is different

def connect_to_sqlite():
    """Connect to SQLite database"""
    return sqlite3.connect(SQLITE_DB_PATH)

def connect_to_postgres():
    """Connect to PostgreSQL database"""
    return psycopg2.connect(
        host=PG_HOST,
        port=PG_PORT,
        dbname=PG_DB,
        user=PG_USER,
        password=PG_PASSWORD
    )

def get_sqlite_data(conn, table_name):
    """Get all data from a SQLite table"""
    cursor = conn.cursor()
    cursor.execute(f"SELECT * FROM {table_name}")
    rows = cursor.fetchall()

    # Get column names
    cursor.execute(f"PRAGMA table_info({table_name})")
    columns = [column[1] for column in cursor.fetchall()]

    return rows, columns

def migrate_communities(sqlite_conn, pg_conn):
    """Migrate communities data from SQLite to PostgreSQL"""
    print("Migrating communities...")

    # Get data from SQLite
    rows, _ = get_sqlite_data(sqlite_conn, 'communities')

    # Prepare PostgreSQL cursor
    pg_cursor = pg_conn.cursor()

    # Get current timestamp for created_at and updated_at fields
    now = datetime.now()

    # Check if communities table exists in PostgreSQL
    pg_cursor.execute("""
    SELECT EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'communities'
    );
    """)
    table_exists = pg_cursor.fetchone()[0]

    if not table_exists:
        # Create communities table if it doesn't exist
        pg_cursor.execute("""
        CREATE TABLE communities (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            address VARCHAR(255) NOT NULL,
            city VARCHAR(255),
            state VARCHAR(20) DEFAULT 'Inactive',
            phone VARCHAR(20) NOT NULL,
            spaces INTEGER,
            ad_specialist_name VARCHAR(255),
            ad_specialist_email VARCHAR(255),
            ad_specialist_phone VARCHAR(20),
            selected_ad_type_id INTEGER,
            newsletter_link VARCHAR(255),
            general_notes TEXT,
            active BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(selected_ad_type_id) REFERENCES ad_types(id)
        );
        """)
        pg_conn.commit()

    # Insert data into PostgreSQL
    for row in rows:
        # Map SQLite columns to PostgreSQL columns
        # Note: SQLite uses "ad-specialist-name" but PostgreSQL uses "ad_specialist_name"
        # Set active status based on state
        active = True if row[9] == 'Active' else False

        pg_cursor.execute("""
        INSERT INTO communities (
            id, name, address, city, state, phone, spaces,
            ad_specialist_name, ad_specialist_email, ad_specialist_phone,
            selected_ad_type_id, newsletter_link, general_notes, active,
            created_at, updated_at
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            address = EXCLUDED.address,
            city = EXCLUDED.city,
            state = EXCLUDED.state,
            phone = EXCLUDED.phone,
            spaces = EXCLUDED.spaces,
            ad_specialist_name = EXCLUDED.ad_specialist_name,
            ad_specialist_email = EXCLUDED.ad_specialist_email,
            ad_specialist_phone = EXCLUDED.ad_specialist_phone,
            selected_ad_type_id = EXCLUDED.selected_ad_type_id,
            newsletter_link = EXCLUDED.newsletter_link,
            general_notes = EXCLUDED.general_notes,
            active = EXCLUDED.active,
            updated_at = EXCLUDED.updated_at
        """, (
            row[0],  # id
            row[1],  # name
            row[2],  # address
            row[3],  # city
            row[9],  # state
            row[4],  # phone
            row[5],  # spaces
            row[6],  # ad_specialist_name (was "ad-specialist-name" in SQLite)
            row[7],  # ad_specialist_email (was "ad-specialist-email" in SQLite)
            row[8],  # ad_specialist_phone (was "ad-specialist-phone" in SQLite)
            row[13], # selected_ad_type_id
            row[11], # newsletter_link
            row[12], # general_notes
            active,  # active status
            now,     # created_at
            now      # updated_at
        ))

    # Reset the sequence to the max id + 1
    pg_cursor.execute("SELECT setval('communities_id_seq', (SELECT MAX(id) FROM communities));")

    pg_conn.commit()
    print(f"Migrated {len(rows)} communities")

def migrate_ad_types(sqlite_conn, pg_conn):
    """Migrate ad_types data from SQLite to PostgreSQL"""
    print("Migrating ad_types...")

    # Get data from SQLite
    rows, _ = get_sqlite_data(sqlite_conn, 'ad_types')

    # Prepare PostgreSQL cursor
    pg_cursor = pg_conn.cursor()

    # Get current timestamp for created_at and updated_at fields
    now = datetime.now()

    # Check if ad_types table exists in PostgreSQL
    pg_cursor.execute("""
    SELECT EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'ad_types'
    );
    """)
    table_exists = pg_cursor.fetchone()[0]

    if not table_exists:
        # Create ad_types table if it doesn't exist
        pg_cursor.execute("""
        CREATE TABLE ad_types (
            id SERIAL PRIMARY KEY,
            community_id INTEGER NOT NULL,
            name VARCHAR(255) NOT NULL,
            width FLOAT,
            height FLOAT,
            cost FLOAT,
            start_date DATE,
            end_date DATE,
            deadline_date DATE,
            term_months INTEGER,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(community_id) REFERENCES communities(id)
        );
        """)
        pg_conn.commit()

    # Insert data into PostgreSQL
    for row in rows:
        pg_cursor.execute("""
        INSERT INTO ad_types (
            id, community_id, name, width, height, cost,
            start_date, end_date, deadline_date, term_months,
            created_at, updated_at
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (id) DO UPDATE SET
            community_id = EXCLUDED.community_id,
            name = EXCLUDED.name,
            width = EXCLUDED.width,
            height = EXCLUDED.height,
            cost = EXCLUDED.cost,
            start_date = EXCLUDED.start_date,
            end_date = EXCLUDED.end_date,
            deadline_date = EXCLUDED.deadline_date,
            term_months = EXCLUDED.term_months,
            updated_at = EXCLUDED.updated_at
        """, (
            row[0],  # id
            row[1],  # community_id
            row[2],  # name
            row[3],  # width
            row[4],  # height
            row[5],  # cost
            row[6],  # start_date
            row[7],  # end_date
            row[8],  # deadline_date
            row[9],  # term_months
            now,     # created_at
            now      # updated_at
        ))

    # Reset the sequence to the max id + 1
    pg_cursor.execute("SELECT setval('ad_types_id_seq', (SELECT MAX(id) FROM ad_types));")

    pg_conn.commit()
    print(f"Migrated {len(rows)} ad_types")

def main():
    """Main function to run the migration"""
    print("Starting migration from SQLite to PostgreSQL...")

    # Connect to databases
    sqlite_conn = connect_to_sqlite()
    pg_conn = connect_to_postgres()

    try:
        # Migrate data - ad_types must be first since communities references it
        migrate_ad_types(sqlite_conn, pg_conn)
        migrate_communities(sqlite_conn, pg_conn)

        print("Migration completed successfully!")
    except Exception as e:
        print(f"Error during migration: {e}")
        pg_conn.rollback()
    finally:
        # Close connections
        sqlite_conn.close()
        pg_conn.close()

if __name__ == "__main__":
    main()
