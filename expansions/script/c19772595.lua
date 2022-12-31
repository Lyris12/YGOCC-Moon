--La Tenacia degli AoJ
--Script by XGlitchy30
function c19772595.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19772595,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c19772595.cost)
	e1:SetTarget(c19772595.target)
	e1:SetOperation(c19772595.activate)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19772595,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,19772595)
	e2:SetCost(c19772595.tdcost)
	e2:SetTarget(c19772595.tdtg)
	e2:SetOperation(c19772595.tdop)
	c:RegisterEffect(e2)
end
--filters
function c19772595.cfilter(c)
	return c:IsAbleToRemoveAsCost()
end
function c19772595.filter(c)
	return c:IsSetCard(0x197) and c:IsFaceup()
end
function c19772595.rtfilter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
function c19772595.spfilter(c,e,tp)
	return c:GetLevel()==4 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--Activate
function c19772595.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19772595.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c19772595.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	if g:GetCount()>1 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c19772595.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c19772595.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c19772595.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c19772595.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c19772595.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetValue(aux.indoval)
		tc:RegisterEffect(e2)
	end
end
--spsummon
function c19772595.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST)
end
function c19772595.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19772595.rtfilter,tp,LOCATION_REMOVED,0,3,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c19772595.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c19772595.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.GetMatchingGroup(c19772595.rtfilter,tp,LOCATION_REMOVED,0,nil)
	if g:GetCount()>2 then
		local rt=g:Select(tp,3,3,nil)
		if rt:GetCount()<3 then return end
		if Duel.SendtoDeck(rt,nil,2,REASON_EFFECT+REASON_RETURN)~=0 then
			if Duel.IsExistingMatchingCard(c19772595.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sp=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19772595.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
				if sp:GetCount()>0 then
					Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end