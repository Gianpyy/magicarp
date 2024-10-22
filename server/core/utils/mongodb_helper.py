from datetime import datetime, timedelta
import gridfs
from pymongo import MongoClient

COLLECTION_PROCESSED = 'processed-data'
COLLECTION_RAW = 'raw-data'
COLLECTION_TEST = 'test'
COLLECTION_PATIENT = 'patient-data'
COLLECTION_MEDIC = 'medic-data'
COLLECTION_PREDICTION = 'prediction-data'
COLLECTED_AUDIO_DELAY = 20


class MongoDBHelper:
    """
    This class provides a helper for interacting with MongoDB, focusing on multiple collections
    such as raw data, patient data, and processed data.
    """

    def __init__(self, db_name):
        """
        Initializes the MongoDBHelper instance by connecting to the MongoDB server
        and selecting the specified database.

        :param db_name: The name of the database to connect to.
        """
        self.client = MongoClient('mongodb://localhost:27017/')  # Connects to the MongoDB server.
        self.db = self.client[db_name]  # Selects the database.

    def insert_raw_data(self, data):
        """
        Inserts a single raw data document into the raw data collection.

        :param data: The document to be inserted.
        :return: The result of the insert operation.
        """
        collection = self.db[COLLECTION_RAW]  # Selects the raw data collection.
        return collection.insert_one(data)  # Inserts one document.

    def insert_many_raw_data(self, data):
        """
        Inserts multiple raw data documents into the raw data collection.

        :param data: A list of documents to be inserted.
        :return: The result of the insert operation.
        """
        collection = self.db[COLLECTION_RAW]  # Selects the raw data collection.
        return collection.insert_many(data)  # Inserts multiple documents.

    def upload_audio_file(self, file):
        # Initialize GridFS
        fs = gridfs.GridFS(self.db)

        # Upload audio in GridFS
        file_id = fs.put(file, filename=file.filename)

        return file_id

    def store_file_information(self, user_id, file_id):
        # Calculate sensor time for audio measure
        fist_measure_sensor_time = self.db[COLLECTION_RAW].find().next()['sensorStartTime']
        fist_measure_date_time = datetime.fromtimestamp(fist_measure_sensor_time / 1_000_000)
        fist_measure_date_time += timedelta(seconds=20)
        measure_sensor_time = int(fist_measure_date_time.timestamp() * 1_000_000)

        # Store data
        collection = self.db[COLLECTION_RAW]
        file_data = {
            "__type": "audio",
            "fileId": file_id,
            "date": fist_measure_date_time,
        }

        data = {
            "sensorStartTime": measure_sensor_time,
            "data": file_data,
            "userId": user_id,
        }

        return collection.insert_one(data)

    def find_all_patients_data(self):
        """
        Retrieves all documents from the patient data collection.

        :return: A cursor containing all patient documents.
        """
        collection = self.db[COLLECTION_PATIENT]  # Selects the patient data collection.
        return collection.find()  # Retrieves all documents from the collection.

    def find_patients_at_risk(self):
        collection = self.db[COLLECTION_PATIENT]
        pipeline = [
            {
                "$lookup": {
                    "from": COLLECTION_PREDICTION,  # Name of the prediction data collection
                    "localField": "EurekaID",  # Field in the patient collection
                    "foreignField": "EurekaID",  # Field in the prediction collection
                    "as": "prediction_data"  # Field name to store the joined data (an array of results)
                }
            },
            {
                "$unwind": "$prediction_data"  # Unwind the prediction_data array to access individual documents
            },
            {
                "$match": {
                    "prediction_data.Relapse": 1  # Filter for patients with "Relapse" = 1 (at risk of relapse)
                }
            },
            {
                "$project": {
                    "prediction_data.Relapse": 0  # Exclude the Relapse field from the final result
                }
            }
        ]

        result = collection.aggregate(pipeline)
        return list(result)

    def find_patient_data_by_id(self, patient_id):
        """
        Finds a specific patient's data by their user ID from the patient collection.

        :param patient_id: The user ID of the patient to be found.
        :return: The document corresponding to the specified patient ID.
        """
        collection = self.db[COLLECTION_PATIENT]  # Selects the patient data collection.
        query = {'userId': patient_id}  # Query to find the patient by user ID.
        return collection.find(query).next()  # Returns the first matching document.

    def find_raw_location_data_by_hour(self, start_time_microseconds, end_time_microseconds, user_id):
        """
        Retrieves raw location data documents from the raw collection for a specific time range.

        :param start_time_microseconds: The start of the time range in microseconds.
        :param end_time_microseconds: The end of the time range in microseconds.
        :param user_id: The ID of the user for whom we are requesting data.
        :return: A list of documents that match the query within the time range.
        """
        collection = self.db[COLLECTION_RAW]  # Selects the raw data collection.
        query = {
            "userId": user_id,  # Filters for userId
            "data.__type": "location",  # Filters for location data.
            "sensorStartTime": {  # Filters based on the time range.
                '$gte': start_time_microseconds,
                '$lt': end_time_microseconds
            }
        }
        return list(collection.find(query))  # Returns the list of matching documents.

    def find_raw_screen_data_by_hour(self, start_time_microseconds, end_time_microseconds, user_id):
        """
        Retrieves raw screen event data for a specified user within a given time range.

        Args:
            start_time_microseconds (int): The start time of the range in microseconds.
            end_time_microseconds (int): The end time of the range in microseconds.
            user_id (str): The ID of the user/device.

        Returns:
            list: A list of documents representing the raw screen event data within the specified time range.
        """
        collection = self.db[COLLECTION_RAW]  # Selects the raw data collection.
        query = {
            "userId": user_id,  # Filters for userId
            "data.__type": "screenevent",  # Filters for screen event data.
            "sensorStartTime": {  # Filters based on the time range.
                '$gte': start_time_microseconds,
                '$lt': end_time_microseconds
            }
        }
        return list(collection.find(query))  # Returns the list of matching documents.

    def find_raw_light_data_by_hour(self, start_time_microseconds, end_time_microseconds, user_id):
        """
        Retrieves raw light data for a specified user within a given time range.

        Args:
            start_time_microseconds (int): The start time of the range in microseconds.
            end_time_microseconds (int): The end time of the range in microseconds.
            user_id (str): The ID of the user/device.

        Returns:
            list: A list of documents representing the raw light data within the specified time range.
        """
        collection = self.db[COLLECTION_RAW]  # Selects the raw data collection.
        query = {
            "userId": user_id,  # Filters for userId
            "data.__type": "ambientlight",  # Filters for light data.
            "sensorStartTime": {  # Filters based on the time range.
                '$gte': start_time_microseconds,
                '$lt': end_time_microseconds
            }
        }
        return list(collection.find(query))

    def find_raw_acceleration_data_by_hour(self, start_time_microseconds, end_time_microseconds, user_id):
        """
        Retrieves raw acceleration data for a specified user within a given time range.

        Args:
            start_time_microseconds (int): The start time of the range in microseconds.
            end_time_microseconds (int): The end time of the range in microseconds.
            user_id (str): The ID of the user/device.

        Returns:
            list: A list of documents representing the raw acceleration data within the specified time range.
        """
        collection = self.db[COLLECTION_RAW]  # Selects the raw data collection.
        query = {
            "userId": user_id,  # Filters for userId
            "data.__type": "accelerationfeatures",  # Filters for light data.
            "sensorStartTime": {  # Filters based on the time range.
                '$gte': start_time_microseconds,
                '$lt': end_time_microseconds
            }
        }
        return list(collection.find(query))

    def find_raw_audio_data_by_user(self, date, user_id):
        # Retrieve file info
        start_date = date
        end_date = start_date + timedelta(days=1)

        collection = self.db[COLLECTION_RAW]
        query = {
            "userId": user_id,  # Filters for userId
            "data.__type": "audio",  # Filters for light data.
            'data.date': {
                '$gte': start_date,
                '$lt': end_date
            },  # Filters for documents with the specified date.
        }

        file_info = collection.find(query).next()

        # Initialize GridFS
        fs = gridfs.GridFS(self.db)

        # Get file id from file info
        file_id = file_info['data']['fileId']

        # Retrieve file from GridFS
        audio_file = fs.get(file_id)

        file_info['data']['audioFile'] = audio_file

        return file_info

    def find_first_data_timestamp_for_hour(self, start_time_microseconds, end_time_microseconds, user_id):
        """
        Finds the first recorded data timestamp for a specified user within a given time range.

        Args:
            start_time_microseconds (int): The start time of the range in microseconds.
            end_time_microseconds (int): The end time of the range in microseconds.
            user_id (str): The ID of the user/device.

        Returns:
            int: The timestamp of the first recorded event within the specified time range in microseconds.
        """
        collection = self.db[COLLECTION_RAW]
        query = {
            "userId": user_id,  # Filters for userId
            "sensorStartTime": {  # Filters based on the time range.
                '$gte': start_time_microseconds,
                '$lt': end_time_microseconds
            }
        }
        return collection.find(query).next()['sensorStartTime']  # Returns the first matching document

    def find_last_data_timestamp_for_hour(self, start_time_microseconds, end_time_microseconds, user_id):
        collection = self.db[COLLECTION_RAW]
        query = {
            "userId": user_id,  # Filters for userId
            "sensorStartTime": {  # Filters based on the time range.
                '$gte': start_time_microseconds,
                '$lt': end_time_microseconds
            }
        }

        # Esegui la query ordinando per 'sensorStartTime' in ordine decrescente e limita il risultato a 1
        result = collection.find(query).sort("sensorStartTime", -1).limit(1)

        # Se c'è un risultato, restituisci 'sensorStartTime', altrimenti None
        if result:
            return result[0]['sensorStartTime']
        else:
            return None

    def find_processed_location_data_by_day(self, date, user_id):
        """
        Retrieves processed location data documents for a specific day from the processed collection.

        :param user_id: The ID of the user for whom we are requesting data.
        :param date: The date for which the processed data is needed.
        :return: A cursor containing all processed data for the specified day.
        """

        start_date = date
        end_date = start_date + timedelta(days=1)

        collection = self.db[COLLECTION_PROCESSED]  # Selects the processed data collection.
        query = {
            'type': 'distance',
            'date': {
                '$gte': start_date,
                '$lt': end_date
            },  # Filters for documents with the specified date.
            'userId': user_id,
        }
        return collection.find(query)  # Returns the matching documents.

    def find_processed_places_data_by_day(self, date, user_id):
        start_date = date
        end_date = start_date + timedelta(days=1)

        collection = self.db[COLLECTION_PROCESSED]  # Selects the processed data collection.
        query = {
            'type': 'places',
            'date': {
                '$gte': start_date,
                '$lt': end_date
            },  # Filters for documents with the specified date.
            'userId': user_id,
        }
        return collection.find(query)  # Returns the matching documents.

    def update_processed_distance_data(self, hour, date, distance, user_id, upsert=True):
        """
        Updates or inserts processed location data for a specific hour and date. If the document
        doesn't exist, it can be created based on the 'upsert' flag.

        :param user_id: The ID of the user for whom we are storing data.
        :param hour: The hour for which the data should be updated.
        :param date: The date of the processed data.
        :param distance: The distance value to be updated.
        :param upsert: If True, a new document is created if none matches the query.
        :return: The result of the update operation.
        """
        collection = self.db[COLLECTION_PROCESSED]  # Selects the processed data collection.
        query = {  # Query to find the relevant document.
            'type': 'distance',
            'userId': user_id,
            'hour': hour,
            'date': date,
        }
        update = {'value': distance}  # Update the document with the new distance.
        return collection.update_one(query, {'$set': update}, upsert)  # Updates the document.


    def update_processed_places_data(self, hour, date, places, user_id, upsert=True):
        collection = self.db[COLLECTION_PROCESSED]  # Selects the processed data collection.
        query = {  # Query to find the relevant document.
            'type': 'places',
            'userId': user_id,
            'hour': hour,
            'date': date,
        }
        update = {'value': places}  # Update the document with the new distance.
        return collection.update_one(query, {'$set': update}, upsert)  # Updates the document.

    def update_processed_screen_time(self, hour, date, screentime, user_id, upsert=True):
        """
        Updates the processed screen time data for a specific user, hour, and date. If no matching document exists,
        it creates a new one.

        Args:
            hour (int): The hour of the day (0-23) for which the data applies.
            date (str): The date for which the data applies.
            screentime (float): The total screen time (in minutes) for the hour.
            user_id (str): The ID of the user/device.
            upsert (bool, optional): Whether to insert a new document if no matching one is found. Defaults to True.

        Returns:
            UpdateResult: The result of the update operation.
        """
        collection = self.db[COLLECTION_PROCESSED]  # Selects the processed data collection.
        query = {  # Query to find the relevant document.
            'type': 'screensum',
            'userId': user_id,
            'hour': hour,
            'date': date,
        }
        update = {'value': screentime}  # Update the document with the new distance.
        return collection.update_one(query, {'$set': update}, upsert)  # Updates the document.

    def update_processed_screen_usage(self, hour, date, screenusage, user_id, upsert=True):
        collection = self.db[COLLECTION_PROCESSED]  # Selects the processed data collection.
        query = {  # Query to find the relevant document.
            'type': 'screenusage',
            'userId': user_id,
            'hour': hour,
            'date': date,
        }
        update = {'value': screenusage}  # Update the document with the new distance.
        return collection.update_one(query, {'$set': update}, upsert)  # Updates the document.

    def update_processed_light_data(self, hour, date, light_amplitude, user_id, upsert=True):
        """
        Updates the processed light amplitude data for a specific user, hour, and date. If no matching document exists,
        it creates a new one.

        Args:
            hour (int): The hour of the day (0-23) for which the data applies.
            date (str): The date for which the data applies.
            light_amplitude (double): The light amplitude for the hour.
            user_id (str): The ID of the user/device.
            upsert (bool, optional): Whether to insert a new document if no matching one is found. Defaults to True.

        Returns:
            UpdateResult: The result of the update operation.
        """
        collection = self.db[COLLECTION_PROCESSED]  # Selects the processed data collection.
        query = {  # Query to find the relevant document.
            'type': 'light',
            'userId': user_id,
            'hour': hour,
            'date': date,
        }
        update = {'value': light_amplitude}  # Update the document with the new distance.
        return collection.update_one(query, {'$set': update}, upsert)  # Updates the document.

    def update_processed_acceleration_data(self, hour, date, acceleration, user_id, upsert=True):
        """
        Updates the processed acceleration data for a specific user, hour, and date. If no matching document exists,
        it creates a new one.

        Args:
            hour (int): The hour of the day (0-23) for which the data applies.
            date (str): The date for which the data applies.
            acceleration (double): The light amplitude for the hour.
            user_id (str): The ID of the user/device.
            upsert (bool, optional): Whether to insert a new document if no matching one is found. Defaults to True.

        Returns:
            UpdateResult: The result of the update operation.
        """
        collection = self.db[COLLECTION_PROCESSED]  # Selects the processed data collection.
        query = {  # Query to find the relevant document.
            'type': 'acceleration',
            'userId': user_id,
            'hour': hour,
            'date': date,
        }
        update = {'value': acceleration}  # Update the document with the new distance.
        return collection.update_one(query, {'$set': update}, upsert)  # Updates the document.

    def update_processed_conversation_data(self, hour, date, conversation_duration, user_id, upsert=True):
        collection = self.db[COLLECTION_PROCESSED]  # Selects the processed data collection.
        query = {  # Query to find the relevant document.
            'type': 'conversation',
            'userId': user_id,
            'hour': hour,
            'date': date,
        }
        update = {'value': conversation_duration}  # Update the document with the new distance.
        return collection.update_one(query, {'$set': update}, upsert)  # Updates the document.

    def update_processed_volume_data(self, hour, date, audio_amplitude, user_id, upsert=True):
        collection = self.db[COLLECTION_PROCESSED]  # Selects the processed data collection.
        query = {  # Query to find the relevant document.
            'type': 'volume',
            'userId': user_id,
            'hour': hour,
            'date': date,
        }
        update = {'value': audio_amplitude}  # Update the document with the new distance.
        return collection.update_one(query, {'$set': update}, upsert)  # Updates the document.

    def find_processed_screen_data_by_day(self, date, user_id):
        """
        Retrieves the processed screen time data for a specified user on a given date.

        Args:
            date (datetime): The date for which the data is retrieved.
            user_id (str): The ID of the user/device.

        Returns:
            Cursor: A cursor to the documents representing the processed screen time data for the specified date.
        """

        start_date = date
        end_date = start_date + timedelta(days=1)

        collection = self.db[COLLECTION_PROCESSED]
        query = {
            'type': 'screensum',
            'date': {
                '$gte': start_date,
                '$lt': end_date
            },  # Filters for documents with the specified date.
            'userId': user_id,
        }
        return collection.find(query)

    def find_processed_screenusage_data_by_day(self, date, user_id):
        start_date = date
        end_date = start_date + timedelta(days=1)

        collection = self.db[COLLECTION_PROCESSED]
        query = {
            'type': 'screenusage',
            'date': {
                '$gte': start_date,
                '$lt': end_date
            },  # Filters for documents with the specified date.
            'userId': user_id,
        }
        return collection.find(query)

    def find_processed_light_data_by_day(self, date, user_id):
        """
        Retrieves the processed light amplitude data for a specified user on a given date.

        Args:
            date (datetime): The date for which the data is retrieved.
            user_id (str): The ID of the user/device.

        Returns:
            Cursor: A cursor to the documents representing the processed light amplitude data for the specified date.
        """

        start_date = date
        end_date = start_date + timedelta(days=1)

        collection = self.db[COLLECTION_PROCESSED]
        query = {
            'type': 'light',
            'date': {
                '$gte': start_date,
                '$lt': end_date
            },  # Filters for documents with the specified date.
            'userId': user_id,
        }
        return collection.find(query)

    def find_processed_acceleration_data_by_day(self, date, user_id):
        """
        Retrieves the processed acceleration data for a specified user on a given date.

        Args:
            date (datetime): The date for which the data is retrieved.
            user_id (str): The ID of the user/device.

        Returns:
            Cursor: A cursor to the documents representing the processed acceleration data for the specified date.
        """

        start_date = date
        end_date = start_date + timedelta(days=1)

        collection = self.db[COLLECTION_PROCESSED]
        query = {
            'type': 'acceleration',
            'date': {
                '$gte': start_date,
                '$lt': end_date
            },  # Filters for documents with the specified date.
            'userId': user_id,
        }
        return collection.find(query)

    def find_processed_conversation_data_by_day(self, date, user_id):
        start_date = date
        end_date = start_date + timedelta(days=1)

        collection = self.db[COLLECTION_PROCESSED]
        query = {
            'type': 'conversation',
            'date': {
                '$gte': start_date,
                '$lt': end_date
            },  # Filters for documents with the specified date.
            'userId': user_id,
        }
        return collection.find(query)

    def find_processed_volume_data_by_day(self, date, user_id):
        start_date = date
        end_date = start_date + timedelta(days=1)

        collection = self.db[COLLECTION_PROCESSED]
        query = {
            'type': 'volume',
            'date': {
                '$gte': start_date,
                '$lt': end_date
            },  # Filters for documents with the specified date.
            'userId': user_id,
        }
        return collection.find(query)

    def find_user_data(self, username):
        collection = self.db[COLLECTION_MEDIC]
        query = {
            "username": username
        }

        return collection.find_one(query)

    def insert_user(self, name, surname, username, password):
        collection = self.db[COLLECTION_MEDIC]
        document = {
            "firstName": name,
            "lastName": surname,
            "username": username,
            "password": password
        }

        return collection.insert_one(document)

    def close_connection(self):
        """
        Closes the connection to the MongoDB server. Should be called when the database
        operations are finished to release resources.

        :return: None
        """
        self.client.close()  # Closes the connection to the database.
