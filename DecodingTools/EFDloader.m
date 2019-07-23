function [efds] = EFDloader(Catalog)

%% Read that catalog
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include));
FT = T.FT(logical(T.include));
LT = T.LT(logical(T.include));

for R = 1:length(KWIKfiles)
    efds(R) = EFDmaker(KWIKfiles{R});
end

end