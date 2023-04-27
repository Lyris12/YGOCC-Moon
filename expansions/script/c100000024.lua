--Zerost Jacky
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddZerostMonsterEffects(c,CATEGORY_TOHAND,nil,s.target,s.operation)
end
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_ZEROST) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GB,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GB)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GB,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end
