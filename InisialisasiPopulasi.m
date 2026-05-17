%=================================================================
% Membangkitkan sejumlah UkPop kromosom, masing-masing kromosom
% berisi bilangan biner (0 dan 1) sejumlah JumGen
%
% Masukan
%   UkPop  : ukuran populasi atau jumlah kromosom dalam populasi
%   JumGen : jumlah gen dalam kromosom
%
% Keluaran
%   Populasi : kumpulan kromosom, matriks berukuran UkPop x JumGen
%=================================================================
function Populasi = InisialisasiPopulasi(UkPop, JumGen)
    Populasi = fix(2 * rand(UkPop, JumGen));
end
