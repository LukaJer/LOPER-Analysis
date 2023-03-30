% for n=1:35
% Elements2(n)=cellstr(string(Elements{n}(1:2)) +" "+string(Elements{n}(3:5)));
% end
X=categorical(Elements2);
barh(X,A,'DisplayName','A');
ax = gca;
ax.XGrid = 'on';
ax.YGrid = 'off';
set(gca, 'YDir','reverse')
xlabel('$$\frac{mg}{l}$$',Interpreter='latex')
title("Element concentration")
legend("Sample 1", "Sample 2")