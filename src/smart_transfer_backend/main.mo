// import Principal "mo:base/Principal";
// import Text "mo:base/Text";
// import Hash "mo:base/Hash";
// import Iter "mo:base/Iter";
// import HashMap "mo:base/HashMap";
// import Array "mo:base/Array";
// import Error "mo:base/Error";
// import Result "mo:base/Result";
// import Nat64 "mo:base/Nat64";

// actor ChatPlatform {
//   // Define the user structure
//   type User = {
//     principal: Principal;
//     username: Text;
//     messages: [Text];
//     btcAddress: Text;
//   };
//   // Create an instance of the BitcoinIntegration actor
//   let bitcoinIntegration = actor("rrkah-fqaaa-aaaaa-aaaaq-cai") : actor {
//     get_btc_address : (Principal) -> async Text;
//     get_balance : (Text) -> async Nat64;
//     send_bitcoin : (Principal, Principal, Nat64) -> async Result.Result<Text, Text>;
//   };

//   // Modify the register function to include Bitcoin address
//   public shared({ caller }) func register(username: Text) : async () {
//   if (users.get(caller) != null) {
//     throw Error.reject("User already registered");
//   };

//   let btcAddress = await bitcoinIntegration.get_btc_address(caller);

//   let newUser: User = {
//     principal = caller;
//     username = username;
//     messages = [];
//     btcAddress = btcAddress;
//   };

//   users.put(caller, newUser);
// };

//   // Add a function to get user's Bitcoin balance
//   public shared({ caller }) func getBitcoinBalance() : async Nat64 {
//     switch (users.get(caller)) {
//       case (?user) { await bitcoinIntegration.get_balance(user.btcAddress) };
//       case null { throw Error.reject("User not registered") };
//     };
//   };

//   // Add a function to send Bitcoin
//   public shared({ caller }) func sendBitcoin(to: Text, amount: Nat64) : async Result.Result<Text, Text> {
//     switch (users.get(caller)) {
//       case (?fromUser) {
//         switch (Array.find<User>(Iter.toArray(users.vals()), func(u: User) : Bool { u.username == to })) {
//           case (?toUser) {
//             await bitcoinIntegration.send_bitcoin(caller, toUser.principal, amount);
//           };
//           case null { #err("Recipient not found") };
//         };
//       };
//       case null { #err("Sender not registered") };
//     };
//   };

//   // Create a HashMap to store users
//   private var users = HashMap.HashMap<Principal, User>(
//     10,                 // Initial capacity
//     Principal.equal,    // Equality function
//     Principal.hash      // Hash function
//   );

//   // Stable storage for upgrades
//   private stable var usersEntries : [(Principal, User)] = [];

//   system func preupgrade() {
//     usersEntries := Iter.toArray(users.entries());
//   };

//   system func postupgrade() {
//     users := HashMap.fromIter<Principal, User>(usersEntries.vals(), 10, Principal.equal, Principal.hash);
//     usersEntries := [];
//   };

//   // public shared({ caller }) func register(username: Text) : async () {
//   //   if (users.get(caller) != null) {
//   //     throw Error.reject("User already registered");
//   //   };

//   //   let newUser: User = {
//   //     principal = caller;
//   //     username = username;
//   //     messages = [];
//   //   };

//   //   users.put(caller, newUser);
//   // };

//   // Reintroduced sendMessage function
//   public shared({ caller }) func sendMessage(message: Text) : async () {
//     switch (users.get(caller)) {
//       case (?user) {
//         let updatedMessages = Array.append<Text>(user.messages, [message]);
//         let updatedUser: User = {
//         principal = user.principal;
//         username = user.username;
//         messages = updatedMessages;
//         btcAddress = user.btcAddress;  // Include the existing btcAddress
//       };
//       users.put(caller, updatedUser);
//       };
//       case null { throw Error.reject("User not registered") };
//     };
//   };

//   // Function to retrieve messages for the authenticated user
//   public query({ caller }) func getMessages() : async [Text] {
//     switch (users.get(caller)) {
//       case (?user) { user.messages };
//       case null { throw Error.reject("User not registered") };
//     };
//   };

//   // Function to retrieve all usernames
//   public query func getUsernames() : async [Text] {
//     Iter.toArray(Iter.map(users.vals(), func (user : User) : Text { user.username }));
//   };
// }
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Nat64 "mo:base/Nat64";

