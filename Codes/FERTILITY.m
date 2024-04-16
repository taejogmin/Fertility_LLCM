% Load the data in csv - download packages for statistics and machine
% learning beforehand
data = readtable('OECD_FERTILITY.csv');

% Convert 'CountryCode' and 'Year' to categorical and create dummy
% variables for fixed effect estimation
countryDummies = dummyvar(categorical(data.CountryCode));
yearDummies = dummyvar(categorical(data.Year)); 

% Create new tables from dummy variables
countryDummyNames = strcat('Country_', string(1:size(countryDummies, 2)));
yearDummyNames = strcat('Year_', string(1:size(yearDummies, 2)));
countryDummiesTable = array2table(countryDummies, 'VariableNames', countryDummyNames);
yearDummiesTable = array2table(yearDummies, 'VariableNames', yearDummyNames);

% Combine the data with the country and year dummies
dataWithDummies = [data, countryDummiesTable, yearDummiesTable];

% Remove CountryCode and Year to avoid multicollinearity
dataWithDummies.CountryCode = [];
dataWithDummies.Year = []; 

% model formula for working hour independent variable
formula = 'FERTILITY ~ HRWK + AVWAGE + CPI - 1';

% Run the fixed effects model (linear regression with dummy variables)
mdl = fitlm(dataWithDummies, formula);

% Display the model results
disp(mdl);

% Calculate Utility and add it to the dataWithDummies table
% 8760 hours is total hours in a year. 365 * 8 is hours spent sleeping in a
% year
%change ^0.5 to 0.7 (if 0.7 is set for AVWAGE, set Leisure as 0.3) in order
%to set different preference in the society. 
dataWithDummies.Utility = data.AVWAGE.^0.50 .* (8760 - (data.HRWK + 365 * 8)).^0.50;

% model formula for Utility as independent variable
NewFormula = 'FERTILITY ~ Utility + CPI - 1';

% Run the new fixed effects model (linear regression with dummy variables)
Newmdl = fitlm(dataWithDummies, NewFormula);

% Display the new model results
disp(Newmdl);


% Code to draw curve
graph = readtable('leisure utility curve.csv'); 

% Extract data from the table
X = graph{:, 2}; % Assuming the second column is X values
Y = graph{:, 1}; % Assuming the first column is Y values

% Plot the data
% preference on Leisure = 1 -  preference on Budget as one has to sacrifice
% money for leisure time and vice versa
plot(X, Y);
xlabel('Estimated Coefficient of Utility'); 
ylabel('Preference on Leisure Time, Utility'); 
title('Fertility Rate based on Utility Preference'); 




% Extract unique country codes
country = unique(data.CountryCode);

% Create a figure for the plot
figure;

% Loop over each country code to plot its data
for i = 1:length(country)
    % Extract data for the current country
    countryData = data(strcmp(data.CountryCode, country{i}), :);
    
    % Plot the data
    plot(countryData.Year, countryData.FERTILITY, 'DisplayName', country{i});
    hold on;  % Keep the plot open to add more lines
end

% Add labels and title
xlabel('Year');
ylabel('Fertility Rate');
title('Fertility Rate by Country Over Years');

% Add a legend
legend('Location', 'bestoutside');

% Hold off to finish plotting
hold off;

% Read the data from the CSV file
data = readtable('OECD_FERTILITY.csv');

% Extract necessary columns
years = data.Year;
countryCodes = data.CountryCode;
avgWage = data.AVWAGE;
hrWk = data.HRWK;  

% Find unique country codes
uniqueCountries = unique(countryCodes);

% Initialize a figure for plotting
figure;

% Loop over each country code to plot its data
for i = 1:length(uniqueCountries)
    % Extract data for the current country
    countryData = data(strcmp(data.CountryCode, uniqueCountries{i}), :);
    
    % Calculate average wage per hour for the current country
    avgWagePerHour = countryData.AVWAGE ./ countryData.HRWK;
    
    % Plot the data
    plot(countryData.Year, avgWagePerHour, 'DisplayName', uniqueCountries{i});
    hold on;  % Keep the plot open to add more lines
end

% Add labels and title
xlabel('Year');
ylabel('Average Wage per Hour');
title('Average Wage per Hour Worked for Each Country Over Years');
legend;
hold off;

