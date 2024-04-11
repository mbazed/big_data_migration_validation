import json

from flask import Flask, request, jsonify, send_file
import os

from reportlab.pdfgen import canvas
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import Column, Integer, String, create_engine
import pandas as pd

from readSouce import *
from tokenfinder import *
from dbconncomplete import *
from comonPk import *
from commonCompositePk import get_two_keys
from validation3 import *
from sampling import *
# from validationThreading import *
from cryptography.fernet import Fernet
import uuid  # for generating unique request IDs
import logging

app = Flask(__name__)
CORS(app)


# Configure your database URI (SQLite in this example)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///data.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

key = Fernet.generate_key()
cipher_suite = Fernet(key)

class DataRecord(db.Model):
    id = Column(Integer, primary_key=True)
    request_id = Column(String, unique=True)
    source_data = Column(String)
    target_data = Column(String)
    source_primary_key = Column(String)
    target_primary_key = Column(String)
    mapping_document = Column(String)
    validation_document = Column(String)
def encrypt_data(data):
    encrypted_data = cipher_suite.encrypt(data.encode())
    return encrypted_data

# def decrypt_data(encrypted_data):
#     decrypted_data = cipher_suite.decrypt(encrypted_data)
#     return decrypted_data.decode()



def decrypt_data(encrypted_data):
    try:
        decrypted_data = cipher_suite.decrypt(encrypted_data)
        return decrypted_data.decode()
    except Exception as e:
        logging.error(f"Decryption failed: {e}")
        return None
# Create tables within the application context
with app.app_context():
    db.create_all()

@app.route('/getdata',methods=['POST'])
def get_data():
    request_id = str(uuid.uuid4())
    print("[⌄] getting data...")
    try:
        source_type= request.form.get('source_type')
        target_type= request.form.get('target_type')
        # print(source_type,target_type)
        
        if(source_type == 'File Mode'):
            source_file = request.files['sourceFile']
            sourcedata = read_file_content_df(source_file)
            source_json = encrypt_data(sourcedata.to_json())
        else:
            source_hostname = request.form.get('source_hostname')
            source_username = request.form.get('source_username')
            source_database = request.form.get('source_database')
            source_password = request.form.get('source_password')
            source_table = request.form.get('source_table')
            sourcedata = gbtodf(source_type,source_hostname,source_username,source_password,source_database,source_table)
            source_json = encrypt_data(sourcedata.to_json())
            
        if(target_type == 'File Mode'):
            target_file = request.files['targetFile']
            targetdata = read_file_content_df(target_file)
            target_json = encrypt_data(targetdata.to_json())
        else:
            target_hostname = request.form.get('target_hostname')
            target_username = request.form.get('target_username')
            target_database = request.form.get('target_database')
            target_password = request.form.get('target_password')
            target_table = request.form.get('target_table')
            targetdata = gbtodf(target_type,target_hostname,target_username,target_password,target_database,target_table)
            target_json = encrypt_data(targetdata.to_json())
            
        record = DataRecord(
                request_id=request_id,
                source_data=source_json,
                target_data=target_json,
           
            )
        db.session.add(record)
        db.session.commit()
        message = '[+] Data Received'
        
        
        
    except Exception as e:
        print(f"[!]An error occurred on get_data: {e}")
        message = '[-] Data not Received'
    print(message)
    print("[^] returning response...")
    return jsonify({'message': message, 'request_id': request_id})

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
        try:
            sourcedata = gbtodf(source_database_type,source_hostname,source_username,source_password,source_database,source_table)
            targetdata = gbtodf(target_database_type,target_hostname,target_username,target_password,target_database,target_table)
            source_json = encrypt_data(sourcedata.to_json())
            target_json = encrypt_data(targetdata.to_json())

        # Store data in the database with the associated request ID
            record = DataRecord(
                request_id=request_id,
                source_data=source_json,
                target_data=target_json,
           
                )
            db.session.add(record)
            db.session.commit()

            # print(sourcedata,targetdata)
            message = '[+] Files Received successfully'
            print(message , "with request_id:", request_id)
            return jsonify({'message': message, 'request_id': request_id})
        except Exception as e:
            message = '[-] Database Connection Failed!'
            return jsonify({'message': message, 'request_id': request_id})
            
        # Convert DataFrames to JSON strings for storage
        

    except Exception as e:
        print(f"[!]An error occurred on get_from_db: {e}")
        message = '[-] Database Connection Failed!'
        return jsonify({'message': message, 'request_id': request_id})



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
            source_json = encrypt_data(sourcedata.to_json())
            target_json = encrypt_data(targetdata.to_json())

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
    
    encrypted_source_data = record.source_data
    encrypted_target_data = record.target_data
     
    decrypt_source_data = decrypt_data(encrypted_source_data)
    decrypt_target_data = decrypt_data(encrypted_target_data)
    # decrypt_source_data = record.source_data
    # decrypt_target_data = record.target_data
    sourcedata = pd.read_json( decrypt_source_data)
    targetdata= pd.read_json(decrypt_target_data) 
    

    # print(targetPrimaryKey,sourcedata,targetdata)
    
    sourceColumns =(',').join( sourcedata.columns.tolist())
    targetColumns=(',').join( targetdata.columns.tolist())
    
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
    
    # record.source_primary_key = sourcePrimaryKey
    # record.target_primary_key = targetPrimaryKey

    #         # Commit the changes to the database
    # db.session.add(record)
    
    db.session.commit()

    
        
    
        
    print(message)
    print("[^] returning response...")    
    # print(sourceColumns,targetColumns,sourcePrimaryKey,targetPrimaryKey,message)
    return jsonify({  'source-columns':sourceColumns.split(','),'target-columns':targetColumns.split(','), 'sourcePrimaryKey': sourcePrimaryKey, 'targetPrimaryKey': targetPrimaryKey,'message': message})


