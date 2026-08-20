function Plot_data()

% =========================================================================
% Plot_data
%
% Input:
%   Temp/Sag/Model1.mat ... Model8.mat
%   Temp/Swell/Model1.mat ... Model8.mat
%   Temp/Harmonics/Model1.mat ... Model8.mat
%
% Each Model#.mat is expected to contain:
%   Model#.out1.Load_current
%   Model#.out1.Load_Voltage
%   Model#.out1.Input_current
%   Model#.out1.Input_Voltage
%
% Waveforms are cropped to 0.05 s - 0.50 s.
%
% Output:
%   Results/<Signal>/
%
%   Load_Current_Waveforms/
%       Load_Current_Models_1_3.png
%       Load_Current_Models_1_3_Model1.csv
%       Load_Current_Models_1_3_Model2.csv
%       Load_Current_Models_1_3_Model3.csv
%       Load_Current_Models_4_6.png
%       ...
%
%   Load_Voltage_Waveforms/
%       image + corresponding model CSV files
%
%   Input_Current_Waveforms/
%       image + corresponding model CSV files
%
%   Input_Voltage_Waveforms/
%       image + corresponding model CSV files
%
%   Individual_Load_Current/
%       Model1_Load_Current.png
%       Model1_Load_Current.csv
%
%   Individual_Input_Voltage/
%       Model1_Input_Voltage.png
%       Model1_Input_Voltage.csv
%
%   Apparent_Power/
%       Apparent_Power_Bar.png
%       Apparent_Power.csv
%
%   Power_Factor/
%       Power_Factor_Bar.png
%       Power_Factor.csv
%
%   Reactive_Power/
%       Reactive_Power_Bar.png
%       Reactive_Power.csv
%
%   THD/
%       THD_Bar.png
%       THD.csv
%
% =========================================================================

clc;
close all;

Signals = ["Sag","Swell","Harmonics"];

StartTime = 0.05;
EndTime   = 0.50;

ResultsRoot = "Results";

if ~exist(ResultsRoot,'dir')
    mkdir(ResultsRoot);
end

