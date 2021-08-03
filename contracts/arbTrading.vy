# @version ^0.2.0

interface iDex:
    def viewPrices(sticker: String[30]) -> uint256: view
    def buyAsset(sticker: String[30], amount: uint256, price: uint256) -> bool: nonpayable
    def sellAsset(sticker: String[30], amount: uint256, price: uint256) -> bool: nonpayable

interface iOracle:
    def getData(dataKey: bytes32) -> uint256: view

admin: address
oracle: address

struct Asset:
    name: String[30]
    dex: address

nameToAsset: HashMap[String[30], Asset]

@external
def __init__():
    self.admin = msg.sender

@external
def setupOracle(addr: address):
    assert self.admin == msg.sender, "Only admin may add Oracle address"
    self.oracle = addr

@external
def addAsset(_name: String[30], _dex: address) -> bool:
    self.nameToAsset[_name] = Asset({name: _name, dex: _dex})
    return True

@external
def tradeAsset(_name: String[30], date: int128) -> bool:
    assert self.nameToAsset[_name].dex != ZERO_ADDRESS, "This asset does not exist"
    # keccak256 will only take one parameter(String, Bytes, bytes32)
    dataKey: bytes32 = keccak256(convert(date, bytes32))

    # Use Oracle to fetch data validity and use dex to find trade info
    oraclePrice: uint256 = iOracle(self.oracle).getData(dataKey)
    dexPrice: uint256 = iDex(self.nameToAsset[_name].dex).viewPrices(_name)

    amount: uint256 = 1_000_000_000_000_000_000 / dexPrice
    if dexPrice > oraclePrice:
        iDex(self.nameToAsset[_name].dex).sellAsset(_name, amount, (99 * dexPrice) / 100)
    elif dexPrice < oraclePrice:
        iDex(self.nameToAsset[_name].dex).buyAsset(_name, amount, (101 * dexPrice) / 100)

    return True