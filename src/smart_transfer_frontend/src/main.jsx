import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.scss';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
import { smart_transfer_backend } from 'declarations/smart_transfer_backend';
import { idlFactory } from 'declarations/smart_transfer_backend/smart_transfer_backend.did.js';