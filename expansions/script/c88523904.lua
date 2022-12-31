--Kitseki Emergenza della Personalità
--Script by XGlitchy30
function c88523904.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c88523904.target)
	e1:SetOperation(c88523904.activate)
	c:RegisterEffect(e1)
end
--filters
function c88523904.filter(c,e,tp)
	return c:IsSetCard(0x215a) and c:GetLevel()>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(c88523904.tdfilter,tp,LOCATION_GRAVE,0,c:GetLevel(),c)
end
function c88523904.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x215a) and c:IsAbleToDeck()
end
--Activate
function c88523904.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c88523904.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c88523904.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c88523904.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local lv=g:GetFirst():GetLevel()
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,lv,tp,LOCATION_GRAVE)
end
function c88523904.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local g=Duel.GetMatchingGroup(c88523904.tdfilter,tp,LOCATION_GRAVE,0,tc)
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_GRAVE) then
		local td=g:Select(tp,tc:GetLevel(),tc:GetLevel(),tc)
		if td:GetCount()<tc:GetLevel() then return end
		if Duel.SendtoDeck(td,nil,2,REASON_EFFECT)~=0 then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end