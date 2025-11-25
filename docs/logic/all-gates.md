# All Boolean Gates

Standard gates:
$$\mathsf{AND} = \begin{bmatrix} 0 & 0 \\\ 0 & 1\end{bmatrix}$$
$$\mathsf{NAND} = \begin{bmatrix} 1 & 1 \\\ 1 & 0\end{bmatrix}$$
$$\mathsf{OR} = \begin{bmatrix} 0 & 1 \\\ 1 & 1\end{bmatrix}$$
$$\mathsf{NOR} = \begin{bmatrix} 1 & 0 \\\ 0 & 0\end{bmatrix}$$
$$\mathsf{XOR} = \begin{bmatrix} 0 & 1 \\\ 1 & 0\end{bmatrix}$$
$$\mathsf{XNOR} = \begin{bmatrix} 1 & 0 \\\ 0 & 1\end{bmatrix}$$

Material Implication ($¬a \lor b$):
$$\mathsf{IMPL} = \begin{bmatrix} 1 & 1 \\\ 0 & 1\end{bmatrix}$$
$$\mathsf{NIMPL} = \begin{bmatrix} 0 & 0 \\\ 1 & 0\end{bmatrix}$$
Reverse implication ($a \lor ¬b$):
$$\mathsf{REQ} = \begin{bmatrix} 1 & 0 \\\ 1 & 1\end{bmatrix}$$
$$\mathsf{NREQ} = \begin{bmatrix} 0 & 1 \\\ 0 & 0\end{bmatrix}$$

Ignore both inputs:
$$\mathsf{FALSE} = \begin{bmatrix} 0 & 0 \\\ 0 & 0\end{bmatrix}$$
$$\mathsf{TRUE} = \begin{bmatrix} 1 & 1 \\\ 1 & 1\end{bmatrix}$$
Ignore one input:
$$\mathsf{A} = \begin{bmatrix} 0 & 0 \\\ 1 & 1\end{bmatrix}$$
$$\mathsf{B} = \begin{bmatrix} 0 & 1 \\\ 0 & 1\end{bmatrix}$$
$$\mathsf{NA} = \begin{bmatrix} 1 & 1 \\\ 0 & 0\end{bmatrix}$$
$$\mathsf{NB} = \begin{bmatrix} 1 & 0 \\\ 1 & 0\end{bmatrix}$$
