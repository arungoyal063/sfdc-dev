global class fooArticle implements iterable<FAQ__kav>{
   global Iterator<FAQ__kav> Iterator(){
      return new CustomIterableArticle();
   }
}