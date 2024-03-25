from flask import Flask, request, jsonify
from flask_cors import CORS
import pdfplumber
import spacy
import json


app = Flask(__name__)
CORS(app)  

nlp = spacy.load("fr_core_news_sm")

def extract_text_sections(pdf_file):
    doc = pdfplumber.open(pdf_file)
    text = ""
    for page in doc.pages:
        text += page.extract_text()

    # Traiter le texte avec spaCy
    doc = nlp(text)

    # Extraire les entités nommées pertinentes
    entites = {}
    for ent in doc.ents:
        label = ent.label_
        if label not in entites:
            entites[label] = []
        entites[label].append(ent.text)
    result=json.dumps(entites, indent=2, ensure_ascii=False)
    
    return result


@app.route('/extract_text', methods=['POST'])
def extract_text():
    # Vérifier si un fichier PDF est fourni
    if 'file' not in request.files:
        return jsonify({'error': 'No PDF file provided'})
    print(type(request))
    # Récupérer le fichier PDF depuis la requête
    pdf_file = request.files['file']
    print(type(pdf_file))
    sections = extract_text_sections(pdf_file)

  

    return sections



if __name__ == '__main__':
    print('API star')
    app.run(debug=True)
    






