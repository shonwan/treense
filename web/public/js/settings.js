document.addEventListener('DOMContentLoaded', () => {
    const firstNameElem = document.getElementById('first-name');
    const lastNameElem = document.getElementById('last-name');
    const emailElem = document.getElementById('email');
    const editBtn = document.getElementById('edit-btn');

    // Function to fetch user profile data from the backend
    async function fetchUserProfile() {
        try {
            // Retrieve token from localStorage (you can change this depending on where you store the token)
            const token = localStorage.getItem('token');
            if (!token) {
                throw new Error('No token found');
            }

            const response = await fetch('http://localhost:3000/api/auth/profile', {
                method: 'GET',
                headers: {
                    'Authorization': `Bearer ${token}`  // Send JWT token in the Authorization header
                }
            });

            if (!response.ok) {
                throw new Error('Error fetching user profile');
            }

            const user = await response.json();

            // Update the profile fields with the fetched data
            firstNameElem.textContent = user.first_name || 'Loading...';
            lastNameElem.textContent = user.last_name || 'Loading...';
            emailElem.textContent = user.email || 'Loading...';
        } catch (error) {
            console.error('Error fetching user profile:', error);
            firstNameElem.textContent = 'Error';
            lastNameElem.textContent = 'Error';
            emailElem.textContent = 'Error';
        }
    }

    // Call the fetchUserProfile function when the page loads
    fetchUserProfile();
});
