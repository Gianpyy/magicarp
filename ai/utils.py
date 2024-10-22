import numpy as np
from pymongo import MongoClient

def save_anomalies_to_markdown(results, output_file):
    with open(output_file, "a") as f:  # Modalità append
        f.write("# Risultati della Valutazione\n\n")
        for result in results:
            f.write(f"## Eureka ID: {result['EurekaID']}\n")
            f.write(f"- **Numero di giorni**: {result['Support']}\n")
            f.write(f"- **Soglia**: {result['Threshold']}\n")
            f.write(f"- **Anomalie Rilevate**: {result['Anomalous Days']}\n")
            f.write(f"- **Relapse**: {result['Relapse']}\n")
            f.write(f"- **Percentuale anomalie**: {result['Anomaly Percentage']}\n")
            f.write(f"- **Mean Square Error (MSE)**: {result['MSE']}\n")
            f.write(f"- **Errore cumulativo**: {result['Cumulative Error']}\n")
            f.write(f"- **Errore di ricostruzione medio**: {result['Mean Reconstruction Error']}\n")
            f.write(f"- **Deviazione standard dell'errore di ricostruzione**: {result['Std Reconstruction Error']}\n")
            f.write(f"- **Loss media durante il training**: {result['Average Training Loss']}\n")
            f.write("\n---\n")


def set_relapse_label(threshold, results, global_anomalous_days):
    relapse_threshold = np.percentile(global_anomalous_days, threshold)

    for result in results:
        num_anomalous_days = result["Anomalous Days"]
        result["Threshold"] = relapse_threshold

        if num_anomalous_days > relapse_threshold:
            result["Relapse"] = 1
        else:
            result["Relapse"] = 0


def save_results_to_db(all_results):
    client = MongoClient('mongodb://localhost:27017/')
    db = client['magicarp']
    collection = db['prediction-data']
    collection.insert_many(all_results)
