%=================================================================
% EKSPERIMEN 3: Pengaruh Jumlah Generasi terhadap Kualitas Solusi
%
% Fungsi: h(x1,x2) = 1000*(x1-2*x2)^2 + (1-x1)^2
%=================================================================

clc; clear all; close all;

%% Parameter tetap (konfigurasi terbaik dari Eks1 & Eks2)
Nvar     = 2;
Nbit     = 10;
JumGen   = Nbit * Nvar;
Rb       = -5.12;
Ra       =  5.12;
UkPop    = 200;
Psilang  = 0.8;
Pmutasi  = 0.05;
BilKecil = 10^-1;
Fthreshold = 1/BilKecil;
nRun     = 10;

%% Variasi jumlah generasi
MaxGOptions = [10, 20, 30, 50, 75, 100, 150, 200];
nConfig = length(MaxGOptions);

%% Penyimpanan hasil
results3 = struct();
for c = 1:nConfig
    MaxG_cur = MaxGOptions(c);
    results3(c).MaxG         = MaxG_cur;
    results3(c).bestFitness  = zeros(1, nRun);
    results3(c).minH         = zeros(1, nRun);
    results3(c).successRate  = 0;
    results3(c).avgHistory   = zeros(1, MaxG_cur);
    allHist                  = zeros(nRun, MaxG_cur);

    fprintf('MaxG = %3d | Running %d kali...', MaxG_cur, nRun);

    for r = 1:nRun
        Populasi = InisialisasiPopulasi(UkPop, JumGen);
        fitnessHist = zeros(1, MaxG_cur);

        for generasi = 1:MaxG_cur
            x = DekodekanKromosom(Populasi(1,:), Nvar, Nbit, Ra, Rb);
            Fitness(1) = EvaluasiIndividu(x, BilKecil);
            MaxF = Fitness(1); MinF = Fitness(1);
            IndeksIndividuTerbaik = 1;
            BestX = x;

            for ii = 2:UkPop
                Kromosom = Populasi(ii,:);
                x = DekodekanKromosom(Kromosom, Nvar, Nbit, Ra, Rb);
                Fitness(ii) = EvaluasiIndividu(x, BilKecil);
                if Fitness(ii) > MaxF
                    MaxF = Fitness(ii);
                    IndeksIndividuTerbaik = ii;
                    BestX = x;
                end
                if Fitness(ii) < MinF, MinF = Fitness(ii); end
            end

            fitnessHist(generasi) = MaxF;

            if MaxF >= Fthreshold, break; end

            TempPopulasi = Populasi;
            if mod(UkPop,2)==0
                IterasiMulai = 3;
                TempPopulasi(1,:) = Populasi(IndeksIndividuTerbaik,:);
                TempPopulasi(2,:) = Populasi(IndeksIndividuTerbaik,:);
            else
                IterasiMulai = 2;
                TempPopulasi(1,:) = Populasi(IndeksIndividuTerbaik,:);
            end

            LinearFitness = LinearFitnessRanking(UkPop, Fitness, MaxF, MinF);

            for jj = IterasiMulai:2:UkPop
                IP1 = RouletteWheel(UkPop, LinearFitness);
                IP2 = RouletteWheel(UkPop, LinearFitness);
                if rand < Psilang
                    Anak = PindahSilang(Populasi(IP1,:), Populasi(IP2,:), JumGen);
                    TempPopulasi(jj,:)   = Anak(1,:);
                    TempPopulasi(jj+1,:) = Anak(2,:);
                else
                    TempPopulasi(jj,:)   = Populasi(IP1,:);
                    TempPopulasi(jj+1,:) = Populasi(IP2,:);
                end
            end

            for kk = IterasiMulai:UkPop
                TempPopulasi(kk,:) = Mutasi(TempPopulasi(kk,:), JumGen, Pmutasi);
            end

            Populasi = TempPopulasi;
        end

        if generasi < MaxG_cur
            fitnessHist(generasi+1:end) = MaxF;
        end

        results3(c).bestFitness(r) = MaxF;
        results3(c).minH(r)        = (1/MaxF) - BilKecil;
        allHist(r,:) = fitnessHist;
    end

    results3(c).meanFitness = mean(results3(c).bestFitness);
    results3(c).stdFitness  = std(results3(c).bestFitness);
    results3(c).meanMinH    = mean(results3(c).minH);
    results3(c).successRate = sum(results3(c).bestFitness >= Fthreshold) / nRun * 100;
    results3(c).avgHistory  = mean(allHist, 1);

    fprintf(' Mean fitness: %.4f | Success: %.0f%%\n', ...
        results3(c).meanFitness, results3(c).successRate);
