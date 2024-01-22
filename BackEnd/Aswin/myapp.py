import pandas as pd
from readSouce import read_csv_string
from tokenfinder import *
from flask import Flask, request, jsonify
from flask_cors import CORS
from uniqueKeyIdentifier import getPrimaryKey
from validation import *
from comonPk import *
sourceFileString = None
sourcedata = None
targetFileString = None
targetdata = None 
sourcePrimaryKey= None
targetPrimaryKey= None
mapingDoc = None


app = Flask(__name__)



CORS(app)
@app.route('/findKeys', methods=['POST'])
def findKeys():
    global sourceFileString
    global targetFileString
    global sourcePrimaryKey
    global targetPrimaryKey
    
    try:
        sourceFileString = request.form.get('source')
        sourcedata = read_csv_string(sourceFileString)
        targetFileString = request.form.get('target')
        targetdata = read_csv_string(targetFileString)
        sourcePrimaryKey=""
        targetPrimaryKey=""
        
        pks = get_two_keys(sourcedata,targetdata)
        if(pks[0]==None or pks[1]==None):
            sourcePrimaryKey=   getPrimaryKey(sourcedata)
            targetPrimaryKey= getPrimaryKey(targetdata)
            
            sourcePrimaryKey = sourcePrimaryKey[0]
            targetPrimaryKey = targetPrimaryKey[0]
            
            if(sourcePrimaryKey==None or targetPrimaryKey==None):
                message = '[-] Primary key identification Failed!'
            else:
                message = '[+] Primary key identification Success! Choose Primary Key(s) from the list'
        
            
        elif(len(pks) == 2):
            sourcePrimaryKey= pks[0]
            targetPrimaryKey=pks[1]
            message = '[+] Primary key identification Success! Found Common Primary Key(s)'
        elif(len(pks)>2):
            printKeys(pks)
            for pair in pks:
                sourcePrimaryKey += pair[0] + ", "
                targetPrimaryKey += pair[1] + ", "
                message = '[+] Primary key identification Success! Found multiple Common Primary Key(s)'
    
    except Exception as e:
        print(e)
        
        
        
        
        
    print("sourcePrimaryKey: {sourcePrimaryKey}, targetPrimaryKey: {targetPrimaryKey},message: {message}".format(sourcePrimaryKey=sourcePrimaryKey,targetPrimaryKey=targetPrimaryKey,message=message))  
    return jsonify({'sourcePrimaryKey': sourcePrimaryKey, 'targetPrimaryKey': targetPrimaryKey,'message': message})
@app.route('/mapData', methods=['POST'])
def mapData():
    global sourceFileString
    global targetFileString
    global sourcePrimaryKey
    global targetPrimaryKey
    global mapingDoc
    
    try:
        # sourceFileString = request.form.get('source')
        # targetFileString = request.form.get('target')
        # sourcePrimaryKey = request.form.get('sourcePk')
        # targetPrimaryKey = request.form.get('targetPk')
        
        mapingStr,mapingDoc = mapColumnstring(sourceFileString, targetFileString,sourcePrimaryKey,targetPrimaryKey)
        message =  '[+] Data maping Success!'
        
    except:
        mapingDoc=None
        message =  '[-] Data maping Failed!'
        
    
    return jsonify({'MapingDoc': mapingStr, 'message': message}) 
@app.route('/validateData', methods=['POST'])
def validateData():

    global sourceFileString
    global targetFileString
    global sourcePrimaryKey
    global targetPrimaryKey  
    global mapingDoc
    targetdata = read_csv_string(targetFileString)
    sourcedata = read_csv_string(sourceFileString)
    # print(sourcePrimaryKey,targetPrimaryKey,sourcedata,targetdata)
    resultString =compareData(sourcePrimaryKey,targetPrimaryKey,sourcedata,targetdata,mapingDoc)
    print(resultString)

    # resultString = driver(sourcedata,targetdata)
    # return resultString

    return jsonify({'validationDoc': resultString, 'message': 'Validation Complete!'}) 



if __name__ == '__main__':
    app.run(host='127.0.0.1', port=4564)
