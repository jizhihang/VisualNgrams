function qname = randqname

if rand > 0.25
    qname = 'notcuda.q';
else
    qname = 'cuda.q';
end
