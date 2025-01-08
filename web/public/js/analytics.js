document.addEventListener('DOMContentLoaded', () => {
    const totalScansElem = document.getElementById('total-scans');
    const healthyRateElem = document.getElementById('healthy-rate');
    const unhealthyRateElem = document.getElementById('unhealthy-rate');

    async function fetchSummary() {
        try {
            // Fetch the summary data from the backend
            const response = await fetch('http://localhost:3000/api/auth/summary');
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            const summary = await response.json();

            // Set the Total Scans, Healthy Rate, and Unhealthy Rate elements
            const totalScans = summary.total;
            const healthyRate = ((summary.healthy / totalScans) * 100).toFixed(2);
            const unhealthyRate = ((summary.unhealthy / totalScans) * 100).toFixed(2);

            totalScansElem.textContent = totalScans;
            healthyRateElem.textContent = `${healthyRate}%`;
            unhealthyRateElem.textContent = `${unhealthyRate}%`;

            // Update the charts with the fetched data
            updateCharts(summary.healthy, summary.unhealthy);
        } catch (error) {
            console.error('Error fetching summary:', error);
            totalScansElem.textContent = 'Error';
            healthyRateElem.textContent = 'Error';
            unhealthyRateElem.textContent = 'Error';
        }
    }

    // Function to update the charts
    function updateCharts(healthy, unhealthy) {
        const healthChartData = {
            labels: ['Healthy', 'Unhealthy'],
            datasets: [{
                label: 'Tree Health',
                data: [healthy, unhealthy],
                backgroundColor: ['#4CAF50', '#F44336'],
                borderColor: ['#4CAF50', '#F44336'],
                borderWidth: 1
            }]
        };

        const classificationPieData = {
            labels: ['Healthy', 'Unhealthy'],
            datasets: [{
                data: [healthy, unhealthy],
                backgroundColor: ['#4CAF50', '#F44336'],
            }]
        };

        // Create the Bar Chart
        const healthChartContext = document.getElementById('healthChart').getContext('2d');
        new Chart(healthChartContext, {
            type: 'bar',
            data: healthChartData,
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });

        // Create the Pie Chart
        const classificationPieChartContext = document.getElementById('classificationPieChart').getContext('2d');
        new Chart(classificationPieChartContext, {
            type: 'pie',
            data: classificationPieData
        });
    }

    // Fetch data
    fetchSummary();
});
