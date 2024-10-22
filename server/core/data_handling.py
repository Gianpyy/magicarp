import json
import pandas as pd
from datetime import datetime
import pytz
from config.config import db_helper


def insert_data_from_device(data):
    """
    Inserts a single document of raw data received from a device into the database.

    :param data: The data document to be inserted.
    """
    db_helper.insert_raw_data(data)


def process_uploaded_json(file, user_id):
    """
    Processes the uploaded JSON file, performs validation, and stores its content into the database.

    :param file: The uploaded JSON file object.
    :param user_id: The user_id associated to the file.
    :return: A message and status code indicating success or failure.
    """
    if file is None:
        return {'message': 'No file part'}, 400  # No file uploaded.

    if file.filename == '':
        return {'message': 'No selected file'}, 400  # No file selected.

    if not file.filename.endswith('.json'):
        return {'message': 'Invalid file type, only JSON allowed'}, 400  # File type validation.

    if user_id == '':
        return {'message': 'UserId is empty'}, 400  # No userId selected

    try:
        # Load content from the JSON file
        data = json.load(file.stream)

        # Trim the measure type in the data and add userId
        for document in data:
            document['userId'] = user_id
            measure_type = document['data']['__type']
            measure_type_splitted = measure_type.split(".")
            document['data']['__type'] = measure_type_splitted[-1]  # Extracts the last part of the type.

        # Insert the data into MongoDB
        if isinstance(data, list):
            db_helper.insert_many_raw_data(data)  # Insert multiple documents.
        else:
            db_helper.insert_raw_data(data)  # Insert a single document.

        return {'message': 'File uploaded and data saved successfully!'}, 200  # Success message.

    except json.JSONDecodeError:
        return {'message': 'Invalid JSON file'}, 400  # Error in JSON decoding.


def process_uploaded_audio_file(file, user_id):
    """
    Processes the uploaded audio file, performs validation, and stores its content into the database.

    :param file: The uploaded audio file object.
    :param user_id: The user_id associated to the file.
    :return: A message and status code indicating success or failure.
    """
    if file is None:
        return {'message': 'No file part'}, 400  # No file uploaded.

    if file.filename == '':
        return {'message': 'No selected file'}, 400  # No file selected.

    if not file.filename.endswith('.mp4') or file.filename.endswith('.wav'):
        return {'message': 'Invalid file type, only MP4 or WAV allowed'}, 400  # File type validation.

    if user_id == '':
        return {'message': 'UserId is empty'}, 400  # No userId selected

    try:
        # Upload audio file using GridFS
        file_id = db_helper.upload_audio_file(file)

        # Store file information in raw data
        db_helper.store_file_information(user_id, file_id)

        return {'message': 'File uploaded and data saved successfully!'}, 200  # Success message.

    except json.JSONDecodeError:
        return {'message': 'Invalid JSON file'}, 400  # Error in JSON decoding.


def format_timestamp(microseconds, timezone="Europe/Rome"):
    """
    Converts a timestamp in microseconds to a human-readable date format (UTC).

    :param timezone: Timezone to which you want to convert the timestamp (default is 'Europe/Rome').
    :param microseconds: Timestamp in microseconds since epoch.
    :return: A formatted string representing the date and time.
    """
    timestamp_in_seconds = microseconds / 1_000_000  # Convert to seconds.
    utc_datetime = datetime.utcfromtimestamp(timestamp_in_seconds)  # Convert to UTC datetime.
    local_timezone = pytz.timezone(timezone)
    local_datetime = pytz.utc.localize(utc_datetime).astimezone(local_timezone)
    return local_datetime.strftime('%Y-%m-%d %H:%M:%S')  # Format to string.


def get_raw_location_data_for_hour(start_time, end_time, user_id):
    """
    Retrieves raw location data from the database for a given time range (hour).

    :param start_time: The start time as a datetime object.
    :param end_time: The end time as a datetime object.
    :param user_id: The ID of the user for whom we are requesting data.
    :return: A list of documents containing location data.
    """
    start_time_microseconds = int(start_time.timestamp() * 1_000_000)  # Convert start time to microseconds.
    end_time_microseconds = int(end_time.timestamp() * 1_000_000)  # Convert end time to microseconds.

    return db_helper.find_raw_location_data_by_hour(start_time_microseconds, end_time_microseconds, user_id)


