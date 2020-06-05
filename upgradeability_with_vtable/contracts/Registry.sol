pragma solidity ^0.6.8;

import './IRegistry.sol';
import './Upgradeable.sol';
import './UpgradeabilityProxy.sol';

/**
 * @title Registry
 * @dev This contract works as a registry of versions, it holds the implementations for the registered versions.
 */
contract Registry is IRegistry {
  // Mapping of versions to implementations of different functions
  mapping (string => mapping (bytes4 => address)) internal versions;

  // Mapping of versions to list of identifiers of its functions
  mapping (string => bytes4[]) internal funcs;
  
  // Fallback function implementation for each version
  mapping (string => address) internal fallbacks;

  /**
   * @dev Returns a function name and implementation for a given version, given its index
   */
  function getFunctionByIndex(string memory version, uint256 index) public view override returns (bytes4, address) {
    bytes4 func = funcs[version][index];
    return (funcs[version][index], versions[version][func]);
  }

  /**
   * @dev Returns the number of functions (excluding the fallback function) registered for a specific version
   */
  function getFunctionCount(string memory version) public view override returns (uint256) {
    return funcs[version].length;
  }

  /**
   * @dev Returns the the fallback function for a specific version, if registered
   */
  function getFallback(string memory version) public view override returns (address) {
    return fallbacks[version];
  }

  /**
   * @dev Registers a fallback function implementation for a version
   */
  function addFallback(string memory version, address implementation) public {
    require(fallbacks[version] == address(0));
    fallbacks[version] = implementation;
    emit FallbackAdded(version, implementation);
  }
  
  function funcToBytes4(string memory func) public pure returns (bytes4){
      bytes memory s = abi.encodePacked(func);
      return bytes4(keccak256(s));
  } 
  
  function funcToBytes4_v2(string memory func) public pure returns (bytes4){
      bytes memory s = bytes(func);
      return bytes4(keccak256(s));
  } 

  /**
  * @dev Registers a new version of a function with its implementation address
  * @param version representing the version name of the new function implementation to be registered
  * @param func representing the name of the function to be registered
  * @param implementation representing the address of the new function implementation to be registered
  */
  function addVersionFromName(string memory version, string memory func, address implementation) public override {
    return addVersion(version, bytes4(keccak256(bytes(func))), implementation);
  }

  /**
  * @dev Registers a new version of a function with its implementation address
  * @param version representing the version name of the new function implementation to be registered
  * @param func representing the signature of the function to be registered
  * @param implementation representing the address of the new function implementation to be registered
  */
  function addVersion(string memory version, bytes4 func, address implementation) public override{
    require(versions[version][func] == address(0));
    versions[version][func] = implementation;
    funcs[version].push(func);
    VersionAdded(version, func, implementation);
  }

  /**
  * @dev Tells the address of the function implementation for a given version
  * @param version representing the version of the function implementation to be queried
  * @param func representing the signature of the function to be queried
  * @return address of the function implementation registered for the given version
  */
  function getFunction(string memory version, bytes4 func) public view override returns (address) {
    return versions[version][func];
  }

  /**
  * @dev Creates an upgradeable proxy
  * @return address of the new proxy created
  */
  function createProxy(string memory version) public payable returns (UpgradeabilityProxy) {
    UpgradeabilityProxy proxy = new UpgradeabilityProxy(version);
    //Upgradeable(address(proxy)).initialize.value(msg.value)(msg.sender);
    Upgradeable(address(proxy)).initialize{value: msg.value}(msg.sender);
    ProxyCreated(address(proxy));
    return proxy;
  }
}
