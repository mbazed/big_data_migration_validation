import json
from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import Column, Integer, String, create_engine
import pandas as pd

from readSouce import *
from tokenfinder import *
from dbconncomplete import *
from comonPk import *
from validation3 import *
import uuid  # for generating unique request IDs

app = Flask(__name__)
CORS(app)


# Configure your database URI (SQLite in this example)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///data.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

class DataRecord(db.Model):
    id = Column(Integer, primary_key=True)
    request_id = Column(String, unique=True)
    source_data = Column(String)
    target_data = Column(String)
    source_primary_key = Column(String)
    target_primary_key = Column(String)
    mapping_document = Column(String)
    

# Create tables within the application context
with app.app_context():
    db.create_all()

@app.route('/getfromdb',methods=['POST'])
def get_from_db():
    print("[⌄]getting from DB...")
    try:
        request_id = str(uuid.uuid4())
        source_database_type = request.form.get('source_database_type')
        source_hostname = request.form.get('source_hostname')
        source_username = request.form.get('source_username')
        source_database = request.form.get('source_database')
        source_password = request.form.get('source_password')
        source_table = request.form.get('source_table')
        target_database_type = request.form.get('target_database_type')
        target_hostname = request.form.get('target_hostname')
        target_username = request.form.get('target_username')
        target_database = request.form.get('target_database')
        target_password = request.form.get('target_password')
        target_table = request.form.get('target_table')

        sourcedata = gbtodf(source_database_type,source_hostname,source_username,source_password,source_database,source_table)
        targetdata = gbtodf(target_database_type,target_hostname,target_username,target_password,target_database,target_table)

        # Convert DataFrames to JSON strings for storage
        source_json = sourcedata.to_json()
        target_json = targetdata.to_json()

        # Store data in the database with the associated request ID
        record = DataRecord(
            request_id=request_id,
            source_data=source_json,
            target_data=target_json,
           
            )
        db.session.add(record)
        db.session.commit()

        message = '[+] Files Received successfully'
        print(message , "with request_id:", request_id)
        return jsonify({'message': message, 'request_id': request_id})

    except Exception as e:
        print(f"An error occurred on get_from_db: {e}")



@app.route('/upload', methods=['POST'])
def upload_files():
   

    print("[⌄]uploaded Files...")

    # Generate a unique request ID for each upload
    try:
        
        request_id = str(uuid.uuid4())

        source_file = request.files['sourceFile']
        target_file = request.files['targetFile']

        if source_file.filename == '' or target_file.filename == '':
            message = '[-] No selected files'
        else:
            sourcedata = read_file_content_df(source_file)
            targetdata = read_file_content_df(target_file)

        # Convert DataFrames to JSON strings for storage
            source_json = sourcedata.to_json()
            target_json = targetdata.to_json()

        # Store data in the database with the associated request ID
            record = DataRecord(
                request_id=request_id,
                source_data=source_json,
                target_data=target_json,
           
            )
            db.session.add(record)
            db.session.commit()

            message = '[+] Files Received successfully'
            print(message , "with request_id:", request_id)
        return jsonify({'message': message, 'request_id': request_id})
    except Exception as e:
        print(f"upload_files/Exception occurred: {str(e)}")
        message = '[-] Files Receive Failed!'
        return jsonify({'message': message, 'request_id': request_id}),500
        
        
        
    

# Add other routes and functions as needed






@app.route('/findKeys', methods=['POST'])
def findKeys():
    sourcePrimaryKey= None
    targetPrimaryKey= None
    request_id = request.form.get('request_id')
    
    record = DataRecord.query.filter_by(request_id=request_id).first()
    
    

    sourcedata = json_to_df(record.source_data)
    targetdata = json_to_df(record.target_data)
    
    try:
        print("[⌄] Primary key request received...")
        
        pks = get_two_keys(sourcedata,targetdata)
        if(len(pks) == 2):
            sourcePrimaryKey= pks[0]
            targetPrimaryKey=pks[1]
        elif(len(pks)>2):
            printKeys(pks)
            sourcePrimaryKey=''
            targetPrimaryKey=''
            for pair in pks:
                
                sourcePrimaryKey +=pair[0]+","
                targetPrimaryKey +=pair[1]+","
        message = '[+] Primary key identification Success!'
    except:
        sourcePrimaryKey=None
        targetPrimaryKey=None
        message = '[-] Primary key identification Failed!'
    
    record.source_primary_key = sourcePrimaryKey
    record.target_primary_key = targetPrimaryKey

            # Commit the changes to the database
    db.session.add(record)
    
    db.session.commit()

    message = '[+] Primary keys updated successfully'
        
    
        
    print(message)
    print("[^] returning response...")    
    return jsonify({'sourcePrimaryKey': sourcePrimaryKey, 'targetPrimaryKey': targetPrimaryKey,'message': message})
@app.route('/mapData', methods=['POST'])
def mapData():
    
    
    
    
    mapingStr = ""
    request_id = request.form.get('request_id')
    
    sourcePrimaryKey = request.form.get('sourcePk').strip()
    targetPrimaryKey = request.form.get('targetPk').strip()
    
    
    record = DataRecord.query.filter_by(request_id=request_id).first()
    sourcedata = json_to_df(record.source_data)
    targetdata= json_to_df(record.target_data)
    
    
    print("[⌄] Data map request received...")
    print("with source-Primary-Key:",sourcePrimaryKey,"target-Primary-Key:",targetPrimaryKey)
    
    
    record.source_primary_key = sourcePrimaryKey
    record.target_primary_key = targetPrimaryKey
    db.session.add(record)
    

            # Commit the changes to the database
    
    try:
        
        
        mapingStr,mapingDoc = mappColumn(sourcedata,targetdata,sourcePrimaryKey,targetPrimaryKey)
        if(mapingDoc == {}):
            message =  '[-] Data maping Failed!'
        else:
            message =  '[+] Data maping Success!'
            record.mapping_document = json.dumps(mapingDoc)
            db.session.add(record)


    except Exception as e:
    # Print the exception message
        
        print(f"mapData/Exception occurred : {str(e)}")
        mapingDoc=None
        message =  '[-] Data maping Failed!'
    db.session.commit()
        
    print(message)
    print("[^] returning response...")
    return jsonify({'MapingDoc': mapingStr, 'message': message}) 


@app.route('/validateData', methods=['POST'])
def validateData():
    request_id = request.form.get('request_id')
    
    record = DataRecord.query.filter_by(request_id=request_id).first()
    
    sourcedata = json_to_df(record.source_data)
    targetdata= json_to_df(record.target_data)
    mapingDoc = json.loads(record.mapping_document)
    targetPrimaryKey = record.target_primary_key
    
    print("[⌄] validation request received...")
    
    resultString = "Valiadation Failed!"
    
    # print(sourcePrimaryKey,targetPrimaryKey,sourcedata,targetdata)
    try:
        resultString =dividedCompare(sourcedata,targetdata,mapingDoc,targetPrimaryKey)
    except Exception as e:
    # Print the exception message
        
        print(f"validateData/Exception occurred: {str(e)}")
        
    
    
    # print(resultString)
    
    # resultString = driver(sourcedata,targetdata)
    # return resultString
    print("[^] returning response...")

    return jsonify({'validationDoc': resultString, 'message': 'Validation Complete!'}) 



if __name__ == '__main__':
    # Create the database tables before running the app
    
    app.run(host='127.0.0.1', port=4564, debug=False)