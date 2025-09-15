const { ethers } = require("hardhat");

async function main() {
  const AduanRakyat = await ethers.getContractFactory("VoxChain");
  const aduanRakyat = await AduanRakyat.deploy();

  console.log(`Kontrak AduanRakyat berhasil di-deploy ke alamat: ${await aduanRakyat.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});