import logging
from datetime import datetime

import numpy as np
import plotly.express as px
from core.data_handling import get_processed_location_data_for_day, get_processed_screen_data_for_day, \
    get_processed_light_data_for_day, get_processed_acceleration_data_for_day, get_processed_conversation_data_for_day, \
    get_processed_volume_data_for_day, get_processed_screenusage_data_for_day, get_processed_places_data_for_day


def generate_hourly_graph(hours, values, title, x_label, y_label):
    """
    Generates a graph for hourly data with markers and lines.

    :param hours: List of hours (x-axis).
    :param values: List of values (y-axis) corresponding to each hour.
    :param title: Title of the graph.
    :param x_label: Label for the x-axis.
    :param y_label: Label for the y-axis.
    :return: A dictionary representation of the Plotly figure.
    """
    # Generate graph
    fig = px.line(x=hours, y=values, labels={'x': x_label, 'y': y_label},
                  title=title, range_x=[0, 23], range_y=[0, max(values, default=0) + 1])

    # Modify graph style
    for trace in fig.data:
        trace.update(mode='lines+markers')

    # Convert to dictionary and ensure numpy arrays are converted to lists
    fig_dict = fig.to_dict()

    for trace in fig_dict['data']:
        trace['x'] = np.array(trace['x']).tolist() if isinstance(trace['x'], np.ndarray) else trace['x']
        trace['y'] = np.array(trace['y']).tolist() if isinstance(trace['y'], np.ndarray) else trace['y']

    return fig_dict


def build_hourly_distance_graph(patient_id, date=datetime.today()):
    """
    Generates a graph displaying the total distance traveled for each hour of the day.
    If no data is available for a specific hour, a placeholder graph with zero distances is generated.

    :param date: The date (in datetime format) for which the patient's data is being requested.
    :param patient_id: The ID of the patient for whom we are requesting data.
    :return: A Plotly figure object containing the generated graph.
    """
    # Retrieve processed data from database
    logging.info(f"Retrieving distance data for userID:{patient_id} in date: {date}")
    processed_data = get_processed_location_data_for_day(date, patient_id)
    logging.info(f"Data retrieved: {processed_data}")

    # Extract data for graphs
    hours, distances = extract_data(processed_data)

    return generate_hourly_graph(hours, distances,
                                 title="Distanza totale percorsa per ogni ora",
                                 x_label="Ora del giorno", y_label="Distanza totale (km)")


def build_hourly_places_graph(patient_id, date=datetime.today()):
    # Retrieve processed data from database
    logging.info(f"Retrieving distance data for userID:{patient_id} in date: {date}")
    processed_data = get_processed_places_data_for_day(date, patient_id)
    logging.info(f"Data retrieved: {processed_data}")

    # Extract data for graphs
    hours, distances = extract_data(processed_data)

    return generate_hourly_graph(hours, distances,
                                 title="Numero di luoghi visitati per ogni ora",
                                 x_label="Ora del giorno", y_label="Numero di luoghi visitati")


def build_hourly_screensum_graph(patient_id, date=datetime.today()):
    """
    Builds a graph showing the total phone usage (screen time) per hour for a specific patient on the current day.
    If no data is available, it generates a placeholder graph with zero values for all 24 hours.

    Args:
        patient_id (str): The ID of the patient/device.
        date (datetime): The date for which the patient's data is being requested.

    Returns:
        dict: A dictionary representation of the Plotly graph figure, with numpy arrays converted to lists.
    """
    # Retrieve processed data from database
    logging.info(f"Retrieving screen usage data for userID:{patient_id} in date: {date}")
    processed_data = get_processed_screen_data_for_day(date, patient_id)
    logging.info(f"Data retrieved: {processed_data}")

    # Extract data for graphs
    hours, screentimes = extract_data(processed_data)

    return generate_hourly_graph(hours, screentimes,
                                 title='Utilizzo del telefono per ogni ora',
                                 x_label='Ora del giorno', y_label='Utilizzo telefono (minuti)')


