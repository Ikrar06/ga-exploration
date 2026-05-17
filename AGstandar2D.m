%=================================================================
% Algoritma Genetika Standar (dengan grafis 2D) terdiri dari:
%
% 1. Satu populasi dengan UkPop kromosom
% 2. Binary encoding
% 3. Linear fitness ranking
% 4. Roulette-wheel selection
% 5. Pindah silang satu titik potong
% 6. Probabilitas pindah silang dan probabilitas mutasi bernilai tetap
% 7. Elitisme, satu atau dua buah kopi dari individu bernilai fitness tertinggi
% 8. Generational replacement: mengganti semua individu dengan individu baru
%=================================================================

clc
clear all

Nvar     = 2;           % Jumlah variabel pada fungsi yang dioptimasi
Nbit     = 10;          % Jumlah bit yang mengkodekan satu variabel
JumGen   = Nbit * Nvar; % Jumlah gen dalam kromosom
Rb       = -5.12;       % Batas bawah interval
Ra       =  5.12;       % Batas atas interval

UkPop    = 200;         % Jumlah kromosom dalam populasi
Psilang  = 0.8;         % Probabilitas pindah silang
Pmutasi  = 0.05;        % Probabilitas mutasi
MaxG     = 100;         % Jumlah generasi

BilKecil  = 10^-1;
Fthreshold = 1/BilKecil;
Bgraf      = Fthreshold;

% --- Inisialisasi grafis 2D ---
hfig = figure;
hold on
title('Optimasi fungsi menggunakan AG standar dengan grafis 2D')
set(hfig, 'position', [50,50,700,450]);
set(hfig, 'DoubleBuffer', 'on');
axis([1 MaxG 0 Bgraf]);
hbestplot = plot(1:MaxG, zeros(1,MaxG));
htext1 = text(0.6*MaxG, 0.25*Bgraf, sprintf('Fitness terbaik: %7.4f', 0.0));
htext2 = text(0.6*MaxG, 0.20*Bgraf, sprintf('Variabel X1: %5.4f', 0.0));
htext3 = text(0.6*MaxG, 0.15*Bgraf, sprintf('Variabel X2: %5.4f', 0.0));
htext4 = text(0.6*MaxG, 0.10*Bgraf, sprintf('Nilai minimum: %5.4f', 0.0));
xlabel('Generasi');
ylabel('Fitness terbaik');
hold off
drawnow;

% --- Inisialisasi populasi ---
Populasi = InisialisasiPopulasi(UkPop, JumGen);

% --- Loop evolusi ---
for generasi = 1:MaxG

    % Evaluasi semua individu
    x              = DekodekanKromosom(Populasi(1,:), Nvar, Nbit, Ra, Rb);
    Fitness(1)     = EvaluasiIndividu(x, BilKecil);
    MaxF           = Fitness(1);
    MinF           = Fitness(1);
    IndeksIndividuTerbaik = 1;

    for ii = 2:UkPop
        Kromosom   = Populasi(ii,:);
        x          = DekodekanKromosom(Kromosom, Nvar, Nbit, Ra, Rb);
        Fitness(ii) = EvaluasiIndividu(x, BilKecil);
        if (Fitness(ii) > MaxF)
            MaxF = Fitness(ii);
            IndeksIndividuTerbaik = ii;
            BestX = x;
        end
        if (Fitness(ii) < MinF)
            MinF = Fitness(ii);
        end
    end

    % Update grafis 2D
    plotvector = get(hbestplot, 'YData');
    plotvector(generasi) = MaxF;
    set(hbestplot, 'YData', plotvector);
    set(htext1, 'String', sprintf('Fitness terbaik: %7.4f', MaxF));
    set(htext2, 'String', sprintf('Variabel X1: %5.4f', BestX(1)));
    set(htext3, 'String', sprintf('Variabel X2: %5.4f', BestX(2)));
    set(htext4, 'String', sprintf('Nilai minimum: %5.4f', (1/MaxF) - BilKecil));
    drawnow

    if MaxF >= Fthreshold
        break;
    end

    % Elitisme
    TempPopulasi = Populasi;
    if mod(UkPop, 2) == 0    % ukuran populasi genap
        IterasiMulai = 3;
        TempPopulasi(1,:) = Populasi(IndeksIndividuTerbaik,:);
        TempPopulasi(2,:) = Populasi(IndeksIndividuTerbaik,:);
    else                      % ukuran populasi ganjil
        IterasiMulai = 2;
        TempPopulasi(1,:) = Populasi(IndeksIndividuTerbaik,:);
    end

    % Linear Fitness Ranking
    LinearFitness = LinearFitnessRanking(UkPop, Fitness, MaxF, MinF);

    % Roulette-wheel dan pindah silang
    for jj = IterasiMulai:2:UkPop
        IP1 = RouletteWheel(UkPop, LinearFitness);
        IP2 = RouletteWheel(UkPop, LinearFitness);
        if (rand < Psilang)
            Anak = PindahSilang(Populasi(IP1,:), Populasi(IP2,:), JumGen);
            TempPopulasi(jj,:)   = Anak(1,:);
            TempPopulasi(jj+1,:) = Anak(2,:);
        else
            TempPopulasi(jj,:)   = Populasi(IP1,:);
            TempPopulasi(jj+1,:) = Populasi(IP2,:);
        end
    end

    % Mutasi pada semua kromosom
    for kk = IterasiMulai:UkPop
        TempPopulasi(kk,:) = Mutasi(TempPopulasi(kk,:), JumGen, Pmutasi);
    end

    % Generational Replacement
    Populasi = TempPopulasi;

end

fprintf('\n=== HASIL AKHIR ===\n');
fprintf('Generasi terakhir : %d\n', generasi);
fprintf('Fitness terbaik   : %.6f\n', MaxF);
fprintf('X1 terbaik        : %.6f (target: 1.0)\n', BestX(1));
fprintf('X2 terbaik        : %.6f (target: 0.5)\n', BestX(2));
fprintf('Nilai minimum h   : %.6f (target: 0.0)\n', (1/MaxF) - BilKecil);
