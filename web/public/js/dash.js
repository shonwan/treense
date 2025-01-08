document.addEventListener('DOMContentLoaded', () => {
  const totalSeedlingsElem = document.getElementById('total-seedlings');
  const healthySeedlingsElem = document.getElementById('healthy-seedlings');
  const unhealthySeedlingsElem = document.getElementById('unhealthy-seedlings');

  async function fetchSummary() {
      try {
          const response = await fetch('http://localhost:3000/api/auth/summary');
          if (!response.ok) {
              throw new Error('Network response was not ok');
          }
          const summary = await response.json();

          totalSeedlingsElem.textContent = summary.total;
          healthySeedlingsElem.textContent = summary.healthy;
          unhealthySeedlingsElem.textContent = summary.unhealthy;
      } catch (error) {
          console.error('Error fetching summary:', error);
          totalSeedlingsElem.textContent = 'Error';
          healthySeedlingsElem.textContent = 'Error';
          unhealthySeedlingsElem.textContent = 'Error';
      }
  }

  async function fetchRecentActivities() {
    try {
        const response = await fetch('http://localhost:3000/api/auth/recent-uploads'); // Adjust this to match your endpoint
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        const recentUploads = await response.json();

        const recentUploadsListElem = document.getElementById('recent-uploads-list');
        recentUploadsListElem.innerHTML = '';

        recentUploads.forEach(upload => {
            const listItem = document.createElement('li');
            listItem.classList.add('flex', 'items-center', 'space-x-4', 'bg-gray-50', 'p-4', 'rounded-lg', 'shadow-sm');
            listItem.innerHTML = `
                <div class="w-16 h-16 rounded-full overflow-hidden">
                    <img src="${upload.image_url}" alt="Image" class="w-full h-full object-cover">
                </div>
                <div class="flex-1">
                    <p class="font-semibold text-gray-700">${upload.classification}</p>
                    <p class="text-sm text-gray-500">${new Date(upload.created_at).toLocaleString()}</p>
                </div>
            `;
            recentUploadsListElem.appendChild(listItem);
        });
    } catch (error) {
        console.error('Error fetching recent uploads:', error);
    }
}



  fetchSummary();
  fetchRecentActivities();
});
