import React, { useState, useEffect } from 'react';
import { AuthClient } from '@dfinity/auth-client';
import { Actor, HttpAgent } from '@dfinity/agent';
import Register from './components/Register';
import ChatRoom from './components/ChatRoom';
import { idlFactory } from 'declarations/smart_transfer_backend/smart_transfer_backend.did.js';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [authClient, setAuthClient] = useState(null);
  const [actor, setActor] = useState(null);
  const [username, setUsername] = useState('');

  useEffect(() => {
    initAuth();
  }, []);

  const initAuth = async () => {
    const client = await AuthClient.create();
    setAuthClient(client);

    if (await client.isAuthenticated()) {
      handleAuthenticated(client);
    }
  };

  const handleAuthenticated = async (client) => {
    const identity = client.getIdentity();
    const agent = new HttpAgent({ identity });
    const newActor = Actor.createActor(idlFactory, {
      agent,
      canisterId: process.env.CANISTER_ID_SMART_TRANSFER_BACKEND,
    });
    setActor(newActor);
    setIsAuthenticated(true);
  };

  const login = async () => {
    await authClient?.login({
      identityProvider: process.env.II_URL,
      onSuccess: () => handleAuthenticated(authClient),
    });
  };

  const handleRegister = async (newUsername) => {
    try {
      await actor.register(newUsername);
      setUsername(newUsername);
    } catch (error) {
      console.error("Registration failed:", error);
    }
  };

  return (
    <div className="App">
      <h1>Chat Platform</h1>
      {!isAuthenticated ? (
        <button onClick={login}>Login with Internet Identity</button>
      ) : !username ? (
        <Register onRegister={handleRegister} />
      ) : (
        <ChatRoom username={username} actor={actor} />
      )}
    </div>
  );
}

export default App;