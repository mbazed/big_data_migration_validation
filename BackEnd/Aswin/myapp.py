from validation3 import *
import pandas as pd
from readSouce import *
from tokenfinder import *
from flask import Flask, request, jsonify
from flask_cors import CORS
from uniqueKeyIdentifier import getPrimaryKey
from validation import *
from comonPk import *
from validationHaritha import *
sourceFileString = None
sourcedata = None
targetFileString = None
targetdata = None 
sourcePrimaryKey= None
targetPrimaryKey= None
mapingDoc = None




app = Flask(__name__)
CORS(app)
@app.route('/upload', methods=['POST'])
def upload_files():
    global sourcedata
    global targetdata
    
    print("[⌄]uploaded Files...")
    source_file = request.files['sourceFile']
    target_file = request.files['targetFile']

    if source_file.filename == '' or target_file.filename == '':
        message =  '[-] No selected files'
    else:
        sourcedata=read_file_content_df(source_file)
        targetdata=read_file_content_df(target_file)

        message= '[+] Files Recieved successfully'

    # Process the files as needed
    print(message)
    return jsonify({'message': message})


@app.route('/process')
def process_file():
    global uploaded_file  # Access the global variable

    if uploaded_file is not None:
        # Process the file as needed
        content = uploaded_file.read()
        return f'File content: {content}'
    else:
        return 'No file uploaded yet'



@app.route('/findKeys', methods=['POST'])
def findKeys():
    global sourcedata
    global targetdata
    global sourcePrimaryKey
    global targetPrimaryKey
    
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
        
    print(message)
    print("[^] returning response...")    
    return jsonify({'sourcePrimaryKey': sourcePrimaryKey, 'targetPrimaryKey': targetPrimaryKey,'message': message})
@app.route('/mapData', methods=['POST'])
def mapData():
    global sourcedata
    global targetdata
    global sourcePrimaryKey
    global targetPrimaryKey
    global mapingDoc
    mapingStr = ""
    sourcePrimaryKey = request.form.get('sourcePk').strip()
    targetPrimaryKey = request.form.get('targetPk').strip()
    print("[⌄] Data map request received...")
    print("with source-Primary-Key:",sourcePrimaryKey,"target-Primary-Key:",targetPrimaryKey)
    try:
        
        
        mapingStr,mapingDoc = mappColumn(sourcedata,targetdata,sourcePrimaryKey,targetPrimaryKey)
        if(mapingDoc == {}):
            message =  '[-] Data maping Failed!'
        else:
            message =  '[+] Data maping Success!'

    except Exception as e:
    # Print the exception message
        
        print(f"mapData/Exception occurred : {str(e)}")
        mapingDoc=None
        message =  '[-] Data maping Failed!'
        
    print(message)
    print("[^] returning response...")
    return jsonify({'MapingDoc': mapingStr, 'message': message}) 
@app.route('/validateData', methods=['POST'])
def validateData():

    global sourcedata
    global targetdata
    global sourcePrimaryKey
    global targetPrimaryKey  
    global mapingDoc
    
    print("[⌄] validation request received...")
    
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
    app.run(host='127.0.0.1', port=4564,debug=False)
