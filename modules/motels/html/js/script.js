// JavaScript for motels
document.addEventListener('DOMContentLoaded', function() {
    // Initialize UI
    window.addEventListener('message', function(event) {
        let data = event.data;
        
        if (data.action === 'open') {
            // Handle open action
        } else if (data.action === 'close') {
            // Handle close action
        }
    });
});

// Function to send data back to the client
function sendData(data) {
    fetch('https://' + GetParentResourceName() + '/callback', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
    });
}
