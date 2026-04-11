console.log("JS LOADED");

// ✅ base URLs already include stage
let API_BASE_URL;

const host = window.location.hostname;

if (host === "d39zozrtbs5abm.cloudfront.net") {
    // DEV
    API_BASE_URL = "https://tbcqji2kw1.execute-api.ap-south-1.amazonaws.com/dev";
} else if (host === "d18e9cahqplfqu.cloudfront.net") {
    // STAGE
    API_BASE_URL = "https://i4trhrqq93.execute-api.ap-south-1.amazonaws.com/stage";
} else if (host === "duazps8okfa9t.cloudfront.net") {
    // PROD
    API_BASE_URL = "https://w3ap3c371l.execute-api.ap-south-1.amazonaws.com/prod";
} else {
    // fallback
    API_BASE_URL = "https://w3ap3c371l.execute-api.ap-south-1.amazonaws.com/prod";
}

console.log("Using API:", API_BASE_URL);


document.getElementById("signupForm").addEventListener("submit", async function(e) {
    console.log("FORM SUBMITTED");
    e.preventDefault();

    const username = document.getElementById("username").value;
    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;

    try {
        const res = await fetch(`${API_BASE_URL}/signup`, {
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

        const result = await res.json();

        document.getElementById("status-message").innerText =
            result.message || result.error;

    } catch (err) {
        console.error(err);
        document.getElementById("status-message").innerText =
            "Something went wrong";
    }
});