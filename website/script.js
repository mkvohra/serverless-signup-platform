console.log("JS LOADED");

document.getElementById("signupForm").addEventListener("submit", async function(e) {
    console.log("FORM SUBMITTED")
    e.preventDefault();

    const username = document.getElementById("username").value;
    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;

    try {
        const res = await fetch("/api/signup", {
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

        const data = await res.json();
        const result = JSON.parse(data.body);

        document.getElementById("status-message").innerText =
            result.message || result.error;

    } catch (err) {
        console.error(err);
        document.getElementById("status-message").innerText =
            "Something went wrong";
    }
});