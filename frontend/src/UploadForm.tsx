import React, { useState } from "react";
function UploadForm() {
  const [url, setUrl] = useState<string>("");
  const [file, setFile] = useState<any>(null);

  const handleSubmit = async (e: any) => {
    e.preventDefault();

    let formData = new FormData();
    formData.append("file", file.data);

    const response = await fetch(
      //TO DO:
      //What URL should be here?
      "http://localhost:5001/upload-file-to-cloud-storage",
      {
        method: "POST",
        body: formData,
      }
    );

    const responseWithBody = await response.json();
    if (response) setUrl(responseWithBody.publicUrl);
  };

  const handleFileChange = (e: any) => {
    const fileToUpload = {
      data: e.target.files[0],
    };
    setFile(fileToUpload);
  };

  return (
    <form className="form" onSubmit={handleSubmit}>
      <input type="file" name="file" onChange={handleFileChange}></input>
      <button className="form-button" type="submit">
        Upload
      </button>
    </form>
  );
}
export default UploadForm;