for s = 1:numel(Signals)

    SignalName = Signals(s);

    InputFolder  = fullfile("Temp",SignalName);
    OutputFolder = fullfile(ResultsRoot,SignalName);

    % =====================================================================
    % CREATE OUTPUT FOLDERS
    % =====================================================================

    LoadCurrentFolder = fullfile(OutputFolder,"Load_Current_Waveforms");
    LoadVoltageFolder = fullfile(OutputFolder,"Load_Voltage_Waveforms");
    InputCurrentFolder = fullfile(OutputFolder,"Input_Current_Waveforms");
    InputVoltageFolder = fullfile(OutputFolder,"Input_Voltage_Waveforms");

    IndividualLoadCurrentFolder = ...
        fullfile(OutputFolder,"Individual_Load_Current");

    IndividualInputVoltageFolder = ...
        fullfile(OutputFolder,"Individual_Input_Voltage");

    ApparentPowerFolder = fullfile(OutputFolder,"Apparent_Power");
    PowerFactorFolder   = fullfile(OutputFolder,"Power_Factor");
    ReactivePowerFolder = fullfile(OutputFolder,"Reactive_Power");
    THDFolder           = fullfile(OutputFolder,"THD");

    Folders = { ...
        OutputFolder, ...
        LoadCurrentFolder, ...
        LoadVoltageFolder, ...
        InputCurrentFolder, ...
        InputVoltageFolder, ...
        IndividualLoadCurrentFolder, ...
        IndividualInputVoltageFolder, ...
        ApparentPowerFolder, ...
        PowerFactorFolder, ...
        ReactivePowerFolder, ...
        THDFolder};

    for f = 1:numel(Folders)
        if ~exist(Folders{f},'dir')
            mkdir(Folders{f});
        end
    end

    % =====================================================================
    % LOAD ALL 8 MODELS
    % =====================================================================

    Models = cell(1,8);

    for m = 1:8

        FileName = fullfile(InputFolder,sprintf("Model%d.mat",m));

        if ~isfile(FileName)
            error("File not found: %s",FileName);
        end

        Models{m} = load(FileName);

    end

    % =====================================================================
    % EXTRACT ALL FOUR SIGNALS
    % =====================================================================

    LoadCurrent  = cell(1,8);
    LoadVoltage  = cell(1,8);
    InputCurrent = cell(1,8);
    InputVoltage = cell(1,8);

    for m = 1:8

        ModelName = sprintf("Model%d",m);

        if ~isfield(Models{m},ModelName)
            error("%s.mat does not contain variable %s.", ...
                ModelName,ModelName);
        end

        Root = Models{m}.(ModelName);

        if ~isfield(Root,"out1")
            error("%s.mat does not contain out1.",ModelName);
        end

        Out = Root.out1;

        RequiredSignals = { ...
            "Load_current", ...
            "Load_Voltage", ...
            "Input_Current", ...
            "Input_Voltage"};

        for q = 1:numel(RequiredSignals)

            FieldName = RequiredSignals{q};

            if ~isfield(Out,FieldName)
                error("%s.mat does not contain out1.%s.", ...
                    ModelName,FieldName);
            end

        end

        LoadCurrent{m}  = Out.Load_current;
        LoadVoltage{m}  = Out.Load_Voltage;
        InputCurrent{m} = Out.Input_Current;
        InputVoltage{m} = Out.Input_Voltage;

    end

    % =====================================================================
    % 1. LOAD CURRENT
    % =====================================================================

    createWaveformGroupPlots( ...
        LoadCurrent, ...
        "Load Current", ...
        "Current (A)", ...
        LoadCurrentFolder, ...
        StartTime, ...
        EndTime, ...
        SignalName);

    % =====================================================================
    % 2. LOAD VOLTAGE
    % =====================================================================

    createWaveformGroupPlots( ...
        LoadVoltage, ...
        "Load Voltage", ...
        "Voltage (V)", ...
        LoadVoltageFolder, ...
        StartTime, ...
        EndTime, ...
        SignalName);

    % =====================================================================
    % 3. INPUT CURRENT
    % =====================================================================

    createWaveformGroupPlots( ...
        InputCurrent, ...
        "Input Current", ...
        "Current (A)", ...
        InputCurrentFolder, ...
        StartTime, ...
        EndTime, ...
        SignalName);

    % =====================================================================
    % 4. INPUT VOLTAGE
    % =====================================================================

    createWaveformGroupPlots( ...
        InputVoltage, ...
        "Input Voltage", ...
        "Voltage (V)", ...
        InputVoltageFolder, ...
        StartTime, ...
        EndTime, ...
        SignalName);

    % =====================================================================
    % 5. INDIVIDUAL MODEL 1 LOAD CURRENT
    %
    % No title as requested.
    % =====================================================================

    createIndividualPlot( ...
        LoadCurrent{1}, ...
        "Current (A)", ...
        IndividualLoadCurrentFolder, ...
        "Model1_Load_Current", ...
        StartTime, ...
        EndTime);

    % =====================================================================
    % 6. INDIVIDUAL MODEL 1 INPUT VOLTAGE
    %
    % No title as requested.
    % =====================================================================

    createIndividualPlot( ...
        InputVoltage{1}, ...
        "Voltage (V)", ...
        IndividualInputVoltageFolder, ...
        "Model1_Input_Voltage", ...
        StartTime, ...
        EndTime);

    % =====================================================================
    % 7. POWER METRICS
    % =====================================================================

    MetricNames = strings(8,1);

    ApparentPower = zeros(8,1);
    RealPower     = zeros(8,1);
    ReactivePower = zeros(8,1);
    PowerFactor   = zeros(8,1);
    THDPercent    = zeros(8,1);

    for m = 1:8

        MetricNames(m) = sprintf("Model%d",m);

        % -------------------------------------------------------------
        % Voltage
        % -------------------------------------------------------------

        V = getSignalData(InputVoltage{m});
        TV = getSignalTime(InputVoltage{m});

        % -------------------------------------------------------------
        % Current
        % -------------------------------------------------------------

        I = getSignalData(InputCurrent{m});
        TI = getSignalTime(InputCurrent{m});

        V = makeThreePhase(V);
        I = makeThreePhase(I);

        % -------------------------------------------------------------
        % Limit to available samples
        % -------------------------------------------------------------

        NV = min(numel(TV),size(V,1));
        NI = min(numel(TI),size(I,1));

        TV = TV(1:NV);
        V  = V(1:NV,:);

        TI = TI(1:NI);
        I  = I(1:NI,:);

        % -------------------------------------------------------------
        % Crop to 0.05 - 0.50 s
        % -------------------------------------------------------------

        IdxV = TV >= StartTime & TV <= EndTime;
        IdxI = TI >= StartTime & TI <= EndTime;

        TV = TV(IdxV);
        V  = V(IdxV,:);

        TI = TI(IdxI);
        I  = I(IdxI,:);

        if isempty(TV) || isempty(TI)
            error("Model%d does not contain samples in %.2f-%.2f s.", ...
                m,StartTime,EndTime);
        end

        % -------------------------------------------------------------
        % Put current on voltage time base if needed
        % -------------------------------------------------------------

        if numel(TV) ~= numel(TI) || ...
                max(abs(TV(1:min(numel(TV),numel(TI))) - ...
                TI(1:min(numel(TV),numel(TI))))) > 1e-12

            IInterp = zeros(numel(TV),3);

            for p = 1:3
                IInterp(:,p) = interp1( ...
                    TI,I(:,p),TV,'linear','extrap');
            end

            I = IInterp;

        end

        % -------------------------------------------------------------
        % RMS
        % -------------------------------------------------------------

        VrmsPhase = sqrt(mean(V.^2,1));
        IrmsPhase = sqrt(mean(I.^2,1));

        % -------------------------------------------------------------
        % Real power
        % -------------------------------------------------------------

        PhaseRealPower = mean(V.*I,1);
        P = sum(PhaseRealPower);

        % -------------------------------------------------------------
        % Apparent power
        %
        % For three-phase phase quantities:
        % S = sum(Vrms_phase * Irms_phase)
        % -------------------------------------------------------------

        S = sum(VrmsPhase .* IrmsPhase);

        % -------------------------------------------------------------
        % Power factor
        % -------------------------------------------------------------

        if S > eps
            PF = P/S;
        else
            PF = 0;
        end

        PF = max(-1,min(1,PF));

        % -------------------------------------------------------------
        % Reactive power
        % -------------------------------------------------------------

        Q = sign(P)*sqrt(max(S^2-P^2,0));

        % -------------------------------------------------------------
        % THD
        %
        % THD is calculated from the INPUT CURRENT because the input
        % current is the current used with the input voltage for power
        % quality evaluation.
        % -------------------------------------------------------------

        THDValues = zeros(1,3);

        for p = 1:3
            THDValues(p) = calculateTHD(I(:,p),TV);
        end

        THD = mean(THDValues);

        RealPower(m)     = P;
        ApparentPower(m) = S;
        ReactivePower(m) = Q;
        PowerFactor(m)   = PF;
        THDPercent(m)    = THD;

    end

    % =====================================================================
    % 8. SAVE APPARENT POWER CSV + BAR PLOT
    % =====================================================================

    ApparentTable = table( ...
        MetricNames, ...
        ApparentPower, ...
        'VariableNames', ...
        {'Model','ApparentPower_VA'});

    writetable(ApparentTable, ...
        fullfile(ApparentPowerFolder,"Apparent_Power.csv"));

    Fig = createMetricBarFigure( ...
        MetricNames, ...
        ApparentPower, ...
        "Apparent Power (VA)", ...
        "");

    exportgraphics(Fig, ...
        fullfile(ApparentPowerFolder,"Apparent_Power_Bar.png"), ...
        "Resolution",300);

    close(Fig);

    % =====================================================================
    % 9. SAVE POWER FACTOR CSV + BAR PLOT
    % =====================================================================

    PFTable = table( ...
        MetricNames, ...
        abs(PowerFactor), ...
        'VariableNames', ...
        {'Model','PowerFactor'});

    writetable(PFTable, ...
        fullfile(PowerFactorFolder,"Power_Factor.csv"));

    Fig = createMetricBarFigure( ...
        MetricNames, ...
        abs(PowerFactor), ...
        "Power Factor", ...
        "");

    ylim([min(0,min(PowerFactor)-0.05) 1.05]);

