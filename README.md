
Untuk menjalankan jaringan Fabric secara keseluruhan dapat mengunduh source code implemnetasi pada repository Github sebagai berikut https://github.com/HugoIr/ehr-system. Setelah itu, dapat menjalankan perintah-perintah berikut secara berurutan:

./network-setup.sh down
    Perintah ini berfungsi untuk menghentikan container dan menghapus \textit{certificates}, \textit{channel artifact}, \textit{system genesis block}, log, dan \textit{file chaincode} pada jaringan Fabric. Tujuan penghapusan ini adalah agar sistem dapat kembali dijalankan seperti semula tanpa adanya konflik dengan file yang sudah pernah dibuat.

docker compose -f docker/docker-compose-ca.yaml up -d
    Perintah ini berfungsi untuk menjalankan container Certificate Authority (CA) pada Docker dimana CA ini memiliki fungsi yang sama dengan CA seperti pada umumnya, yaitu untuk menerbitkan suatu sertifikat atas entitas yang digunakan sebagai pengenal dari entitas tersebut.

./generate-certificate.sh
    Perintah ini dapat dijalankan setelah CA dijalankan karena perintah ini berisikan script untuk melakukan enroll pada CA dan menyimpan certificates yang sudah diterbitkan oleh CA.

./network--setup.sh up
    Perintah ini berfungsi untuk membuat \textit{orderer genesis block} dan menjalankan container peer, orderer, fabric-tools, dan CouchDB dengan \textit{environment} Docker yang telah disesuaikan sehingga koneksi antara masing-masing peer dapat terjadi.
        
./network--setup.sh createChannel
    Melakukan pembuatan channel dengan beberapa tahapan yaitu pembuatan konfigurasi transaksi channel, penggabungan \textit{peer} ke channel, serta melakukan penambahan konfigurasi channel agar dapat mengenali \textit{anchor peer} dari masing-masing organisasi.

./network-setup.sh deployCC
    Menjalankan perintah untuk pembuatan \textit{package chaincode} dan melakukan instalasi \textit{chaincode} pada masing-masing peer. Selanjutnya, dilakukan penyetujuan chaincode oleh \textit{organization} agar organization tersebut dapat menggunakan chaincode. Approval chaincode ini memerlukan minimum \textit{organization} untuk menyetujuinya sebagaimana ditetapkan pada LifecycleEndorsement \textit{policy} \citep{hyperledger}. Terakhir, dilakukan commit 

./consortium/ccp-generate.sh
    Merupakan file script yang digunakan untuk membuat file Common Connection Profile (CCP). CCP ini dibuat mengikuti kerangka format yang dibuat pada ccp-template.json dan ccp-template.yaml. CCP ini berisikan informasi untuk koneksi dengan jaringan Fabric.
