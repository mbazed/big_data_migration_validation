from validation3 import *
import pandas as pd
from readSouce import read_csv_string
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

@app.route('/upload', methods=['POST'])
def upload_file():
    global uploaded_file  # Access the global variable

    if 'file' not in request.files:
        return 'No file part'

    file = request.files['file']

    if file.filename == '':
        return 'No selected file'

    # Save the file to a desired location
    file.save('uploads/' + file.filename)

    # Assign the file object to the global variable
    uploaded_file = file

    return 'File uploaded successfully'

@app.route('/process')
def process_file():
    global uploaded_file  # Access the global variable

    if uploaded_file is not None:
        # Process the file as needed
        content = uploaded_file.read()
        return f'File content: {content}'
    else:
        return 'No file uploaded yet'


CORS(app)
@app.route('/findKeys', methods=['POST'])
def findKeys():
    global sourceFileString
    global targetFileString
    global sourcePrimaryKey
    global targetPrimaryKey
    
    try:
        print("request received...")
        sourceFileString = request.form.get('source')
        sourcedata = read_csv_string(sourceFileString)
        targetFileString = request.form.get('target')
        targetdata = read_csv_string(targetFileString)
        
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
        
    print(message,"returning response...")    
    return jsonify({'sourcePrimaryKey': sourcePrimaryKey, 'targetPrimaryKey': targetPrimaryKey,'message': message})
@app.route('/mapData', methods=['POST'])
def mapData():
    global sourceFileString
    global targetFileString
    global sourcePrimaryKey
    global targetPrimaryKey
    global mapingDoc
    mapingStr = ""
    sourcePrimaryKey = request.form.get('sourcePk').strip()
    targetPrimaryKey = request.form.get('targetPk').strip()
    print("Data map request received...")
    print("with source-Primary-Key:",sourcePrimaryKey,"target-Primary-Key:",targetPrimaryKey)
    try:
        # sourceFileString = request.form.get('source')
        # targetFileString = request.form.get('target')
        # sourcePrimaryKey = request.form.get('sourcePk')
        # targetPrimaryKey = request.form.get('targetPk')
        
        mapingStr,mapingDoc = mapColumnstring(sourceFileString, targetFileString,sourcePrimaryKey,targetPrimaryKey)
        if(mapingDoc == {}):
            message =  '[-] Data maping Failed!'
        else:
            message =  '[+] Data maping Success!'

    except:
        mapingDoc=None
        message =  '[-] Data maping Failed!'
        
    print(message,"returning response...")
    return jsonify({'MapingDoc': mapingStr, 'message': message}) 
@app.route('/validateData', methods=['POST'])
def validateData():

    global sourceFileString
    global targetFileString
    global sourcePrimaryKey
    global targetPrimaryKey  
    global mapingDoc
    
    print("validation request received...")
    targetdata = read_csv_string(targetFileString)
    sourcedata = read_csv_string(sourceFileString)
    # print(sourcePrimaryKey,targetPrimaryKey,sourcedata,targetdata)
    try:
        resultString =dividedCompare(sourcedata,targetdata,mapingDoc)
    except:
        print("error in validation")
    
    
    # print(resultString)
    
    # resultString = driver(sourcedata,targetdata)
    # return resultString
    print("returning response...")

    return jsonify({'validationDoc': resultString, 'message': 'Validation Complete!'}) 



if __name__ == '__main__':
    app.run(host='127.0.0.1', port=4564)