%     exportgraphics(Fig, ...
%         fullfile(PowerFactorFolder,"Power_Factor_Bar.png"), ...
%         "Resolution",300);
    
    saveas(Fig, ...
    fullfile(PowerFactorFolder,"Power_Factor_Bar.png"));
    close(Fig);

    % =====================================================================
    % 10. SAVE REACTIVE POWER CSV + BAR PLOT
    % =====================================================================

    QTable = table( ...
        MetricNames, ...
        abs(ReactivePower), ...
        'VariableNames', ...
        {'Model','ReactivePower_VAR'});

    writetable(QTable, ...
        fullfile(ReactivePowerFolder,"Reactive_Power.csv"));

    Fig = createMetricBarFigure( ...
        MetricNames, ...
        abs(ReactivePower), ...
        "Reactive Power (VAR)", ...
        "");

%     exportgraphics(Fig, ...
%         fullfile(ReactivePowerFolder,"Reactive_Power_Bar.png"), ...
%         "Resolution",300);

    saveas(Fig, ...
    fullfile(ReactivePowerFolder,"Reactive_Power_Bar.png"));
    close(Fig);

%     close(Fig);

    % =====================================================================
    % 11. SAVE THD CSV + BAR PLOT
    % =====================================================================

    THDTable = table( ...
        MetricNames, ...
        THDPercent, ...
        'VariableNames', ...
        {'Model','THD_Percent'});

    writetable(THDTable, ...
        fullfile(THDFolder,"THD.csv"));

    Fig = createMetricBarFigure( ...
        MetricNames, ...
        THDPercent, ...
        "THD (%)", ...
        "");
