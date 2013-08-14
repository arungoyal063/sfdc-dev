global class SelectOptionWrapper /*implements Comparable*/ {
	
	/*
        @Param:List of selectOption to be sort.
        @Return: Sorted list of selectOptions by Label(desc)
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
            if(SO.getLabel() > pivotValue.getLabel()){
                lessSelectOption.add(SO);
            }else if(SO.getLabel() <= pivotValue.getLabel()){
                greaterSelectOption.add(SO);   
            }
        }
        list<selectOption> sortedSelectOptions = new list<selectOption>(); 
        sortedSelectOptions.addAll(selectOptionSortByLabel(lessSelectOption));
        sortedSelectOptions.add(pivotValue);
        sortedSelectOptions.addAll(selectOptionSortByLabel(greaterSelectOption));
        return SortedSelectOptions;
    }	
	
    /*public SelectOption oppy;
    
    // Constructor
    public SelectOptionWrapper(SelectOption op) {
        oppy = op;
    }
    
    // Compare opportunities based on the opportunity amount.
    global Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        SelectOptionWrapper compareToOppy = (SelectOptionWrapper)compareTo;
        
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            System.debug(oppy.getLabel()+ '###' + compareToOppy.oppy.getLabel());
            String[] orgString = oppy.getLabel().split('\\.');
            String[] compString = compareToOppy.oppy.getLabel().split('\\.');
            Integer minLength = (orgString.size() < compString.size()) ? orgString.size() : compString.size();
            System.debug(orgString + '@@' + compString );
            
            for(Integer i = 0; i < minLength; i++) {
                try {
                    if(Integer.valueOf(orgString[i].trim()) > Integer.valueOf(compString[i].trim())) {
                        return -1;
                    } else if(Integer.valueOf(orgString[i].trim()) < Integer.valueOf(compString[i].trim())) {
                        return 1;
                    }  
               } catch(Exception e) {
                   if(i > 0) {
                        if(orgString[i] > compString[i]) {
                            return -1;
                        } else if(orgString[i] < compString[i]) {
                            return 1;
                        } 
                  } else {
                      return 0;
                  } 
               }  
            }
            return 1;
 
        return returnValue;       
    }*/
    
    static testmethod void versiotest(){

		List<SelectOption> sortedList = new List<SelectOption>();
		SelectOption[] selectOptionList = new List<SelectOption>();
		selectOptionList.add( new SelectOption('12', '12'));
		selectOptionList.add( new SelectOption('20', '20'));
		selectOptionList.add( new SelectOption('1', '1'));
		selectOptionList.add( new SelectOption('test1', 'test1'));
		selectOptionList.add( new SelectOption('20.A', '20.A'));
		selectOptionList.add( new SelectOption('20.B', '20.B'));         
		// Sort the wrapper objects using the implementation of the        
        sortedList = SelectOptionWrapper.selectOptionSortByLabel(selectOptionList);
        
        
       /*SelectOptionWrapper[] oppyList = new List<SelectOptionWrapper>();
       oppyList.add( new SelectOptionWrapper(new SelectOption('12', '12')));
       oppyList.add( new SelectOptionWrapper(new SelectOption('20', '20')));
       oppyList.add( new SelectOptionWrapper(new SelectOption('1', '1')));
       oppyList.add( new SelectOptionWrapper(new SelectOption('test1', 'test1'))); 
       oppyList.add( new SelectOptionWrapper(new SelectOption('20.A', '20.A')));
       oppyList.add( new SelectOptionWrapper(new SelectOption('20.B', '20.B')));   
        // Sort the wrapper objects using the implementation of the 
        // compareTo method.
        oppyList.sort();
     
        // Write the sorted list contents to the debug log.
        System.debug(oppyList);*/
    }
}