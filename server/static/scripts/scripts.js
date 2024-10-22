let selectedPatientId = null  // Store patient ID

function setCurrentDate() {
    document.getElementById('date').value = new Date().toISOString().split('T')[0];
}

function loadDataforDate() {
    if(selectedPatientId) {
        loadPatientData(selectedPatientId)
    }
}

function loadPatientData(patientId) {
    selectedPatientId = patientId
    const selectedDate = document.getElementById('date').value

    fetch(`/patient-data?patient_id=${patientId}&date=${selectedDate}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Update first name and last name
                let userId = data['patient_data']['userId']
                let fName = data['patient_data']['firstName']
                let lName = data['patient_data']['lastName']
                console.log("UserId: "+userId)
                document.getElementById("dashboardTitle").innerText = "Dashboard di " + fName + " " + lName
                document.getElementById("patientsAtRisk").style.display = 'none';

                // Update graphs
                // document.getElementById('message').style.display = 'none';

                document.getElementById('distanceGraph').style.display = 'block';
                Plotly.newPlot('distanceGraph', data.distance_graph_data.data, data.distance_graph_data.layout);

                document.getElementById('screenGraph').style.display = 'block';
                Plotly.newPlot('screenGraph', data.screensum_graph_data.data, data.screensum_graph_data.layout);

                document.getElementById('lightGraph').style.display = 'block';
                Plotly.newPlot('lightGraph', data.light_amplitude_graph_data.data, data.light_amplitude_graph_data.layout);

                document.getElementById("accelerationGraph").style.display = 'block'
                Plotly.newPlot('accelerationGraph', data.acceleration_graph_data.data, data.acceleration_graph_data.layout)

                document.getElementById("conversationGraph").style.display = 'block'
                Plotly.newPlot('conversationGraph', data.conversation_graph_data.data, data.conversation_graph_data.layout)

                document.getElementById("volumeGraph").style.display = 'block'
                Plotly.newPlot('volumeGraph', data.amplitude_graph_data.data, data.amplitude_graph_data.layout)

                document.getElementById("placesGraph").style.display = 'block'
                Plotly.newPlot('placesGraph', data.places_graph_data.data, data.places_graph_data.layout)

                document.getElementById("usageGraph").style.display = 'block'
                Plotly.newPlot('usageGraph', data.screenusage_graph_data.data, data.screenusage_graph_data.layout)

                // Make upload forms visible and update userID
                document.getElementById("fileForm").style.display = 'block'
                document.getElementById("audioForm").style.display = 'block'
                document.getElementById("dateSelector").style.visibility = 'visible';
                Array.from(document.getElementsByName("userId")).forEach(function (element) {
                    element.value = userId
                })
            } else {
                console.error("Error: " + data.error)
            }
        })
        .catch(error => console.error('Errore durante il caricamento dei dati del paziente:', error));
}

window.onload = setCurrentDate;