% 
%     exportgraphics(Fig, ...
%         fullfile(THDFolder,"THD_Bar.png"), ...
%         "Resolution",300);
    saveas(Fig, ...
    fullfile(THDFolder,"THD_Bar.png"));
    close(Fig);
%     close(Fig);

    % =====================================================================
    % 12. SAVE ALL POWER METRICS IN ONE CSV ALSO
    % =====================================================================

    AllMetricsTable = table( ...
        MetricNames, ...
        RealPower, ...
        abs(ApparentPower), ...
        abs(ReactivePower), ...
        abs(PowerFactor), ...
        THDPercent, ...
        'VariableNames', ...
        {'Model','RealPower_W','ApparentPower_VA', ...
         'ReactivePower_VAR','PowerFactor','THD_Percent'});

    writetable(AllMetricsTable, ...
        fullfile(OutputFolder, ...
        sprintf("%s_All_Power_Metrics.csv",SignalName)));

    fprintf("\n====================================================\n");
    fprintf("Completed: %s\n",SignalName);
    fprintf("Results: %s\n",OutputFolder);
    fprintf("====================================================\n");

end

fprintf("\nAll Sag, Swell and Harmonics results completed.\n");

end


% =========================================================================
% FUNCTION: CREATE GROUP WAVEFORM PLOTS
%
% Creates:
%   Models 1-3  -> one image with 3 subplots
%   Models 4-6  -> one image with 3 subplots
%   Models 7-8  -> one image with 2 subplots
%
% Each model also gets its own CSV inside the same folder.
% =========================================================================

function createWaveformGroupPlots( ...
    Signals, ...
    SignalLabel, ...
    YLabelText, ...
    OutputFolder, ...
    StartTime, ...
    EndTime, ...
    SignalName)

ModelGroups = {[1 2 3],[4 5 6],[7 8]};

