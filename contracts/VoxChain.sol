// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VoxChain {
    struct Pengaduan {
        uint256 id;
        string deskripsi;
        address pengirim;
        uint256 timestamp;
        uint8 status; // 0: Terkirim, 1: Dalam Proses, 2: Selesai
    }

    address public owner;
    uint256 private nextPengaduanId = 1;
    Pengaduan[] public daftarPengaduan;

    event PengaduanBaru(uint256 indexed id, address indexed pengirim);

    modifier onlyOwner() {
        require(msg.sender == owner, "Hanya pemilik yang bisa memanggil fungsi ini.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function buatPengaduan(string memory _deskripsi) public {
        daftarPengaduan.push(Pengaduan({
            id: nextPengaduanId,
            deskripsi: _deskripsi,
            pengirim: msg.sender,
            timestamp: block.timestamp,
            status: 0
        }));
        emit PengaduanBaru(nextPengaduanId, msg.sender);
        nextPengaduanId++;
    }

    function ubahStatus(uint256 _id, uint8 _statusBaru) public onlyOwner {
        require(_id > 0 && _id <= daftarPengaduan.length, "ID pengaduan tidak valid.");
        daftarPengaduan[_id - 1].status = _statusBaru;
    }

    function getPengaduan(uint256 _id) public view returns (uint256, string memory, address, uint256, uint8) {
        require(_id > 0 && _id <= daftarPengaduan.length, "ID pengaduan tidak valid.");
        Pengaduan storage p = daftarPengaduan[_id - 1];
        return (p.id, p.deskripsi, p.pengirim, p.timestamp, p.status);
    }
}