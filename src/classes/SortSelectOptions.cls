/*
    @Author: Mohammad Usman
    @Description: Class is used to sort selectOptions by Label and value
    @version:1.0
*/
public with sharing class SortSelectOptions {
    /*
        @Param:List of selectOption to be sort.
        @Return: Sorted list of selectOptions by Label
    */
    public static list<selectOption> selectOptionSortByLabel(list<selectOption>
                                                            selectOptionsToSort) {
        if(selectOptionsToSort == null || selectOptionsToSort.size() <= 1){
            return selectOptionsToSort;
        }
        List<SelectOption> lessSelectOption = new List<SelectOption>();
        List<SelectOption> greaterSelectOption = new List<SelectOption>();
        integer pivot = selectOptionsToSort.size() / 2;
        
        //save the pivot and remove it from the selectOption list
        SelectOption pivotValue = selectOptionsToSort[pivot];
        selectOptionsToSort.remove(pivot);
        for(selectOption SO : selectOptionsToSort){
            if(SO.getLabel() <= pivotValue.getLabel()){
                lessSelectOption.add(SO);
            }else if(SO.getLabel() > pivotValue.getLabel()){
                greaterSelectOption.add(SO);   
            }
        }
        list<selectOption> sortedSelectOptions = new list<selectOption>(); 
        sortedSelectOptions.addAll(selectOptionSortByLabel(lessSelectOption));
        sortedSelectOptions.add(pivotValue);
        sortedSelectOptions.addAll(selectOptionSortByLabel(greaterSelectOption));
        return SortedSelectOptions;
    }
    /*
        @Param:List of selectOption to be sort.
        @Return: Sorted list of selectOptions by Value
    */
    public static list<selectOption> selectOptionSortByValue(list<selectOption>
                                                            selectOptionsToSort){
        if(selectOptionsToSort == null || selectOptionsToSort.size() <= 1){
            return selectOptionsToSort;
        }       
        List<SelectOption> lessSelectOption = new List<SelectOption>();
        List<SelectOption> greaterSelectOption = new List<SelectOption>();
        integer pivot = selectOptionsToSort.size() / 2;
         
        //save the pivot and remove it from the selectOption list
        SelectOption pivotValue = selectOptionsToSort[pivot]; 
        selectOptionsToSort.remove(pivot);
        for(selectOption SO : selectOptionsToSort){
            if(SO.getValue() <= pivotValue.getValue()){
                lessSelectOption.add(SO);
            }else if(SO.getValue() > pivotValue.getValue()){
                greaterSelectOption.add(SO);   
            }
        }
        list<selectOption> SortedSelectOptions = new list<selectOption>(); 
        SortedSelectOptions.addAll(selectOptionSortByValue(lessSelectOption));
        SortedSelectOptions.add(pivotValue);
        SortedSelectOptions.addAll(selectOptionSortByValue(greaterSelectOption));
        return SortedSelectOptions;
    }
    
    static testMethod void sortingUnitTest() {
        list<selectOption>  options = new list<selectOption>();
        options.add(new selectOption('1', '1'));
        options.add(new selectOption('10', '10')); 
        options.add(new selectOption('2', '2')); 
        
        // sort by Label
        list<selectOption>  sortSelectOption = SortSelectOptions.selectOptionSortByLabel(options);
        
        list<selectOption>  selOptions = new list<selectOption>();
        selOptions.add(new selectOption('1', '1'));
        selOptions.add(new selectOption('10', '10')); 
        selOptions.add(new selectOption('2', '2')); 
        
        // sort by Value
        list<selectOption>  resultSelectOption = SortSelectOptions.selectOptionSortByValue(selOptions);
    }
}