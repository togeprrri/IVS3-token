const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token contract", function () {

    async function deployToken() {
        const [deployer, acc1, acc2, acc3, acc4] = await ethers.getSigners();

        const IterableMapping = await ethers.getContractFactory("IterableMapping");
    
        const itMap = await IterableMapping.deploy();
        const itMapAddress = await itMap.address;
    
        const Token = await ethers.getContractFactory("Token", {
            libraries: {
                IterableMapping: itMapAddress
            }
        });
    
        const token = await Token.deploy();

        return {Token, token, deployer, acc1, acc2, acc3, acc4};
    };

    describe("ERC-20 Token Standard", function () {
        it("Should be all functions", async function() {
            const { token } = await loadFixture(deployToken);
            expect(await token.name, "Not exist function 'name'").to.be.a('function');
            expect(await token.symbol, "Not exist function 'symbol'").to.be.a('function');
            expect(await token.decimals, "Not exist function 'decimals'").to.be.a('function');
            expect(await token.totalSupply, "Not exist function 'totalSupply'").to.be.a('function');
            expect(await token.balanceOf, "Not exist function 'balanceOf'").to.be.a('function');
            expect(await token.transfer, "Not exist function 'transfer'").to.be.a('function');
            expect(await token.transferFrom, "Not exist function 'transferFrom'").to.be.a('function');
            expect(await token.approve, "Not exist function 'approve'").to.be.a('function');
            expect(await token.allowance, "Not exist function 'allowance'").to.be.a('function');
        });
    });

    describe("Deployment", function () {
        it("The deployer should be the first owner", async function() {
            const { token } = await loadFixture(deployToken);

            expect(await token.ownersCount(), "The owners count is not one").to.equal(1);
        });

        it("Should be changed total supply", async function() {
            const { token, deployer } = await loadFixture(deployToken);

            const decimals = await token.decimals();

            expect(
                await token.totalSupply(), 
                "Total supply doesn't equal to deployer's balance"
            ).to.equal(await token.balanceOf(deployer.address));
        });
    });

    describe("Transfer", function () {
        it("Should transfer tokens from sender account to another", async function() {
            const { token, deployer, acc1, acc2 } = await loadFixture(deployToken);

            await expect(
                await token.transfer(acc1.address, 50),
                "Error in function 'transfer' when transfer token from owner"
            ).to.changeTokenBalances(token, [deployer, acc1], [-50, 50]);

            await expect(
                await token.connect(acc1).transfer(acc2.address, 50),
                "Error in function 'transfer' when transfer token from not owner"
            ).to.changeTokenBalances(token, [acc1, acc2], [-50, 50]);
        })

        it("Should transfers tokens with function 'transferFrom'", async function() {
            const { token, deployer, acc1, acc2 } = await loadFixture(deployToken);
            token.approve(acc1.address, 50);

            expect(
                await token.allowance(deployer.address, acc1.address), 
                "Approve error"
            ).to.equal(50);

            await expect(
                await token.connect(acc1).transferFrom(deployer.address, acc2.address, 50),
                "Not transfered tokens with 'transferFrom' function"
            ).to.changeTokenBalances(token, [deployer, acc2], [-50,50]);

            expect(
                await token.allowance(deployer.address, acc1.address), 
                "Not changed allowance after transfer"
            ).to.equal(0);
        })
    })
    describe("Getters", function () {
        it("name()", async function () {
            const { token } = await loadFixture(deployToken);

            expect(await token.name()).to.equal("Fourth Ivasiuk Token");
        });

        it("symbol()", async function () {
            const { token } = await loadFixture(deployToken);

            expect(await token.symbol()).to.equal("IVS3");
        });

        it("decimals()", async function () {
            const { token } = await loadFixture(deployToken);

            expect(await token.decimals()).to.equal(18);
        });
    })
});