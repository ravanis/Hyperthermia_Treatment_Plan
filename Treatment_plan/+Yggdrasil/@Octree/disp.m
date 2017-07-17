function disp(oct)
%DISP(oct)
    class_name = strrep(class(oct),'Yggdrasil.','');
    if usejava('desktop')
        class_str = ['<a href = "matlab:helpPopup ' ...
            class(oct) '" style="font-weight:bold">' class_name '</a>'];
    else
        class_str = class_name;
    end
    
    
    if numel(oct) ~= 1 % If multiple data values
        dim = builtin('size',oct);
        size_str = [sprintf('%d', dim(1)) sprintf('x%d', dim(2:end))];
        delim_str = '.';
        vis_str = '';
        
        if ndims(oct) <= 2 && numel(oct)~=0
            delim_str = ':';
            c = num2str(ones(dim));
            vis_str = [];
            for i = 1:size(c,1)
                vis_str = [vis_str '    ' num2str(c(1,:)) char(13)];
            end
            vis_str = strrep(vis_str, '1', class_name);
            vis_str = [vis_str '\n'];
        end
        
        fprintf(['  ' size_str ' ' class_str ' array' delim_str '\n\n' vis_str]);
        
        return;
    end
    dim = size(oct);
    D = oct.data;
    size_str = [sprintf('%d', dim(1)) sprintf('x%d', dim(2:end))];
    
    if usejava('desktop')        
        header_str = [size_str ' ' class_str ' with properties:\n'];
        
        meta_str = [ ...
            sprintf('  <strong>meta:</strong>\n    N: %d\n    original_matrix_size: [%d  %d  %d]\n', ...
                    oct.meta.N, oct.meta.original_matrix_size) ...
            sprintf('    eps: %g\n    enum_order: [%d  %d  %d  %d  %d  %d  %d  %d]\n', ...
                    oct.meta.eps, oct.meta.enum_order)];
        
        data_header_str = '  <strong>data:</strong>\n';
        
        if isreal(D)
            if size(D,2) == 1
                data_str = sprintf('    [%0.3g]\n', D');
            else
                data_str = sprintf('    [%0.3g  %0.3g  ...  %0.3g  %0.3g]\n', ...
                                   [D(:,1:2) D(:,end-1:end)]');
            end
        else
            if size(D,2) == 1
                data_str = sprintf('    [%0.3g + %0.3gi]\n', [real(D), imag(D)]');
            else
                data_str = sprintf('    [%0.3g + %0.3gi  ...  %0.3g + %0.3gi]\n', ...
                                   [real(D(:,1)),imag(D(:,1)), real(D(:,end)),imag(D(:,end))]');
            end
        end

        adr_header_str  = ['  <strong>adr:</strong>\n'];

    else
        c_keyw = '\033[4m';
        c_reset = '\033[0m';

        header_str = [size_str ...
            ' '...
            c_keyw class_str c_reset ...
            ' with properties:\n'];
        
        meta_str = [ ...
            sprintf(['  ' c_keyw 'meta:' c_reset '\n    N: %d\n    original_matrix_size: [%d  %d  %d]\n'], ...
                    oct.meta.N, oct.meta.original_matrix_size) ...
            sprintf('    eps: %g\n    enum_order: [%d  %d  %d  %d  %d  %d  %d  %d]\n', ...
                    oct.meta.eps, oct.meta.enum_order)];
        
        data_header_str = ['  ' c_keyw 'data:\n' c_reset];
        
        if isreal(D)
            if size(D,2) == 1
                data_str = sprintf('    [%0.3g]\n', D');
            else
                data_str = sprintf('    [%0.3g  %0.3g  ...  %0.3g  %0.3g]\n', ...
                                [D(:,1:2) D(:,end-1:end)]');
            end
        else
            if size(D,2) == 1
                data_str = sprintf('    [%0.3g + %0.3gi]\n', [real(D), imag(D)]');
            else
                data_str = sprintf('    [%0.3g + %0.3gi  ...  %0.3g + %0.3gi]\n', ...
                                [real(D(:,1)),imag(D(:,1)), real(D(:,end)),imag(D(:,end))]');
            end
        end

        adr_header_str = ['  ' c_keyw 'adr:' c_reset '\n'];
    end

    if size(oct.adr,2) < 10
        adr_str = ['    [' num2str(oct.adr) ']\n\n'];
    else
        adr_str = ['    [' num2str(oct.adr(:,1:2)) '  ...  ' num2str(oct.adr(:,end-1:end)) ']\n\n'];
    end
    
    fprintf([header_str meta_str data_header_str data_str adr_header_str adr_str]);
end
