from datetime import timedelta
import numpy as np
import pandas as pd
from geopy.distance import great_circle
from sklearn.cluster import DBSCAN


def dbscan_filter(coordinates, eps=0.00001, min_samples=5):
    """
    Applies the DBSCAN clustering algorithm to filter out noisy GPS points.
    The algorithm clusters points based on spatial proximity, and points
    labeled as noise (with label -1) are removed.

    :param coordinates: A numpy array of GPS coordinates (latitude, longitude).
    :param eps: The maximum distance between two points for them to be considered as in the same neighborhood.
    :param min_samples: The minimum number of points required to form a dense region (i.e., a cluster).
    :return: A numpy array of filtered points, excluding noise points.
    """
    # Initialize DBSCAN with given epsilon and minimum sample parameters
    dbscan = DBSCAN(eps=eps, min_samples=min_samples)

    # Perform DBSCAN clustering on the coordinates
    labels = dbscan.fit_predict(coordinates)

    # Filter out noisy points (labeled as -1)
    filtered_points = coordinates[labels != -1]
    filtered_labels = labels[labels != -1]

    # Return the filtered (non-noisy) coordinates
    return filtered_points, filtered_labels


def calculate_places_visited(labels):
    """
    Calculates the number of distinct places visited based on DBSCAN cluster labels.

    :param labels: An array of cluster labels for GPS points.
    :return: The number of unique clusters (places visited).
    """
    # Find unique cluster labels (each cluster represents a place)
    unique_clusters = set(labels)

    # Return the number of unique clusters
    return len(unique_clusters)


def calculate_total_distance(points):
    """
    Calculates the total distance traveled by summing up the great-circle distance
    between consecutive points. Great-circle distance takes into account the curvature of the Earth.

    :param points: A list of GPS points (latitude, longitude).
    :return: The total distance traveled in kilometers.
    """
    total_distance = 0
    # Convert points to tuples for compatibility with the great_circle function
    points_list = [tuple(point) for point in points]

    # Loop through the points and calculate distance between consecutive pairs
    for i in range(len(points_list) - 1):
        # Add the distance between consecutive points to the total distance
        total_distance += great_circle(points_list[i], points_list[i + 1]).kilometers

    # Return the total distance in kilometers
    return total_distance


def calculate_hourly_distance_and_places(df):
    """
    Calculates the total distance traveled and the number of places visited
    during a specific hour by first applying DBSCAN to remove noise, and then
    summing up the distance between filtered points.

    :param df: A pandas DataFrame containing 'Latitude' and 'Longitude' columns for the points in a given hour.
    :return: A tuple containing:
             1. The total distance traveled in kilometers for that hour.
             2. The number of distinct places visited in that hour.
    """
    # Extract latitude and longitude coordinates from the DataFrame as a numpy array
    hourly_coordinates = np.array(list(zip(df['Latitude'], df['Longitude'])))

    # If there are fewer than 2 points, no distance or places can be calculated
    if len(hourly_coordinates) < 2:
        return 0, 0

    # Apply DBSCAN to filter out noisy points and get cluster labels
    filtered_coordinates, filtered_labels = dbscan_filter(hourly_coordinates)

    # If there are at least 2 valid (non-noisy) points, calculate the total distance
    if len(filtered_coordinates) > 1:
        total_distance = calculate_total_distance(filtered_coordinates)
        places_visited = calculate_places_visited(filtered_labels)
        return total_distance, places_visited

    # If no valid points or only one point remains after filtering, return 0 for both
    return 0, 0


first_ever_measure = None  # Timestamp of the first measure of the day
has_measure_been_saved = False  # Has measure been saved?
is_first_measure = True  # Is this the first measure?