// Import necessary types and functions for ckBTC integration
import ckbtcLedger "canister:icrc1_ledger_canister";
import Debug "mo:base/Debug";

actor ChatPlatform {
  // Define the updated user structure
  type User = {
    principal: Principal;
    username: Text;
    messages: [Text];
    btcAddress: Text;
    verificationCount: Nat64;
    voteCount: Nat64;
  };

  // Create instances of necessary actors
  let bitcoinIntegration = actor("rrkah-fqaaa-aaaaa-aaaaq-cai") : actor {
    get_btc_address : (Principal) -> async Text;
    get_balance : (Text) -> async Nat64;
    send_bitcoin : (Principal, Principal, Nat64) -> async Result.Result<Text, Text>;
  };

  // Create HashMaps to store users and verifications
  private var users = HashMap.HashMap<Principal, User>(
    10,
    Principal.equal,
    Principal.hash
  );

  private var verifications = HashMap.HashMap<Text, [Principal]>(
    10,
    Text.equal,
    Text.hash
  );

  // Stable storage for upgrades
  private stable var usersEntries : [(Principal, User)] = [];
  private stable var verificationsEntries : [(Text, [Principal])] = [];

  system func preupgrade() {
    usersEntries := Iter.toArray(users.entries());
    verificationsEntries := Iter.toArray(verifications.entries());
  };

  system func postupgrade() {
    users := HashMap.fromIter<Principal, User>(usersEntries.vals(), 10, Principal.equal, Principal.hash);
    verifications := HashMap.fromIter<Text, [Principal]>(verificationsEntries.vals(), 10, Text.equal, Text.hash);
    usersEntries := [];
    verificationsEntries := [];
  };

  public shared({ caller }) func register(username: Text) : async () {
    if (users.get(caller) != null) {
      throw Error.reject("User already registered");
    };

    let btcAddress = await bitcoinIntegration.get_btc_address(caller);

    let newUser: User = {
      principal = caller;
      username = username;
      messages = [];
      btcAddress = btcAddress;
      verificationCount = 0;
      voteCount = 0;
    };

    users.put(caller, newUser);
  };

  public shared({ caller }) func sendMessage(message: Text) : async () {
    switch (users.get(caller)) {
      case (?user) {
        let updatedMessages = Array.append<Text>(user.messages, [message]);
        let updatedUser: User = {
          principal = user.principal;
          username = user.username;
          messages = updatedMessages;
          btcAddress = user.btcAddress;
          verificationCount = user.verificationCount;
          voteCount = user.voteCount;
        };
        users.put(caller, updatedUser);
      };
      case null { throw Error.reject("User not registered") };
    };
  };

  public query({ caller }) func getMessages() : async [Text] {
    switch (users.get(caller)) {
      case (?user) { user.messages };
      case null { throw Error.reject("User not registered") };
    };
  };

  public query func getUsernames() : async [Text] {
    Iter.toArray(Iter.map(users.vals(), func (user : User) : Text { user.username }));
  };

  // Function to verify information
  public shared({ caller }) func verifyInformation(info: Text) : async () {
    switch (users.get(caller)) {
      case (?user) {
        let updatedVerificationCount = user.verificationCount + 1;
        let updatedUser: User = {
          principal = user.principal;
          username = user.username;
          messages = user.messages;
          btcAddress = user.btcAddress;
          verificationCount = updatedVerificationCount;
          voteCount = user.voteCount;
        };
        users.put(caller, updatedUser);

        // Update verifications HashMap
        let currentVerifications = switch (verifications.get(info)) {
          case (?existing) existing;
          case null Array.init(0, Principal.fromActor(caller));
        };
        verifications.put(info, Array.append(currentVerifications, [caller]));
      };
      case null { throw Error.reject("User not registered") };
    };
  };

  // Function to cast a vote for a verifier
  public shared({ caller }) func voteVerifier(verifierUsername: Text) : async () {
    switch (users.get(caller)) {
      case (?user) {
        switch (Array.find<User>(Iter.toArray(users.vals()), func(u: User) : Bool { u.username == verifierUsername })) {
          case (?verifierUser) {
            let updatedVoteCount = verifierUser.voteCount + 1;
            let updatedVerifierUser: User = {
              principal = verifierUser.principal;
              username = verifierUser.username;
              messages = verifierUser.messages;
              btcAddress = verifierUser.btcAddress;
              verificationCount = verifierUser.verificationCount;
              voteCount = updatedVoteCount;
            };
            users.put(verifierUser.principal, updatedVerifierUser);
          };
          case null { throw Error.reject("Verifier user not found") };
        };
      };
      case null { throw Error.reject("User not registered") };
    };
  };

  // Function to get the top verifier
  public query func getTopVerifier() : async ?Text {
    let maxVotes = 0;
    var topVerifier: ?Text = null;

    for ((_, user) in users.entries()) {
      if (user.voteCount > maxVotes) {
        maxVotes := user.voteCount;
        topVerifier := ?user.username;
      }
    };

    topVerifier
  };

  // Function to get user's Bitcoin balance
  public shared({ caller }) func getBitcoinBalance() : async Nat64 {
    switch (users.get(caller)) {
      case (?user) { await bitcoinIntegration.get_balance(user.btcAddress) };
      case null { throw Error.reject("User not registered") };
    };
  };

  // Function to send Bitcoin
  public shared({ caller }) func sendBitcoin(to: Text, amount: Nat64) : async Result.Result<Text, Text> {
    switch (users.get(caller)) {
      case (?fromUser) {
        switch (Array.find<User>(Iter.toArray(users.vals()), func(u: User) : Bool { u.username == to })) {
          case (?toUser) {
            await bitcoinIntegration.send_bitcoin(caller, toUser.principal, amount);
          };
          case null { #err("Recipient not found") };
        };
      };
      case null { #err("Sender not registered") };
    };
  };

  // Function to mint ckBTC
  public shared({ caller }) func mintCKBTC(amount: Nat64) : async Result.Result<ckbtcLedger.BlockIndex, Text> {
    switch (users.get(caller)) {
      case (?user) {
        let transferArgs: ckbtcLedger.TransferArg = {
          memo = null;
          amount = amount;
          from_subaccount = null;
          fee = null;
          to = { owner = user.principal; subaccount = null };
          created_at_time = null;
        };

        try {
          let transferResult = await ckbtcLedger.icrc1_transfer(transferArgs);
          switch (transferResult) {
            case (#Err(transferError)) {
              return #err("Couldn't mint ckBTC:\n" # debug_show(transferError));
            };
            case (#Ok(blockIndex)) { return #ok(blockIndex) };
          };
        } catch (error : Error) {
          return #err("Reject message: " # Error.message(error));
        };
      };
      case null { return #err("User not registered") };
    };
  };

  // Function to transfer ckBTC
  public shared({ caller }) func transferCKBTC(to: Text, amount: Nat64) : async Result.Result<ckbtcLedger.BlockIndex, Text> {
    switch (users.get(caller)) {
      case (?fromUser) {
        switch (Array.find<User>(Iter.toArray(users.vals()), func(u: User) : Bool { u.username == to })) {
          case (?toUser) {
            let transferArgs: ckbtcLedger.TransferArg = {
              memo = null;
              amount = amount;
              from_subaccount = null;
              fee = null;
              to = { owner = toUser.principal; subaccount = null };
              created_at_time = null;
            };

            try {
              let transferResult = await ckbtcLedger.icrc1_transfer(transferArgs);
              switch (transferResult) {
                case (#Err(transferError)) {
                  return #err("Couldn't transfer ckBTC:\n" # debug_show(transferError));
                };
                case (#Ok(blockIndex)) { return #ok(blockIndex) };
              };
            } catch (error : Error) {
              return #err("Reject message: " # Error.message(error));
            };
          };
          case null { return #err("Recipient not found") };
        };
      };
      case null { return #err("Sender not registered") };
    };
  };

  // Function to burn ckBTC
  public shared({ caller }) func burnCKBTC(amount: Nat64) : async Result.Result<ckbtcLedger.BlockIndex, Text> {
    switch (users.get(caller)) {
      case (?user) {
        let transferArgs: ckbtcLedger.TransferArg = {
          memo = null;
          amount = amount;
          from_subaccount = null;
          fee = null;
          to = { owner = user.principal subaccount = null };
          created_at_time = null;
        };

        try {
          let transferResult = await ckbtcLedger.icrc1_transfer(transferArgs);
          switch (transferResult) {
            case (#Err(transferError)) {
              return #err("Couldn't burn ckBTC:\n" # debug_show(transferError));
            };
            case (#Ok(blockIndex)) { return #ok(blockIndex) };
          };
        } catch (error : Error) {
          return #err("Reject message: " # Error.message(error));
        };
      };
      case null { return #err("User not registered") };
    };
  };
};
