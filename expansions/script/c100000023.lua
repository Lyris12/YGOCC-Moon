--Zerost Vroomy
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddZerostMonsterEffects(c,CATEGORY_SPECIAL_SUMMON,EFFECT_FLAG_CARD_TARGET,s.target,s.operation)
end
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsMonster() and c:IsSetCard(ARCHE_ZEROST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GB) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingTarget(s.filter,tp,LOCATION_GB,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GB,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
