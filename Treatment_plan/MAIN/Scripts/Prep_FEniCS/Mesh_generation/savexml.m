function savexml(no, el, fname)
%SAVEXML(no, el, fname)
%   Saves the mesh to xml format, used by FEniCS
    fid = fopen(fname, 'w');

    if (fid == -1)
        error('Could not open file.');
    end

    nodes = no(:,1:3);
    node_num = size(nodes,1);
    node_ind = (0:node_num-1)';

    elements = el(:,[3 1 2 4])-1;
    element_num = size(elements,1);
    element_ind = (0:element_num-1)';

    fprintf (fid, '<?xml version="1.0" encoding="UTF-8"?>\n\n');
    fprintf (fid, '<dolfin xmlns:dolfin="http://www.fenics.org/dolfin/">\n' );
    fprintf (fid, '  <mesh celltype="tetrahedron" dim="3">\n');
    fprintf (fid, '    <vertices size="%d">\n', node_num);
    fprintf (fid, '      <vertex index="%d" x="%g" y="%g" z="%g"/>\n', ...
             [node_ind, nodes]' );
    fprintf (fid, '    </vertices>\n' );
    fprintf (fid, '    <cells size="%d">\n', element_num);
    fprintf (fid, '      <tetrahedron index="%d" v0="%d" v1="%d" v2="%d" v3="%d"/>\n', ...
             [element_ind, elements]');
    fprintf (fid, '    </cells>\n');
    fprintf (fid, '  </mesh>\n');
    fprintf (fid,  '</dolfin>\n');

    fclose(fid);
end
