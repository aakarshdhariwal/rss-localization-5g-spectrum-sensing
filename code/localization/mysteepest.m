function [x, conv] = mysteepest(A, b, x, tol, maxiter)
% MYSTEEPEST - solve A*x = b using steepest descent algorithm
% returns the solution and the convergence information
    iter = 1;
    r = b - A*x;
    delta = r'*r;
    conv = delta;
    delta0 = delta;
    while (delta > tol*delta0) && (iter < maxiter)
        q = A*r;
        alpha = delta/(q'*r);
        x = x + alpha*r;
        if mod(iter,50) == 0
            r = b - A*x; % once in a while recalculate r
        else
            r = r - alpha*q;
        end
        delta = r'*r;
        conv = [conv, delta];
        iter = iter + 1;
    end
end
%load("pqfile.mat")
%[x, conv] = mysteepest(A, b, x, 10^-3, 50)
