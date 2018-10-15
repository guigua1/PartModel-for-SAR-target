function [parts, d] = selfOrder(conn_r)
parts = {1};
d = {0};

for ii = 2:conn_r.len

    [parts, d] = insertPart(parts, d, conn_r, ii);

end
ii = 1;
while ii <= length(d)
    jj = ii + 1;
    flag = false;
    while jj <= length(d)
            dtmp = intersect(d{ii}, d{jj});
            ptmp = intersect(parts{ii}, parts{jj});
            if ~isempty(dtmp) && ~isempty(ptmp)
                d{ii} = dtmp;
                parts{ii} = union(parts{ii}, parts{jj});
                d(jj) = [];
                parts(jj) = [];
                flag = true;
                break;
            end
            jj = jj + 1;
    end
    if ~flag
        ii = ii + 1;
    end
end

function [parts, d] = insertPart(parts, d, conn_r, ii)

global S_tol;

flag = false;

book = false(1, conn_r.len);
pointII = conn_r.c(ii,:); 

for kk = 1:length(parts) 
    part = parts{kk};

    for jj = part
        
        if book(jj)
            continue;
        end
        pointJJ = conn_r.c(jj,:);
        vectorP =  pointII - pointJJ;
        dTar = octalQuadrant(-vectorP);
        dSrc = octalQuadrant(vectorP);
        dtmp = min(dTar, dSrc);
        
        edgeII = conn_r.cod(ii,dTar); edgeJJ = conn_r.cod(jj,dSrc);
    
        if any(~(edgeII | edgeJJ))
        
            mR = conn_r.m(ii) / conn_r.m(jj);
            if mR > 1
                mR = 1/mR;
            end
        
            vR = conn_r.v(ii)/conn_r.v(jj);
            if vR > 1
                vR = 1/vR;
            end

            rR = conn_r.r(ii) / conn_r.r(jj);
            if rR > 1
                rR = 1/rR;
            end
         
            s_ij = mR * vR * rR;

            if s_ij > S_tol
                if d{kk} == 0
                    parts{kk} = [part, ii];
                    d{kk} = dtmp;
                elseif ~isempty(intersect(d{kk},dtmp))
                    parts{kk} = [part, ii];
                    d{kk} = intersect(d{kk}, dtmp);
                else
                    parts{end+1} = [jj, ii];
                    d{end+1} = dtmp;
                end
                flag = true;
                book(jj) = true;
            end
        end
    end
end
if ~flag
    parts{end+1} = ii;
    d{end+1} = 0;
end
