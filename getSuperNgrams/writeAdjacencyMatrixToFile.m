function writeAdjacencyMatrixToFile(cachedir, outfname, accfname)

try    
    
disp(['writeAdjacencyMatrixToFile(''' cachedir ''',''' outfname ''')']);

conf = voc_config('paths.model_dir', '/tmp/tmpdir_for_vocconfig/');
domode = conf.threshs.featExtMode_imgClfr;

load([cachedir '/edgematrix.mat'], 'edgeval');
if domode == 1, [phrasenames, accval, ngramval, phrasenames_orig] = selectTopPhrasenames(accfname);
elseif domode == 2, [phrasenames, accval, ngramval] = selectTopPhrasenames_slow(accfname); end
numcls = numel(phrasenames);

disp(' update the matrix such that edgeval(i,j) has score at least as much as  edgeval(j,j) ');
dmat = edgeval;
for j=1:size(edgeval,1)
    inds = find(dmat(:,j) < dmat(j,j));  
    dmat(inds, j) = dmat(j,j);
    
    inds = find(dmat(j,:) < dmat(j,j));
    dmat(j, inds) = dmat(j,j);
end

disp(' print info');
fid = fopen(outfname, 'w');
for i=1:numcls
    myprintf(i,100);
    for j=1:numcls
        fprintf(fid, '%s %s %f %f\n', phrasenames{i}, phrasenames{j}, dmat(i,j), dmat(j,i));
    end
end
myprintfn;
fclose(fid);

catch
    disp(lasterr); keyboard;
end
