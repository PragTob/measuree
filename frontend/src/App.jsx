import { useState, useEffect } from "react";
import MeasurementForm from "./components/MeasurementForm";
import Graphs from "./components/Graphs";
import {
  fetchMeasurementStatistics,
  fetchMetrics,
} from "./api";
import toast, { Toaster } from "react-hot-toast";
import Modal from "react-modal";
import "./App.css";

function App() {
  const [statistics, setStatistics] = useState(null);
  const [metrics, setMetrics] = useState([]);
  const [modalIsOpen, setModalIsOpen] = useState(false);

  const openModal = () => {
    setModalIsOpen(true);
  };

  const closeModal = () => {
    setModalIsOpen(false);
  };

  useEffect(() => {
    async function fetchData() {
      try {
        const statistics = await fetchMeasurementStatistics();
        const metrics = await fetchMetrics();

        setStatistics(statistics);
        setMetrics(metrics);
      } catch (error) {
        toast.error("Oops! Fetching data failed: " + error.message);
      }
    }

    fetchData();
  }, []);

  const handleSubmit = async () => {
    // Refresh statistics after submitting a new measurement
    const updatedStatistics = await fetchMeasurementStatistics();
    setStatistics(updatedStatistics);
  };

  return (
    <div className="container">
      <Toaster />

      <div className="header-with-action">
        <h1>Welcome to Measuree!</h1>
        <button className="success-button" onClick={openModal}>
          Add new Measurement
        </button>
      </div>

      <Modal
        isOpen={modalIsOpen}
        onRequestClose={closeModal}
        style={{
          content: {
            maxWidth: "400px",
            left: "50%",
            transform: "translateX(-50%)",
          },
        }}
        appElement={document.getElementById("root")}
      >
        <button className="modal-close" onClick={closeModal}>
          X
        </button>
        <MeasurementForm onSubmit={handleSubmit} metrics={metrics} />
      </Modal>
      <Graphs statistics={statistics} metrics={metrics} />
    </div>
  );
}

export default App;