def get_first_data_timestamp_for_hour(start_time, end_time, user_id):
    """
    Retrieves the first timestamp of the data for a specific user between the given start and end times.
    Converts the start and end times to microseconds since epoch before querying the database.

    Args:
        start_time (datetime): The start of the hour period.
        end_time (datetime): The end of the hour period.
        user_id (str): The ID of the user/device.

    Returns:
        str: The formatted timestamp of the first data point for the specified hour range.
    """
    start_time_microseconds = int(start_time.timestamp() * 1_000_000)  # Convert start time to microseconds.
    end_time_microseconds = int(end_time.timestamp() * 1_000_000)  # Convert end time to microseconds.

    return format_timestamp(
        db_helper.find_first_data_timestamp_for_hour(start_time_microseconds, end_time_microseconds, user_id)
    )


def get_last_data_timestamp_for_hour(start_time, end_time, user_id):
    start_time_microseconds = int(start_time.timestamp() * 1_000_000)  # Convert start time to microseconds.
    end_time_microseconds = int(end_time.timestamp() * 1_000_000)  # Convert end time to microseconds.

    return format_timestamp(
        db_helper.find_last_data_timestamp_for_hour(start_time_microseconds, end_time_microseconds, user_id)
    )


def get_raw_screen_data_for_hour(start_time, end_time, user_id):
    """
    Retrieves raw screen data for a specific user between the given start and end times.
    Converts the start and end times to microseconds since epoch before querying the database.

    Args:
        start_time (datetime): The start of the hour period.
        end_time (datetime): The end of the hour period.
        user_id (str): The ID of the user/device.

    Returns:
        list: A list of raw screen data records for the specified hour range.
    """
    start_time_microseconds = int(start_time.timestamp() * 1_000_000)  # Convert start time to microseconds.
    end_time_microseconds = int(end_time.timestamp() * 1_000_000)  # Convert end time to microseconds.

    return db_helper.find_raw_screen_data_by_hour(start_time_microseconds, end_time_microseconds, user_id)


def get_raw_light_data_for_hour(start_time, end_time, user_id):
    """
    Retrieves raw light data for a specific user between the given start and end times.
    Converts the start and end times to microseconds since epoch before querying the database.

    Args:
        start_time (datetime): The start of the hour period.
        end_time (datetime): The end of the hour period.
        user_id (str): The ID of the user/device.

    Returns:
        list: A list of raw light data records for the specified hour range.
    """
    start_time_microseconds = int(start_time.timestamp() * 1_000_000)  # Convert start time to microseconds.
    end_time_microseconds = int(end_time.timestamp() * 1_000_000)  # Convert end time to microseconds.

    return db_helper.find_raw_light_data_by_hour(start_time_microseconds, end_time_microseconds, user_id)


def get_raw_acceleration_data_for_hour(start_time, end_time, user_id):
    """
   Retrieves raw acceleration data for a specific user between the given start and end times.
   Converts the start and end times to microseconds since epoch before querying the database.

   Args:
       start_time (datetime): The start of the hour period.
       end_time (datetime): The end of the hour period.
       user_id (str): The ID of the user/device.

   Returns:
       list: A list of raw acceleration data records for the specified hour range.
   """
    start_time_microseconds = int(start_time.timestamp() * 1_000_000)  # Convert start time to microseconds.
    end_time_microseconds = int(end_time.timestamp() * 1_000_000)  # Convert end time to microseconds.

    return db_helper.find_raw_acceleration_data_by_hour(start_time_microseconds, end_time_microseconds, user_id)


def get_raw_audio_data_for_user(date, user_id):
    return db_helper.find_raw_audio_data_by_user(date, user_id)


def store_processed_distance_data(hour, date, distance, user_id):
    """
    Stores or updates processed location data in the database for a specific hour and date.

    :param hour: The hour for which data is being processed.
    :param date: The date of the processed data.
    :param distance: The calculated distance to store.
    :param user_id: The ID of the user for whom we are storing data.
    """
    db_helper.update_processed_distance_data(hour, date, distance, user_id)


def store_processed_places_data(hour, date, places, user_id):
    db_helper.update_processed_places_data(hour, date, places, user_id)


