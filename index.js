import express from "express";
const PORT = 3000;

const app = express();

app.get("/", (req, res) => { 
    res.send("Hello from CI/CD");
});

app.listen(PORT, console.log(`app listening on ${PORT}`));