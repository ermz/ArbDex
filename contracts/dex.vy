# @version ^0.2.0

interface iERC20:
    def transferFrom(_from: address, to: address, amount: uint256) -> bool: nonpayable
    def approve(addr: address, amount: uint256) -> bool: nonpayable
    def transfer(addr: address, amount: uint256) -> bool: nonpayable

struct Token:
    name: String[30]
    ticker: String[4]
    tokenAddr: address

struct Order:
    name: String[30]
    symbol: String[4]
    amount: uint256
    price: uint256
    side: int128
    time: uint256
    filled: uint256


tickerToToken: HashMap[String[4], Token]

assetPrice: HashMap[String[30], uint256]

addrToFunds: HashMap[address, HashMap[String[4], uint256]]

addrToTokens: HashMap[address, HashMap[String[4], uint256]]

admin: address

# Will classify an order as buy(0) or sell(1)
stateEnum: int128[2]

# String[4] = Symbol, int128 = side, Order[100] = array of Order struct
# Order struct will be in order of cheapes and earliest by time
orderLedger: HashMap[String[4], HashMap[int128, Order[100]]]

@external
def __init__():
    self.admin = msg.sender
    self.stateEnum[0] = 0
    self.stateEnum[1] = 1

@external
def addToken(_name: String[30], _ticker: String[4], _address: address) -> bool:
    assert self.admin == msg.sender
    assert self.tickerToToken[_ticker].tokenAddr == ZERO_ADDRESS, "This Token has already been added"
    self.tickerToToken[_ticker] =  Token({ name: _name, ticker: _ticker, tokenAddr: _address})
    return True

@external
@payable
def depositFunds(_ticker: String[4], amount: uint256):
    assert msg.value >= (amount * 1_000_000_000_000_000_000), "You haven't sent enough to deposit that amount of funds"
    assert self.tickerToToken[_ticker].tokenAddr != ZERO_ADDRESS, "This token doesn't exist"
    self.addrToFunds[msg.sender][_ticker] += amount

@external
def withdrawFunds(_ticker: String[4], amount: uint256):
    assert self.tickerToToken[_ticker].tokenAddr != ZERO_ADDRESS, "This token doesn't exist"
    assert self.addrToFunds[msg.sender][_ticker] >= amount, "Insufficient funds"
    assert self.balance > amount, "This contract doesn't have those funds avaiable"
    self.addrToFunds[msg.sender][_ticker] -= amount
    send(msg.sender, amount)

# The user who call depositTokens, will have to approve this address
# In order for the call to work, so they'll have to do that before they can call this function
@external
def depositTokens(_ticker: String[4], amount: uint256):
    assert self.tickerToToken[_ticker].tokenAddr != ZERO_ADDRESS, "This token does not exist"
    iERC20(self.tickerToToken[_ticker].tokenAddr).transferFrom(msg.sender, self, amount)
    self.addrToTokens[msg.sender][_ticker] += amount

@external
def withdrawTokens(_ticker: String[4], amount: uint256):
    assert self.tickerToToken[_ticker].tokenAddr != ZERO_ADDRESS, "This token does not exist"
    assert self.addrToTokens[msg.sender][_ticker] >= amount, "You don't have enough token to withdraw"
    iERC20(self.tickerToToken[_ticker].tokenAddr).transfer(msg.sender, amount)
    self.addrToTokens[msg.sender][_ticker] -= amount

@external
def createLimitOrder(
        _name: String[30],
        _symbol: String[4],
        _amount: uint256,
        _price: uint256,
        _side: int128,
        _time: uint256,
        _filled: uint256
    ) -> bool:

    newOrder: Order = Order({
        name: _name,
        symbol: _symbol,
        amount: _amount,
        price: _price,
        side: _side,
        time: _time,
        filled: _filled
    })

    # self.orderLedger[_symbol][_side][0] = newOrder
    # for i in self.orderLedger[_symbol][_side]:
    #     pass

    # You cannot modify a value in an array while it is being iterated,
    # or call to a function that might modify the array being iterated.
    # Need something to keep things in order by price and date
    # Everything becomes too convoluted
    return True


@external
@view
def viewPrices(sticker: String[30]) -> uint256:
    return self.assetPrice[sticker]

@external
def buyAsset(sticker: String[30], amount: uint256, price: uint256) -> bool:
    #ERC20 implementaion
    return True

@external
def sellAsset(sticker: String[30], amount: uint256, price: uint256) -> bool:
    #ERC20 implementation
    return True