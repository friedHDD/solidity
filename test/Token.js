const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Token contract", function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const [owner,airdropBox] = await ethers.getSigners();

    const hardhatToken = await ethers.deployContract("Token",[airdropBox.address]);

    const ownerBalance = await hardhatToken.balanceOf(owner.address);
    const totalSupply = await hardhatToken.totalSupply();
    const totalAirdrop = await hardhatToken.totalAirdrop();
    
    expect(ownerBalance).to.equal(totalSupply - totalAirdrop);
    

    const airdropBoxBalance = await hardhatToken.balanceOf(airdropBox.address);
    expect(airdropBoxBalance).to.equal(totalAirdrop);
  });
});