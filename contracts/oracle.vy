# @version ^0.2.0

struct Result:
    exist: bool
    payload: uint256
    approvedNumber: uint256


validators: address[10]

keyToResult: HashMap[bytes32, Result]

addrToApprove: HashMap[address, HashMap[bytes32, bool]]

@external
def __init__(_validators: address[10]):
    self.validators = _validators

@internal
@view
def realValidator(addr: address) -> bool:
    for i in self.validators:
        if i == addr:
            return True
    
    return False

@external
def feedData(dataKey: bytes32, _payload: uint256) -> bool:
    assert self.keyToResult[dataKey].exist == False, "Data already exists"
    assert self.realValidator(msg.sender) == True, "You must be a validator to feed data"
    self.keyToResult[dataKey] = Result({exist: True, payload: _payload, approvedNumber: 1})
    self.addrToApprove[msg.sender][dataKey] = True
    return True

@external
def approveData(dataKey: bytes32) -> bool:
    assert self.keyToResult[dataKey].exist == True, "Data doesn't exist"
    assert self.realValidator(msg.sender) == True, "You must be a validator to approve data"
    assert self.addrToApprove[msg.sender][dataKey] == False, "You've already approved this data"
    self.addrToApprove[msg.sender][dataKey] = True
    self.keyToResult[dataKey].approvedNumber += 1
    return True

@external
def getData(dataKey: bytes32) -> uint256:
    # I could add an assertion that will allow a piece of data to only work
    # once a certain amount of approvals have been commited
    # or I can leave it up to the function that calls this function
    assert self.keyToResult[dataKey].exist == True, "This data doens't exist"
    assert self.keyToResult[dataKey].approvedNumber >= 6, "Data hasn't been approved enough to be reiable"
    return self.keyToResult[dataKey].payload