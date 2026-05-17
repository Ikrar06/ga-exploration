%=================================================================
% Menskalakan nilai fitness ke dalam ranking sehingga diperoleh
% nilai-nilai fitness baru yang berada dalam rentang [MaxF, MinF]
%
% Masukan
%   UkPop   : ukuran populasi atau jumlah kromosom dalam populasi
%   Fitness : nilai fitness, matriks ukuran 1 x UkPop
%   MaxF    : nilai fitness maximum
%   MinF    : nilai fitness minimum
%
% Keluaran
%   LFR : Linear Fitness Ranking
%=================================================================
function LFR = LinearFitnessRanking(UkPop, Fitness, MaxF, MinF)
    [~, IndF] = sort(Fitness);
    for rr = 1:UkPop
        LFR(IndF(UkPop - rr + 1)) = MaxF - (MaxF - MinF) * ((rr-1) / (UkPop-1));
    end
end
