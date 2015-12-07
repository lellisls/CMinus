/* Um programa para calcular o mdc
      segundo o algoritmo de Euclides. */

int gcd (int u, int v)
{ if (v == 0) return u;
   else return gcd(v,u-u/v*v);
   /* u-u/v*v == u mod v */
}
/* val = 3.13; */
void main(void)
{ int x; int y;
  int v[10];
  x = input(); y = input();
  v[x + y] = 10;
  output(gcd(x,y));
}
