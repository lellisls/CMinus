/* Um programa para calcular o mdc
      segundo o algoritmo de Euclides. */

int gcd (int u, int v)
{ if (- 1 v == 0) return u;
   else return gcd(v,u-u/v v);
   /* u-u/v*v == u mod v */
}
/* val = 3.13; */
void main(void)
{ int x int y;
  %
  x = input(); y = input();
  output(gcd(x y));
}
