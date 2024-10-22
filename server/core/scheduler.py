import io
import os
import time
import librosa
import numpy as np
from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime, timedelta
import logging
from pydub import AudioSegment, silence
from core.data_handling import get_raw_location_data_for_hour, store_processed_distance_data, \
    convert_raw_location_data_to_dataframe, get_all_patients_data, get_raw_screen_data_for_hour, \
    convert_raw_screen_data_to_dataframe, store_processed_screen_data, get_first_data_timestamp_for_hour, \
    get_raw_light_data_for_hour, convert_raw_light_data_to_dataframe, store_processed_light_data, \
    convert_raw_acceleration_data_to_dataframe, get_raw_acceleration_data_for_hour, store_processed_acceleration_data, \
    get_raw_audio_data_for_user, store_processed_conversation_data, store_processed_volume_data, \
    store_processed_places_data
from core.measures_calculation import calculate_hourly_screensum, \
    calculate_hourly_light_amplitude, calculate_hourly_acceleration, calculate_hourly_distance_and_places

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


# Calculate hourly distance and store it into the database
def store_hourly_distances():
    try:
        logging.info("Starting hourly distance calculation...")

        # Get the start of the current day
        # current_day = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
        # TEST: Get start of day
        current_day = datetime.strptime("Sunday 14 July 2024 10:53:19.017", "%A %d %B %Y %H:%M:%S.%f").replace(hour=0,
                                                                                                               minute=0,
                                                                                                               second=0,
                                                                                                               microsecond=0)
        logging.info(f"Current day: {current_day}")

        # Get all patients data
        patients_data = get_all_patients_data()

        for patient in patients_data:
            user_id = patient['userId']
            for hour in range(24):
                # Get start and end time of the hour
                start_time = current_day + timedelta(hours=hour)
                end_time = start_time + timedelta(hours=1)

                # Get raw data and create a Dataframe
                raw_data = get_raw_location_data_for_hour(start_time, end_time, user_id)
                df = convert_raw_location_data_to_dataframe(raw_data)

                # Store data into the database
                if df is not None:
                    hourly_distance, places_visited = calculate_hourly_distance_and_places(df)
                    store_processed_distance_data(hour, current_day.replace(hour=hour), hourly_distance, user_id)
                    store_processed_places_data(hour, current_day.replace(hour=hour), places_visited, user_id)
                    logging.info(f"Stored distance data for user {user_id} hour {hour}")
                else:
                    logging.warning(f"No location data found for user {user_id} hour {hour}")

        logging.info("Hourly distance calculation completed.")

    except Exception as e:
        logging.error(f"Error during hourly distance calculation: {str(e)}")


def store_hourly_screensum():
    try:
        logging.info("Starting hourly screen sum calculation...")

        # Get the start of the current day
        # current_day = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
        # TEST: Get start of day
        current_day = datetime.strptime("Sunday 14 July 2024 10:53:19.017", "%A %d %B %Y %H:%M:%S.%f").replace(hour=0,
                                                                                                               minute=0,
                                                                                                               second=0,
                                                                                                               microsecond=0)
        logging.info(f"Current day: {current_day}")

        # Get all patients data
        patients_data = get_all_patients_data()
        first_measure = None
        for patient in patients_data:
            user_id = patient['userId']
            for hour in range(24):
                # Get start and end time of the hour
                start_time = current_day + timedelta(hours=hour)
                end_time = start_time + timedelta(hours=1)

                logging.info(f"Processing for user {user_id} between {start_time} and {end_time}")

                # Get raw data and create a Dataframe
                raw_data = get_raw_screen_data_for_hour(start_time, end_time, user_id)
                df = convert_raw_screen_data_to_dataframe(raw_data)

                # Debug: print retrieved raw data
                logging.info(f"Raw screen data for user {user_id}, hour {hour}: {raw_data}")

                # Store data into the database
                if df is not None:
                    if first_measure is None:
                        first_measure = datetime.strptime(
                            get_first_data_timestamp_for_hour(start_time, end_time, user_id),
                            '%Y-%m-%d %H:%M:%S'
                        )
                        logging.info(f"First measure timestamp: {first_measure}")

                    logging.info(f"DataFrame for user {user_id}, hour {hour}:")
                    logging.info(df)
                    hourly_screensum, hourly_number_of_uses = calculate_hourly_screensum(df, start_time, end_time,
                                                                                         first_measure)
                    store_processed_screen_data(hour, current_day.replace(hour=hour), hourly_screensum,
                                                hourly_number_of_uses, user_id)
                    logging.info(f"Stored screen sum data for user {user_id} hour {hour}")
                else:
                    logging.warning(f"No screen data found for user {user_id} hour {hour}")

        logging.info("Hourly screen sum calculation completed.")

    except Exception as e:
        logging.error(f"Error during hourly screen sum calculation: {str(e)}")


