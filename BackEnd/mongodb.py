from pymongo import MongoClient

def connect_to_mongodb(connection_string):
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

def get_data_from_collection(client, database_name, collection_name):
    try:
        # Access the specified database
        db = client[database_name]
        # Access the specified collection
        collection = db[collection_name]
        # Retrieve data from the collection
        data = collection.find()
        # Return the retrieved data
        return data
    except Exception as e:
        print(f"Failed to retrieve data from collection: {e}")
        # return None

# Example connection string (replace this with the one provided by the user)
connection_string = "mongodb+srv://dasharitha10:jzilmMSRpXjnnGpg@cluster0.ruhqvtu.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

# Call the function to establish connection
client = connect_to_mongodb(connection_string)

if client:
    # Specify the database name and collection name
    database_name = "sample_mflix"
    collection_name = "comments"

    # Call the function to retrieve data from the collection
    data = get_data_from_collection(client, database_name, collection_name)

    if data:
        # Print the retrieved data
        # for document in data:
        #     print(document)
        print("Data Received")
    else:
        print("No data retrieved from the collection.")