end

%% === VISUALISASI ===

% --- Plot 1: Success Rate vs MaxG ---
figure('Name', 'Eks3 - Kualitas Solusi vs Jumlah Generasi', 'Position', [50 50 900 400]);

subplot(1,2,1);
successRates3 = arrayfun(@(x) x.successRate, results3);
plot(MaxGOptions, successRates3, 'rs-', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Jumlah Generasi (MaxG)');
ylabel('Success Rate (%)');
title('Success Rate vs Jumlah Generasi');
grid on;
ylim([0 110]);

subplot(1,2,2);
meanFit3 = arrayfun(@(x) x.meanFitness, results3);
stdFit3  = arrayfun(@(x) x.stdFitness, results3);
errorbar(MaxGOptions, meanFit3, stdFit3, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Jumlah Generasi (MaxG)');
ylabel('Mean Fitness Terbaik ± Std');
title('Kualitas Solusi vs Jumlah Generasi');
grid on;

saveas(gcf, 'Eks3_KualitasVsGenerasi.png');

% --- Plot 2: Kurva konvergensi untuk MaxG tertentu ---
figure('Name', 'Eks3 - Kurva Konvergensi', 'Position', [100 100 800 500]);
colors = lines(nConfig);
hold on;
legendStr = cell(1, nConfig);
for c = 1:nConfig
    xVals = 1:MaxGOptions(c);
    plot(xVals, results3(c).avgHistory, 'Color', colors(c,:), 'LineWidth', 2);
    legendStr{c} = sprintf('MaxG=%d', MaxGOptions(c));
end
xlabel('Generasi');
ylabel('Rata-rata Fitness Terbaik');
title('Pola Konvergensi pada Berbagai Batas Generasi');
legend(legendStr, 'Location', 'southeast');
grid on;
hold off;
saveas(gcf, 'Eks3_PatterkKonvergensi.png');

%% === ANALISIS DIMINISHING RETURNS ===
fprintf('\n=== Analisis Diminishing Returns ===\n');
for c = 2:nConfig
    delta_MaxG = MaxGOptions(c) - MaxGOptions(c-1);
    delta_Fit  = meanFit3(c) - meanFit3(c-1);
    fprintf('MaxG %3d -> %3d: Delta Fitness = %+.4f (per 10 gen: %+.4f)\n', ...
        MaxGOptions(c-1), MaxGOptions(c), delta_Fit, delta_Fit/delta_MaxG*10);
end

%% === TABEL RINGKASAN ===
fprintf('\n========================================================\n');
fprintf('  RINGKASAN EKSPERIMEN 3: Pengaruh Jumlah Generasi\n');
fprintf('========================================================\n');
fprintf('%-8s %-14s %-10s %-14s %-12s\n', ...
    'MaxG', 'Mean Fitness', 'Std', 'Mean min-h', 'Success(%)');
fprintf('%s\n', repmat('-',1,60));
for c = 1:nConfig
    fprintf('%-8d %-14.4f %-10.4f %-14.6f %-12.1f\n', ...
        results3(c).MaxG, results3(c).meanFitness, results3(c).stdFitness, ...
        results3(c).meanMinH, results3(c).successRate);
end
fprintf('========================================================\n');

save('results_eks3_generasi.mat', 'results3', 'MaxGOptions');
fprintf('\nHasil disimpan ke results_eks3_generasi.mat\n');
