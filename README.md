# ChatPlatform with Bitcoin Integration

## Overview

ChatPlatform is a decentralized chat application with integrated Bitcoin (BTC) and ckBTC functionalities. The platform allows users to:
- Register with a unique username.
- Send and receive messages.
- Perform Bitcoin transactions, including querying balances and transferring BTC.
- Participate in a verification system to confirm information and vote for top verifiers.
- Mint and transfer ckBTC using the ICP blockchain.

This project leverages Motoko language for building decentralized applications on the Internet Computer (IC) blockchain and integrates ckBTC ledger functionalities.

## Features

### 1. User Management
- **Registration**: Users can register with a unique username and are assigned a Bitcoin address.
- **Message Sending**: Registered users can send messages stored in their profile.
- **Retrieve Messages**: Users can query and retrieve their message history.

### 2. Verification System
- **Information Verification**: Users can verify specific pieces of information.
- **Voting for Verifiers**: Users can vote for others who have verified information.
- **Top Verifier Identification**: Retrieve the username of the user with the highest vote count.

### 3. Bitcoin Integration
- **Get Bitcoin Address**: Users are assigned a Bitcoin address during registration.
- **Query Bitcoin Balance**: Users can check the Bitcoin balance of their assigned address.
- **Send Bitcoin**: Users can transfer BTC to others registered on the platform.

### 4. ckBTC Integration
- **Mint ckBTC**: Users can mint ckBTC tokens using the ICP blockchain.
- **Transfer ckBTC**: Users can transfer ckBTC to other registered users.

### 5. Persistent Storage
- **Stable Data Storage**: User data and verifications are persistently stored and can be safely upgraded without data loss.

## Technical Details

### Technologies and Libraries
- **Motoko**: Programming language for the Internet Computer blockchain.
- **ICP Blockchain**: The backend infrastructure for the platform.
- **ckBTC Ledger**: For minting and transferring ckBTC tokens.
- **HashMap**: Efficient data storage and retrieval for users and verifications.
- **Result/Error Handling**: Robust handling of operations for improved reliability.

### Key Components
1. **User Registration**:
   - Registers a user with a Bitcoin address fetched from a Bitcoin integration actor.
2. **Messaging**:
   - Enables users to send and view messages.
3. **Verification and Voting**:
   - Allows users to verify information and vote for others based on verification activity.
4. **Bitcoin and ckBTC Operations**:
   - Integration with Bitcoin for transactions.
   - Minting and transferring ckBTC using the `ckbtcLedger` module.

### Persistent Storage and Upgrades
- Data is stored in `HashMap` structures.
- Uses `preupgrade` and `postupgrade` hooks to preserve data during system upgrades.

## Usage

### Register a User
```motoko
register("username");
Send a Message
motoko
Copy code
sendMessage("Hello, World!");
Retrieve Messages
motoko
Copy code
getMessages();
Verify Information
motoko
Copy code
verifyInformation("Sample Info");
Vote for a Verifier
motoko
Copy code
voteVerifier("VerifierUsername");
Query Bitcoin Balance
motoko
Copy code
getBitcoinBalance();
Send Bitcoin
motoko
Copy code
sendBitcoin("RecipientUsername", 1000000);
Mint ckBTC
motoko
Copy code
mintCKBTC(1000000);
Transfer ckBTC
motoko
Copy code
transferCKBTC("RecipientUsername", 1000000);
Contribution
Contributions are welcome! Feel free to fork this repository and submit pull requests.

License
This project is licensed under the MIT License. See the LICENSE file for details.

vbnet
Copy code

Let me know if you'd like any adjustments or further details added!# chainfusion
