from flask import Flask, request, jsonify
from flask_cors import CORS
from uniqueKeyIdentifier import getPrimaryKey
import sampleModels

app = Flask(__name__)
CORS(app)
@app.route('/validate', methods=['POST'])
def validate():
    source_file_name = request.form.get('source')
    data = sampleModels.sampledata1

    PrimaryKey=getPrimaryKey(data)
    

    # Your validation logic goes here
    # Example: print the source file name
    print(f'Source file name: {source_file_name}')
    print(f'Primary Key: {PrimaryKey}')

    # You can send a response back to the Flutter app if needed
    return jsonify({'primarykey': PrimaryKey, 'message': 'Validation successful'})


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=4564)
