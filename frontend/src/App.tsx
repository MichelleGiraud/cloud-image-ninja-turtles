import "./app.css";
import UploadForm from "./UploadForm";

function App() {
  return (
    <div className="app">
      <header className="app-container">
        <img
          src={require("./team-logo.jpg")}
          className="app-logo"
          alt="team logo"
        />
        <UploadForm />
      </header>
    </div>
  );
}

export default App;
