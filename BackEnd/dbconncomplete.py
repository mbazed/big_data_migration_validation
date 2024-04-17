import pandas as pd
import pymongo
import mysql.connector
# import cx_Oracle

# def connect_mongodb(host, port, user, password, database):
#     client = pymongo.MongoClient(f"mongodb://{user}:{password}@{host}:{port}/")
#     return client[database]
    # jzilmMSRpXjnnGpg

from pymongo import MongoClient

def connect_mongodb(connection_string):
    try:
        # Connect to MongoDB
        client = MongoClient(connection_string)
        # Check if the connection was successful
        client.server_info()  # This will throw an exception if the connection fails
        print("Connected to MongoDB successfully!")
        return client
    except Exception as e:
        print(f"Failed to connect to MongoDB: {e}")
        return None

# # Example connection string (replace this with the one provided by the user)
# connection_string = "mongodb+srv://dasharitha10:jzilmMSRpXjnnGpg@cluster0.ruhqvtu.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

# # Call the function to establish connection
# client = connect_to_mongodb(connection_string)

# Use the 'client' object to interact with the MongoDB database


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

def fetch_table_to_dataframe_sql(connection, table_name):
    cursor = connection.cursor()

    if ',' in table_name:
    # If it's a list of values, split them and join tables in the query
      table_names = table_name.split(',')
      join_condition = ' NATURAL JOIN '.join(table_names)
      query = f"SELECT * FROM {join_condition}"
    else:
    # If it's a single value, use the simple SELECT * FROM table_name query
      query = f"SELECT * FROM {table_name}"

    cursor.execute(query)
    data = cursor.fetchall()
    columns = [desc[0] for desc in cursor.description]
    
    df = pd.DataFrame(data, columns=columns)
    return df

def fetch_table_to_dataframe_mongo(connection, database, table_name):
    try:
        # Access the specified database
        db = connection[database]
        # Access the specified collection
        collection = db[table_name]
        # Retrieve data from the collection
        cursor = collection.find()
        # Convert cursor to list of dictionaries
        data_list = list(cursor)
        # Convert list of dictionaries to DataFrame
        df = pd.DataFrame(data_list)
        # Drop the _id column from the DataFrame
        df = df.drop('_id', axis=1)
        # Return the DataFrame
        return df
    except Exception as e:
        print(f"Failed to retrieve data from collection: {e}")
        return None

def gbtodf(db_type,host,user,password,database,table_name):
    
    # Connect to the selected database
    if db_type == 'MongoDB':
        connection = connect_mongodb(host)
    elif db_type == 'MySQL':
        connection = connect_mysql(host, user, password, database)
    # elif db_type == 'Oracle DB':
    #     connection = connect_oracle(host, user, password, database)
    else:
        print("Invalid database type. Exiting.")
        return

    # Fetch table into a Pandas DataFrame
    if db_type == 'MongoDB':
        df = fetch_table_to_dataframe_mongo(connection, database,table_name)
    else:
        df = fetch_table_to_dataframe_sql(connection, table_name)

    # Close the connection
    connection.close()
    return df