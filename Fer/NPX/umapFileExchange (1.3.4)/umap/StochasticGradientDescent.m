classdef StochasticGradientDescent < handle
    methods(Static)
        function [out, cmdOut]=Go(inFile, outFile, background, head_embedding, ...
                tail_embedding,head, tail, n_epochs, ...
                n_vertices, epochs_per_sample, a, b, gamma, ...
                initial_alpha, negative_sample_rate, randis)
            if ~exist('head_embedding', 'var') || isempty(head_embedding) ...
               || ~exist('tail_embedding', 'var') || isempty(tail_embedding) ...
               || ~exist('head', 'var') || isempty(head) ...
               || ~exist('tail', 'var') || isempty(tail) ...
               || ~exist('n_epochs', 'var') || isempty(n_epochs) ...
               || ~exist('n_vertices', 'var') || isempty(n_vertices) ...
               || ~exist('epochs_per_sample', 'var') || isempty(epochs_per_sample) ...
               || ~exist('n_vertices', 'var') || isempty(n_vertices) ...
               || ~exist('a', 'var') || isempty(a) ...
               || ~exist('b', 'var') || isempty(b) ...
               || ~exist('gamma', 'var') || isempty(gamma) ...
               || ~exist('initial_alpha', 'var') || isempty(initial_alpha) ...
               || ~exist('negative_sample_rate', 'var') || isempty(negative_sample_rate) ...
                    out=[];
                    cmdOut = 1;
                    error('Not enough input parameters');
            end 
           
            if nargin < 16
                StochasticGradientDescent.WriteText(inFile, head_embedding, tail_embedding,head, tail, n_epochs, ...
                        n_vertices, epochs_per_sample, a, b, gamma, ...
                        initial_alpha, negative_sample_rate);
            else
                StochasticGradientDescent.WriteText(inFile, head_embedding, tail_embedding,head, tail, n_epochs, ...
                        n_vertices, epochs_per_sample, a, b, gamma, ...
                        initial_alpha, negative_sample_rate, randis);
            end
            
            if ispc
                exe=[String.ToSystem(...
                        fullfile(pwd, '/StochasticGradientDescent.exe'))];
            else
                 exe=String.ToSystem(fullfile(pwd,'/StochasticGradientDescent'));
            end
            
            cmd=[ exe ' ' String.ToSystem(inFile) ' ' ...
                String.ToSystem(outFile)];% ' ' num2str(random)];
            
            if ismac         
                terminalName=['AutoGate StochasticGradientDescent ' datestr(datetime)];
                setTerminalName=['echo -n -e "\033]0;' terminalName '\007"'];
                closeTerminal=['osascript -e ''tell application '...
                    '"Terminal" to close (every window whose name '...
                    'contains "' terminalName '")'' &'];
                fldr=fileparts(inFile);
                sh=fullfile(fldr,'/StochasticGradientDescent.sh');                
                strs={setTerminalName, cmd, closeTerminal, 'exit'};
                File.WriteTextFile(sh, strs);
                newCmd=String.ToSystem(sh);
                system(['chmod 777 ' newCmd]);
                cmd=['open -b com.apple.terminal ' newCmd];
            elseif ispc
                cmd=[cmd ' < nul'];
            end
            if background
                cmd=[cmd ' &'];
            end
            delete(outFile);
            if ispc
                scriptFile=fullfile(pwd, '/StochasticGradientDescent.cmd');
                [flag, cmdOut] = File.Spawn(cmd, scriptFile, '');
            else
                [flag, cmdOut] = system(cmd);
            end
            if flag~=0
                error(cmdOut);
            end
            if ~background
                maxSecondsToWait = 60 * 5;
                secondsWaitedSoFar  = 0;
                while secondsWaitedSoFar < maxSecondsToWait 
                  if exist(outFile, 'file')
                    break;
                  end
                  pause(3);
                  secondsWaitedSoFar = secondsWaitedSoFar + 3;
                end
                if exist(outFile, 'file')
                  out=StochasticGradientDescent.GetResult(outFile, inFile);
                else
                  %msgBox(['<html>Process resulted into an error or taking more time  <br>'...
                  %      ' than expected, please try later or contact support.<br><br></html>']);
                  out=[];
                end   
                if ismac
                    delete(sh);
                end
            else
                if exist(outFile, 'file')
                  out=StochasticGradientDescent.GetResult(outFile, inFile);
                else
                    out=[];
                end
            end
        end
        
        function [head_embedding]=GetResult(outFile, inFile)
            [head_embedding] = StochasticGradientDescent.ReadEmbedding(outFile);
            delete(outFile);
            delete(inFile);
        end
       
        function WriteEmbedding(outFile, head_embedding)
            h = fopen(outFile, 'wb');
            d=size(head_embedding);
            fprintf(h, "%d\n", d);
            fprintf(h, "%f\n",head_embedding);
        end
              
        function head_embedding=ReadEmbedding(inFile)
            h = fopen(inFile, 'rb');
            rows = fscanf(h, "%d\n", 1);
            cols=fscanf(h, "%d\n", 1);
            temp = fscanf(h, "%f\n", rows*cols);
            head_embedding = reshape(temp,rows,[]);
            fclose(h);
        end
        
        function randis=ReadRandis(inFile)
            h = fopen(inFile, 'rb');
            d = fscanf(h, "%d\n", 1);
            fscanf(h, "%d\n", 1);
            randis = fscanf(h, "%d\n", d);
        end
  
        function WriteText(inFile, head_embedding, tail_embedding,head, tail, n_epochs, ...
            n_vertices, epochs_per_sample, a, b, gamma, ...
            initial_alpha, negative_sample_rate, randis)
            h = fopen(inFile, 'wb');
            
            d=size(head_embedding);
            fprintf(h, "%d\n", d(2));
            fprintf(h, "%d\n", d(1));
            fprintf(h, "%f\n",head_embedding');
            
            d=size(tail_embedding);
            fprintf(h, "%d\n", d(1));
            fprintf(h, "%f\n", tail_embedding');
            
            d=size(head);
            fprintf(h, "%d\n", d(1));
            fprintf(h, "%d\n", head);
            
            d=size(tail);
            fprintf(h, "%d\n", d(1));
            fprintf(h, "%d\n", tail);
            
            d=size(n_epochs);
            fprintf(h, "%d\n", d(1));
            fprintf(h, "%d\n", n_epochs);
            
            d=size(n_vertices);
            fprintf(h, "%d\n", d(1));
            fprintf(h, "%d\n", n_vertices);
            
            d=size(epochs_per_sample);
            fprintf(h, "%d\n", d(1));
            fprintf(h, "%f\n", epochs_per_sample);
            
            d=size(a);
            fprintf(h, "%d\n", d(1));
            fprintf(h, "%f\n", a);
            
            d=size(b);
            fprintf(h, "%d\n", d(1));
            fprintf(h, "%f\n", b);
            
            d=size(gamma);
            fprintf(h, "%d\n", d(1));
            fprintf(h, "%f\n", gamma);
            
            d=size(initial_alpha);
            fprintf(h, "%d\n", d(1));
            fprintf(h, "%f\n", initial_alpha);
            
            d=size(negative_sample_rate);
            fprintf(h, "%d\n", d(1));
            fprintf(h, "%d\n", negative_sample_rate);
            
            if nargin >= 16
                d=size(randis);
                fprintf(h, "%d\n", d(1));
                fprintf(h, "%d\n", randis);
            
           end
           
            fclose(h);
        end
        
        function [head_embedding, tail_embedding,head, tail, n_epochs, ...
            n_vertices, epochs_per_sample, a, b, gamma, ...
            initial_alpha, negative_sample_rate, randis] = ReadText(outFile)
            h = fopen(outFile, 'rb');
            
            d = fscanf(h, "%d\n", 1);  
            temp = fscanf(h, "%f\n", d*2);
            head_embedding = reshape(temp,d,[]);
            
            d = fscanf(h, "%d\n", 1);  
            temp = fscanf(h, "%f\n", d*2);
            tail_embedding = reshape(temp,d,[]);
            
            d = fscanf(h, "%d\n", 1);  
            head = fscanf(h, "%f\n", d);
            
            d = fscanf(h, "%d\n", 1);  
            tail = fscanf(h, "%f\n", d);
            
            d = fscanf(h, "%d\n", 1);  
            n_epochs = fscanf(h, "%f\n", d);
            
            d = fscanf(h, "%d\n", 1);  
            n_vertices = fscanf(h, "%f\n", d);
            
            d = fscanf(h, "%d\n", 1);  
            epochs_per_sample = fscanf(h, "%f\n", d);
            
            d = fscanf(h, "%d\n", 1);  
            a = fscanf(h, "%f\n", d);
            
            d = fscanf(h, "%d\n", 1);  
            b = fscanf(h, "%f\n", d);
           
            d = fscanf(h, "%d\n", 1);  
            gamma = fscanf(h, "%f\n", d);
            
            d = fscanf(h, "%d\n", 1);  
            initial_alpha = fscanf(h, "%f\n", d);
            
            d = fscanf(h, "%d\n", 1);  
            negative_sample_rate = fscanf(h, "%f\n", d);
            
            d = fscanf(h, "%d\n", 1);  
            randis = fscanf(h, "%f\n", d);
           
            fclose(h);
        end
 
    end
end