function myprintfdot(i,N)

if ~exist('N','var')
    fprintf('%d ',i);
    return;
end   
if mod(i,N) == 1
    fprintf('.');
end
