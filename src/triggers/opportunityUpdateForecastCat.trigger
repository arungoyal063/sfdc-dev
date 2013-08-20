trigger opportunityUpdateForecastCat on Opportunity (before insert, before update)
{
  for(Opportunity o: Trigger.new)
  {
    if(o.Probability == 0)
        o.ForecastCategoryName = 'Omitted (0%) Probability';
    else if(o.Probability > 0 && o.Probability <= 50)
        o.ForecastCategoryName = 'Pipeline (0%-50%) Probability';
    else if(o.Probability > 50 && o.Probability <= 80)
        o.ForecastCategoryName = 'Best Case (51%-80%) Prob.';
    else if(o.Probability > 80 && o.Probability <= 99)
        o.ForecastCategoryName = 'Commit (81%-99%) Prob.';
    else if(o.Probability > 99)
        o.ForecastCategoryName = 'Closed (100%) Probability';
  }
 }