def store_hourly_light_amplitude():
    try:
        logging.info("Starting hourly light amplitude calculation...")

        # Get the start of the current day
        # current_day = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
        # TEST: Get start of day
        current_day = datetime.strptime("Sunday 14 July 2024 10:53:19.017", "%A %d %B %Y %H:%M:%S.%f").replace(hour=0,
                                                                                                               minute=0,
                                                                                                               second=0,
                                                                                                               microsecond=0)
        logging.info(f"Current day: {current_day}")

        # Get all patients data
        patients_data = get_all_patients_data()

        for patient in patients_data:
            user_id = patient['userId']
            for hour in range(24):
                # Get start and end time of the hour
                start_time = current_day + timedelta(hours=hour)
                end_time = start_time + timedelta(hours=1)

                # Get raw data and create a Dataframe
                raw_data = get_raw_light_data_for_hour(start_time, end_time, user_id)
                df = convert_raw_light_data_to_dataframe(raw_data)

                # Store data into the database
                if df is not None:
                    hourly_light_amplitude = calculate_hourly_light_amplitude(df)
                    store_processed_light_data(hour, current_day.replace(hour=hour), hourly_light_amplitude, user_id)
                    logging.info(f"Stored light amplitude data for user {user_id} hour {hour}")
                else:
                    logging.warning(f"No light data found for user {user_id} hour {hour}")

        logging.info("Hourly light amplitude calculation completed.")

    except Exception as e:
        logging.error(f"Error during hourly light amplitude calculation: {str(e)}")


def store_hourly_acceleration():
    try:
        logging.info("Starting hourly acceleration calculation...")

        # Get the start of the current day
        # current_day = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
        # TEST: Get start of day
        current_day = datetime.strptime("Sunday 14 July 2024 10:53:19.017", "%A %d %B %Y %H:%M:%S.%f").replace(hour=0,
                                                                                                               minute=0,
                                                                                                               second=0,
                                                                                                               microsecond=0)
        logging.info(f"Current day: {current_day}")

        # Get all patients data
        patients_data = get_all_patients_data()

        for patient in patients_data:
            user_id = patient['userId']
            for hour in range(24):
                # Get start and end time of the hour
                start_time = current_day + timedelta(hours=hour)
                end_time = start_time + timedelta(hours=1)

                # Get raw data and create a Dataframe
                raw_data = get_raw_acceleration_data_for_hour(start_time, end_time, user_id)
                df = convert_raw_acceleration_data_to_dataframe(raw_data)

                # Store data into the database
                if df is not None:
                    hourly_acceleration = calculate_hourly_acceleration(df)
                    store_processed_acceleration_data(hour, current_day.replace(hour=hour), hourly_acceleration,
                                                      user_id)
                    logging.info(f"Stored light amplitude data for user {user_id} hour {hour}")
                else:
                    logging.warning(f"No acceleration data found for user {user_id} hour {hour}")

        logging.info("Hourly acceleration calculation completed.")

    except Exception as e:
        logging.error(f"Error during acceleration amplitude calculation: {str(e)}")


