var SimpleSumGame = artifacts.require("./SimpleSumGame.sol");

contract('Test SimpleSumGame', function(accounts) {
  it("should check initial prize pool value correctly", async function() {
    let simpleSumGame = await SimpleSumGame.deployed();
    await web3.eth.sendTransaction({to: simpleSumGame.address, from: accounts[0], value: web3.utils.toWei("0.5", "ether")})
    let initialPrizePool = await simpleSumGame.getPrizePool.call({from: accounts[0]});
    assert.equal(initialPrizePool.toString(10), '500000000000000000');
  });

  it("should update winners correctly", async function() {
    let simpleSumGame = await SimpleSumGame.deployed();
    await simpleSumGame.submitAnswer(2, 3, {from: accounts[1]});
    await simpleSumGame.submitAnswer(1, 4, {from: accounts[2]});
    await simpleSumGame.submitAnswer(1, 5, {from: accounts[3]});
    let winnersCount = await simpleSumGame.getWinnersCount.call({from: accounts[0]});
    assert.equal(winnersCount, 2);
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
    assert.equal(currentPrizePerShare, '249999999999999999');
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
    let initialPrizePool = await simpleSumGame.getPrizePool.call({from: accounts[1]});
    let currentPrizePerShare =  await simpleSumGame.getCurrentPrizePerShare.call({from: accounts[1]});
    await simpleSumGame.claimPrize({from: accounts[1]});
    let leftPrizePool = await simpleSumGame.getPrizePool.call({from: accounts[1]});
    assert(initialPrizePool.sub(leftPrizePool).eq(currentPrizePerShare));
    await simpleSumGame.claimPrize({from: accounts[2]});
    leftPrizePool = await simpleSumGame.getPrizePool.call({from: accounts[1]});
    assert.equal(leftPrizePool.toString(10),'2');
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
    let leftovers = await simpleSumGame.getLeftovers.call({from: accounts[1]});
    assert.equal(leftovers.toString(10),'2');
    try {
      await simpleSumGame.refundLeftovers({from: accounts[1]});
      assert.fail();
    } catch (err) {
      assert.ok(/revert/.test(err.message));
    }   
    await simpleSumGame.refundLeftovers({from: accounts[0]});
    let finalPrizePool = await simpleSumGame.getPrizePool.call({from: accounts[0]});
    assert.equal(finalPrizePool.toString(10), '0');
    // TODO:
  });
});