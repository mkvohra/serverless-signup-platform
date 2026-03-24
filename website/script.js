document.getElementById("signupForm").addEventListener("submit", async function(e) {
    e.preventDefault();

    const username = document.getElementById("username").value;
    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;

    const statusMsg = document.getElementById("status-message");

    try {
        const response = await fetch("/api/signup", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                username: username,
                email: email,
                password: password
            })
        });

        const data = await response.json();

        if (response.ok) {
            statusMsg.innerText = "Signup successful!";
        } else {
            statusMsg.innerText = data.error || "Signup failed";
        }

    } catch (error) {
        statusMsg.innerText = "Something went wrong";
    }
});