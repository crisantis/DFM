%% ========================================================================
%  VelocityRelaxationAndProfiles.m
%  ------------------------------------------------------------------------
%  The code was made on : January 4th, 2019
%  For assistance, conact: atritinger@gmail.com
%
%
%  Description:
%  ------------------------------------------------------------------------
%  This script computes the velocity relaxation time and visualizes
%  velocity profiles (U and V) at different depths and flow directions.
%  It also generates contour maps of relaxation time as a function of
%  flow speed and depth.
%
%  Key Outputs:
%   - Individual velocity profile figures (U, V vs Depth)
%   - A multi-panel contour plot showing relaxation times
%
%  Requirements:
%   - MATLAB R2018a or later
%   - Data files formatted as: <dir>_<speed>_<depth>outU.txt / outV.txt
%
%  ========================================================================

clear; close all; clc;

%% ------------------------- USER PARAMETERS ------------------------------
dockit = @() set(gcf, 'windowstyle', 'docked'); % Dock figures automatically
G = 9.81;                                       % Gravity [m/s²]
dt = 0.5;                                       % Time step [s]
small = 0.01;                                   % Relaxation threshold
smallfont = 20;
bigfont = 26;

% Flow parameters
SPEED = [5,10,20,40];                           % Flow speeds [m/s]
DEPTH = [5,10,15,20,25,30];                     % Depths [m]
DIR   = [-90,-45,-22.5,0,22.5,45,90];           % Directions [°]

NUMSPEED = numel(SPEED);
NUMDEPTH = numel(DEPTH);
NUMDIR   = numel(DIR);

% Colors (replace cbrewer with MATLAB built-ins)
RD = interp1(linspace(0,1,256), colormap('hot'),    linspace(0,1,12));
BL = interp1(linspace(0,1,256), colormap('winter'), linspace(0,1,12));
rb = interp1(linspace(0,1,256), colormap('jet'),    linspace(0,1,16));
rb = flipud(rb);

letters = ['a','b','c','d','e','f','g','h','i'];

%% ---------------------- RELAXATION TIME ANALYSIS ------------------------
fprintf('Computing relaxation times...\n');
REL = zeros(NUMSPEED, NUMDEPTH, NUMDIR); % Preallocate

for i = 1:NUMSPEED
    valS = num2str(100 + SPEED(i));

    for l = 1:NUMDIR
        valdir = num2str(100 + l);

        for j = 1:NUMDEPTH
            NH = 41;             % Number of depth nodes (generalized)
            TH = 1 / NH;         % Depth increment
            valD = num2str(100 + DEPTH(j));

            % File names
            fileU = sprintf('%s_%s_%soutU.txt', valdir, valS, valD);
            fileV = sprintf('%s_%s_%soutV.txt', valdir, valS, valD);

            % Skip missing files
            if ~isfile(fileU) || ~isfile(fileV)
                warning('Missing files for S=%s, Dir=%s, D=%s', valS, valdir, valD);
                continue;
            end

            % Load velocity data
            UU = load(fileU);
            VV = load(fileV);
            TIME = length(UU) / (NH + 1);
            t = round(TIME - 1);

            % Extract last timestep profiles
            lastU = UU(((NH+1)*(t-1)+2):((NH+1)*t), 1);
            lastV = VV(((NH+1)*(t-1)+2):((NH+1)*t), 1);

            % Compute decay of difference from final state
            sigU = zeros(TIME, 1);
            sigV = zeros(TIME, 1);

            for tt = 1:TIME
                curU = UU(((NH+1)*(tt-1)+2):((NH+1)*tt), 1);
                curV = VV(((NH+1)*(tt-1)+2):((NH+1)*tt), 1);

                sigU(tt) = sum((lastU - curU).^2) * TH;
                sigV(tt) = sum((lastV - curV).^2) * TH;
            end

            % Determine relaxation time (first point below threshold)
            for tt = 1:TIME
                if abs(sigU(tt)) < small && abs(sigV(tt)) < small
                    REL(i,j,l) = tt;
                    break;
                end
            end
        end
    end
end

fprintf('Relaxation time computation complete.\n');

%% ------------------- VELOCITY PROFILE PLOTS (U & V) ---------------------
fprintf('Plotting velocity profiles...\n');
counter = 100;
labelIndex = 0;

% Plot only mid-range directions and shallow/deep depths
for l = 3:5
    valdir = num2str(100 + l);

    for j = [1, NUMDEPTH] % Top & bottom depths
        valD = num2str(100 + DEPTH(j));
        counter = counter + 1;
        figure(counter); hold on; grid on;

        labelIndex = labelIndex + 1;

        for i = 1:NUMSPEED
            valS = num2str(100 + SPEED(i));

            fileU = sprintf('%s_%s_%soutU.txt', valdir, valS, valD);
            fileV = sprintf('%s_%s_%soutV.txt', valdir, valS, valD);

            if ~isfile(fileU) || ~isfile(fileV)
                continue;
            end

            UU = load(fileU);
            VV = load(fileV);
            t = round(length(UU)/(NH+1) - 1);

            % Plot U (solid) and V (dashed)
            plot(UU(((NH+1)*(t-1)+2):((NH+1)*t),1), UU(2:(NH+1),2), ...
                 'LineWidth', 3, 'Color', BL(i+6,:));
            plot(VV(((NH+1)*(t-1)+2):((NH+1)*t),1), VV(2:(NH+1),2), ...
                 'LineWidth', 3, 'Color', RD(i+6,:), 'LineStyle', '--');
        end

        xlabel('Velocity (m/s)', 'FontSize', smallfont, 'Color', 'b');
        ylabel('Depth (m)', 'FontSize', smallfont, 'Color', 'b');
        title(sprintf('( %s )', letters(labelIndex)), 'FontSize', bigfont);
        axis([-1, 1, -DEPTH(j), 0]);
        legend(arrayfun(@(s) sprintf('U,V @ %dm/s', s), SPEED, 'UniformOutput', false), ...
               'Location', 'SouthEast', 'FontSize', smallfont);

        dockit();
        saveas(gcf, sprintf('VelocityProfile_Dir%s_Depth%s.png', valdir, valD));
    end
end

fprintf('Velocity profile plots complete.\n');

%% ----------------------- RELAXATION CONTOUR PLOT ------------------------
fprintf('Generating relaxation contour plots...\n');
figure(1115);
letterSeq = ['a','b','c','d','e','f','g'];
order = [5,7,9,1,8,6,4]; % Custom subplot order

for z = 1:NUMDIR
    subplot(3,3,order(z));
    contourf(DEPTH, SPEED, REL(:,:,z), 'LineStyle', 'none');
    title(sprintf('( %s ) Dir: %.1f°', letterSeq(z), DIR(z)), 'FontSize', smallfont);
    
    xlabel('Depth (m)');
    if ismember(order(z), [1,4,7])
        ylabel('Wind Speed (m/s)');
    end

    hcb = colorbar;
    title(hcb, 'Relaxation Time (s)');
    colormap(rb);
    grid on;
end

dockit();
print(gcf, '-dpng', 'RelaxationTime_Subplots', '-r300');

fprintf('All figures generated successfully.\n');
