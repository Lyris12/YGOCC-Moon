--Desiderio Bigbang
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	c:DestroyedFieldTrigger(false,0,CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY,EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET,false,{1,0,EFFECT_COUNT_CODE_OATH},aux.EventGroupCond(s.cf),nil,s.tg,s.op,true)
end
function s.cf(c,_,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousTypeOnField()&TYPE_BIGBANG>0
end
function s.spfilter(c,e,tp)
	return c:IsMonster(TYPE_BIGBANG) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.fil(c,vibe)
	return c:IsFaceup() and c:IsMonster() and c:GetVibe()~=vibe
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsFaceup()
	and Duel.IsExists(false,s.fil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tc:GetVibe()) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g=Duel.Select(HINTMSG_DESTROY,false,tp,s.fil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc:GetVibe())
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end