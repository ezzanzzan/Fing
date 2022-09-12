
import './App.css';
import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import { Home } from './components/Home';
import { Goods } from './components/Goods';
import { About } from './components/About';
import {Service} from './components/Service';
import {Personal} from './components/Personal';

function App() {
  return (
    <Router>
      <div className="App">
        <Routes>
          <Route path="/" element={<Home/>}></Route>
          <Route path="/goods" element={<Goods/>}></Route>
          <Route path="/about" element={<About/>}></Route>
          <Route path="/personal" element={<Personal/>}></Route>
          <Route path="/service" element={<Service/>}></Route>
        </Routes>
      </div>
    </Router>
  );
}

export default App;
