from flask import Flask, render_template, request, redirect, url_for
import os

# Get the absolute path to the directory where app.py is located (i.e., 'backend/')
basedir = os.path.abspath(os.path.dirname(__file__))

# Construct the path to the 'frontend/templates' directory
# Go up one level from 'backend/' to 'customer-feedback-app/'
# Then go down into 'frontend/templates'
template_dir = os.path.join(basedir, '..', 'frontend')

# Construct the path to the 'frontend/static' directory
# Go up one level from 'backend/' to 'customer-feedback-app/'
# Then go down into 'frontend/static'
static_dir = os.path.join(basedir, '..', 'frontend', 'static')

# Ensure these paths are absolute and normalized
template_dir = os.path.normpath(template_dir)
static_dir = os.path.normpath(static_dir)

app = Flask(__name__, template_folder=template_dir, static_folder=static_dir)

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        name = request.form['name']
        feedback = request.form['feedback']
        return render_template('feedback_submitted.html', name=name, feedback=feedback)
    return render_template('index.html')

@app.route('/feedback_submitted')
def feedback_submitted():
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)