def calculate_hourly_screensum(df, start_time, end_time, first_ever_measure_timestamp=None):
    """
    Calculates the total screen-on time for a given hour based on screen event data in the DataFrame.
    This function processes a series of screen events ("SCREEN_ON", "SCREEN_OFF", "SCREEN_UNLOCKED") and
    computes the time the screen was on within the specified time range.

    Args:
        df (pd.DataFrame): A DataFrame containing screen events with timestamps.
        start_time (datetime): The start time of the hour.
        end_time (datetime): The end time of the hour.
        first_ever_measure_timestamp (datetime, optional): The timestamp of the first-ever screen measure, if available.

    Returns:
        float: The total screen-on time in minutes for the specified time range.
    """
    # Convert all timestamps
    if df['Timestamp'].dtype == 'object':
        df['Timestamp'] = pd.to_datetime(df['Timestamp'], format='%Y-%m-%d %H:%M:%S')

    # Debug: Check conversion
    print("Start Time:", start_time)
    print("End Time:", end_time)
    print("DataFrame Timestamps:")
    print(df['Timestamp'])

    # Save first ever measure
    global first_ever_measure
    global has_measure_been_saved
    global is_first_measure
    if first_ever_measure_timestamp is not None and not has_measure_been_saved:
        first_ever_measure = first_ever_measure_timestamp
        has_measure_been_saved = True

    # If dataframe has only one element, check the type of the element
    if len(df) == 1:
        if df.iloc[0]['ScreenEvent'] == "SCREEN_OFF":
            if is_first_measure:
                is_first_measure = False
                return df.iloc[0]['Timestamp'] - first_ever_measure, 1
            else:
                return (df.iloc[0][
                            'Timestamp'] - start_time) / 60, 1  # If the value is OFF, return time between start and the measure
        else:
            return (end_time - df.iloc[0]['Timestamp']) / 60, 1  # Else, return time between measure and the end time

    # Dataframe has 2 or more elements
    else:
        is_screen_on = None
        last_time_screen_was_on = None
        total_time = timedelta(0)
        num_usages = 0

        for index, row in df.iterrows():
            num_usages += 1
            event_time = row['Timestamp']
            print(f"Processing row {index}, Event: {row['ScreenEvent']}, Timestamp: {event_time}")

            if row['ScreenEvent'] == "SCREEN_OFF":
                if is_screen_on is None:
                    # First value is SCREEN_OFF
                    is_screen_on = False
                    if is_first_measure:
                        time_on = event_time - first_ever_measure
                    else:
                        time_on = event_time - start_time
                    total_time += time_on
                    print(f"Screen OFF: Adding {time_on.total_seconds() / 60} minutes")
                elif is_screen_on:
                    is_screen_on = False
                    time_on = event_time - last_time_screen_was_on
                    total_time += time_on
                    print(f"Screen OFF: Adding {time_on.total_seconds() / 60} minutes")

            elif row['ScreenEvent'] == "SCREEN_ON":
                is_screen_on = True
                last_time_screen_was_on = row['Timestamp']
                print(f"Screen ON at {event_time}")

            elif row['ScreenEvent'] == "SCREEN_UNLOCKED":
                if not is_screen_on:
                    is_screen_on = True
                    last_time_screen_was_on = row['Timestamp']
                    print(f"Screen UNLOCKED at {event_time}")

        if is_screen_on and last_time_screen_was_on is not None:
            # Last value is SCREEN_ON or SCREEN_UNLOCKED
            time_on = end_time - last_time_screen_was_on
            total_time += time_on
            print(f"Screen still ON at end time: Adding {time_on.total_seconds() / 60} minutes")

    print(f"Total calculated time: {total_time.total_seconds() / 60} minutes")
    return total_time.total_seconds() / 60, num_usages  # Return time in minutes


def calculate_hourly_light_amplitude(df):
    """
    Calculates the light amplitude mean for a given hour based on light data in the DataFrame.

    Args:
        df (pd.DataFrame): A DataFrame containing screen events with timestamps.

    Returns:
        float: The light amplitude mean in lux for the specified time range.
    """
    if df is None:
        return 0

    total_light_amplitude = 0.0
    for index, row in df.iterrows():
        light_amplitude = row['Light Amplitude']
        total_light_amplitude += light_amplitude

    number_of_elements = len(df)
    return total_light_amplitude / number_of_elements


def calculate_hourly_acceleration(df):
    """
    Calculates the acceleration mean for a given hour based on screen event data in the DataFrame.

    Args:
        df (pd.DataFrame): A DataFrame containing screen events with timestamps.
    Returns:
        float: The acceleration mean in m/s^2 for the specified time range.
    """
    if df is None:
        return 0

    total_acceleration = 0.0
    for index, row in df.iterrows():
        acceleration = row['Acceleration']
        total_acceleration += acceleration

    number_of_elements = len(df)
    return total_acceleration / number_of_elements