def store_processed_screen_data(hour, date, screentime, screen_uses, user_id):
    """
    Stores the processed screen time data for a specific user and hour on a given date.
    This function updates the database with the processed data.

    Args:
        hour (int): The hour of the day (0-23) for which the data is being stored.
        date (str): The date for which the screen time is processed.
        screentime (int): The total screen time for the specified hour (in minutes).
        screen_uses(int): The number of screen uses for the specified hour
        user_id (str): The ID of the user/device.

    Returns:
        None
    """
    db_helper.update_processed_screen_time(hour, date, screentime, user_id)
    db_helper.update_processed_screen_usage(hour, date, screen_uses, user_id)


def store_processed_light_data(hour, date, light_amplitude, user_id):
    """
   Stores the processed light amplitude data for a specific user and hour on a given date.
   This function updates the database with the processed data.

   Args:
       hour (int): The hour of the day (0-23) for which the data is being stored.
       date (str): The date for which the screen time is processed.
       light_amplitude (double): The light amplitude mean for the specified hour
       user_id (str): The ID of the user/device.

   Returns:
       None
   """
    db_helper.update_processed_light_data(hour, date, light_amplitude, user_id)


def store_processed_acceleration_data(hour, date, acceleration, user_id):
    """
   Stores the processed acceleration data for a specific user and hour on a given date.
   This function updates the database with the processed data.

   Args:
       hour (int): The hour of the day (0-23) for which the data is being stored.
       date (str): The date for which the screen time is processed.
       acceleration (double): The light amplitude mean for the specified hour
       user_id (str): The ID of the user/device.

   Returns:
       None
   """
    db_helper.update_processed_acceleration_data(hour, date, acceleration, user_id)


def store_processed_conversation_data(hour, date, conversation_duration, user_id):
    db_helper.update_processed_conversation_data(hour, date, conversation_duration, user_id)


def store_processed_volume_data(hour, date, audio_amplitude, user_id):
    db_helper.update_processed_volume_data(hour, date, audio_amplitude, user_id)


def get_processed_location_data_for_day(date, user_id):
    """
    Retrieves processed location data for a specific day from the database.

    :param user_id: The ID of the user for whom we are requesting data.
    :param date: The date for which processed data is requested.
    :return: A list of documents containing the processed data.
    """
    return list(db_helper.find_processed_location_data_by_day(date, user_id))


def get_processed_places_data_for_day(date, user_id):
    return list(db_helper.find_processed_places_data_by_day(date, user_id))


def get_processed_screen_data_for_day(date, user_id):
    """
    Retrieves the processed screen time data for a specific user on a given date.
    The data is returned as a list of records.

    Args:
        date (datetime): The date for which the processed screen time is requested.
        user_id (str): The ID of the user/device.

    Returns:
        list: A list of processed screen data records for the specified date.
    """
    return list(db_helper.find_processed_screen_data_by_day(date, user_id))


def get_processed_screenusage_data_for_day(date, user_id):
    return list(db_helper.find_processed_screenusage_data_by_day(date, user_id))


def get_processed_light_data_for_day(date, user_id):
    """
    Retrieves the processed light amplitude data for a specific user on a given date.
    The data is returned as a list of records.

    Args:
        date (datetime): The date for which the processed screen time is requested.
        user_id (str): The ID of the user/device.

    Returns:
        list: A list of processed screen data records for the specified date.
    """
    return list(db_helper.find_processed_light_data_by_day(date, user_id))


def get_processed_acceleration_data_for_day(date, user_id):
    """
    Retrieves the processed acceleration data for a specific user on a given date.
    The data is returned as a list of records.

    Args:
        date (datetime): The date for which the processed screen time is requested.
        user_id (str): The ID of the user/device.

    Returns:
        list: A list of processed screen data records for the specified date.
    """
    return list(db_helper.find_processed_acceleration_data_by_day(date, user_id))


def get_processed_conversation_data_for_day(date, user_id):
    return list(db_helper.find_processed_conversation_data_by_day(date, user_id))


def get_processed_volume_data_for_day(date, user_id):
    return list(db_helper.find_processed_volume_data_by_day(date, user_id))