def store_hourly_conversation_and_volume():
    try:
        logging.info("Starting hourly conversation and volume calculation...")

        # Get the start of the current day
        # current_day = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
        # TEST: Get start of day
        current_day = datetime.strptime("Sunday 14 July 2024 10:53:19.017", "%A %d %B %Y %H:%M:%S.%f").replace(hour=0,
                                                                                                               minute=0,
                                                                                                               second=0,
                                                                                                               microsecond=0)
        logging.info(f"Current day: {current_day}")

        # Get all patients data
        patients_data = get_all_patients_data()

        for patient in patients_data:
            user_id = patient['userId']

            # Get raw data
            audio_data = get_raw_audio_data_for_user(current_day, user_id)

            # Get audio file from audio data
            audio_file = audio_data['data']['audioFile']

            # Read file in memory
            audio_file_data = io.BytesIO(audio_file.read())

            # Load audio in pydub
            audio = AudioSegment.from_file(audio_file_data, format="mp4")

            # Calculate number of 1hr audio segments
            one_hour_in_ms = 60 * 60 * 1000  # 3.600.000 ms
            total_length = len(audio)
            num_segments = total_length // one_hour_in_ms

            # Definisci il percorso del file
            output_directory = "../tmp"
            output_path = os.path.join(output_directory, "segment.wav")

            # Crea la cartella se non esiste
            if not os.path.exists(output_directory):
                os.makedirs(output_directory)

            # Divide audio in 1h segments
            start_time = audio_data['data']['date']
            current_hour = start_time.hour
            for i in range(num_segments + 1):
                if i + current_hour >= 24:
                    break

                start_time = i * one_hour_in_ms
                end_time = start_time + one_hour_in_ms
                segment = audio[start_time:end_time]

                # Salva l'audio in formato wav (necessario per l'elaborazione successiva)
                segment.export(output_path, format="wav")

                # Carica l'audio
                segment_wav = AudioSegment.from_file(output_path)

                # Carica l'audio (solo i dati)
                y, sr = librosa.load(output_path, sr=None)

                # Calculate conversation duration using pydub
                non_silent_segments = silence.detect_nonsilent(segment, min_silence_len=1000, silence_thresh=-50)
                total_conversation_duration_seconds = sum((end - start) for start, end in non_silent_segments) / 1000
                total_conversation_duration_minutes = total_conversation_duration_seconds / 60

                # Calcola l'ampiezza media
                amplitude_mean = float(np.mean(np.abs(y)))

                # Store data in database
                logging.info(f"Storing {total_conversation_duration_minutes} minute long conversation segment "
                             f"for hour {current_hour}")
                store_processed_conversation_data(current_hour,
                                                  current_day.replace(hour=current_hour),
                                                  total_conversation_duration_minutes,
                                                  user_id)

                store_processed_volume_data(current_hour,
                                            current_day.replace(hour=current_hour),
                                            amplitude_mean,
                                            user_id)

                # Increment current hour
                current_hour += 1
        logging.info("Hourly conversation and volume calculation completed.")

    except Exception as e:
        logging.error(f"Error during conversation and volume calculation: {str(e)}")


# Setup scheduler
scheduler = BackgroundScheduler()
scheduler.add_job(store_hourly_distances, 'cron', hour=0, minute=0)  # Scheduled at midnight
scheduler.add_job(store_hourly_screensum, 'cron', hour=0, minute=0)  # Scheduled at midnight
scheduler.add_job(store_hourly_light_amplitude, 'cron', hour=0, minute=0)  # Scheduled at midnight
scheduler.add_job(store_hourly_acceleration, 'cron', hour=0, minute=0)  # Scheduled at midnight
scheduler.add_job(store_hourly_conversation_and_volume, 'cron', hour=0, minute=0)  # Scheduled at midnight
scheduler.start()
