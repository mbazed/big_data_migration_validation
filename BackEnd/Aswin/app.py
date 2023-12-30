import pandas as pd
from readSouce import read_csv_string
from tokenfinder import *
from flask import Flask, request, jsonify
from flask_cors import CORS
from uniqueKeyIdentifier import getPrimaryKey
# import sampleModels
from validation import *
targetdata=None
sourcedata=None
sourcePrimaryKey=None
targetPrimaryKey=None


app = Flask(__name__)
CORS(app)
@app.route('/findKeys', methods=['POST'])
def findKeys():
    
    try:
        sourceFileString = request.form.get('source')
        sourcedata = read_csv_string(sourceFileString)
        targetFileString = request.form.get('target')
        targetdata = read_csv_string(targetFileString)
        sourcePrimaryKey=getPrimaryKey(sourcedata)
        targetPrimaryKey=getPrimaryKey(targetdata)
        message = '[+] Primary key identification Success!'
    except:
        sourcePrimaryKey=None
        targetPrimaryKey=None
        message = '[-] Primary key identification Failed!'
        
        
    return jsonify({'sourcePrimaryKey': sourcePrimaryKey[0], 'targetPrimaryKey': targetPrimaryKey[0],'message': message})
@app.route('/mapData', methods=['POST'])
def mapData():
    try:
        sourceFileString = request.form.get('source')
        targetFileString = request.form.get('target')
        mapingDoc = mapColumnstring(sourceFileString, targetFileString)
        message =  '[+] Data maping Success!'
        # sourcedata = read_csv_string(sourceFileString)
        # targetdata = read_csv_string(targetFileString)
        # validationDoc =validateData()
        
        
    except:
        mapingDoc=None
        message =  '[-] Data maping Failed7!'
        
        
        
    
    return jsonify({'MapingDoc': mapingDoc, 'message': message }) 


@app.route('/validateData', methods=['POST'])
def validateData():
    
    sourceFileString = request.form.get('source')
    targetFileString = request.form.get('target')
    sourcePrimaryKey = request.form.get('sourcePrimaryKey')
    targetPrimaryKey = request.form.get('targetPrimaryKey')   
    targetdata = read_csv_string(targetFileString)
    sourcedata = read_csv_string(sourceFileString)
    # print(sourcePrimaryKey,targetPrimaryKey,sourcedata,targetdata)
    resultString =compareData(sourcePrimaryKey,targetPrimaryKey,sourcedata,targetdata)
    print(resultString)
    
    # resultString = driver(sourcedata,targetdata)
    # return resultString
    
    return jsonify({'validationDoc': resultString, 'message': 'Validation Complete!'}) 



if __name__ == '__main__':
    app.run(host='127.0.0.1', port=4564)
