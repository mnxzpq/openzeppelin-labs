pragma solidity ^0.6.8;


/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
abstract contract Proxy {
  /**
  * @dev Tells the address of the implementation where every call will be delegated.
  * @return address of the implementation to which it will be delegated
  */
  function implementation(bytes4 func) public view virtual returns (address);

  /**
  * @dev Fallback function allowing to perform a delegatecall to the given implementation.
  * This function will return whatever the implementation call returns
  */
//   function () payable public {
//     address _impl = implementation(msg.sig);
//     require(_impl != address(0));

//     assembly {
//       let ptr := mload(0x40)
//       calldatacopy(ptr, 0, calldatasize)
//       let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
//       let size := returndatasize
//       returndatacopy(ptr, 0, size)

//       switch result
//       case 0 { revert(ptr, size) }
//       default { return(ptr, size) }
//     }
//   }
  
  fallback() external payable{
    address _impl = implementation(msg.sig);
    require(_impl != address(0));

    (bool callSuccess,) = _impl.delegatecall(msg.data);
    if (callSuccess) {
        // copy result of the request to the return data
        // we can use the second return value from `delegatecall` (bytes memory)
        // but it will consume a little more gas
        assembly {
            returndatacopy(0x0, 0x0, returndatasize())
            return(0x0, returndatasize())
        }
    } else {
        revert();
    }
  }
}