def combine_columns(row,col_list):
    return ''.join(str(row[col.strip()]) for col in col_list)

@app.route('/mapData', methods=['POST'])
def mapData():
    connectionsList=[]
    
    
    
    mapingStr = ""
    request_id = request.form.get('request_id')
    
    sourcePrimaryKey = request.form.get('sourcePk').strip()
    targetPrimaryKey = request.form.get('targetPk').strip()
    connectionsList.append([sourcePrimaryKey,targetPrimaryKey])
    
    
    record = DataRecord.query.filter_by(request_id=request_id).first()
    encrypted_source_data = record.source_data
    encrypted_target_data = record.target_data
     
    decrypt_source_data = decrypt_data(encrypted_source_data)
    decrypt_target_data = decrypt_data(encrypted_target_data)
    # decrypt_source_data = record.source_data
    # decrypt_target_data = record.target_data
    sourcedata = pd.read_json( decrypt_source_data)
    targetdata= pd.read_json(decrypt_target_data) 
    # encrypted_source_data = record.source_data
    # encrypted_target_data = record.target_data
    # sourcedata = json_to_df(decrypt_data(encrypted_source_data))
    # targetdata= json_to_df(decrypt_data(encrypted_target_data))
    
    
    srcpkList = sourcePrimaryKey.strip().split(',')
    tarpkList = targetPrimaryKey.strip().split(',')
    
    if len(srcpkList) > 1:
        print("composite pk for src")
        sourcedata[sourcePrimaryKey]= sourcedata.apply(combine_columns,args=(srcpkList,), axis=1)
        record.source_data= sourcedata.to_json()
    if len(tarpkList) > 1:
        print("composite pk for tar")
        targetdata[targetPrimaryKey]= targetdata.apply(combine_columns,args=(tarpkList,), axis=1)
        record.target_data=targetdata.to_json()
        
    print("[⌄] Data map request received...")
    print("with source-Primary-Key:",sourcePrimaryKey,"target-Primary-Key:",targetPrimaryKey)
    
    
    record.source_primary_key = sourcePrimaryKey
    record.target_primary_key = targetPrimaryKey

    
    
    print("[⌄] Data map request received...")
    print("with source-Primary-Key:",sourcePrimaryKey,"target-Primary-Key:",targetPrimaryKey)
    
    
    record.source_primary_key = sourcePrimaryKey
    record.target_primary_key = targetPrimaryKey
    db.session.add(record)
    

            # Commit the changes to the database
    
    try:
        
        
        mapingStr,mapingDoc,connectionsList = mappColumn(sourcedata,targetdata,sourcePrimaryKey,targetPrimaryKey)
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
    return jsonify({'MapingDoc': mapingStr,'connections':connectionsList, 'message': message}) 


@app.route('/validateData', methods=['POST'])
def validateData():
    request_id = request.form.get('request_id')
   
    record = DataRecord.query.filter_by(request_id=request_id).first()
    if record:
        encrypted_source_data = record.source_data
        encrypted_target_data = record.target_data

        if encrypted_source_data and encrypted_target_data:
            decrypted_source_data = decrypt_data(encrypted_source_data)
            decrypted_target_data = decrypt_data(encrypted_target_data)

            # sourcedata = json_to_df(decrypted_source_data)
            # targetdata= json_to_df(decrypted_target_data)
        else:
            print("[⌄] Error: encrypted data is missing.")

    sourcedata = pd.read_json( decrypted_source_data)
    targetdata= pd.read_json(decrypted_target_data) 
    mapingDoc = json.loads(record.mapping_document)
    targetPrimaryKey = record.target_primary_key
   
    sample_percent = 10
    
    sampled_source_data, sampled_primary_keys = collect_sample_data_with_primary_key(sourcedata, sample_percent, targetPrimaryKey)
    sampled_target_data = collect_corresponding_data_from_target(targetdata, sampled_primary_keys, targetPrimaryKey)
    print("[⌄] validation request received...")
    
    resultString = "Valiadation Failed!"
    
    #print(targetPrimaryKey,sourcedata,targetdata)
    try:
        resultString =dividedCompare(sampled_source_data,sampled_target_data,mapingDoc,targetPrimaryKey)
    except Exception as e:
    # Print the exception message
        
        print(f"validateData/Exception occurred: {str(e)}")
        
    
    
    # print(resultString)
    
    # resultString = driver(sourcedata,targetdata)
    # return resultString
    record.validation_document = resultString
    db.session.add(record)
    db.session.commit()
    print("[^] returning response...")

    return jsonify({'validationDoc': resultString, 'message': 'Validation Complete!'}) 


@app.route('/download', methods=['POST'])
def download_report():
    print("[⌄] Download request received...")
    request_id = request.form.get('request_id')
    record = DataRecord.query.filter_by(request_id=request_id).first()

    # Combine mapping and validation documents
    data = record.mapping_document + record.validation_document

    # If the documents are already JSON strings, no need to load and dump them again
    formatted_content = data
    
    # Create a PDF file
    pdf_path = f'{request_id}_output.pdf'
    create_pdf(formatted_content, pdf_path)

    # Send the PDF file to the client
    response = send_file(pdf_path, as_attachment=True)

    # Clean up the temporary PDF file after sending
    # os.remove(pdf_path)
    print("[^] returning response...")
    return response

def create_pdf(content, pdf_path):
    pdf_canvas = canvas.Canvas(pdf_path)
    
    # Customize your PDF content here:
    pdf_canvas.drawString(100, 800, content)

    pdf_canvas.save()



if __name__ == '__main__':
    app.run(host='127.0.0.1', port=4564, debug=True)
    