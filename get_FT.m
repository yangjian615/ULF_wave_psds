% Input should be just a vector of data. (We expect empty rows to have been
% removd beforehand)
% We output the frequency spectra found and also the normalisation constant
% for the windowing function.

function [output,W] =  get_FT( input )
    % Initialise stuff
    output = zeros( size(input) ); % OR SHOULD THIS BE HALF AS LONG AS REAL SIGNAL?
    N = length( input );
    input_size = size(input);
    
    
    % Hanning window
    w = [0:N-1];
    w = 0.5*( 1 - cos( 2*pi*w / (N-1) ));
    W = ( w * w' );
    
    % Remove mean and apply Hanning window
    for col = [1:input_size(2)]
        input(:,col) = w' .* (input(:,col) - mean(input(:,col)));
%         input(:,col) = w' .* input(:,col);
    end
    
    output = fft( input );
    output(floor(N/2)+1 : N,:) = [];


end