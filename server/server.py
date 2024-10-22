import logging
from datetime import datetime
from flask import Flask, request, jsonify, render_template, url_for, redirect, flash, session
from core.data_handling import insert_data_from_device, process_uploaded_json, get_all_patients_data, get_patient_data, \
    process_uploaded_audio_file, get_user_data, insert_user, get_patients_at_risk_data
from core.graph_builder import build_hourly_distance_graph, build_hourly_screensum_graph, \
    build_hourly_light_amplitude_graph, build_hourly_acceleration_graph, build_hourly_conversation_graph, \
    build_hourly_audio_amplitude_graph, build_hourly_screenusage_graph, build_hourly_places_graph
from werkzeug.security import generate_password_hash, check_password_hash
from core.utils.json_encoder import CustomJSONProvider
from core.scheduler import scheduler
from config.config import secret_key
from functools import wraps

app = Flask(__name__)
app.json = CustomJSONProvider(app)
app.secret_key = secret_key


def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            flash('Devi essere loggato per accedere a questa pagina', 'danger')
            return redirect(url_for('login'))
        return f(*args, **kwargs)

    return decorated_function


@app.route('/data', methods=['POST'])
def receive_data():
    data = request.get_json()

    # Print data to console
    print(f'Received data: {data}')

    # Save data in MongoDB
    insert_data_from_device(data)

    return jsonify({'message': 'Data saved successfully!'}), 200


# Endpoint for uploading a JSON file
@app.route('/upload-json', methods=['POST'])
@login_required
def upload_json():
    user_id = request.form['userId']
    file = request.files.get('file', None)
    result, status_code = process_uploaded_json(file, user_id)

    if status_code == 200:
        return redirect(url_for('dashboard'))
    else:
        return jsonify(result), status_code


@app.route('/upload-audio', methods=['POST'])
@login_required
def upload_audio():
    user_id = request.form['userId']
    file = request.files.get('file', None)
    result, status_code = process_uploaded_audio_file(file, user_id)

    if status_code == 200:
        return redirect(url_for('dashboard'))
    else:
        return jsonify(result), status_code


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        # Retrieve data from form
        username = request.form['username']
        password = request.form['password']

        # Check if user is in database
        user = get_user_data(username)

        if user and check_password_hash(user['password'], password):
            # Save user session
            session['user_id'] = str(user['_id'])
            session['lastName'] = str(user['lastName'])
            flash('Login effettuato con successo!', 'success')
            return redirect(url_for('dashboard'))
        else:
            flash('Nome utente o password errati', 'danger')

    return render_template('login.html')


@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        # Retrieve data from form
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        username = request.form['username']
        password = request.form['password']

        # Check if user is in database
        if get_user_data(username):
            flash('Nome utente già in uso', 'danger')
        else:
            # Cripta la password e salva l'utente nel database
            hashed_password = generate_password_hash(password)
            insert_user(first_name, last_name, username, hashed_password)
            flash('Registrazione completata, ora puoi accedere', 'success')
            return redirect(url_for('login'))

    return render_template('register.html')


@app.route('/logout')
@login_required
def logout():
    session.pop('user_id', None)
    flash('Logout effettuato con successo', 'success')
    return redirect(url_for('login'))


@app.route('/')
@login_required
def dashboard():
    # Get patient names
    patients = get_all_patients_data()

    patients_at_risk = get_patients_at_risk_data()
    print(patients_at_risk)

    return render_template('dashboard.html', patients=patients, patients_at_risk=patients_at_risk)


@app.route('/patient-data', methods=['GET'])
@login_required
def load_patient_data():
    patient_id = request.args.get('patient_id')
    selected_date = request.args.get('date')

    # Retrieve patient data using Patient ID
    patient_data = get_patient_data(patient_id)

    if patient_data:
        # Build hourly distance graphs
        distance_graph_data = build_hourly_distance_graph(patient_id, datetime.strptime(selected_date, '%Y-%m-%d'))
        places_graph_data = build_hourly_places_graph(patient_id, datetime.strptime(selected_date, '%Y-%m-%d'))
        screensum_graph_data = build_hourly_screensum_graph(patient_id, datetime.strptime(selected_date, '%Y-%m-%d'))
        screenusage_graph_data = build_hourly_screenusage_graph(patient_id, datetime.strptime(selected_date, '%Y-%m-%d'))
        light_amplitude_graph_data = build_hourly_light_amplitude_graph(patient_id, datetime.strptime(selected_date, '%Y-%m-%d'))
        acceleration_graph_data = build_hourly_acceleration_graph(patient_id, datetime.strptime(selected_date, '%Y-%m-%d'))
        conversation_graph_data = build_hourly_conversation_graph(patient_id, datetime.strptime(selected_date, '%Y-%m-%d'))
        amplitude_graph_data = build_hourly_audio_amplitude_graph(patient_id, datetime.strptime(selected_date, '%Y-%m-%d'))

        return jsonify({
            'success': True,
            'distance_graph_data': distance_graph_data,
            'screensum_graph_data': screensum_graph_data,
            'light_amplitude_graph_data': light_amplitude_graph_data,
            'acceleration_graph_data': acceleration_graph_data,
            'conversation_graph_data': conversation_graph_data,
            'amplitude_graph_data': amplitude_graph_data,
            'patient_data': patient_data,
            'screenusage_graph_data': screenusage_graph_data,
            'places_graph_data': places_graph_data,
        }), 200
    else:
        return jsonify({'error': 'Patient not found'}), 404


if __name__ == '__main__':
    scheduler.start()  # Start the scheduler
    app.run(debug=True, host='0.0.0.0', port=5000)
