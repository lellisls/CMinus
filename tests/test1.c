int raio;

float area;

int meuvetor[123];

int main(void){
  int raio;
  raio = 10;
  area = 3.14 * raio * raio;
  area = 10;
  if(area < 0 ){
    raio = 124 * area;
  }else{
    int k;
    k = area;
    area = raio;
    raio = k;
  }

}
