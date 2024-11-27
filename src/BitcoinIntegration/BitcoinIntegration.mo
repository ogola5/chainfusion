import Bitcoin "mo:bitcoin";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

actor BitcoinIntegration {
  type SendResult = Result.Result<Text, Text>;

  public func get_btc_address(user: Principal) : async Text {
    let network = #Testnet;
    let key_name = "user_" # Principal.toText(user);
    let derivation_path = [];
    
    let res = await Bitcoin.get_p2pkh_address(network, key_name, derivation_path);
    switch res {
      case (#Ok(address)) { address };
      case (#Err(err)) {
        Debug.trap("Failed to get P2PKH address: " # debug_show(err));
      };
    };
  };

  public func get_balance(address: Text) : async Nat64 {
    let network = #Testnet;
    let res = await Bitcoin.get_balance(network, address);
    switch res {
      case (#Ok(satoshi)) { satoshi };
      case (#Err(err)) {
        Debug.trap("Failed to get balance: " # debug_show(err));
      };
    };
  };

  public func send_bitcoin(from: Principal, to: Principal, amount: Nat64) : async SendResult {
    let network = #Testnet;
    let from_key_name = "user_" # Principal.toText(from);
    let to_address = await get_btc_address(to);

    let res = await Bitcoin.send(network, from_key_name, to_address, amount, null);
    switch res {
      case (#Ok(txid)) { #ok("Transaction sent. TXID: " # Blob.toHex(txid)) };
      case (#Err(err)) { #err("Failed to send Bitcoin: " # debug_show(err)) };
    };
  };
}