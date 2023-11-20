from readSouce import read_csv_string
from tokenfinder import *
from flask import Flask, request, jsonify
from flask_cors import CORS
from uniqueKeyIdentifier import getPrimaryKey
import sampleModels

app = Flask(__name__)
CORS(app)
@app.route('/findKeys', methods=['POST'])
def findKeys():
    sourceFileString = request.form.get('source')
    sourcedata = read_csv_string(sourceFileString)
    targetFileString = request.form.get('target')
    targetdata = read_csv_string(targetFileString)
    sourcePrimaryKey=getPrimaryKey(sourcedata)
    targetPrimaryKey=getPrimaryKey(targetdata)
    # print(f'Primary Key: {sourcePrimaryKey}')
    # mapColumnstring(sourceFileString, targetFileString)
    return jsonify({'sourcePrimaryKey': sourcePrimaryKey, 'targetPrimaryKey': targetPrimaryKey,'message': 'Primary key identification Success!'})
@app.route('/mapData', methods=['POST'])
def mapData():
    sourceFileString = request.form.get('source')
    targetFileString = request.form.get('target')
    mapingDoc = mapColumnstring(sourceFileString, targetFileString)
    return jsonify({'MapingDoc': mapingDoc, 'message': 'Data maping Success!'}) 
if __name__ == '__main__':
    app.run(host='127.0.0.1', port=4564)
