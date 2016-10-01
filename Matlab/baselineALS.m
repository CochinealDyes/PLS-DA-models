function [z] = baseline(y, lambda,p)
%asymmetric least squres baseline correction script from paper by Eilers
%and Boelens
%(www.science.uva.nl/~hboelens/publications/draftpub/Eilers_2005.pdf)

%Estimate the baseline with asymmetric least squares
%Suggested parameter values:
% 0.001< p <0.1
% 10^2 < lambda < 10^9

%original script fromt the paper (but doesn't work because C is sparse and
%w.*y is not):
% m = length(y);
% D = diff(speye(m), 2);
% w = ones(m, 1);
% for it = 1:10
% W = spdiags(w, 0, m, m);
% C = chol(W + lambda * D' * D);
% z = C \ (C' \ (w .* y));
% w = p * (y > z) + (1 - p) * (y < z);
% end

m = length(y);
D = diff(speye(m), 2);
w = ones(m, 1);
for it = 1:10
W = spdiags(w, 0, m, m);
C = chol(W + lambda * D' * D);
E=sparse(double(w .* y));
z = C \ (C' \ E);
z=full(z);
w = p * (y > z) + (1 - p) * (y < z);
end


% %calculate inverse:
% bla=C\eye(size(C));%sneller dan bla=inv(C);



end

