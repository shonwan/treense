document.addEventListener('DOMContentLoaded', () => {
    const tableBody = document.getElementById('history-table-body');
    const filterDate = document.getElementById('filter-date');
    const filterStatus = document.getElementById('filter-status');
    const sortOptions = document.getElementById('sort-options');

    async function fetchData() {
        try {
            const response = await fetch('http://localhost:3000/api/auth/classifications');
            const data = await response.json();
            displayData(data);
        } catch (error) {
            console.error('Error fetching data:', error);
        }
    }

    function displayData(data) {
        tableBody.innerHTML = '';
        data.forEach(item => {
            const row = document.createElement('tr');
            row.classList.add('border-b', 'border-gray-200');
            row.innerHTML = `
                <td class="px-4 py-2 text-gray-700">${new Date(item.created_at).toLocaleDateString()}</td>
                <td class="px-4 py-2"><img src="${item.image_url}" alt="Seedling Image" class="w-12 h-12 object-cover"></td>
                <td class="px-4 py-2 text-gray-700">${item.classification}</td>
                <td class="px-4 py-2 text-gray-700">${item.location || 'N/A'}</td>
            `;
            tableBody.appendChild(row);
        });
    }

    function applyFilters() {
        let dateValue = filterDate.value;
        let statusValue = filterStatus.value;
        let sortValue = sortOptions.value;

        fetch('http://localhost:3000/api/auth/classifications')
            .then(response => response.json())
            .then(data => {
                if (dateValue) {
                    data = data.filter(item => new Date(item.created_at).toLocaleDateString() === new Date(dateValue).toLocaleDateString());
                }

                if (statusValue !== 'all') {
                    data = data.filter(item => item.classification.toLowerCase() === statusValue);
                }

                if (sortValue === 'date') {
                    data.sort((a, b) => new Date(a.created_at) - new Date(b.created_at));
                } else if (sortValue === 'status') {
                    data.sort((a, b) => a.classification.localeCompare(b.classification));
                }

                displayData(data);
            })
            .catch(error => console.error('Error fetching filtered data:', error));
    }

    document.querySelector('.filters button').addEventListener('click', applyFilters);

    fetchData();
});
