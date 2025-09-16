// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VoxChain {
    struct Pengaduan {
        uint256 id;
        string judul; // Judul Pengaduan
        string deskripsi; // Deskripsi Detail
        string kategori; // Kategori Pengaduan
        string lokasi; // Lokasi Spesifik
        uint256 tanggalKejadian; // Tanggal/Waktu Kejadian
        address pengirim;
        uint256 timestampPengiriman; // Waktu pengaduan dikirim
        uint8 status; // 0: Terkirim, 1: Diverifikasi, 2: Diproses, 3: Selesai
        string tindakLanjutPemerintah; // Tindak Lanjut Pemerintah
    }

    address public owner;
    uint256 private nextPengaduanId = 1;
    mapping(uint256 => Pengaduan) public daftarPengaduan; // Menggunakan mapping untuk akses yang lebih efisien berdasarkan ID

    event PengaduanBaru(uint256 indexed id, address indexed pengirim, string judul);
    event StatusDiubah(uint256 indexed id, uint8 statusBaru);
    event TindakLanjutDitambahkan(uint256 indexed id, string tindakLanjut);

    modifier onlyOwner() {
        require(msg.sender == owner, "Hanya pemilik yang bisa memanggil fungsi ini.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice Membuat pengaduan baru dengan detail lengkap.
     * @param _judul Judul singkat dan jelas dari pengaduan.
     * @param _deskripsi Deskripsi detail mengenai masalah yang dilaporkan.
     * @param _kategori Kategori pengaduan (misal: Infrastruktur, Lingkungan, dll.).
     * @param _lokasi Lokasi spesifik kejadian (jalan, RT/RW, kelurahan, dll.).
     * @param _tanggalKejadian Waktu kejadian masalah dilaporkan.
     */
    function buatPengaduan(
        string memory _judul,
        string memory _deskripsi,
        string memory _kategori,
        string memory _lokasi,
        uint256 _tanggalKejadian
    ) public {
        uint256 currentId = nextPengaduanId;
        daftarPengaduan[currentId] = Pengaduan({
            id: currentId,
            judul: _judul,
            deskripsi: _deskripsi,
            kategori: _kategori,
            lokasi: _lokasi,
            tanggalKejadian: _tanggalKejadian,
            pengirim: msg.sender,
            timestampPengiriman: block.timestamp,
            status: 0, // Status awal: Terkirim
            tindakLanjutPemerintah: "" // Awalnya kosong
        });
        emit PengaduanBaru(currentId, msg.sender, _judul);
        nextPengaduanId++;
    }

    /**
     * @notice Mengubah status pengaduan. Hanya dapat dipanggil oleh pemilik (pemerintah).
     * @param _id ID pengaduan yang akan diubah statusnya.
     * @param _statusBaru Status baru untuk pengaduan (0: Terkirim, 1: Diverifikasi, 2: Diproses, 3: Selesai).
     */
    function ubahStatus(uint256 _id, uint8 _statusBaru) public onlyOwner {
        require(_id > 0 && _id < nextPengaduanId, "ID pengaduan tidak valid.");
        require(_statusBaru >= 0 && _statusBaru <= 3, "Status tidak valid. Gunakan 0, 1, 2, atau 3.");
        daftarPengaduan[_id].status = _statusBaru;
        emit StatusDiubah(_id, _statusBaru);
    }

    /**
     * @notice Menambahkan tindak lanjut dari pemerintah untuk sebuah pengaduan.
     * @param _id ID pengaduan yang akan diberi tindak lanjut.
     * @param _tindakLanjut Deskripsi tindak lanjut yang dilakukan pemerintah.
     */
    function tambahTindakLanjut(uint256 _id, string memory _tindakLanjut) public onlyOwner {
        require(_id > 0 && _id < nextPengaduanId, "ID pengaduan tidak valid.");
        require(bytes(_tindakLanjut).length > 0, "Tindak lanjut tidak boleh kosong.");
        daftarPengaduan[_id].tindakLanjutPemerintah = _tindakLanjut;
        emit TindakLanjutDitambahkan(_id, _tindakLanjut);
    }

    /**
     * @notice Mendapatkan detail lengkap dari sebuah pengaduan berdasarkan ID.
     * @param _id ID pengaduan yang ingin diambil datanya.
     * @return id ID pengaduan.
     * @return judul Judul pengaduan.
     * @return deskripsi Deskripsi detail pengaduan.
     * @return kategori Kategori pengaduan.
     * @return lokasi Lokasi kejadian pengaduan.
     * @return tanggalKejadian Waktu kejadian pengaduan.
     * @return pengirim Alamat pengirim pengaduan.
     * @return timestampPengiriman Waktu pengaduan dikirim ke sistem.
     * @return status Status pengaduan saat ini.
     * @return tindakLanjutPemerintah Tindak lanjut yang telah dilakukan pemerintah.
     */
    function getPengaduan(uint256 _id)
        public
        view
        returns (
            uint256 id,
            string memory judul,
            string memory deskripsi,
            string memory kategori,
            string memory lokasi,
            uint256 tanggalKejadian,
            address pengirim,
            uint256 timestampPengiriman,
            uint8 status,
            string memory tindakLanjutPemerintah
        )
    {
        require(_id > 0 && _id < nextPengaduanId, "ID pengaduan tidak valid.");
        Pengaduan storage p = daftarPengaduan[_id];
        return (
            p.id,
            p.judul,
            p.deskripsi,
            p.kategori,
            p.lokasi,
            p.tanggalKejadian,
            p.pengirim,
            p.timestampPengiriman,
            p.status,
            p.tindakLanjutPemerintah
        );
    }

    /**
     * @notice Mendapatkan jumlah total pengaduan yang telah dibuat.
     * @return uint256 Jumlah total pengaduan.
     */
    function getTotalPengaduan() public view returns (uint256) {
        return nextPengaduanId - 1;
    }

    /**
     * @notice Mengembalikan daftar semua ID pengaduan yang ada.
     * @return uint256[] Array berisi ID semua pengaduan.
     */
    function getAllPengaduanIds() public view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](nextPengaduanId - 1);
        for (uint256 i = 1; i < nextPengaduanId; i++) {
            ids[i-1] = i;
        }
        return ids;
    }
}