for g = 1:numel(ModelGroups)

    Group = ModelGroups{g};

    Fig = figure( ...
        "Color","w", ...
        "Position",[100 100 1200 900]);

    Tiled = tiledlayout(numel(Group),1, ...
        "TileSpacing","compact", ...
        "Padding","compact");

    title(Tiled, ...
        sprintf("%s - %s",SignalName,SignalLabel), ...
        "FontWeight","bold", ...
        "FontSize",14);

    for k = 1:numel(Group)

        m = Group(k);

        Data = getSignalData(Signals{m});
        Time = getSignalTime(Signals{m});

        Data = makeThreePhase(Data);

        N = min(numel(Time),size(Data,1));

        Time = Time(1:N);
        Data = Data(1:N,:);

        Idx = Time >= StartTime & Time <= EndTime;

        TimeCrop = Time(Idx);
        DataCrop = Data(Idx,:);

        % -------------------------------------------------------------
        % Plot
        % -------------------------------------------------------------

        nexttile;

        plot(TimeCrop,DataCrop(:,1),"LineWidth",1.2);
        hold on;

        plot(TimeCrop,DataCrop(:,2),"LineWidth",1.2);
        plot(TimeCrop,DataCrop(:,3),"LineWidth",1.2);

        grid on;
        xlim([StartTime EndTime]);

        xlabel("Time (s)");
        ylabel(YLabelText);

        title(sprintf("Model %d - %s",m,SignalLabel));

        legend("Phase A","Phase B","Phase C", ...
            "Location","best");

        % -------------------------------------------------------------
        % CSV inside SAME folder as image
        % -------------------------------------------------------------

        CSVTable = array2table([TimeCrop DataCrop]);
        
        CSVTable.Properties.VariableNames = { ...
            'Time_s', ...
            'PhaseA', ...
            'PhaseB', ...
            'PhaseC'};

        CSVName = sprintf( ...
            "%s_Model%d_0.05_0.50s.csv", ...
            strrep(SignalLabel," ","_"),m);

        writetable(CSVTable, ...
            fullfile(OutputFolder,CSVName));

    end

    % -------------------------------------------------------------
    % Save group image
    % -------------------------------------------------------------

    GroupStart = Group(1);
    GroupEnd   = Group(end);

    PNGName = sprintf( ...
        "%s_Models_%d_%d.png", ...
        strrep(SignalLabel," ","_"), ...
        GroupStart, ...
        GroupEnd);

%     exportgraphics(Fig, ...
%         fullfile(OutputFolder,PNGName), ...
%         "Resolution",300)
    saveas(Fig, ...
    fullfile(OutputFolder,PNGName));
    close(Fig);

%     close(Fig);

end

end


function createIndividualPlot( ...
    Signal, ...
    YLabelText, ...
    OutputFolder, ...
    BaseName, ...
    StartTime, ...
    EndTime)

Data = getSignalData(Signal);
Time = getSignalTime(Signal);

Data = makeThreePhase(Data);

N = min(numel(Time),size(Data,1));

Time = Time(1:N);
Data = Data(1:N,:);

Idx = Time >= StartTime & Time <= EndTime;

TimeCrop = Time(Idx);
DataCrop = Data(Idx,:);

% ==============================================================
% CREATE FIGURE
% ==============================================================

Fig = figure( ...
    'Color','w', ...
    'Position',[100 100 1100 600]);

plot(TimeCrop,DataCrop(:,1),'LineWidth',1.2);
hold on;

plot(TimeCrop,DataCrop(:,2),'LineWidth',1.2);
plot(TimeCrop,DataCrop(:,3),'LineWidth',1.2);

grid on;

xlim([StartTime EndTime]);

xlabel('Time (s)');
ylabel(YLabelText);

% No title

legend('Phase A','Phase B','Phase C', ...
    'Location','best');

% ==============================================================
% CREATE VALID PNG FILENAME
% ==============================================================

PNGFile = fullfile(OutputFolder, ...
    strcat(BaseName,'.png'));

% Save figure
saveas(Fig,PNGFile);

close(Fig);

% ==============================================================
% SAVE CSV IN SAME FOLDER
% ==============================================================

CSVTable = array2table([TimeCrop DataCrop]);

CSVTable.Properties.VariableNames = { ...
    'Time_s', ...
    'PhaseA', ...
    'PhaseB', ...
    'PhaseC'};

CSVFile = fullfile(OutputFolder, ...
    strcat(BaseName,'.csv'));

writetable(CSVTable,CSVFile);

end

% =========================================================================
% FUNCTION: GET SIGNAL TIME
% =========================================================================

function Time = getSignalTime(Signal)

