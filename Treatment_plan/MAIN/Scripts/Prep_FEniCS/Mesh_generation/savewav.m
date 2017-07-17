function savewav(no,el,fname)
    fid = fopen(fname,'w');
    fprintf(fid,'v %f %f %f\n',no');
    fprintf(fid,'f %d %d %d\n',(el(:,[1 3 2]))');
    fclose(fid);
end
