clear, clc, close all

% load the QP data that led to a QP error
load("./failExampleData.mat")

% used variables:
% A_u_mat: $A_{[\cdot]}$ in Eq. (40), each row for a constraint
% b_mat: $B_{[\cdot]}$ in Eq. (40), each element for a constraint
% a_omega_mat: $a_{[\cdot]}$ in Eq. (40), each element for a constraint
%
% Since constraints in QP is linear, we use `linprog` to check feasiblity, 
%    exitflag == -2 for infeasible
%    exitflag == 1 for converged (feasible)
%    exitflag == 3 for unbounded (feasible)

% the cost of linprog, doesn't matter for checking feasibility 
f = ones(size(A_u_mat,2),1);

%% check that: the QP is not feasible with all constraints
[~,~,exitflag] = linprog(f, A_u_mat, b_mat - a_omega_mat, [], [], [], []);
if exitflag == -2
    disp("not feasible with all constraints")
end

%% check that: the QP is feasible with only one constraint
disp(num2str(size(A_u_mat,1)) + " constraints in total")
activeA = false(size(b));
for i = 1:length(b_mat)
    activeAtemp = activeA;
    activeAtemp(i) = true; % activate one constraint at a time
    [~,~,exitflag] = linprog(f, A_u_mat(activeAtemp,:), b_mat(activeAtemp) - a_omega_mat(activeAtemp), [], [], [], [], optimoptions('linprog','Display',"none"));
    if exitflag == 1 || exitflag == -3 % if converge or unbounded
        disp("feasible with " + num2str(i) + "-th constraint only")
    else
        error("not feasible with one constraint")
    end
end

%% check that: optimal decay makes the QP feasible

% the linear inequality costraints for optimal decay
A_mat = [A_u_mat, diag(a_omega_mat)];

% we now have length(a_omega_mat) more variables than before
f = ones(size(A_mat,2),1);

[~,~,exitflag] = linprog(f, A_mat, b_mat, [], [], [], []);
if exitflag == 1 || exitflag == -3 % converge or unbounded
    disp("feasible with optimal decay")
end