const { expect } = require('chai');

describe('LendToken', function () {
  let lendToken;
  let owner, recipient;
  

  beforeEach(async function () {
    const LendToken = await ethers.getContractFactory('LendToken');
    lendToken = await LendToken.deploy();
    await lendToken.deployed();
    [owner, recipient] = await ethers.getSigners();
    
  });

  it('Should have correct name, symbol and decimals', async function () {
    expect(await lendToken.name()).to.equal('Lend Token');
    expect(await lendToken.symbol()).to.equal('LEN');
    expect(await lendToken.decimals()).to.equal(18);
  });

  it('Should mint initial supply to owner', async function () {
    const initialMintAmount = ethers.utils.parseUnits('1000000', 18);
    expect(await lendToken.balanceOf(owner.address)).to.equal(initialMintAmount);
  });

});

describe('BorrowToken', function () {
  let borrowToken;
  let owner, recipient;
  

  beforeEach(async function () {
    const BorrowToken = await ethers.getContractFactory('BorrowToken');
    borrowToken = await BorrowToken.deploy();
    await borrowToken.deployed();
    [owner, recipient] = await ethers.getSigners();
    
  });

  it('Should have correct name, symbol and decimals', async function () {
    expect(await borrowToken.name()).to.equal('Borrow Token');
    expect(await borrowToken.symbol()).to.equal('BOR');
    expect(await borrowToken.decimals()).to.equal(18);
  });

  it('Should mint initial supply to owner', async function () {
    const initialMintAmount = ethers.utils.parseUnits('1000000', 18);
    expect(await borrowToken.balanceOf(owner.address)).to.equal(initialMintAmount);
  });

});

describe("Oracle", function() {
  let Oracle;
  let oracle;

  // const mockPriceFeedAddress = ethers.constants.AddressZero;

  const tokenAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F"; // DAI Token Address

  beforeEach(async function() {
    Oracle = await ethers.getContractFactory("Oracle");
    oracle = await Oracle.deploy();
    await oracle.deployed();

    // await oracle.tokenToPriceFeed(tokenAddress);
  });

  it("should return the correct price for a token in dollars", async function() {
    const expectedPrice = await getExpectedPrice();
    const amount = ethers.utils.parseUnits("1", 18);

    const result = await oracle.getDollarEquivalentOfThisToken(tokenAddress, amount);

    expect(result.toString()).to.equal(expectedPrice);
  });
});

async function getExpectedPrice() {
  const daiPriceFeedAddress = "0x773616E4d11A78F511299002da57A0a94577F1f4"; // Chainlink Price Feed for DAI/USD

  const daiPriceFeed = await ethers.getContractAt("AggregatorV3Interface", daiPriceFeedAddress);
  const [price, , , , ] = await daiPriceFeed.latestRoundData();
  return price.toString();
}
