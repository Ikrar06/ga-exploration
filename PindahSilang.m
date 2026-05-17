%=================================================================
% Memindah-silangkan bagian kromosom Bapak dan Ibu yang dipotong
% secara random, sehingga dihasilkan dua buah kromosom Anak
%
% Masukan
%   Bapak  : kromosom, matriks berukuran 1 x JumGen
%   Ibu    : kromosom, matriks berukuran 1 x JumGen
%   JumGen : jumlah gen
%
% Keluaran
%   Anak : kromosom hasil pindah silang, matriks berukuran 2 x JumGen
%=================================================================
function Anak = PindahSilang(Bapak, Ibu, JumGen)
    TP = 1 + fix(rand * (JumGen - 1));
    Anak(1,:) = [Bapak(1:TP)  Ibu(TP+1:JumGen)];
    Anak(2,:) = [Ibu(1:TP)    Bapak(TP+1:JumGen)];
end
