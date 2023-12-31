const express = require('express');
const axios = require("axios");
const app = express();

const port = process.env.PORT || 8080;

app.use(express.json());

// GETTING ERRORS (404) WHEN USING THIS FOR THE IMAGE

app.get("/", (req, res) => {
  const name = process.env.NAME || 'World';
  res.send(`Hello ${name}!`);
});

// app.post('/', (req, res) => {
//   if (!req.body) {
//     const msg = 'no Pub/Sub message received';
//     console.error(`error: ${msg}`);
//     res.status(400).send(`Bad Request: ${msg}`);
//     return;
//   }
//   if (!req.body.message) {
//     const msg = 'invalid Pub/Sub message format';
//     console.error(`error: ${msg}`);
//     res.status(400).send(`Bad Request: ${msg}`);
//     return;
//   }

//   const pubSubMessage = req.body.message;
//   const data = Buffer.from(pubSubMessage.data, 'base64').toString().trim()

//   const sourceBucket = "cint_upload_bucket";
//   const sourceObject = JSON.parse(data.toString()).name;

//   const destinationBucket = "cint_clean_bucket"
//   const destinationObject = `clean-${sourceObject}`;

//   const apiUrl = `https://storage.googleapis.com/storage/v1/b/${sourceBucket}/o/${sourceObject}/rewriteTo/b/${destinationBucket}/o/${destinationObject}`;

//   console.log("URL:", apiUrl)

//   const moveObject = async () => {
//     try {
//       const response = await axios.post(apiUrl)
//       if (response.status === 200) {
//         console.log("Success!");
//         res.status(200).send();
//       } else {
//         console.error("Bad response:", response.statusText)
//         res.status(response.status).send();
//       }
//     } catch (error) {
//       console.error("Failed:", error.message)
//       res.status(error.status).send();
//     }

//   }

//   moveObject();
//  });

app.listen(port, () => {
  console.log(`helloworld: listening on port ${port}`);
});
