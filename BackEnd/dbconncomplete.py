import pandas as pd
import pymongo
import mysql.connector
# import cx_Oracle

def connect_mongodb(host, port, user, password, database):
    client = pymongo.MongoClient(f"mongodb://{user}:{password}@{host}:{port}/")
    return client[database]

def connect_mysql(host, user, password, database):
    connection = mysql.connector.connect(
        host=host,
        user=user,
        password=password,
        database=database,
        
    )
    return connection

# def connect_oracle(host, user, password, database):
#     dsn = cx_Oracle.makedsn(host, 1521, service_name=database)
#     connection = cx_Oracle.connect(user=user, password=password, dsn=dsn)
#     return connection

def fetch_table_to_dataframe(connection, table_name):
    cursor = connection.cursor()
    query = f"SELECT * FROM {table_name}"
    cursor.execute(query)
    data = cursor.fetchall()
    columns = [desc[0] for desc in cursor.description]
    
    df = pd.DataFrame(data, columns=columns)
    return df

def gbtodf(db_type,host,user,password,database,table_name):
    # User input
    # db_type = input("Enter the database type (mongodb/mysql/oracle): ").lower()
    # host = input("Enter the host: ")
    # user = input("Enter the user: ")
    # password = input("Enter the password: ")
    # database = input("Enter the database name: ")
    # table_name = input("Enter the table name: ")


    # Connect to the selected database
    if db_type == 'MongoDB':
        connection = connect_mongodb(host, 27017, user, password, database)
    elif db_type == 'MySQL':
        connection = connect_mysql(host, user, password, database)
    # elif db_type == 'Oracle DB':
    #     connection = connect_oracle(host, user, password, database)
    else:
        print("Invalid database type. Exiting.")
        return

    # Fetch table into a Pandas DataFrame
    df = fetch_table_to_dataframe(connection, table_name)

    # Print the DataFrame
    # print(df)

    # Close the connection
    connection.close()
    return df


