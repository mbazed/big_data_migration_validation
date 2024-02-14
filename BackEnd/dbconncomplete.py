import pandas as pd
import pymongo
import mysql.connector
import cx_Oracle

def connect_mongodb(host, port, user, password, database):
    # Use the provided parameters or your connection string
    # client = pymongo.MongoClient(host)
    # client = pymongo.MongoClient(f"mongodb://{user}:{password}@{host}:{port}/")
    client = pymongo.MongoClient("mongodb+srv://dasharitha10:FINT4zAkZ2LYn9EJ@cluster0.g355bm4.mongodb.net/?retryWrites=true&w=majority")

    try:
        # Check the connection using the ping method
        client.server_info()
        print("Connected to MongoDB successfully.")
    except pymongo.errors.ServerSelectionTimeoutError as e:
        print("Failed to connect to MongoDB. Error:", e)

    return client

def connect_mysql(host, user, password, database):
    connection = mysql.connector.connect(
        host=host,
        user=user,
        password=password,
        database=database,
        
    )
    return connection

def connect_oracle(host, user, password, database):
    dsn = cx_Oracle.makedsn(host, 1521, service_name=database)
    connection = cx_Oracle.connect(user=user, password=password, dsn=dsn)
    return connection

def fetch_table_to_dataframe_sql(connection, table_name):
    cursor = connection.cursor()
    query = f"SELECT * FROM {table_name}"
    cursor.execute(query)
    data = cursor.fetchall()
    columns = [desc[0] for desc in cursor.description]
    
    df = pd.DataFrame(data, columns=columns)
    return df

def fetch_table_to_dataframe_nosql(connection,database,table):
    
    # database_name = "sample_airbnb"
    # table_name = "listingsAndReviews"
    db = connection[database]
    collection = db[table]

    # Fetch data from the collection
    cursor = collection.find()
    data = list(cursor)

    # Convert data to Pandas DataFrame
    df = pd.DataFrame(data)

    # Close the MongoDB connection
    # connection.close()
    
    return df

def gbtodf(db_type,host,user,password,database,table_name):
    
    # Connect to the selected database
    if db_type == 'MongoDB':
        connection = connect_mongodb(host, 27017, user, password, database)   
    elif db_type == 'MySQL':
        connection = connect_mysql(host, user, password, database)
    elif db_type == 'Oracle DB':
        connection = connect_oracle(host, user, password, database)
    else:
        print("Invalid database type. Exiting.")
        return

    # Fetch table into a Pandas DataFrame
    if db_type == 'MongoDB':
        df = fetch_table_to_dataframe_nosql(connection, database, table_name)
    else:
        df = fetch_table_to_dataframe_sql(connection, table_name)

    connection.close()
    print(df)
    return df