if isstruct(Signal)

    if isfield(Signal,"Time")
        Time = Signal.Time;
    else
        error("Signal does not contain Time.");
    end

elseif isobject(Signal)

    if isprop(Signal,"Time")
        Time = Signal.Time;
    else
        error("Signal does not contain Time.");
    end

else

    error("Unsupported signal format.");

end

Time = double(Time(:));

end


% =========================================================================
% FUNCTION: GET SIGNAL DATA
% =========================================================================

function Data = getSignalData(Signal)

if isstruct(Signal)

    if isfield(Signal,"Data")
        Data = Signal.Data;
    else
        error("Signal does not contain Data.");
    end

elseif isobject(Signal)

    if isprop(Signal,"Data")
        Data = Signal.Data;
    else
        error("Signal does not contain Data.");
    end

else

    error("Unsupported signal format.");

end

Data = squeeze(Data);

if isvector(Data)
    Data = Data(:);
end

if size(Data,1) == 3 && size(Data,2) ~= 3
    Data = Data.';
end

Data = double(Data);

end


% =========================================================================
% FUNCTION: MAKE THREE PHASE
% =========================================================================

function Data = makeThreePhase(Data)

Data = squeeze(Data);

if isvector(Data)
    Data = Data(:);
end

if size(Data,2) < 3

    error([ ...
        "Expected a three-phase signal with at least 3 columns. " ...
        "Received %d x %d."], ...
        size(Data,1),size(Data,2));

end

if size(Data,2) > 3
    Data = Data(:,1:3);
end

end


% =========================================================================
% FUNCTION: CALCULATE THD
%
% THD = sqrt(sum(HarmonicAmplitude^2)) / FundamentalAmplitude * 100
%
% The fundamental is automatically detected as the largest non-DC
% spectral component.
% =========================================================================

function THDPercent = calculateTHD(x,t)

x = double(x(:));
t = double(t(:));

Valid = isfinite(x) & isfinite(t);

x = x(Valid);
t = t(Valid);

if numel(x) < 10
    THDPercent = NaN;
    return;
end

% Remove DC component
x = x - mean(x);

N = numel(x);

dt = median(diff(t));

if dt <= 0 || ~isfinite(dt)
    THDPercent = NaN;
    return;
end

Fs = 1/dt;

% Window
w = hann(N);

X = fft(x.*w);

P2 = abs(X/N);

P1 = P2(1:floor(N/2)+1);

if numel(P1) > 2
    P1(2:end-1) = 2*P1(2:end-1);
end

Freq = Fs*(0:floor(N/2))/N;

if numel(Freq) < 3
    THDPercent = NaN;
    return;
end

% Find fundamental
[FundAmplitude,FundIndex] = max(P1(2:end));

FundIndex = FundIndex + 1;

if FundAmplitude <= eps
    THDPercent = 0;
    return;
end

FundFreq = Freq(FundIndex);

MaxHarmonic = floor((Fs/2)/FundFreq);

if MaxHarmonic < 2
    THDPercent = 0;
    return;
end

HarmonicPower = 0;

for h = 2:MaxHarmonic

    TargetFrequency = h*FundFreq;

    [~,Index] = min(abs(Freq-TargetFrequency));

    if Index <= numel(P1)
        HarmonicPower = HarmonicPower + P1(Index)^2;
    end

end

THDPercent = ...
    sqrt(HarmonicPower)/FundAmplitude*100;

end


% =========================================================================
% FUNCTION: CREATE METRIC BAR FIGURE
%
% Every model gets a different bar color.
% =========================================================================

function Fig = createMetricBarFigure( ...
    Names, ...
    Values, ...
    YLabelText, ...
    TitleText)

Fig = figure( ...
    "Color","w", ...
    "Position",[100 100 1100 600]);

b = bar(Values);

b.FaceColor = "flat";

BarColors = lines(numel(Values));

for k = 1:numel(Values)
    b.CData(k,:) = BarColors(k,:);
end

grid on;

xlabel("Model");
ylabel(YLabelText);

if strlength(TitleText) > 0
    title(TitleText);
end

xticks(1:numel(Values));
xticklabels(Names);

end
