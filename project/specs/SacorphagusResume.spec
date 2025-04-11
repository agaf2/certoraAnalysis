/* SarcophagusHarness.spec
   Certora specification for verifying key properties of the SarcophagusHarness contract.
   This file includes one invariant and ten rules.
*/

///// Invariant /////
// The invariant asserts that the external function `archaeologistCount` 
// returns the length of the internal archaeologistAddresses array.
invariant validArchaeologistCount {
    SarcophagusHarness.archaeologistCount() == arrayLength(SarcophagusHarness._data.archaeologistAddresses);
}

///// Rule 1 /////
// After setting a nonzero token address, sarcoToken is nonzero.
rule TokenInitialization {
    assume(tokenAddress != address(0));
    SarcophagusHarness.setSarcoToken(tokenAddress);
    assert(SarcophagusHarness.sarcoToken() != address(0));
}

///// Rule 2 /////
// Registering a new archaeologist increases the archaeologist count by 1.
rule RegisterIncreasesCount {
    uint256 oldCount = SarcophagusHarness.archaeologistCount();
    SarcophagusHarness.registerArchaeologist(
        pubKey,              // bytes: currentPublicKey
        endpoint,            // string: endpoint
        payment,             // address: paymentAddress
        feePerByte,          // uint256: feePerByte
        minBounty,           // uint256: minimumBounty
        minDiggingFee,       // uint256: minimumDiggingFee
        maxResTime,          // uint256: maximumResurrectionTime
        freeBond             // uint256: freeBond
    );
    uint256 newCount = SarcophagusHarness.archaeologistCount();
    assert(newCount == oldCount + 1);
}

///// Rule 3 /////
// For every valid index, the archaeologist address returned is nonzero.
rule ValidArchaeologistAddresses {
    uint256 count = SarcophagusHarness.archaeologistCount();
    for (uint256 i = 0; i < count; i++) {
        address addr = SarcophagusHarness.archaeologistAddresses(i);
        assert(addr != address(0));
    }
}

///// Rule 4 /////
// Creating a new sarcophagus returns an index within bounds and increments the sarcophagus count.
rule CreateSarcophagusReturnsValidIndex {
    uint256 oldCount = SarcophagusHarness.sarcophagusCount();
    uint256 idx = SarcophagusHarness.createSarcophagus(
        name,                // string: name
        archaeologist,       // address: archaeologist
        resurrectionTime,    // uint256: resurrectionTime
        storageFee,          // uint256: storageFee
        diggingFee,          // uint256: diggingFee
        bounty,              // uint256: bounty
        identifier,          // bytes32: identifier
        recipientPublicKey   // bytes: recipientPublicKey
    );
    uint256 newCount = SarcophagusHarness.sarcophagusCount();
    assert(idx < newCount);
    assert(newCount == oldCount + 1);
}

///// Rule 5 /////
// Cancelling an existing sarcophagus returns true.
rule CancelSarcophagusWorks {
    // Precondition: create a sarcophagus first
    SarcophagusHarness.createSarcophagus(
        name, archaeologist, resurrectionTime, storageFee, diggingFee, bounty,
        identifier, recipientPublicKey
    );
    bool res = SarcophagusHarness.cancelSarcophagus(identifier);
    assert(res == true);
}

///// Rule 6 /////
// Rewrapping a sarcophagus updates its resurrectionTime to a new value.
rule RewrapUpdatesResurrectionTime {
    // Assume a sarcophagus with "identifier" exists.
    uint256 oldTime = SarcophagusHarness.sarcophagus(identifier).resurrectionTime;
    bool success = SarcophagusHarness.rewrapSarcophagus(identifier, newResTime, diggingFee, bounty);
    assert(success == true);
    uint256 updatedTime = SarcophagusHarness.sarcophagus(identifier).resurrectionTime;
    assert(updatedTime == newResTime);
}

///// Rule 7 /////
// Unwrapping a sarcophagus results in a state change such that it cannot be rewrapped.
// (Assume that after unwrapping, a field "state" becomes 0, indicating closure.)
rule UnwrapPreventsRewrap {
    bool ok = SarcophagusHarness.unwrapSarcophagus(identifier, privateKey);
    assert(ok == true);
    uint8 stateAfter = SarcophagusHarness.sarcophagus(identifier).state;
    assert(stateAfter == 0);
}

///// Rule 8 /////
// Updating an archaeologist’s profile changes its public key.
rule UpdateArchaeologistChangesKey {
    bytes memory oldKey = SarcophagusHarness.archaeologists(arch);
    bool updated = SarcophagusHarness.updateArchaeologist(
        endpoint, newKey, payment, feePerByte, minBounty, minDiggingFee, maxResTime, freeBond
    );
    assert(updated == true);
    bytes memory keyAfter = SarcophagusHarness.archaeologists(arch);
    assert(keyAfter == newKey);
}

///// Rule 9 /////
// Withdrawing bond decreases the balance correspondingly.
// (Assume a helper function getBondBalance(address) exists in the spec environment.)
rule WithdrawBondReducesBalance {
    uint256 oldBond = getBondBalance(arch);
    bool ret = SarcophagusHarness.withdrawBond(amount);
    assert(ret == true);
    uint256 newBond = getBondBalance(arch);
    assert(newBond == oldBond - amount);
}

///// Rule 10 /////
// Accusing an archaeologist returns true (indicating success).
rule AccuseArchaeologistReturnsTrue {
    bool result = SarcophagusHarness.accuseArchaeologist(identifier, singleHash, payment);
    assert(result == true);
}