def build_hourly_screenusage_graph(patient_id, date=datetime.today()):
    logging.info(f"Retrieving screen usage data for userID:{patient_id} in date: {date}")
    processed_data = get_processed_screenusage_data_for_day(date, patient_id)
    logging.info(f"Data retrieved: {processed_data}")

    # Extract data for graphs
    hours, screentimes = extract_data(processed_data)

    return generate_hourly_graph(hours, screentimes,
                                 title='Numero di utilizzi del telefono per ogni ora',
                                 x_label='Ora del giorno', y_label='Numero di utilizzi')


def build_hourly_light_amplitude_graph(patient_id, date=datetime.today()):
    """
    Builds a graph showing the mean light amplitude per hour for a specific patient on the current day.
    If no data is available, it generates a placeholder graph with zero values for all 24 hours.

    Args:
        patient_id (str): The ID of the patient/device.
        date (datetime): The date for which the patient's data is being requested.

    Returns:
        dict: A dictionary representation of the Plotly graph figure, with numpy arrays converted to lists.
    """
    # Retrieve processed data from database
    logging.info(f"Retrieving light amplitude data for userID:{patient_id} in date: {date}")
    processed_data = get_processed_light_data_for_day(date, patient_id)
    logging.info(f"Data retrieved: {processed_data}")

    # Extract data for graphs
    hours, light_amplitudes = extract_data(processed_data)

    return generate_hourly_graph(hours, light_amplitudes,
                                 title='Ampiezza media della luce per ogni ora',
                                 x_label='Ora del giorno', y_label='Ampiezza media della luce (lux)')


def build_hourly_acceleration_graph(patient_id, date=datetime.today()):
    """
    Builds a graph showing the mean acceleration per hour for a specific patient on the current day.
    If no data is available, it generates a placeholder graph with zero values for all 24 hours.

    Args:
        patient_id (str): The ID of the patient/device.
        date (datetime): The date for which the patient's data is being requested.

    Returns:
        dict: A dictionary representation of the Plotly graph figure, with numpy arrays converted to lists.
    """
    # Retrieve processed data from database
    logging.info(f"Retrieving acceleration data for userID:{patient_id} in date: {date}")
    processed_data = get_processed_acceleration_data_for_day(date, patient_id)
    logging.info(f"Data retrieved: {processed_data}")

    # Extract data for graphs
    hours, accelerations = extract_data(processed_data)

    return generate_hourly_graph(hours, accelerations,
                                 title="Accelerazione media dell'accelerometro per ogni ora",
                                 x_label='Ora del giorno', y_label='Accelerazione media (m/s<sup>2</sup>)')


def build_hourly_conversation_graph(patient_id, date=datetime.today()):
    # Retrieve processed data from database
    logging.info(f"Retrieving conversation data for userID:{patient_id} in date: {date}")
    processed_data = get_processed_conversation_data_for_day(date, patient_id)
    logging.info(f"Data retrieved: {processed_data}")

    # Extract data for graphs
    hours, conversation = extract_data(processed_data)

    return generate_hourly_graph(hours, conversation,
                                 title="Durata delle conversazioni per ogni ora",
                                 x_label='Ora del giorno', y_label='Durata delle conversazioni (minuti)')


def build_hourly_audio_amplitude_graph(patient_id, date=datetime.today()):
    # Retrieve processed data from database
    logging.info(f"Retrieving conversation data for userID:{patient_id} in date: {date}")
    processed_data = get_processed_volume_data_for_day(date, patient_id)
    logging.info(f"Data retrieved: {processed_data}")

    # Extract data for graphs
    hours, audio_amplitudes = extract_data(processed_data)

    return generate_hourly_graph(hours, audio_amplitudes,
                                 title="Ampiezza audio per ogni ora",
                                 x_label='Ora del giorno', y_label='Ampiezza audio (dB)')


def extract_data(processed_data):
    # Check if there's data
    if processed_data:
        extacted_data = {}
        for document in processed_data:
            hour = document['hour']
            hourly_data = document['value']
            extacted_data[hour] = hourly_data

        hours = list(range(24))
        data = [extacted_data.get(h, 0) for h in hours]

    else:
        # Fake data to make placeholder graph
        hours = list(range(24))
        data = [0] * 24

    return hours, data
