var SimpleSumGame = artifacts.require("./SimpleSumGame.sol");

contract('Test SimpleSumGame', function(accounts) {

  it("should check initial prize pool value correctly", async function() {
    let simpleSumGame = await SimpleSumGame.deployed();
    await web3.eth.sendTransaction({to: simpleSumGame.address, from: accounts[0], value: web3.utils.toWei("0.5", "ether")})
    let initialPrizePool = await simpleSumGame.getInitialPrizePool.call({from: accounts[0]});
    assert(initialPrizePool.toString(16), '500000000000000000');
  });

  it("should update winners correctly", async function() {
    let simpleSumGame = await SimpleSumGame.deployed();
    await simpleSumGame.submitAnswer(2, 3, {from: accounts[1]});
    await simpleSumGame.submitAnswer(1, 4, {from: accounts[2]});
    await simpleSumGame.submitAnswer(1, 5, {from: accounts[3]});
    let winnersCount = await simpleSumGame.getWinnersCount.call({from: accounts[0]});
    assert(winnersCount, 2);
  });

  it("should not be able to submit answer twice", async function() {
    let simpleSumGame = await SimpleSumGame.deployed();
    try {
      await simpleSumGame.submitAnswer(3, 2, {from: accounts[1]});
      assert.fail();
    } catch (err) {
      assert.ok(/revert/.test(err.message));
    }    
  });

  it("should not be able to claim if not frozen", async function() {
    let simpleSumGame = await SimpleSumGame.deployed();
    try {
      await simpleSumGame.claimPrize({from: accounts[1]});
      assert.fail();
    } catch (err) {
      assert.ok(/revert/.test(err.message));
    }    
  });

  it("should compute prize per share correctly", async function() {
    let simpleSumGame = await SimpleSumGame.deployed();
    let currentPrizePerShare =  await simpleSumGame.getCurrentPrizePerShare.call({from: accounts[1]});
    assert(currentPrizePerShare, '249999999999999999');
  });

  it("should not be able to submit new answer once frozen", async function() {
    let simpleSumGame = await SimpleSumGame.deployed();
    await simpleSumGame.freeze({from: accounts[0]});
    try {
      await simpleSumGame.submitAnswer(1, 4, {from: accounts[3]});
      assert.fail();
    } catch (err) {
      assert.ok(/revert/.test(err.message));
    }   
  });

  it("should be able to claim prize correctly", async function() {
    let simpleSumGame = await SimpleSumGame.deployed();
    await simpleSumGame.claimPrize({from: accounts[1]});
    let initialPrizePool = await simpleSumGame.getInitialPrizePool.call({from: accounts[1]});
    console.log(initialPrizePool.toString(10));
    // TODO: 
  });

  it("should not be able to claim prize twice", async function() {
    let simpleSumGame = await SimpleSumGame.deployed();
    try {
      await simpleSumGame.claimPrize({from: accounts[1]});
      assert.fail();
    } catch (err) {
      assert.ok(/revert/.test(err.message));
    }   
  });

  it("owner should be able to claim leftovers", async function() {
    let simpleSumGame = await SimpleSumGame.deployed();
    // TODO:
  });
});