def convert_raw_location_data_to_dataframe(raw_data):
    """
    Converts raw location data into a pandas DataFrame for easier manipulation and analysis.

    :param raw_data: A list of raw location data documents.
    :return: A pandas DataFrame containing latitude, longitude, and timestamp data, or None if no data.
    """
    latitudes = []
    longitudes = []
    timestamps = []

    for document in raw_data:
        latitudes.append(document['data']['latitude'])
        longitudes.append(document['data']['longitude'])
        timestamps.append(format_timestamp(document['sensorStartTime']))  # Convert sensor time to readable format.

    if latitudes and longitudes:
        user_id = raw_data[0]['userId']  # Get user id from raw_data
        return pd.DataFrame({
            'userId': user_id,
            'Latitude': latitudes,
            'Longitude': longitudes,
            'Timestamp': pd.to_datetime(timestamps)  # Convert timestamps to pandas datetime format.
        })

    return None  # Return None if there is no valid data.


def convert_raw_screen_data_to_dataframe(raw_data):
    """
    Converts raw screen event data into a pandas DataFrame for easier analysis and manipulation.
    Extracts screen event types and timestamps from the raw data and formats them appropriately.

    Args:
        raw_data (list): A list of raw screen event data records.

    Returns:
        pd.DataFrame or None: A pandas DataFrame containing userId, ScreenEvent, and Timestamp columns,
                              or None if the raw data is empty.
    """
    screenevents = []
    timestamps = []

    for document in raw_data:
        screenevents.append(document['data']['screenEvent'])
        timestamps.append(format_timestamp(document['sensorStartTime']))  # Convert sensor time to readable format.

    if screenevents:
        user_id = raw_data[0]['userId']  # Get user id from raw_data
        return pd.DataFrame({
            'userId': user_id,
            'ScreenEvent': screenevents,
            'Timestamp': pd.to_datetime(timestamps)  # Convert timestamps to pandas datetime format.
        })

    return None  # Return None if there is no valid data.


def convert_raw_light_data_to_dataframe(raw_data):
    """
    Converts raw light amplitude data into a pandas DataFrame for easier analysis and manipulation.
    Extracts screen event types and timestamps from the raw data and formats them appropriately.

    Args:
        raw_data (list): A list of raw light data records.

    Returns:
        pd.DataFrame or None: A pandas DataFrame containing userId, ScreenEvent, and Timestamp columns,
                              or None if the raw data is empty.
    """
    light_amplitudes = []
    timestamps = []

    for document in raw_data:
        light_amplitudes.append(document['data']['meanLux'])
        timestamps.append(format_timestamp(document['sensorStartTime']))

    if light_amplitudes:
        user_id = raw_data[0]['userId']  # Get user id from raw data
        return pd.DataFrame({
            'userId': user_id,
            'Light Amplitude': light_amplitudes,
            'Timestamp': pd.to_datetime(timestamps)
        })

    return None  # Return None if there is no valid data.


def convert_raw_acceleration_data_to_dataframe(raw_data):
    """
    Converts raw acceleration data into a pandas DataFrame for easier analysis and manipulation.
    Extracts screen event types and timestamps from the raw data and formats them appropriately.

    Args:
        raw_data (list): A list of raw acceleration data records.

    Returns:
        pd.DataFrame or None: A pandas DataFrame containing userId, ScreenEvent, and Timestamp columns,
                              or None if the raw data is empty.
    """
    accelerations = []
    timestamps = []

    for document in raw_data:
        accelerations.append(document['data']['avgResultAcceleration'])
        timestamps.append(format_timestamp(document['sensorStartTime']))

    if accelerations:
        user_id = raw_data[0]['userId']  # Get user id from raw data
        return pd.DataFrame({
            'userId': user_id,
            'Acceleration': accelerations,
            'Timestamp': pd.to_datetime(timestamps)
        })

    return None  # Return None if there is no valid data.


def get_all_patients_data():
    """
    Retrieves all patient data from the database.

    :return: A cursor or list of patient data documents.
    """
    return db_helper.find_all_patients_data()


def get_patients_at_risk_data():

    return list(db_helper.find_patients_at_risk())


def get_patient_data(patient_id):
    """
    Retrieves data for a specific patient from the database based on their patient ID.

    :param patient_id: The user ID of the patient.
    :return: The document containing the patient's data.
    """
    return db_helper.find_patient_data_by_id(patient_id)


def get_user_data(username):
    return db_helper.find_user_data(username)


def insert_user(fist_name, last_name, username, password):
    return db_helper.insert_user(fist_name, last_name, username, password)
