// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Only import what is actually used.
import "../@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./libraries/Events.sol";
import "./libraries/Types.sol";
import "./libraries/Datas.sol";
import "./libraries/Archaeologists.sol";
import "./libraries/Sarcophaguses.sol";

/**
 * @title SarcophagusHarness
 * @notice A harness version of the Sarcophagus system contract for formal verification.
 *         This version exposes the full public interface of the original contract but removes
 *         the initializer to allow manual state setup (for example, setting the token address).
 */
contract SarcophagusHarness {
    // Use the original token type.
    IERC20 public sarcoToken;

    // All system data is stored in a single instance.
    Datas.Data internal _data;

    // ------------------------------------------------
    // SETUP FUNCTIONS (for testing and state initialization)
    // ------------------------------------------------

    /**
     * @notice Sets the token address manually (bypassing the initializer).
     * @param tokenAddress The address of the token contract.
     */
    function setSarcoToken(address tokenAddress) public {
        require(tokenAddress != address(0), "Token address must be nonzero");
        sarcoToken = IERC20(tokenAddress);
    }

    // ------------------------------------------------
    // VIEW FUNCTIONS (exposing internal state for verification)
    // ------------------------------------------------

    function archaeologistCount() public view returns (uint256) {
        return _data.archaeologistAddresses.length;
    }

    function archaeologistAddresses(uint256 index) public view returns (address) {
        return _data.archaeologistAddresses[index];
    }

    function archaeologists(address account) public view returns (Types.Archaeologist memory) {
        return _data.archaeologists[account];
    }

    function sarcophagusCount() public view returns (uint256) {
        return _data.sarcophagusIdentifiers.length;
    }

    function sarcophagusIdentifier(uint256 index) public view returns (bytes32) {
        return _data.sarcophagusIdentifiers[index];
    }

    function embalmerSarcophagusCount(address embalmer) public view returns (uint256) {
        return _data.embalmerSarcophaguses[embalmer].length;
    }

    function embalmerSarcophagusIdentifier(address embalmer, uint256 index) public view returns (bytes32) {
        return _data.embalmerSarcophaguses[embalmer][index];
    }

    function archaeologistSarcophagusCount(address archaeologist) public view returns (uint256) {
        return _data.archaeologistSarcophaguses[archaeologist].length;
    }

    function archaeologistSarcophagusIdentifier(address archaeologist, uint256 index) public view returns (bytes32) {
        return _data.archaeologistSarcophaguses[archaeologist][index];
    }

    function recipientSarcophagusCount(address recipient) public view returns (uint256) {
        return _data.recipientSarcophaguses[recipient].length;
    }

    function recipientSarcophagusIdentifier(address recipient, uint256 index) public view returns (bytes32) {
        return _data.recipientSarcophaguses[recipient][index];
    }

    function archaeologistSuccessesCount(address archaeologist) public view returns (uint256) {
        return _data.archaeologistSuccesses[archaeologist].length;
    }

    function archaeologistSuccessesIdentifier(address archaeologist, uint256 index) public view returns (bytes32) {
        return _data.archaeologistSuccesses[archaeologist][index];
    }

    function archaeologistCancelsCount(address archaeologist) public view returns (uint256) {
        return _data.archaeologistCancels[archaeologist].length;
    }

    function archaeologistCancelsIdentifier(address archaeologist, uint256 index) public view returns (bytes32) {
        return _data.archaeologistCancels[archaeologist][index];
    }

    function archaeologistAccusalsCount(address archaeologist) public view returns (uint256) {
        return _data.archaeologistAccusals[archaeologist].length;
    }

    function archaeologistAccusalsIdentifier(address archaeologist, uint256 index) public view returns (bytes32) {
        return _data.archaeologistAccusals[archaeologist][index];
    }

    function archaeologistCleanupsCount(address archaeologist) public view returns (uint256) {
        return _data.archaeologistCleanups[archaeologist].length;
    }

    function archaeologistCleanupsIdentifier(address archaeologist, uint256 index) public view returns (bytes32) {
        return _data.archaeologistCleanups[archaeologist][index];
    }

    function sarcophagus(bytes32 identifier) public view returns (Types.Sarcophagus memory) {
        return _data.sarcophaguses[identifier];
    }

    // ------------------------------------------------
    // STATE-CHANGING FUNCTIONS
    // ------------------------------------------------

    function registerArchaeologist(
        bytes memory currentPublicKey,
        string memory endpoint,
        address paymentAddress,
        uint256 feePerByte,
        uint256 minimumBounty,
        uint256 minimumDiggingFee,
        uint256 maximumResurrectionTime,
        uint256 freeBond
    ) public returns (uint256) {
        return Archaeologists.registerArchaeologist(
            _data,
            currentPublicKey,
            endpoint,
            paymentAddress,
            feePerByte,
            minimumBounty,
            minimumDiggingFee,
            maximumResurrectionTime,
            freeBond,
            sarcoToken
        );
    }

    function updateArchaeologist(
        string memory endpoint,
        bytes memory newPublicKey,
        address paymentAddress,
        uint256 feePerByte,
        uint256 minimumBounty,
        uint256 minimumDiggingFee,
        uint256 maximumResurrectionTime,
        uint256 freeBond
    ) public returns (bool) {
        return Archaeologists.updateArchaeologist(
            _data,
            newPublicKey,
            endpoint,
            paymentAddress,
            feePerByte,
            minimumBounty,
            minimumDiggingFee,
            maximumResurrectionTime,
            freeBond,
            sarcoToken
        );
    }

    function withdrawBond(uint256 amount) public returns (bool) {
        return Archaeologists.withdrawBond(_data, amount, sarcoToken);
    }

    function createSarcophagus(
        string memory name,
        address archaeologist,
        uint256 resurrectionTime,
        uint256 storageFee,
        uint256 diggingFee,
        uint256 bounty,
        bytes32 identifier,
        bytes memory recipientPublicKey
    ) public returns (uint256) {
        return Sarcophaguses.createSarcophagus(
            _data,
            name,
            archaeologist,
            resurrectionTime,
            storageFee,
            diggingFee,
            bounty,
            identifier,
            recipientPublicKey,
            sarcoToken
        );
    }

    function updateSarcophagus(
        bytes memory newPublicKey,
        bytes32 identifier,
        string memory assetId,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public returns (bool) {
        return Sarcophaguses.updateSarcophagus(
            _data,
            newPublicKey,
            identifier,
            assetId,
            v,
            r,
            s,
            sarcoToken
        );
    }

    function cancelSarcophagus(bytes32 identifier) public returns (bool) {
        return Sarcophaguses.cancelSarcophagus(_data, identifier, sarcoToken);
    }

    function rewrapSarcophagus(
        bytes32 identifier,
        uint256 resurrectionTime,
        uint256 diggingFee,
        uint256 bounty
    ) public returns (bool) {
        return Sarcophaguses.rewrapSarcophagus(
            _data,
            identifier,
            resurrectionTime,
            diggingFee,
            bounty,
            sarcoToken
        );
    }

    function unwrapSarcophagus(bytes32 identifier, bytes32 privateKey) public returns (bool) {
        return Sarcophaguses.unwrapSarcophagus(
            _data,
            identifier,
            privateKey,
            sarcoToken
        );
    }

    function accuseArchaeologist(
        bytes32 identifier,
        bytes memory singleHash,
        address paymentAddress
    ) public returns (bool) {
        return Sarcophaguses.accuseArchaeologist(
            _data,
            identifier,
            singleHash,
            paymentAddress,
            sarcoToken
        );
    }

    function burySarcophagus(bytes32 identifier) public returns (bool) {
        return Sarcophaguses.burySarcophagus(_data, identifier, sarcoToken);
    }

    function cleanUpSarcophagus(bytes32 identifier, address paymentAddress) public returns (bool) {
        return Sarcophaguses.cleanUpSarcophagus(
            _data,
            identifier,
            paymentAddress,
            sarcoToken
        );
    }
}
